import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../config/constants.dart';

/// Service de localisation
/// Gestion du GPS et du geofencing

class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastPosition;
  
  /// Vérifier et demander les permissions
  Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
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
  
  /// Démarrer le tracking en temps réel
  void startTracking({
    required void Function(Position) onPositionUpdate,
    void Function(Object)? onError,
  }) {
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: AppConstants.gpsDistanceFilterMeters,
    );
    
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _lastPosition = position;
        onPositionUpdate(position);
      },
      onError: onError,
    );
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
