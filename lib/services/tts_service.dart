import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

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
  String _currentLanguage = 'fr-CA';

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;

  // Stream controllers pour écouter les changements d'état
  final _stateController = StreamController<TtsState>.broadcast();
  Stream<TtsState> get stateStream => _stateController.stream;

  // Voix préférées par langue — voix masculines pour Marco 🎙️
  static const Map<String, List<String>> _preferredVoices = {
    'fr-CA': ['Nicolas', 'Thomas', 'Jean-Pierre'],
    'fr-FR': ['Thomas', 'Nicolas'],
    'en-US': ['Daniel', 'Aaron', 'Tom'],
    'en-GB': ['Daniel', 'Oliver'],
    'es-ES': ['Jorge', 'Diego', 'Juan'],
    'es-MX': ['Juan', 'Jorge'],
  };

  /// Initialiser le service TTS.
  Future<void> init() async {
    // Config Marco — voix masculine, rythme guide touristique
    await _tts.setSpeechRate(0.42); // Posé, pas pressé
    await _tts.setVolume(1.0);
    await _tts.setPitch(0.95); // Légèrement plus grave = plus masculin

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

  /// Configurer la langue et sélectionner la meilleure voix disponible.
  ///
  /// [language] — Code ISO: 'fr', 'en', ou 'es'
  Future<void> setLanguage(String language) async {
    final locale = _languageToLocale(language);
    _currentLanguage = locale;
    await _tts.setLanguage(locale);
    await _selectBestVoice(locale);
  }

  /// Lire un script audio.
  ///
  /// [text] — Le contenu du script
  /// [language] — Code ISO optionnel ('fr', 'en', 'es')
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
    // flutter_tts n'a pas de vrai resume — on re-speak le texte
    // Note: sur iOS, pause/resume natif fonctionne
    if (_isPaused) {
      await _tts.speak(_currentText ?? '');
    }
  }

  /// Arrêter la lecture.
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Modifier la vitesse de lecture.
  ///
  /// [rate] — 0.0 à 1.0 (0.5 = normal, plus bas = plus lent)
  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  /// Modifier la hauteur de la voix.
  ///
  /// [pitch] — 0.5 à 2.0 (1.0 = normal)
  Future<void> setPitch(double pitch) async {
    await _tts.setPitch(pitch);
  }

  /// Lister les voix disponibles pour une langue.
  Future<List<Map<String, String>>> getAvailableVoices(String language) async {
    final locale = _languageToLocale(language);
    final voices = await _tts.getVoices;
    if (voices == null) return [];

    return (voices as List)
        .where((v) =>
            v['locale']?.toString().startsWith(locale.substring(0, 2)) == true)
        .map<Map<String, String>>((v) => {
              'name': v['name']?.toString() ?? '',
              'locale': v['locale']?.toString() ?? '',
            })
        .toList();
  }

  /// Sélectionner la meilleure voix disponible pour un locale.
  Future<void> _selectBestVoice(String locale) async {
    final voices = await _tts.getVoices;
    if (voices == null) return;

    final preferred = _preferredVoices[locale] ?? [];
    final langPrefix = locale.substring(0, 2);

    // Chercher une voix préférée
    for (final pref in preferred) {
      for (final voice in voices) {
        final name = voice['name']?.toString() ?? '';
        final voiceLocale = voice['locale']?.toString() ?? '';
        if (name.contains(pref) && voiceLocale.startsWith(langPrefix)) {
          await _tts.setVoice({'name': name, 'locale': voiceLocale});
          return;
        }
      }
    }

    // Fallback: voix Enhanced/Premium masculine si disponible
    for (final quality in ['Premium', 'Enhanced']) {
      for (final voice in voices) {
        final name = voice['name']?.toString() ?? '';
        final voiceLocale = voice['locale']?.toString() ?? '';
        if (voiceLocale.startsWith(langPrefix) && name.contains(quality)) {
          // Éviter les voix féminines connues
          final femaleNames = ['Amelie', 'Amélie', 'Samantha', 'Paulina',
            'Audrey', 'Martha', 'Siri', 'Karen', 'Moira', 'Tessa'];
          final isFemale = femaleNames.any(
            (f) => name.toLowerCase().contains(f.toLowerCase()));
          if (!isFemale) {
            await _tts.setVoice({'name': name, 'locale': voiceLocale});
            return;
          }
        }
      }
    }
  }

  /// Convertir un code langue ISO en locale complet.
  String _languageToLocale(String language) {
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
