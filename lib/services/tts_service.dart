import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service TTS — Lecture audio des scripts via voix natives du téléphone.
///
/// Utilise les voix système (Apple Speech / Google TTS).
/// Gratuit, offline, instantané. Supporte FR, EN, ES.

class TtsService {
  final FlutterTts _tts = FlutterTts();

  // État
  bool _isPlaying = false;
  bool _isPaused = false;
  String? _currentText;

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;

  // Stream controllers pour écouter les changements d'état
  final _stateController = StreamController<TtsState>.broadcast();
  Stream<TtsState> get stateStream => _stateController.stream;

  // Voix forcées par défaut — testées et approuvées sur Android
  static const Map<String, String> _defaultVoices = {
    'fr': 'fr-ca-x-cac-local',
    'en': 'en-us-x-tpd-local',
    'es': '', // à définir — fallback auto
  };

  // Clés SharedPreferences pour les voix choisies par l'utilisateur
  static const String _prefKeyVoiceFr = 'tts_voice_fr';
  static const String _prefKeyVoiceEn = 'tts_voice_en';
  static const String _prefKeyVoiceEs = 'tts_voice_es';

  /// Initialiser le service TTS.
  Future<void> init() async {
    await _tts.setSpeechRate(0.52);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.05);

    // Callbacks
    _tts.setStartHandler(() {
      _isPlaying = true;
      _isPaused = false;
      _stateController.add(TtsState.playing);
    });

    _tts.setCompletionHandler(() {
      _isPlaying = false;
      _isPaused = false;
      _stateController.add(TtsState.stopped);
    });

    _tts.setCancelHandler(() {
      _isPlaying = false;
      _isPaused = false;
      _stateController.add(TtsState.stopped);
    });

    _tts.setPauseHandler(() {
      _isPaused = true;
      _isPlaying = false;
      _stateController.add(TtsState.paused);
    });

    _tts.setContinueHandler(() {
      _isPaused = false;
      _isPlaying = true;
      _stateController.add(TtsState.playing);
    });

