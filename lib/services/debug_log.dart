// Service de logs in-app — accessible depuis l'écran Settings.
// Stocke les derniers messages de debug pour diagnostic sans USB.

import 'package:flutter/foundation.dart';

class DebugLog {
  DebugLog._();
  static final DebugLog _instance = DebugLog._();
  factory DebugLog() => _instance;

  final List<String> _entries = [];
  final List<String> _geoDecisions = [];
  static const int _maxEntries = 100;
  static const int _maxGeoDecisions = 500;

  List<String> get entries => List.unmodifiable(_entries);
  List<String> get geoDecisions => List.unmodifiable(_geoDecisions);

  void log(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    _entries.add('[$timestamp] $message');
    if (_entries.length > _maxEntries) {
      _entries.removeAt(0);
    }
    // Miroir vers la console (logcat / console navigateur) pour le debug.
    debugPrint('[AppVoyage] $message');
  }

  void logGeoDecision({
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    required double accuracy,
    required String poiId,
    required double distance,
    required double confidence,
    required bool approaching,
    required String decision,
    required String reason,
  }) {
    final entry = '${timestamp.toIso8601String()}|'
        '${latitude.toStringAsFixed(6)}|'
        '${longitude.toStringAsFixed(6)}|'
        '${accuracy.toStringAsFixed(1)}|'
        '$poiId|'
        '${distance.toStringAsFixed(1)}|'
        '${confidence.toStringAsFixed(2)}|'
        '$approaching|'
        '$decision|'
        '$reason';
    _geoDecisions.add(entry);
    if (_geoDecisions.length > _maxGeoDecisions) {
      _geoDecisions.removeAt(0);
    }
  }

  void clear() {
    _entries.clear();
    _geoDecisions.clear();
  }
}
