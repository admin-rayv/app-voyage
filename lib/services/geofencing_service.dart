import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/point.dart';
import 'debug_log.dart';
import 'location_service.dart';

/// Service de geofencing GPS pour detecter l'entree dans le rayon des POIs.
class GeofencingService {
  GeofencingService._internal();

  static final GeofencingService _instance = GeofencingService._internal();
  factory GeofencingService() => _instance;

  static const double _exitHysteresisMeters = 20.0;

  final LocationService _locationService = LocationService();
  final StreamController<Point> _triggeredPoisController =
      StreamController<Point>.broadcast();
  final Set<String> _alreadyTriggered = <String>{};
  final Set<String> _insideRadius = <String>{};

  List<Point> _pois = const [];
  bool _isMonitoring = false;

  bool get isMonitoring => _isMonitoring;
  Stream<Point> get triggeredPois => _triggeredPoisController.stream;
  Set<String> get alreadyTriggered => UnmodifiableSetView(_alreadyTriggered);

  Future<bool> start(List<Point> pois) async {
    _log('[GeofencingService] start requested with ${pois.length} POIs');

    final hasPermission = await _locationService.checkPermissions();
    if (!hasPermission) {
      _log('[GeofencingService] start aborted: location permission denied');
      return false;
    }

    stop();
    _pois = List<Point>.unmodifiable(pois);
    _insideRadius.clear();

    _locationService.startTracking(
      onPositionUpdate: _handlePositionUpdate,
      onError: (error) {
        _log('[GeofencingService] GPS tracking error: $error');
      },
    );

    _isMonitoring = true;
    _log('[GeofencingService] monitoring started');
    return true;
  }

  void stop() {
    if (!_isMonitoring && _pois.isEmpty) {
      return;
    }

    _locationService.stopTracking();
    _pois = const [];
    _insideRadius.clear();
    _isMonitoring = false;
    _log('[GeofencingService] monitoring stopped');
  }

  void resetTriggered() {
    _alreadyTriggered.clear();
    _insideRadius.clear();
    _log('[GeofencingService] triggered POIs reset');
  }

  void _handlePositionUpdate(Position position) {
    if (!_isMonitoring || _pois.isEmpty) {
      return;
    }

    _log(
      '[GeofencingService] position update '
      'lat=${position.latitude}, lng=${position.longitude}',
    );

    Point? closestCandidate;
    double? closestDistance;

    for (final poi in _pois) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        poi.lat,
        poi.lng,
      );

      final isInside = _insideRadius.contains(poi.id);
      final entryThreshold = poi.triggerRadiusM.toDouble();
      final exitThreshold = entryThreshold + _exitHysteresisMeters;

      if (isInside) {
        if (distance > exitThreshold) {
          _insideRadius.remove(poi.id);
          _log(
            '[GeofencingService] POI exited radius '
            'id=${poi.id} distance=${distance.toStringAsFixed(1)}m',
          );
        }
        continue;
      }

      if (distance < entryThreshold) {
        _insideRadius.add(poi.id);
        _log(
          '[GeofencingService] POI entered radius '
          'id=${poi.id} distance=${distance.toStringAsFixed(1)}m',
        );

        if (_alreadyTriggered.contains(poi.id)) {
          continue;
        }

        if (closestDistance == null || distance < closestDistance) {
          closestCandidate = poi;
          closestDistance = distance;
        }
      }
    }

    if (closestCandidate == null) {
      return;
    }

    _alreadyTriggered.add(closestCandidate.id);
    _triggeredPoisController.add(closestCandidate);
    _log(
      '[GeofencingService] POI triggered '
      'id=${closestCandidate.id} distance=${closestDistance!.toStringAsFixed(1)}m',
    );
  }

  void dispose() {
    stop();
    _triggeredPoisController.close();
  }

  void _log(String message) {
    DebugLog().log(message);
    debugPrint(message);
  }
}