    _tts.setErrorHandler((msg) {
      _isPlaying = false;
      _isPaused = false;
      _stateController.add(TtsState.stopped);
    });
  }

  /// Configurer la langue et sélectionner la voix (user pref → default → fallback).
  Future<void> setLanguage(String language) async {
    await configureVoiceForTts(_tts, language);
  }

  /// Lire un script audio.
  Future<void> speak(String text, {String? language}) async {
    if (language != null) {
      await setLanguage(language);
    }
    _currentText = text;
    await _tts.speak(text);
  }

  /// Pause la lecture.
  Future<void> pause() async {
    await _tts.pause();
  }

  /// Reprendre après une pause.
  Future<void> resume() async {
    if (_isPaused) {
      await _tts.speak(_currentText ?? '');
    }
  }

  /// Arrêter la lecture.
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Modifier la vitesse de lecture.
  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  /// Modifier la hauteur de la voix.
  Future<void> setPitch(double pitch) async {
    await _tts.setPitch(pitch);
  }

  /// Lister les voix LOCALES disponibles pour une langue.
  /// Retourne les voix filtrées par locale, triées avec "local" en premier.
  Future<List<VoiceInfo>> getLocalVoices(String language) async {
    final locale = _languageToLocale(language);
    final langPrefix = locale.substring(0, 2);
    final voices = await _tts.getVoices;
    if (voices == null) return [];

    final results = <VoiceInfo>[];
    for (final v in (voices as List)) {
      final name = v['name']?.toString() ?? '';
      final voiceLocale = v['locale']?.toString() ?? '';
      if (voiceLocale.startsWith(langPrefix)) {
        final isLocal = name.contains('-local');
        results.add(VoiceInfo(
          name: name,
          locale: voiceLocale,
          isLocal: isLocal,
        ));
      }
    }

    // Trier : local d'abord, puis par nom
    results.sort((a, b) {
      if (a.isLocal && !b.isLocal) return -1;
      if (!a.isLocal && b.isLocal) return 1;
      return a.name.compareTo(b.name);
    });

    return results;
  }

  /// Sauvegarder la voix choisie par l'utilisateur pour une langue.
  Future<void> setUserVoice(String language, String voiceName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _prefKeyForLanguage(language);
    await prefs.setString(key, voiceName);
    // Appliquer immédiatement
    await _applyVoice(voiceName, _languageToLocale(language));
  }

  /// Obtenir la voix actuellement choisie pour une langue.
  Future<String?> getUserVoice(String language) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKeyForLanguage(language));
  }

  /// Sélectionner la voix : user pref → default → premier local dispo.
  Future<void> _selectVoice(String language) async {
    await selectVoiceForTts(_tts, language);
  }

  /// Appliquer une voix spécifique. Retourne true si trouvée.
  Future<bool> _applyVoice(String voiceName, String locale) async {
    return applyVoiceToTts(_tts, voiceName, locale);
  }

  String _prefKeyForLanguage(String language) {
    return prefKeyForLanguage(language);
  }

  /// Convertir un code langue ISO en locale complet.
  String _languageToLocale(String language) {
    return languageToLocale(language);
  }

  /// Configurer une instance TTS externe avec la langue et la voix préférée.
  static Future<void> configureVoiceForTts(FlutterTts tts, String language) async {
    final locale = languageToLocale(language);
    await tts.setLanguage(locale);
    await selectVoiceForTts(tts, language);
  }

  /// Sélectionner la voix préférée pour une instance TTS donnée.
  static Future<void> selectVoiceForTts(FlutterTts tts, String language) async {
    final locale = languageToLocale(language);
    final prefs = await SharedPreferences.getInstance();

    final userVoice = prefs.getString(prefKeyForLanguage(language));
    if (userVoice != null && userVoice.isNotEmpty) {
      if (await applyVoiceToTts(tts, userVoice, locale)) return;
    }

    final defaultVoice = _defaultVoices[language] ?? '';
    if (defaultVoice.isNotEmpty) {
      if (await applyVoiceToTts(tts, defaultVoice, locale)) return;
    }

    final voices = await tts.getVoices;
    if (voices == null) return;

    final langPrefix = locale.substring(0, 2);
    for (final voice in (voices as List)) {
      final name = voice['name']?.toString() ?? '';
      final voiceLocale = voice['locale']?.toString() ?? '';
      if (!voiceLocale.startsWith(langPrefix)) continue;
      if (name.contains('-local')) {
        await tts.setVoice({'name': name, 'locale': voiceLocale});
        return;
      }
    }

    for (final voice in voices) {
      final name = voice['name']?.toString() ?? '';
      final voiceLocale = voice['locale']?.toString() ?? '';
      if (voiceLocale.startsWith(langPrefix)) {
        await tts.setVoice({'name': name, 'locale': voiceLocale});
        return;
      }
    }
  }

  /// Appliquer une voix spécifique sur une instance TTS donnée.
  static Future<bool> applyVoiceToTts(
    FlutterTts tts,
    String voiceName,
    String locale,
  ) async {
    final voices = await tts.getVoices;
    if (voices == null) return false;

    for (final voice in (voices as List)) {
      final name = voice['name']?.toString() ?? '';
      if (name == voiceName) {
        final voiceLocale = voice['locale']?.toString() ?? locale;
        await tts.setVoice({'name': name, 'locale': voiceLocale});
        return true;
      }
    }
    return false;
  }

  /// Obtenir la clé de préférence associée à une langue.
  static String prefKeyForLanguage(String language) {
    switch (language) {
      case 'fr':
        return _prefKeyVoiceFr;
      case 'en':
        return _prefKeyVoiceEn;
      case 'es':
        return _prefKeyVoiceEs;
      default:
        return 'tts_voice_$language';
    }
  }

  /// Convertir un code langue ISO en locale complet.
  static String languageToLocale(String language) {
    switch (language) {
      case 'fr':
        return 'fr-CA';
      case 'en':
        return 'en-US';
      case 'es':
        return 'es-ES';
      default:
        return language;
    }
  }

  /// Libérer les ressources.
  void dispose() {
    _tts.stop();
    _stateController.close();
  }
}

/// États possibles du TTS.
enum TtsState { playing, paused, stopped }

/// Info d'une voix disponible.
class VoiceInfo {
  final String name;
  final String locale;
  final bool isLocal;

  const VoiceInfo({
    required this.name,
    required this.locale,
    required this.isLocal,
  });

  /// Nom lisible pour l'UI.
  String get displayName {
    // "fr-ca-x-cac-local" → "fr-CA cac (local)"
    final parts = name.split('-');
    if (parts.length >= 5) {
      final voiceId = parts[4];
      final type = isLocal ? 'local' : 'network';
      return '${locale} — $voiceId ($type)';
    }
    return name;
  }
}
