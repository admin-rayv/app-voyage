import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  UserPreferencesService._();

  static const String preferredLanguageKey = 'preferred_language';
  static const String discoveryAutoplayEnabledKey =
      'discovery_autoplay_enabled';
  static const String discoveryAutoplayDelaySecKey =
      'discovery_autoplay_delay_sec';
  static const String discoveryAutoplayVibrationEnabledKey =
      'discovery_autoplay_vibration_enabled';
  static const String discoveryReplayVisitedEnabledKey =
      'discovery_replay_visited_enabled';

  static const String defaultPreferredLanguage = 'fr';
  static const bool defaultDiscoveryAutoplayEnabled = true;
  static const int defaultDiscoveryAutoplayDelaySec = 3;
  static const bool defaultDiscoveryAutoplayVibrationEnabled = true;
  static const bool defaultDiscoveryReplayVisitedEnabled = false;
  static const List<int> discoveryAutoplayDelayOptions = [0, 3, 5];

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  static Future<String> getPreferredLanguage() async {
    final prefs = await _prefs();
    return prefs.getString(preferredLanguageKey) ?? defaultPreferredLanguage;
  }

  static Future<void> setPreferredLanguage(String language) async {
    final prefs = await _prefs();
    await prefs.setString(preferredLanguageKey, language);
  }

  static Future<bool> isDiscoveryAutoplayEnabled() async {
    final prefs = await _prefs();
    return prefs.getBool(discoveryAutoplayEnabledKey) ??
        defaultDiscoveryAutoplayEnabled;
  }

  static Future<void> setDiscoveryAutoplayEnabled(bool enabled) async {
    final prefs = await _prefs();
    await prefs.setBool(discoveryAutoplayEnabledKey, enabled);
  }

  static Future<int> getDiscoveryAutoplayDelaySec() async {
    final prefs = await _prefs();
    final delay =
        prefs.getInt(discoveryAutoplayDelaySecKey) ??
        defaultDiscoveryAutoplayDelaySec;
    if (!discoveryAutoplayDelayOptions.contains(delay)) {
      return defaultDiscoveryAutoplayDelaySec;
    }
    return delay;
  }

  static Future<void> setDiscoveryAutoplayDelaySec(int delaySec) async {
    final prefs = await _prefs();
    final normalizedDelay = discoveryAutoplayDelayOptions.contains(delaySec)
        ? delaySec
        : defaultDiscoveryAutoplayDelaySec;
    await prefs.setInt(discoveryAutoplayDelaySecKey, normalizedDelay);
  }

  static Future<bool> isDiscoveryAutoplayVibrationEnabled() async {
    final prefs = await _prefs();
    return prefs.getBool(discoveryAutoplayVibrationEnabledKey) ??
        defaultDiscoveryAutoplayVibrationEnabled;
  }

  static Future<void> setDiscoveryAutoplayVibrationEnabled(bool enabled) async {
    final prefs = await _prefs();
    await prefs.setBool(discoveryAutoplayVibrationEnabledKey, enabled);
  }

  /// Si activé, le mode découverte redéclenche aussi les POIs déjà écoutés
  /// (utile pour les tests terrain). Par défaut: on ne rejoue pas.
  static Future<bool> isDiscoveryReplayVisitedEnabled() async {
    final prefs = await _prefs();
    return prefs.getBool(discoveryReplayVisitedEnabledKey) ??
        defaultDiscoveryReplayVisitedEnabled;
  }

  static Future<void> setDiscoveryReplayVisitedEnabled(bool enabled) async {
    final prefs = await _prefs();
    await prefs.setBool(discoveryReplayVisitedEnabledKey, enabled);
  }
}
