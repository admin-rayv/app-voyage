import 'dart:async';

import 'package:audio_service/audio_service.dart' as audio_svc;
import 'package:flutter_tts/flutter_tts.dart';

import '../models/point.dart' as models;
import 'debug_log.dart';
import 'tts_service.dart';

/// Handler audio TTS — source unique de vérité.
///
/// Suit le pattern officiel audio_service:
/// - Chaque broadcast utilise PlaybackState() complet (pas copyWith)
/// - La position est mise à jour via updatePosition uniquement quand
///   elle change de façon inattendue (début, fin, pause)
/// - AudioService.position côté UI projette la position automatiquement
class AppAudioHandler extends audio_svc.BaseAudioHandler {
  AppAudioHandler() {
    _ready = _configureTts();
    // État initial: idle, bouton play disponible
    _broadcastState(
      playing: false,
      processingState: audio_svc.AudioProcessingState.idle,
      controls: const [audio_svc.MediaControl.play],
      position: Duration.zero,
    );
  }

  final FlutterTts _tts = FlutterTts();
  late final Future<void> _ready;

  String? _currentText;
  String _currentLanguage = 'fr';
  String _currentPoiName = 'Lecture audio';
  models.Point? _currentPoi;
  Duration _estimatedDuration = Duration.zero;
  double _speechRate = 0.52;
  bool _wasPaused = false;
  bool _ignoringCancel = false;

  String? get currentText => _currentText;
  String get currentLanguage => _currentLanguage;
  String get currentPoiName => _currentPoiName;
  models.Point? get currentPoi => _currentPoi;
  Duration get estimatedDuration => _estimatedDuration;

  /// Broadcast un PlaybackState COMPLET (pas copyWith).
  /// Selon la doc: chaque broadcast doit être un objet complet.
  void _broadcastState({
    required bool playing,
    required audio_svc.AudioProcessingState processingState,
    required List<audio_svc.MediaControl> controls,
    required Duration position,
  }) {
    // Indices compacts: les N premiers boutons (max 3)
    final compact = List<int>.generate(
      controls.length > 3 ? 3 : controls.length,
      (i) => i,
    );

    playbackState.add(audio_svc.PlaybackState(
      controls: controls,
      systemActions: const {
        audio_svc.MediaAction.play,
        audio_svc.MediaAction.pause,
        audio_svc.MediaAction.stop,
      },
      androidCompactActionIndices: compact,
      processingState: processingState,
      playing: playing,
      updatePosition: position,
      speed: _speechRate,
    ));
  }

  Future<void> _configureTts() async {
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.05);
    await _tts.setSpeechRate(_speechRate);

    _tts.setStartHandler(() {
      DebugLog().log('[Handler] TTS start');
      _broadcastState(
        playing: true,
        processingState: audio_svc.AudioProcessingState.ready,
        controls: const [
          audio_svc.MediaControl.pause,
          audio_svc.MediaControl.stop,
        ],
        position: Duration.zero,
      );
    });

    _tts.setCompletionHandler(() {
      DebugLog().log('[Handler] TTS completion');
      _wasPaused = false;
      _broadcastState(
        playing: false,
        processingState: audio_svc.AudioProcessingState.completed,
        controls: const [audio_svc.MediaControl.play],
        position: _estimatedDuration,
      );
    });

    _tts.setCancelHandler(() {
      if (_ignoringCancel) {
        DebugLog().log('[Handler] TTS cancel (ignoré)');
        _ignoringCancel = false;
        return;
      }

      DebugLog().log('[Handler] TTS cancel paused=$_wasPaused');
      if (_wasPaused) {
        _broadcastState(
          playing: false,
          processingState: audio_svc.AudioProcessingState.ready,
          controls: const [
            audio_svc.MediaControl.play,
            audio_svc.MediaControl.stop,
          ],
          position: Duration.zero,
        );
      } else {
        _broadcastState(
          playing: false,
          processingState: audio_svc.AudioProcessingState.idle,
          controls: const [audio_svc.MediaControl.play],
          position: Duration.zero,
        );
      }
    });

