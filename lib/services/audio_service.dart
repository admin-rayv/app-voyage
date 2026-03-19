import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'tts_service.dart';
import 'edge_tts_service.dart';
import 'supabase_service.dart';

/// Service Audio — Pont entre les scripts Supabase et la lecture audio.
///
/// Stratégie de lecture (par priorité):
/// 1. Cache local (MP3 déjà téléchargé) → lecture instantanée offline
/// 2. Edge TTS (si internet) → génère MP3 + cache + lecture
/// 3. flutter_tts natif (fallback) → voix du téléphone, toujours dispo

class AudioService {
  final TtsService _tts = TtsService();
  final EdgeTtsService _edgeTts = EdgeTtsService();
  final SupabaseService _supabase = SupabaseService();
  final AudioPlayer _player = AudioPlayer();

  TtsService get tts => _tts;
  EdgeTtsService get edgeTts => _edgeTts;

  // État
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _usingEdgeTts = false;

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  /// True si la dernière lecture utilise Edge TTS (bonne qualité).
  bool get usingEdgeTts => _usingEdgeTts;

  // Stream d'état
  final _stateController = StreamController<TtsState>.broadcast();
  Stream<TtsState> get stateStream => _stateController.stream;

  /// Initialiser les services audio.
  Future<void> init() async {
    await _tts.init();

    // Écouter l'état du player just_audio
    _player.playerStateStream.listen((state) {
      if (!_usingEdgeTts) return; // Seulement quand on utilise Edge TTS
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _isPaused = false;
        _stateController.add(TtsState.stopped);
      } else if (state.playing) {
        _isPlaying = true;
        _isPaused = false;
        _stateController.add(TtsState.playing);
      } else if (!state.playing &&
          state.processingState == ProcessingState.ready) {
        _isPaused = true;
        _isPlaying = false;
        _stateController.add(TtsState.paused);
      }
    });
  }

  /// Jouer le script audio d'un POI.
  ///
  /// [scriptId] — UUID du script dans Supabase
  /// Tente Edge TTS (cache ou live), sinon fallback flutter_tts.
  Future<void> playScript(String scriptId) async {
    final script = await _supabase.getScript(scriptId);
    if (script == null) return;

    final text = script['content'] as String;
    final language = script['language'] as String? ?? 'fr';

    await _playWithFallback(
      scriptId: scriptId,
      text: text,
      language: language,
    );
  }

  /// Jouer un texte directement (preview / mode offline).
  Future<void> playText(String text, {String language = 'fr'}) async {
    await _playWithFallback(
      scriptId: 'preview-${text.hashCode}',
      text: text,
      language: language,
    );
  }

  /// Logique de fallback: Edge TTS → flutter_tts natif.
  Future<void> _playWithFallback({
    required String scriptId,
    required String text,
    required String language,
  }) async {
    // Arrêter toute lecture en cours
    await stop();

    // Tenter Edge TTS (cache ou génération live)
    final audioPath = await _edgeTts.getAudioPath(
      scriptId: scriptId,
      text: text,
      language: language,
    );

    if (audioPath != null) {
      // Lecture MP3 via just_audio
      _usingEdgeTts = true;
      try {
        await _player.setFilePath(audioPath);
        await _player.play();
        return;
      } catch (e) {
        // Si erreur de lecture MP3, fallback
      }
    }

    // Fallback: flutter_tts natif
    _usingEdgeTts = false;
    await _tts.speak(text, language: language);

    // Relayer les états TTS natif
    _tts.stateStream.listen((state) {
      if (!_usingEdgeTts) {
        _isPlaying = state == TtsState.playing;
        _isPaused = state == TtsState.paused;
        _stateController.add(state);
      }
    });
  }

  /// Pause.
  Future<void> pause() async {
    if (_usingEdgeTts) {
      await _player.pause();
    } else {
      await _tts.pause();
    }
  }

  /// Reprendre.
  Future<void> resume() async {
    if (_usingEdgeTts) {
      await _player.play();
    } else {
      await _tts.resume();
    }
  }

  /// Stop.
  Future<void> stop() async {
    if (_usingEdgeTts) {
      await _player.stop();
    }
    await _tts.stop();
    _isPlaying = false;
    _isPaused = false;
    _usingEdgeTts = false;
    _stateController.add(TtsState.stopped);
  }

  /// Modifier la vitesse de lecture.
  Future<void> setSpeechRate(double rate) async {
    // Pour just_audio: 1.0 = normal, 0.5 = lent, 2.0 = rapide
    await _player.setSpeed(rate * 2); // Convertir échelle TTS → just_audio
    await _tts.setSpeechRate(rate);
  }

  /// Télécharger tous les audios d'une ville pour écoute offline.
  Future<void> downloadCityAudios({
    required String cityId,
    required void Function(int current, int total) onProgress,
  }) async {
    // Télécharger les 3 langues
    for (final lang in ['fr', 'en', 'es']) {
      final scripts = await SupabaseService.getScriptsForCity(cityId, lang);
      await _edgeTts.downloadAll(
        scripts: scripts,
        onProgress: onProgress,
      );
    }
  }

  /// Taille du cache audio en MB.
  Future<double> getCacheSizeMB() async {
    final bytes = await _edgeTts.getCacheSize();
    return bytes / (1024 * 1024);
  }

  /// Vider le cache.
  Future<void> clearCache() async {
    await _edgeTts.clearCache();
  }

  /// Libérer les ressources.
  void dispose() {
    _player.dispose();
    _tts.dispose();
    _stateController.close();
  }
}
