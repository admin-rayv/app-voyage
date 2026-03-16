import 'dart:async';
import 'tts_service.dart';
import 'supabase_service.dart';

/// Service Audio — Pont entre les scripts Supabase et le TTS natif.
///
/// Récupère le texte du script depuis Supabase, puis le lit
/// via flutter_tts (voix native du téléphone).
/// Pas de génération MP3, pas d'API externe, 100% offline après sync.

class AudioService {
  final TtsService _tts = TtsService();
  final SupabaseService _supabase = SupabaseService();

  TtsService get tts => _tts;

  /// Initialiser le service.
  Future<void> init() async {
    await _tts.init();
  }

  /// Jouer le script audio d'un POI.
  ///
  /// [scriptId] — UUID du script dans Supabase
  /// Récupère le texte + langue, puis lance la lecture TTS.
  Future<void> playScript(String scriptId) async {
    final script = await _supabase.getScript(scriptId);
    if (script == null) return;

    final text = script['content'] as String;
    final language = script['language'] as String? ?? 'fr';

    await _tts.speak(text, language: language);
  }

  /// Jouer un texte directement (sans passer par Supabase).
  ///
  /// Utile pour les previews ou le mode offline avec cache local.
  Future<void> playText(String text, {String language = 'fr'}) async {
    await _tts.speak(text, language: language);
  }

  /// Pause.
  Future<void> pause() async {
    await _tts.pause();
  }

  /// Stop.
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Stream d'état (playing, paused, stopped).
  Stream<TtsState> get stateStream => _tts.stateStream;

  bool get isPlaying => _tts.isPlaying;
  bool get isPaused => _tts.isPaused;

  /// Modifier la vitesse de lecture.
  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  /// Libérer les ressources.
  void dispose() {
    _tts.dispose();
  }
}
