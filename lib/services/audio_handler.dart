import 'package:audio_service/audio_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'tts_service.dart';

/// Handler audio dédié au TTS pour exposer une vraie session média système.
class AppAudioHandler extends BaseAudioHandler with SeekHandler {
  final FlutterTts _tts = FlutterTts();
  late final Future<void> _ready;

  bool _isPlaying = false;
  bool _isPaused = false;
  String? _currentText;
  String _currentLanguage = 'fr';
  String _currentTitle = 'Lecture audio';
  Duration _currentDuration = Duration.zero;
  double _speechRate = 0.52;

  AppAudioHandler() {
    _ready = _configureTts();
    _publishPlaybackState(
      processingState: AudioProcessingState.idle,
      playing: false,
    );
  }

  Future<void> _configureTts() async {
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.05);
    await _tts.setSpeechRate(_speechRate);

    _tts.setStartHandler(() {
      _isPlaying = true;
      _isPaused = false;
      _publishPlaybackState(
        processingState: AudioProcessingState.ready,
        playing: true,
      );
    });

    _tts.setCompletionHandler(() {
      _isPlaying = false;
      _isPaused = false;
      _publishPlaybackState(
        processingState: AudioProcessingState.idle,
        playing: false,
      );
    });

    _tts.setCancelHandler(() {
      _isPlaying = false;
      _isPaused = false;
      _publishPlaybackState(
        processingState: AudioProcessingState.idle,
        playing: false,
      );
    });

    _tts.setPauseHandler(() {
      _isPlaying = false;
      _isPaused = true;
      _publishPlaybackState(
        processingState: AudioProcessingState.ready,
        playing: false,
      );
    });

    _tts.setContinueHandler(() {
      _isPlaying = true;
      _isPaused = false;
      _publishPlaybackState(
        processingState: AudioProcessingState.ready,
        playing: true,
      );
    });

    _tts.setErrorHandler((message) {
      _isPlaying = false;
      _isPaused = false;
      _publishPlaybackState(
        processingState: AudioProcessingState.idle,
        playing: false,
      );
    });
  }

  Future<void> speakText({
    required String text,
    required String language,
    String? title,
    String? mediaId,
    Duration? duration,
  }) async {
    await _ready;
    _currentText = text;
    _currentLanguage = language;
    _currentTitle = title?.trim().isNotEmpty == true ? title!.trim() : 'Lecture audio';
    _currentDuration = duration ?? Duration.zero;

    mediaItem.add(
      MediaItem(
        id: mediaId ?? 'tts-${text.hashCode}',
        album: 'App Voyage',
        title: _currentTitle,
        artist: 'Marco',
        duration: _currentDuration == Duration.zero ? null : _currentDuration,
      ),
    );

    _publishPlaybackState(
      processingState: AudioProcessingState.ready,
      playing: false,
    );

    await TtsService.configureVoiceForTts(_tts, language);
    await _tts.setSpeechRate(_speechRate);
    await _tts.speak(text);
  }

  Future<void> configureSpeechRate(double rate) async {
    await _ready;
    _speechRate = rate;
    await _tts.setSpeechRate(rate);
    _publishPlaybackState(
      processingState: _isPlaying || _isPaused
          ? AudioProcessingState.ready
          : AudioProcessingState.idle,
      playing: _isPlaying,
    );
  }

  @override
  Future<void> play() async {
    await _ready;
    if ((_currentText ?? '').isEmpty) return;
    await TtsService.configureVoiceForTts(_tts, _currentLanguage);
    await _tts.setSpeechRate(_speechRate);
    await _tts.speak(_currentText!);
  }

  @override
  Future<void> pause() async {
    await _ready;
    await _tts.pause();
  }

  @override
  Future<void> stop() async {
    await _ready;
    await _tts.stop();
    _isPlaying = false;
    _isPaused = false;
    _publishPlaybackState(
      processingState: AudioProcessingState.idle,
      playing: false,
    );
  }

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case 'speak':
        final payload = extras ?? const <String, dynamic>{};
        final durationMs = payload['durationMs'] as int?;
        await speakText(
          text: payload['text'] as String? ?? '',
          language: payload['language'] as String? ?? 'fr',
          title: payload['title'] as String?,
          mediaId: payload['mediaId'] as String?,
          duration: durationMs == null ? null : Duration(milliseconds: durationMs),
        );
        return true;
      case 'setSpeechRate':
        final rawRate = extras?['rate'];
        final rate = rawRate is num ? rawRate.toDouble() : 0.52;
        await configureSpeechRate(rate);
        return true;
      default:
        return await super.customAction(name, extras);
    }
  }

  void _publishPlaybackState({
    required AudioProcessingState processingState,
    required bool playing,
  }) {
    final controls = <MediaControl>[
      if (!playing) MediaControl.play,
      if (playing) MediaControl.pause,
      MediaControl.stop,
    ];

    playbackState.add(
      PlaybackState(
        controls: controls,
        androidCompactActionIndices: List<int>.generate(controls.length, (index) => index),
        processingState: processingState,
        playing: playing,
        updatePosition: Duration.zero,
        bufferedPosition: Duration.zero,
        speed: 1.0,
      ),
    );
  }
}
