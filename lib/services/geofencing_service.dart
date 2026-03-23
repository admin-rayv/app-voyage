import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../config/constants.dart';
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
  final Queue<PositionSample> _positionHistory = ListQueue<PositionSample>();
  final Map<String, DateTime> _pendingTriggers = <String, DateTime>{};

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
    _pendingTriggers.clear();
    _positionHistory.clear();

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
    _pendingTriggers.clear();
    _positionHistory.clear();
    _isMonitoring = false;
    _log('[GeofencingService] monitoring stopped');
  }

  void resetTriggered() {
    _alreadyTriggered.clear();
    _insideRadius.clear();
    _pendingTriggers.clear();
    _log('[GeofencingService] triggered POIs reset');
  }

  void _handlePositionUpdate(Position position) {
    if (!_isMonitoring || _pois.isEmpty) {
      return;
    }

    final now = DateTime.now();
    _addPositionSample(position, now);

    _log(
      '[GeofencingService] position update '
      'lat=${position.latitude}, lng=${position.longitude}',
    );

    Point? closestCandidate;
    double? closestDistance;
    final accuracy = position.accuracy;
    final confidence = _calculateConfidence(accuracy);

    for (final poi in _pois) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        poi.lat,
        poi.lng,
      );

      final isInside = _insideRadius.contains(poi.id);
      final entryThreshold = _calculateEffectiveRadius(poi, confidence);
      final exitThreshold = entryThreshold + _exitHysteresisMeters;
      final isVeryClose = distance < (poi.triggerRadiusM * 0.5);
      final approaching = _isApproaching(poi);
      final confidenceOk = confidence >= AppConstants.gpsMinConfidence;

      if (isInside && distance > exitThreshold) {
        _insideRadius.remove(poi.id);
        if (_pendingTriggers.remove(poi.id) != null) {
          _logGeoDecision(
            position: position,
            timestamp: now,
            poi: poi,
            distance: distance,
            confidence: confidence,
            approaching: approaching,
            decision: 'CANCELLED',
            reason: 'left_radius_before_confirm',
          );
        }
        _log(
          '[GeofencingService] POI exited radius '
          'id=${poi.id} distance=${distance.toStringAsFixed(1)}m',
        );
        continue;
      }

      if (!isInside && distance < entryThreshold) {
        _insideRadius.add(poi.id);
        _log(
          '[GeofencingService] POI entered radius '
          'id=${poi.id} distance=${distance.toStringAsFixed(1)}m',
        );
      }

      final isCurrentlyInside = _insideRadius.contains(poi.id);
      if (!isCurrentlyInside) {
        if (_pendingTriggers.remove(poi.id) != null) {
          _logGeoDecision(
            position: position,
            timestamp: now,
            poi: poi,
            distance: distance,
            confidence: confidence,
            approaching: approaching,
            decision: 'CANCELLED',
            reason: 'left_radius_before_confirm',
          );
        }
        continue;
      }

      if (_alreadyTriggered.contains(poi.id)) {
        _logGeoDecision(
          position: position,
          timestamp: now,
          poi: poi,
          distance: distance,
          confidence: confidence,
          approaching: approaching,
          decision: 'SKIP',
          reason: 'already_triggered',
        );
        continue;
      }

      if (!approaching && !isVeryClose) {
        if (_pendingTriggers.remove(poi.id) != null) {
          _logGeoDecision(
            position: position,
            timestamp: now,
            poi: poi,
            distance: distance,
            confidence: confidence,
            approaching: approaching,
            decision: 'CANCELLED',
            reason: 'moving_away_during_debounce',
          );
        } else {
          _logGeoDecision(
            position: position,
            timestamp: now,
            poi: poi,
            distance: distance,
            confidence: confidence,
            approaching: approaching,
            decision: 'SKIP',
            reason: 'moving_away',
          );
        }
        continue;
      }

      final pendingSince = _pendingTriggers[poi.id];
      if (!confidenceOk && !isVeryClose) {
        _logGeoDecision(
          position: position,
          timestamp: now,
          poi: poi,
          distance: distance,
          confidence: confidence,
          approaching: approaching,
          decision: pendingSince == null ? 'SKIP' : 'WAIT',
          reason: pendingSince == null ? 'low_confidence' : 'low_confidence_pending',
        );
        continue;
      }

      if (pendingSince == null) {
        _pendingTriggers[poi.id] = now;
        _logGeoDecision(
          position: position,
          timestamp: now,
          poi: poi,
          distance: distance,
          confidence: confidence,
          approaching: approaching,
          decision: 'DEBOUNCE',
          reason: 'debounce_pending',
        );
        continue;
      }

      if (_shouldConfirmPendingTrigger(
        poi: poi,
        position: position,
        timestamp: now,
        distance: distance,
        confidence: confidence,
        approaching: approaching,
      )) {
        if (closestDistance == null || distance < closestDistance) {
          closestCandidate = poi;
          closestDistance = distance;
        }
      } else if (_pendingTriggers.containsKey(poi.id)) {
        _logGeoDecision(
          position: position,
          timestamp: now,
          poi: poi,
          distance: distance,
          confidence: confidence,
          approaching: approaching,
          decision: 'WAIT',
          reason: 'debounce_pending',
        );
      }
    }

    if (closestCandidate == null) {
      return;
    }

    _pendingTriggers.remove(closestCandidate.id);
    _alreadyTriggered.add(closestCandidate.id);
    _triggeredPoisController.add(closestCandidate);
    _log(
      '[GeofencingService] POI triggered '
      'id=${closestCandidate.id} distance=${closestDistance!.toStringAsFixed(1)}m',
    );
    _logGeoDecision(
      position: position,
      timestamp: now,
      poi: closestCandidate,
      distance: closestDistance,
      confidence: confidence,
      approaching: _isApproaching(closestCandidate),
      decision: 'TRIGGER',
      reason: 'confirmed_after_debounce',
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

  void _addPositionSample(Position position, DateTime timestamp) {
    _positionHistory.add(
      PositionSample(
        position: position,
        timestamp: timestamp,
        accuracy: position.accuracy,
      ),
    );

    while (_positionHistory.length > AppConstants.positionHistorySize) {
      _positionHistory.removeFirst();
    }
  }

  bool _isApproaching(Point poi) {
    if (_positionHistory.isEmpty) {
      return true;
    }

    final recentSamples = _positionHistory.toList().reversed.take(5).toList();
    if (recentSamples.length < 2) {
      return true;
    }

    final distances = recentSamples.reversed
        .map(
          (sample) => Geolocator.distanceBetween(
            sample.position.latitude,
            sample.position.longitude,
            poi.lat,
            poi.lng,
          ),
        )
        .toList();

    final deltas = <double>[];
    for (var index = 1; index < distances.length; index++) {
      deltas.add(distances[index] - distances[index - 1]);
    }

    final averageDelta =
        deltas.reduce((sum, value) => sum + value) / deltas.length;
    final totalVariation = distances.last - distances.first;

    if (totalVariation.abs() < 5.0) {
      return true;
    }

    return averageDelta <= 0;
  }

  double _calculateConfidence(double accuracy) {
    if (accuracy < 10) {
      return 1.0;
    }
    if (accuracy < 20) {
      return 0.7;
    }
    if (accuracy <= 30) {
      return 0.5;
    }
    return 0.3;
  }

  double _calculateEffectiveRadius(Point poi, double confidence) {
    final multiplier = 1 + (1 - confidence) * 0.5;
    final cappedMultiplier =
        multiplier.clamp(1.0, AppConstants.geofenceMaxRadiusMultiplier);
    return poi.triggerRadiusM * cappedMultiplier;
  }

  bool _shouldConfirmPendingTrigger({
    required Point poi,
    required Position position,
    required DateTime timestamp,
    required double distance,
    required double confidence,
    required bool approaching,
  }) {
    final pendingSince = _pendingTriggers[poi.id];
    if (pendingSince == null) {
      return false;
    }

    final effectiveRadius = _calculateEffectiveRadius(poi, confidence);
    final isVeryClose = distance < (poi.triggerRadiusM * 0.5);
    final confidenceOk = confidence >= AppConstants.gpsMinConfidence;

    if (distance > effectiveRadius) {
      _pendingTriggers.remove(poi.id);
      _logGeoDecision(
        position: position,
        timestamp: timestamp,
        poi: poi,
        distance: distance,
        confidence: confidence,
        approaching: approaching,
        decision: 'CANCELLED',
        reason: 'left_radius_before_confirm',
      );
      return false;
    }

    if (!approaching && !isVeryClose) {
      _pendingTriggers.remove(poi.id);
      _logGeoDecision(
        position: position,
        timestamp: timestamp,
        poi: poi,
        distance: distance,
        confidence: confidence,
        approaching: approaching,
        decision: 'CANCELLED',
        reason: 'moving_away_during_debounce',
      );
      return false;
    }

    if (!confidenceOk && !isVeryClose) {
      _logGeoDecision(
        position: position,
        timestamp: timestamp,
        poi: poi,
        distance: distance,
        confidence: confidence,
        approaching: approaching,
        decision: 'WAIT',
        reason: 'low_confidence_pending',
      );
      return false;
    }

    final elapsed = timestamp.difference(pendingSince).inSeconds;
    return elapsed >= AppConstants.geofenceDebounceSec;
  }

  void _logGeoDecision({
    required Position position,
    required DateTime timestamp,
    required Point poi,
    required double distance,
    required double confidence,
    required bool approaching,
    required String decision,
    required String reason,
  }) {
    DebugLog().logGeoDecision(
      timestamp: timestamp,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      poiId: poi.id,
      distance: distance,
      confidence: confidence,
      approaching: approaching,
      decision: decision,
      reason: reason,
    );
  }
}

class PositionSample {
  const PositionSample({
    required this.position,
    required this.timestamp,
    required this.accuracy,
  });

  final Position position;
  final DateTime timestamp;
  final double accuracy;
}
