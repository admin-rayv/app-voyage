import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../config/constants.dart';
import '../models/point.dart';
import 'debug_log.dart';
import 'geofence_math.dart';
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
  final Map<String, QueuedPoiCandidate> _queuedCandidates =
      <String, QueuedPoiCandidate>{};

  List<Point> _pois = const [];
  bool _isMonitoring = false;
  DateTime? _cooldownUntil;
  Timer? _cooldownTimer;
  Position? _lastKnownPosition;
  int _sessionTriggerCount = 0;

  bool get isMonitoring => _isMonitoring;
  Stream<Point> get triggeredPois => _triggeredPoisController.stream;
  Set<String> get alreadyTriggered => UnmodifiableSetView(_alreadyTriggered);

  /// Nombre de POIs réellement déclenchés depuis le dernier reset
  /// (n'inclut pas les POIs pré-marqués via [seedTriggered]).
  int get sessionTriggerCount => _sessionTriggerCount;

  /// Pré-marquer des POIs comme déjà déclenchés (ex: POIs déjà écoutés,
  /// persistés par VisitedPoiService) pour qu'ils ne rejouent pas.
  void seedTriggered(Iterable<String> poiIds) {
    _alreadyTriggered.addAll(poiIds);
    _log(
      '[GeofencingService] seeded ${poiIds.length} already-visited POIs',
    );
  }

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
    _queuedCandidates.clear();
    _cooldownUntil = null;
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    _lastKnownPosition = null;

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
    _queuedCandidates.clear();
    _cooldownUntil = null;
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    _lastKnownPosition = null;
    _isMonitoring = false;
    _log('[GeofencingService] monitoring stopped');
  }

  void resetTriggered() {
    _alreadyTriggered.clear();
    _insideRadius.clear();
    _pendingTriggers.clear();
    _queuedCandidates.clear();
    _cooldownUntil = null;
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    _sessionTriggerCount = 0;
    _log('[GeofencingService] triggered POIs reset');
  }

  void _handlePositionUpdate(Position position) {
    if (!_isMonitoring || _pois.isEmpty) {
      return;
    }

    final now = DateTime.now();
    _lastKnownPosition = position;
    _addPositionSample(position, now);
    _purgeExpiredQueuedCandidates(now);

    _log(
      '[GeofencingService] position update '
      'lat=${position.latitude}, lng=${position.longitude}',
    );

    final accuracy = position.accuracy;
    final confidence = _calculateConfidence(accuracy);
    final confirmedCandidates = <ConfirmedPoiCandidate>[];

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
        _removeQueuedCandidate(poi.id, reason: 'left_radius');
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
        _removeQueuedCandidate(poi.id, reason: 'outside_radius');
        continue;
      }

      if (_alreadyTriggered.contains(poi.id)) {
        _removeQueuedCandidate(poi.id, reason: 'already_triggered');
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
          reason: pendingSince == null
              ? 'low_confidence'
              : 'low_confidence_pending',
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
        confirmedCandidates.add(
          ConfirmedPoiCandidate(
            poi: poi,
            distance: distance,
            confidence: confidence,
          ),
        );
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

    if (confirmedCandidates.isEmpty) {
      return;
    }

    confirmedCandidates.sort(
      (left, right) => left.distance.compareTo(right.distance),
    );

    if (_isCooldownActive(now)) {
      for (final candidate in confirmedCandidates) {
        _queueCandidate(
          poi: candidate.poi,
          distance: candidate.distance,
          timestamp: now,
          confidence: candidate.confidence,
          reason: 'cooldown_active',
        );
      }
      return;
    }

    final nextCandidate = confirmedCandidates.first;
    _triggerPoi(
      poi: nextCandidate.poi,
      distance: nextCandidate.distance,
      timestamp: now,
      position: position,
      confidence: nextCandidate.confidence,
      reason: 'confirmed_after_debounce',
    );

    for (final candidate in confirmedCandidates.skip(1)) {
      _queueCandidate(
        poi: candidate.poi,
        distance: candidate.distance,
        timestamp: now,
        confidence: candidate.confidence,
        reason: 'overlap_waiting_turn',
      );
    }
  }

  void dispose() {
    stop();
    _triggeredPoisController.close();
  }

  void _log(String message) {
    DebugLog().log(message);
    debugPrint(message);
  }

  bool _isCooldownActive(DateTime now) {
    final cooldownUntil = _cooldownUntil;
    return cooldownUntil != null && now.isBefore(cooldownUntil);
  }

  void _triggerPoi({
    required Point poi,
    required double distance,
    required DateTime timestamp,
    required Position position,
    required double confidence,
    required String reason,
  }) {
    _pendingTriggers.remove(poi.id);
    _removeQueuedCandidate(poi.id, reason: 'triggered');
    _alreadyTriggered.add(poi.id);
    _sessionTriggerCount++;
    _triggeredPoisController.add(poi);
    _log(
      '[GeofencingService] POI triggered '
      'id=${poi.id} distance=${distance.toStringAsFixed(1)}m',
    );
    _logGeoDecision(
      position: position,
      timestamp: timestamp,
      poi: poi,
      distance: distance,
      confidence: confidence,
      approaching: _isApproaching(poi),
      decision: 'TRIGGER',
      reason: reason,
    );
    _startGlobalCooldown(timestamp);
  }

  void _startGlobalCooldown(DateTime timestamp) {
    _cooldownTimer?.cancel();

    final cooldownUntil = timestamp.add(
      const Duration(seconds: AppConstants.geofenceTriggerCooldownSec),
    );
    _cooldownUntil = cooldownUntil;
    _log('[GeofencingService] cooldown started until $cooldownUntil');

    _cooldownTimer = Timer(
      const Duration(seconds: AppConstants.geofenceTriggerCooldownSec),
      _handleCooldownExpired,
    );
  }

  void _handleCooldownExpired() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;

    final now = DateTime.now();
    _cooldownUntil = null;
    _purgeExpiredQueuedCandidates(now);

    if (!_isMonitoring || _queuedCandidates.isEmpty) {
      _log('[GeofencingService] cooldown ended with no queued candidates');
      return;
    }

    final queuedCandidate = _selectNextQueuedCandidate(now);
    if (queuedCandidate == null) {
      _log(
        '[GeofencingService] cooldown ended but no queued candidate remained valid',
      );
      return;
    }

    final position = _lastKnownPosition;
    if (position == null) {
      _removeQueuedCandidate(
        queuedCandidate.poi.id,
        reason: 'missing_last_position',
      );
      _log(
        '[GeofencingService] cooldown ended but no last known position was available',
      );
      return;
    }

    _log(
      '[GeofencingService] trigger released from queue '
      'id=${queuedCandidate.poi.id} distance=${queuedCandidate.distanceMeters.toStringAsFixed(1)}m',
    );
    _triggerPoi(
      poi: queuedCandidate.poi,
      distance: queuedCandidate.distanceMeters,
      timestamp: now,
      position: position,
      confidence: queuedCandidate.confidence,
      reason: 'released_from_queue',
    );
  }

  QueuedPoiCandidate? _selectNextQueuedCandidate(DateTime now) {
    final candidates = _queuedCandidates.values.toList()
      ..sort(
        (left, right) => left.distanceMeters.compareTo(right.distanceMeters),
      );

    for (final candidate in candidates) {
      if (_isQueuedCandidateStillValid(candidate, now)) {
        return candidate;
      }
      _removeQueuedCandidate(
        candidate.poi.id,
        reason: 'invalid_after_cooldown',
      );
    }

    return null;
  }

  bool _isQueuedCandidateStillValid(
    QueuedPoiCandidate candidate,
    DateTime now,
  ) {
    if (_alreadyTriggered.contains(candidate.poi.id)) {
      return false;
    }
    if (!_insideRadius.contains(candidate.poi.id)) {
      return false;
    }

    final age = now.difference(candidate.lastObservedAt);
    return age.inSeconds <= AppConstants.geofenceQueuedCandidateTtlSec;
  }

  void _queueCandidate({
    required Point poi,
    required double distance,
    required DateTime timestamp,
    required double confidence,
    required String reason,
  }) {
    if (_alreadyTriggered.contains(poi.id)) {
      return;
    }

    final existingCandidate = _queuedCandidates[poi.id];
    _queuedCandidates[poi.id] = QueuedPoiCandidate(
      poi: poi,
      distanceMeters: distance,
      lastObservedAt: timestamp,
      confidence: confidence,
    );

    final distanceLabel = distance.toStringAsFixed(1);
    if (existingCandidate == null) {
      _log(
        '[GeofencingService] candidate queued '
        'poi=${poi.id} distance=${distanceLabel}m reason=$reason',
      );
      return;
    }

    _log(
      '[GeofencingService] queued candidate refreshed '
      'poi=${poi.id} distance=${distanceLabel}m reason=$reason',
    );
  }

  void _removeQueuedCandidate(String poiId, {required String reason}) {
    final removed = _queuedCandidates.remove(poiId);
    if (removed == null) {
      return;
    }

    _log(
      '[GeofencingService] queued candidate removed poi=$poiId reason=$reason',
    );
  }

  void _purgeExpiredQueuedCandidates(DateTime now) {
    final expiredPoiIds = <String>[];
    for (final entry in _queuedCandidates.entries) {
      if (!_isQueuedCandidateStillValid(entry.value, now)) {
        expiredPoiIds.add(entry.key);
      }
    }

    for (final poiId in expiredPoiIds) {
      final candidate = _queuedCandidates.remove(poiId);
      if (candidate == null) {
        continue;
      }

      final age = now.difference(candidate.lastObservedAt).inSeconds;
      final reason = _alreadyTriggered.contains(poiId)
          ? 'already_triggered'
          : _insideRadius.contains(poiId)
          ? 'expired_ttl_${age}s'
          : 'left_radius';
      _log(
        '[GeofencingService] queued candidate expired/removed '
        'poi=$poiId reason=$reason',
      );
    }
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

    // Les 5 échantillons les plus récents, en ordre chronologique.
    final recentSamples = _positionHistory.toList().reversed.take(5).toList();
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

    return GeofenceMath.isApproaching(distances);
  }

  double _calculateConfidence(double accuracy) {
    return GeofenceMath.confidenceForAccuracy(accuracy);
  }

  double _calculateEffectiveRadius(Point poi, double confidence) {
    return GeofenceMath.effectiveRadius(
      triggerRadiusM: poi.triggerRadiusM,
      confidence: confidence,
      maxMultiplier: AppConstants.geofenceMaxRadiusMultiplier,
    );
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

class ConfirmedPoiCandidate {
  const ConfirmedPoiCandidate({
    required this.poi,
    required this.distance,
    required this.confidence,
  });

  final Point poi;
  final double distance;
  final double confidence;
}

class QueuedPoiCandidate {
  const QueuedPoiCandidate({
    required this.poi,
    required this.distanceMeters,
    required this.lastObservedAt,
    required this.confidence,
  });

  final Point poi;
  final double distanceMeters;
  final DateTime lastObservedAt;
  final double confidence;
}
