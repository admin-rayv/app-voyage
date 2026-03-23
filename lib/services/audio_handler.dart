import 'dart:async';

import 'package:audio_service/audio_service.dart' as audio_svc;
import 'package:audio_session/audio_session.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/point.dart' as models;
import 'debug_log.dart';
import 'tts_service.dart';

/// Wrapper autour de FlutterTts avec Completer pour attendre la fin.
/// Pattern identique à l'exemple officiel audio_service (Tts class).
class _TtsWrapper {
  final FlutterTts _flutterTts = FlutterTts();
  Completer<void>? _speechCompleter;
  bool _interruptRequested = false;
  bool _playing = false;

  _TtsWrapper() {
    _flutterTts.setCompletionHandler(() {
      _speechCompleter?.complete();
    });
    _flutterTts.setCancelHandler(() {
      _speechCompleter?.complete();
    });
    _flutterTts.setErrorHandler((msg) {
      DebugLog().log('[TtsWrapper] erreur: $msg');
      _speechCompleter?.complete();
    });
  }

  FlutterTts get raw => _flutterTts;
  bool get playing => _playing;

  /// Parler un texte et attendre la fin (ou l'interruption).
  Future<void> speak(String text) async {
    _playing = true;
    if (!_interruptRequested) {
      _speechCompleter = Completer();
      await _flutterTts.speak(text);
      await _speechCompleter!.future;
      _speechCompleter = null;
    }
    _playing = false;
    if (_interruptRequested) {
      _interruptRequested = false;
      throw TtsInterruptedException();
    }
  }

  Future<void> stop() async {
    if (_playing) {
      await _flutterTts.stop();
      _speechCompleter?.complete();
    }
  }

  void interrupt() {
    if (_playing) {
      _interruptRequested = true;
      stop();
    }
  }
}

class TtsInterruptedException {}

/// Handler audio TTS — basé sur l'exemple officiel TextPlayerHandler.
///
/// Différences avec l'exemple officiel:
/// - Pas de queue (on lit un seul texte à la fois)
/// - Configuration de la voix via TtsService
/// - androidCompactActionIndices pour les boutons lock screen
class AppAudioHandler extends audio_svc.BaseAudioHandler {
  final _tts = _TtsWrapper();
  bool _interrupted = false;
  bool _running = false;
  Completer<void>? _runCompleter;

  // Métadonnées du POI en cours
  String? _currentText;
  String _currentLanguage = 'fr';
  String _currentPoiName = 'Lecture audio';
  models.Point? _currentPoi;
  Duration _estimatedDuration = Duration.zero;

  bool get _playing => playbackState.value.playing;

  String? get currentText => _currentText;
  String get currentLanguage => _currentLanguage;
  String get currentPoiName => _currentPoiName;
  models.Point? get currentPoi => _currentPoi;
  Duration get estimatedDuration => _estimatedDuration;

  AppAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    await _tts.raw.setVolume(1.0);
    await _tts.raw.setPitch(1.05);
    await _tts.raw.setSpeechRate(0.52);
  }

  /// Charger un texte à lire (appelé par AudioService.playText).
  Future<void> speakText(
    String text,
    String language,
    String poiName,
    models.Point? poi,
    Duration estimatedDuration,
  ) async {
    DebugLog().log('[Handler] speakText poi=$poiName lang=$language');

    // Arrêter la lecture en cours
    if (_playing || _running) {
      await stop();
    }

    _currentText = text;
    _currentLanguage = language;
    _currentPoiName = poiName.trim().isEmpty ? 'Lecture audio' : poiName.trim();
    _currentPoi = poi;
    _estimatedDuration = estimatedDuration;

    // Informer les clients du media item
    mediaItem.add(audio_svc.MediaItem(
      id: 'tts-${text.hashCode}',
      album: 'App Voyage',
      title: _currentPoiName,
      artist: 'Guide audio',
      duration: estimatedDuration,
    ));

    // Lancer la lecture
    await play();
  }

  @override
  Future<void> play() async {
    if (_playing) return;
    if ((_currentText ?? '').isEmpty) return;

    DebugLog().log('[Handler] play');

    // Activer la session audio manuellement.
    // L'exemple officiel dit: "flutter_tts doesn't activate the session,
    // so we do it here."
    final session = await AudioSession.instance;
    if (await session.setActive(true)) {
      // Broadcaster l'état playing AVANT de parler
      playbackState.add(playbackState.value.copyWith(
        controls: [
          audio_svc.MediaControl.pause,
          audio_svc.MediaControl.stop,
        ],
        androidCompactActionIndices: const [0, 1],
        processingState: audio_svc.AudioProcessingState.ready,
        playing: true,
      ));

      // Forcer l'activation des boutons media sur Android.
      // L'exemple officiel appelle ceci dans la boucle de lecture TTS.
      audio_svc.AudioService.androidForceEnableMediaButtons();

      if (_runCompleter == null) {
        _run();
      }
    } else {
      DebugLog().log('[Handler] session audio refusée');
    }
  }

  /// Boucle de lecture (pattern officiel: run loop).
  Future<void> _run() async {
    _runCompleter = Completer<void>();
    _running = true;

    try {
      // Configurer la voix
      DebugLog().log('[Handler] config voix lang=$_currentLanguage');
      try {
        await TtsService.configureVoiceForTts(_tts.raw, _currentLanguage);
      } catch (e) {
        DebugLog().log('[Handler] erreur config voix: $e');
      }

      // Parler le texte
      DebugLog().log('[Handler] tts.speak start');
      await _tts.speak(_currentText!);
      DebugLog().log('[Handler] tts.speak done');
    } on TtsInterruptedException {
      DebugLog().log('[Handler] TTS interrompu');
    }

    _running = false;

    // Si on n'est pas déjà en idle (stop appelé pendant la lecture),
    // marquer comme terminé
    if (playbackState.value.processingState !=
        audio_svc.AudioProcessingState.idle) {
      playbackState.add(playbackState.value.copyWith(
        controls: [audio_svc.MediaControl.play],
        androidCompactActionIndices: const [0],
        processingState: audio_svc.AudioProcessingState.completed,
        playing: false,
        updatePosition: _estimatedDuration,
      ));
    }

    _runCompleter?.complete();
    _runCompleter = null;
  }

  @override
  Future<void> pause() async {
    DebugLog().log('[Handler] pause');
    _interrupted = false;

    playbackState.add(playbackState.value.copyWith(
      controls: [
        audio_svc.MediaControl.play,
        audio_svc.MediaControl.stop,
      ],
      androidCompactActionIndices: const [0, 1],
      processingState: audio_svc.AudioProcessingState.ready,
      playing: false,
    ));

    _tts.interrupt();
  }

  @override
  Future<void> stop() async {
    DebugLog().log('[Handler] stop');

    playbackState.add(playbackState.value.copyWith(
      controls: [],
      androidCompactActionIndices: const [],
      processingState: audio_svc.AudioProcessingState.idle,
      playing: false,
    ));

    _running = false;
    _tts.interrupt();

    // Attendre que la lecture s'arrête complètement
    await _runCompleter?.future;

    // Arrêter le service (désactive la notification)
    await super.stop();
  }

  /// Changer la vitesse de lecture.
  Future<void> setSpeed(double speed) async {
    DebugLog().log('[Handler] setSpeed=$speed');
    await _tts.raw.setSpeechRate(speed);
  }
}
