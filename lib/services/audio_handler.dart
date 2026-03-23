import 'dart:async';

import 'package:audio_service/audio_service.dart' as audio_svc;
import 'package:flutter_tts/flutter_tts.dart';

import '../models/point.dart' as models;
import 'debug_log.dart';
import 'tts_service.dart';

/// Handler audio TTS unique.
/// Toute l'UI doit lire l'etat depuis `playbackState`.
class AppAudioHandler extends audio_svc.BaseAudioHandler {
  AppAudioHandler() {
    _ready = _configureTts();
    playbackState.add(
      playbackState.value.copyWith(
        controls: const [audio_svc.MediaControl.play],
        systemActions: const {audio_svc.MediaAction.play, audio_svc.MediaAction.pause, audio_svc.MediaAction.stop},
        processingState: audio_svc.AudioProcessingState.idle,
        playing: false,
        updatePosition: Duration.zero,
      ),
    );
  }

  final FlutterTts _tts = FlutterTts();
  late final Future<void> _ready;

  Timer? _positionTimer;
  String? _currentText;
  String _currentLanguage = 'fr';
  String _currentPoiName = 'Lecture audio';
  models.Point? _currentPoi;
  Duration _estimatedDuration = Duration.zero;
  Duration _position = Duration.zero;
  double _speechRate = 0.52;
  bool _wasPaused = false;
  bool _ignoringCancel = false;

  String? get currentText => _currentText;
  String get currentLanguage => _currentLanguage;
  String get currentPoiName => _currentPoiName;
  models.Point? get currentPoi => _currentPoi;
  Duration get estimatedDuration => _estimatedDuration;

  Future<void> _configureTts() async {
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.05);
    await _tts.setSpeechRate(_speechRate);

    _tts.setStartHandler(() {
      DebugLog().log('[AppAudioHandler] start');
      _startPositionUpdates();
      playbackState.add(
        playbackState.value.copyWith(
          playing: true,
          controls: const [
            audio_svc.MediaControl.pause,
            audio_svc.MediaControl.stop,
          ],
          systemActions: const {audio_svc.MediaAction.play, audio_svc.MediaAction.pause, audio_svc.MediaAction.stop},
          processingState: audio_svc.AudioProcessingState.ready,
          androidCompactActionIndices: const [0, 1],
          updatePosition: _position,
        ),
      );
    });

    _tts.setCompletionHandler(() {
      DebugLog().log('[AppAudioHandler] completion');
      _stopPositionUpdates();
      _position = _estimatedDuration;
      _wasPaused = false;
      playbackState.add(
        playbackState.value.copyWith(
          playing: false,
          controls: const [audio_svc.MediaControl.play],
          systemActions: const {audio_svc.MediaAction.play, audio_svc.MediaAction.pause, audio_svc.MediaAction.stop},
          processingState: audio_svc.AudioProcessingState.completed,
          androidCompactActionIndices: const [0],
          updatePosition: _position,
        ),
      );
    });

    _tts.setCancelHandler(() {
      if (_ignoringCancel) {
        _ignoringCancel = false;
        return;
      }

      DebugLog().log('[AppAudioHandler] cancel paused=$_wasPaused');
      _stopPositionUpdates();
      playbackState.add(
        playbackState.value.copyWith(
          playing: false,
          controls: _wasPaused
              ? const [
                  audio_svc.MediaControl.play,
                  audio_svc.MediaControl.stop,
                ]
              : const [audio_svc.MediaControl.play],
          systemActions: const {audio_svc.MediaAction.play, audio_svc.MediaAction.pause, audio_svc.MediaAction.stop},
          processingState: _wasPaused
              ? audio_svc.AudioProcessingState.ready
              : audio_svc.AudioProcessingState.idle,
          updatePosition: _position,
        ),
      );
    });

    _tts.setPauseHandler(() {
      DebugLog().log('[AppAudioHandler] pause');
      _stopPositionUpdates();
      _wasPaused = true;
      playbackState.add(
        playbackState.value.copyWith(
          playing: false,
          controls: const [
            audio_svc.MediaControl.play,
            audio_svc.MediaControl.stop,
          ],
          systemActions: const {audio_svc.MediaAction.play, audio_svc.MediaAction.pause, audio_svc.MediaAction.stop},
          processingState: audio_svc.AudioProcessingState.ready,
          androidCompactActionIndices: const [0, 1],
          updatePosition: _position,
        ),
      );
    });