    _tts.setPauseHandler(() {
      DebugLog().log('[Handler] TTS pause');
      _wasPaused = true;
      _broadcastState(
        playing: false,
        processingState: audio_svc.AudioProcessingState.ready,
        controls: const [
          audio_svc.MediaControl.play,
          audio_svc.MediaControl.stop,
        ],
        position: Duration.zero,
      );
    });

    _tts.setErrorHandler((message) {
      DebugLog().log('[Handler] TTS erreur=$message');
      _wasPaused = false;
      _broadcastState(
        playing: false,
        processingState: audio_svc.AudioProcessingState.idle,
        controls: const [audio_svc.MediaControl.play],
        position: Duration.zero,
      );
    });
  }

  /// Lancer la lecture d'un texte.
  Future<void> speakText(
    String text,
    String language,
    String poiName,
    models.Point? poi,
    Duration estimatedDuration,
  ) async {
    await _ready;
    DebugLog().log('[Handler] speakText poi=$poiName lang=$language');

    // Arrêter la lecture en cours
    final current = playbackState.value;
    if (current.playing ||
        current.processingState == audio_svc.AudioProcessingState.ready) {
      _ignoringCancel = true;
      await _tts.stop();
    }

    _currentText = text;
    _currentLanguage = language;
    _currentPoiName = poiName.trim().isEmpty ? 'Lecture audio' : poiName.trim();
    _currentPoi = poi;
    _estimatedDuration = estimatedDuration;
    _wasPaused = false;

    // Informer les clients du media item en cours
    mediaItem.add(audio_svc.MediaItem(
      id: 'tts-${text.hashCode}',
      album: 'App Voyage',
      title: _currentPoiName,
      artist: 'Guide audio',
      duration: estimatedDuration,
    ));

    await _speakCurrentText();
  }

  Future<void> _speakCurrentText() async {
    final text = _currentText;
    if (text == null || text.isEmpty) {
      DebugLog().log('[Handler] speakCurrentText: texte vide');
      return;
    }

    // État: chargement (configuration de la voix)
    _broadcastState(
      playing: true,
      processingState: audio_svc.AudioProcessingState.loading,
      controls: const [
        audio_svc.MediaControl.pause,
        audio_svc.MediaControl.stop,
      ],
      position: Duration.zero,
    );

    // Configurer la voix
    try {
      await TtsService.configureVoiceForTts(_tts, _currentLanguage);
      DebugLog().log('[Handler] voix configurée');
    } catch (e) {
      DebugLog().log('[Handler] erreur voix: $e');
    }

    await _tts.setSpeechRate(_speechRate);
    DebugLog().log('[Handler] _tts.speak()');
    await _tts.speak(text);
    // Le startHandler sera appelé par flutter_tts → broadcast ready+playing
  }

  @override
  Future<void> play() async {
    await _ready;
    if ((_currentText ?? '').isEmpty) return;

    DebugLog().log('[Handler] play paused=$_wasPaused');
    if (_wasPaused) {
      _ignoringCancel = true;
      await _tts.stop();
      _wasPaused = false;
    }

    await _speakCurrentText();
  }

  @override
  Future<void> pause() async {
    await _ready;
    DebugLog().log('[Handler] pause → stop TTS');
    _wasPaused = true;

    // Broadcast AVANT d'arrêter TTS (sinon cancelHandler interfère)
    _broadcastState(
      playing: false,
      processingState: audio_svc.AudioProcessingState.ready,
      controls: const [
        audio_svc.MediaControl.play,
        audio_svc.MediaControl.stop,
      ],
      position: Duration.zero,
    );

    _ignoringCancel = true;
    await _tts.stop();
  }

  @override
  Future<void> stop() async {
    await _ready;
    DebugLog().log('[Handler] stop');
    _wasPaused = false;

    _ignoringCancel = true;
    await _tts.stop();

    // idle + aucun contrôle → notification disparaît
    _broadcastState(
      playing: false,
      processingState: audio_svc.AudioProcessingState.idle,
      controls: const [],
      position: Duration.zero,
    );
  }

  /// Changer la vitesse de lecture.
  Future<void> setSpeed(double speed) async {
    await _ready;
    _speechRate = speed;
    DebugLog().log('[Handler] setSpeed=$speed');
    await _tts.setSpeechRate(speed);
  }
}
