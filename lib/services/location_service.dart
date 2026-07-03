import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../config/constants.dart';
import 'permission_service.dart';

/// Service de localisation
/// Gestion du GPS et du geofencing

class LocationService {
  final PermissionService _permissionService = PermissionService();
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastPosition;

  /// Vérifier et demander les permissions
  Future<bool> checkPermissions() async {
    final status = await _permissionService.checkDiscoveryPermission();
    if (status.status == DiscoveryPermissionStatus.denied) {
      final requested = await Geolocator.requestPermission();
      return requested == LocationPermission.always ||
          requested == LocationPermission.whileInUse;
    }

    return status.isGranted;
  }

  /// Obtenir la position actuelle
  Future<Position?> getCurrentPosition() async {
    try {
      _lastPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return _lastPosition;
    } catch (e) {
      return null;
    }
  }

  /// Démarrer le tracking en temps réel.
  ///
  /// Les settings sont spécifiques à la plateforme pour que le tracking
  /// continue en arrière-plan (téléphone en poche / écran verrouillé):
  /// - Android: foreground service géré par geolocator (notification persistante)
  /// - iOS: allowBackgroundLocationUpdates + indicateur système
  void startTracking({
    required void Function(Position) onPositionUpdate,
    void Function(Object)? onError,
  }) {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: _buildLocationSettings(),
    ).listen(
      (Position position) {
        _lastPosition = position;
        onPositionUpdate(position);
      },
      onError: onError,
    );
  }

  LocationSettings _buildLocationSettings() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: AppConstants.gpsDistanceFilterMeters,
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: 'Mode découverte actif',
            notificationText:
                'App Voyage surveille les points d’intérêt autour de toi.',
            notificationChannelName: 'Mode découverte',
            enableWakeLock: true,
            setOngoing: true,
          ),
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: AppConstants.gpsDistanceFilterMeters,
          activityType: ActivityType.fitness,
          pauseLocationUpdatesAutomatically: false,
          allowBackgroundLocationUpdates: true,
          showBackgroundLocationIndicator: true,
        );
      default:
        return LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: AppConstants.gpsDistanceFilterMeters,
        );
    }
  }

  /// Arrêter le tracking
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Calculer la distance entre deux points (en mètres)
  double distanceBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Vérifier si on est dans le rayon d'un POI
  bool isWithinRadius(
    Position position,
    double poiLat,
    double poiLng,
    int radiusMeters,
  ) {
    final distance = distanceBetween(
      position.latitude,
      position.longitude,
      poiLat,
      poiLng,
    );
    return distance <= radiusMeters;
  }

  /// Dernière position connue
  Position? get lastPosition => _lastPosition;

  /// Dispose
  void dispose() {
    stopTracking();
  }
}