    _tts.setErrorHandler((message) {
      DebugLog().log('[AppAudioHandler] error=$message');
      _stopPositionUpdates();
      _wasPaused = false;
      playbackState.add(
        playbackState.value.copyWith(
          playing: false,
          controls: const [audio_svc.MediaControl.play],
          systemActions: const {audio_svc.MediaAction.play, audio_svc.MediaAction.pause, audio_svc.MediaAction.stop},
          processingState: audio_svc.AudioProcessingState.idle,
          androidCompactActionIndices: const [0],
          updatePosition: Duration.zero,
        ),
      );
    });
  }

  Future<void> speakText(
    String text,
    String language,
    String poiName,
    models.Point? poi,
    Duration estimatedDuration,
  ) async {
    await _ready;

    final currentPlayback = playbackState.value;
    if (currentPlayback.playing ||
        currentPlayback.processingState ==
            audio_svc.AudioProcessingState.ready) {
      _ignoringCancel = true;
      await _tts.stop();
    }

    _currentText = text;
    _currentLanguage = language;
    _currentPoiName = poiName.trim().isEmpty ? 'Lecture audio' : poiName.trim();
    _currentPoi = poi;
    _estimatedDuration = estimatedDuration;
    _position = Duration.zero;
    _wasPaused = false;

    mediaItem.add(
      audio_svc.MediaItem(
        id: 'tts-${text.hashCode}',
        album: 'App Voyage',
        title: _currentPoiName,
        artist: 'Guide audio',
        duration: estimatedDuration,
      ),
    );

    await _speakCurrentText();
  }

  Future<void> _speakCurrentText() async {
    final text = _currentText;
    if (text == null || text.isEmpty) return;

    _stopPositionUpdates();
    _position = Duration.zero;
    playbackState.add(
      playbackState.value.copyWith(
        playing: true,
        controls: const [
          audio_svc.MediaControl.pause,
          audio_svc.MediaControl.stop,
        ],
        systemActions: const {audio_svc.MediaAction.play, audio_svc.MediaAction.pause, audio_svc.MediaAction.stop},
        processingState: audio_svc.AudioProcessingState.loading,
          androidCompactActionIndices: const [0, 1],
        updatePosition: Duration.zero,
      ),
    );

    await TtsService.configureVoiceForTts(_tts, _currentLanguage);
    await _tts.setSpeechRate(_speechRate);
    await _tts.speak(text);
  }

  @override
  Future<void> play() async {
    await _ready;
    if ((_currentText ?? '').isEmpty) return;

    DebugLog().log('[AppAudioHandler] play paused=$_wasPaused');
    if (_wasPaused) {
      _ignoringCancel = true;
      await _tts.stop();
      _position = Duration.zero;
      _wasPaused = false;
    }

    await _speakCurrentText();
  }

  @override
  Future<void> pause() async {
    await _ready;
    DebugLog().log('[AppAudioHandler] pause -> stop');
    _wasPaused = true;
    _stopPositionUpdates();
    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        controls: const [
          audio_svc.MediaControl.play,
          audio_svc.MediaControl.stop,
        ],
        systemActions: const {audio_svc.MediaAction.play, audio_svc.MediaAction.pause, audio_svc.MediaAction.stop},
        processingState: audio_svc.AudioProcessingState.ready,
          androidCompactActionIndices: const [0, 1],
        updatePosition: _position,
      ),
    );
    await _tts.stop();
  }

  @override
  Future<void> stop() async {
    await _ready;
    DebugLog().log('[AppAudioHandler] stop');
    _wasPaused = false;
    _position = Duration.zero;
    _stopPositionUpdates();
    await _tts.stop();
    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        controls: const [],
        systemActions: const {},
        processingState: audio_svc.AudioProcessingState.idle,
          androidCompactActionIndices: const [],
        updatePosition: Duration.zero,
      ),
    );
  }

  Future<void> setSpeed(double speed) async {
    await _ready;
    _speechRate = speed;
    DebugLog().log('[AppAudioHandler] setSpeed rate=$speed');
    await _tts.setSpeechRate(speed);
    playbackState.add(
      playbackState.value.copyWith(
        updatePosition: _position,
      ),
    );
  }

  void _startPositionUpdates() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      final nextPosition = _position + const Duration(milliseconds: 500);
      _position = nextPosition > _estimatedDuration
          ? _estimatedDuration
          : nextPosition;
      playbackState.add(
        playbackState.value.copyWith(
          updatePosition: _position,
        ),
      );
    });
  }

  void _stopPositionUpdates() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }
}
