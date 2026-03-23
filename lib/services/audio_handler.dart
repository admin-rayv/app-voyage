import 'dart:async';

import 'package:audio_service/audio_service.dart' as audio_svc;
import 'package:audio_session/audio_session.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/point.dart' as models;
import 'debug_log.dart';
import 'tts_service.dart';

/// Wrapper autour de FlutterTts avec Completer pour attendre la fin.
/// Supporte pause natif Android (flutter_tts sauvegarde la position du texte).
class _TtsWrapper {
  final FlutterTts _flutterTts = FlutterTts();
  Completer<void>? _speechCompleter;
  bool _interruptRequested = false;
  bool _pauseRequested = false;
  bool _playing = false;

  _TtsWrapper() {
    _flutterTts.setCompletionHandler(() {
      _speechCompleter?.complete();
    });
    _flutterTts.setCancelHandler(() {
      _speechCompleter?.complete();
    });
    _flutterTts.setPauseHandler(() {
      DebugLog().log('[TtsWrapper] pause handler');
      _speechCompleter?.complete();
    });
    _flutterTts.setContinueHandler(() {
      DebugLog().log('[TtsWrapper] continue handler');
    });
    _flutterTts.setErrorHandler((msg) {
      DebugLog().log('[TtsWrapper] erreur: $msg');
      _speechCompleter?.complete();
    });
  }

  FlutterTts get raw => _flutterTts;
  bool get playing => _playing;

  /// Parler un texte et attendre la fin (ou l'interruption/pause).
  Future<void> speak(String text) async {
    _playing = true;
    if (!_interruptRequested && !_pauseRequested) {
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
    if (_pauseRequested) {
      _pauseRequested = false;
      throw TtsPausedException();
    }
  }

  /// Pause natif flutter_tts — sauvegarde la position dans le texte.
  /// Au prochain speak(), flutter_tts reprend automatiquement.
  Future<void> pause() async {
    if (_playing) {
      _pauseRequested = true;
      await _flutterTts.pause();
      // Le pauseHandler va compléter le _speechCompleter
    }
  }

  /// Stop complet — perd la position.
  Future<void> stop() async {
    if (_playing) {
      _interruptRequested = true;
      await _flutterTts.stop();
      _speechCompleter?.complete();
    }
  }
}

class TtsInterruptedException {}

class TtsPausedException {}

/// Handler audio TTS — basé sur l'exemple officiel TextPlayerHandler
/// avec pause/resume natif flutter_tts.
class AppAudioHandler extends audio_svc.BaseAudioHandler {
  final _tts = _TtsWrapper();
  bool _running = false;
  bool _wasPaused = false;
  Completer<void>? _runCompleter;

  // Timer pour la barre de progression dans l'UI
  Timer? _positionTimer;
  Duration _position = Duration.zero;

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

  /// Charger un texte à lire.
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
    _wasPaused = false;

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

    DebugLog().log('[Handler] play wasPaused=$_wasPaused');

    // Activer la session audio manuellement
    final session = await AudioSession.instance;
    if (await session.setActive(true)) {
      // Si on reprend après pause, garder la position actuelle
      if (!_wasPaused) {
        _position = Duration.zero;
      }

      // Broadcaster l'état playing
      playbackState.add(playbackState.value.copyWith(
        controls: [
          audio_svc.MediaControl.pause,
          audio_svc.MediaControl.stop,
        ],
        androidCompactActionIndices: const [0, 1],
        processingState: audio_svc.AudioProcessingState.ready,
        playing: true,
        updatePosition: _position,
      ));

      // Forcer l'activation des boutons media sur Android
      audio_svc.AudioService.androidForceEnableMediaButtons();

      // Démarrer le timer de position
      _startPositionUpdates();

      // Lancer la lecture (ou reprendre après pause)
      if (_runCompleter == null) {
        _run();
      }
    } else {
      DebugLog().log('[Handler] session audio refusée');
    }
  }

  /// Boucle de lecture.
  Future<void> _run() async {
    _runCompleter = Completer<void>();
    _running = true;
    var finishedNaturally = false;

    try {
      // Configurer la voix seulement si c'est une nouvelle lecture
      if (!_wasPaused) {
        DebugLog().log('[Handler] config voix lang=$_currentLanguage');
        try {
          await TtsService.configureVoiceForTts(_tts.raw, _currentLanguage);
        } catch (e) {
          DebugLog().log('[Handler] erreur config voix: $e');
        }
      }
      _wasPaused = false;

      // Parler le texte.
      // Si on reprend après pause, flutter_tts reprend automatiquement
      // à la position sauvegardée (via onRangeStart index).
      DebugLog().log('[Handler] tts.speak start');
      await _tts.speak(_currentText!);
      DebugLog().log('[Handler] tts.speak done');
      finishedNaturally = true;
    } on TtsInterruptedException {
      DebugLog().log('[Handler] TTS interrompu (stop)');
    } on TtsPausedException {
      DebugLog().log('[Handler] TTS en pause');
      // Ne rien faire — l'état a déjà été mis par pause()
    }

    _running = false;

    // Seulement si la lecture s'est terminée naturellement
    if (finishedNaturally) {
      _stopPositionUpdates();
      _position = _estimatedDuration;
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

    _stopPositionUpdates();
    _wasPaused = true;

    playbackState.add(playbackState.value.copyWith(
      controls: [
        audio_svc.MediaControl.play,
        audio_svc.MediaControl.stop,
      ],
      androidCompactActionIndices: const [0, 1],
      processingState: audio_svc.AudioProcessingState.ready,
      playing: false,
      updatePosition: _position,
    ));

    // Utiliser pause natif flutter_tts — sauvegarde la position dans le texte
    await _tts.pause();
  }

  @override
  Future<void> stop() async {
    DebugLog().log('[Handler] stop');

    _stopPositionUpdates();
    _position = Duration.zero;
    _wasPaused = false;

    playbackState.add(playbackState.value.copyWith(
      controls: [],
      androidCompactActionIndices: const [],
      processingState: audio_svc.AudioProcessingState.idle,
      playing: false,
      updatePosition: Duration.zero,
    ));

    _running = false;
    await _tts.stop();

    // Attendre que la lecture s'arrête complètement
    await _runCompleter?.future;

    // Désactiver la notification
    await super.stop();
  }

  /// Changer la vitesse de lecture.
  Future<void> setSpeed(double speed) async {
    DebugLog().log('[Handler] setSpeed=$speed');
    await _tts.raw.setSpeechRate(speed);
  }

  /// Timer de position pour la barre de progression UI.
  void _startPositionUpdates() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      final next = _position + const Duration(milliseconds: 500);
      _position = next > _estimatedDuration ? _estimatedDuration : next;
      playbackState.add(playbackState.value.copyWith(
        updatePosition: _position,
      ));
    });
  }

  void _stopPositionUpdates() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }
}
