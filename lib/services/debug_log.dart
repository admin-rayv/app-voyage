/// Service de logs in-app — accessible depuis l'écran Settings.
/// Stocke les derniers messages de debug pour diagnostic sans USB.

class DebugLog {
  DebugLog._();
  static final DebugLog _instance = DebugLog._();
  factory DebugLog() => _instance;

  final List<String> _entries = [];
  static const int _maxEntries = 100;

  List<String> get entries => List.unmodifiable(_entries);

  void log(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    _entries.add('[$timestamp] $message');
    if (_entries.length > _maxEntries) {
      _entries.removeAt(0);
    }
  }

  void clear() => _entries.clear();
}
