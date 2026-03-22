import 'dart:async';

import 'package:audio_service/audio_service.dart' as audio_svc;
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/audio_state.dart';
import '../models/point.dart' as models;
import 'audio_handler.dart';
import 'debug_log.dart';
import 'edge_tts_service.dart';
import 'supabase_service.dart';
import 'tts_service.dart';

/// Service audio principal — coordination entre UI, session média et TTS.
class AudioService {
  AudioService._internal();

  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  static const String _speedPrefKey = 'tts_speed';
  static const Duration _positionTick = Duration(milliseconds: 500);
  static final Map<double, double> _speedToSpeechRate = {
    0.75: 0.39,
    1.0: 0.52,
    1.25: 0.65,
    1.5: 0.78,
  };

  final TtsService _tts = TtsService();
  final EdgeTtsService _edgeTts = EdgeTtsService();
  final SupabaseService _supabase = SupabaseService();

  TtsService get tts => _tts;
  EdgeTtsService get edgeTts => _edgeTts;

  bool _isInitialized = false;
  Future<void>? _initFuture;
  audio_svc.AudioHandler? _audioHandler;
  StreamSubscription<audio_svc.PlaybackState>? _handlerPlaybackSubscription;
  StreamSubscription<audio_svc.MediaItem?>? _handlerMediaItemSubscription;
  StreamSubscription<TtsState>? _ttsStateSubscription;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;
  Timer? _positionTimer;
  bool _shouldResumeAfterInterruption = false;
  bool _ttsInitialized = false;

  bool _isPlaying = false;
  bool _isPaused = false;
  double _speed = 1.0;
  String? _currentText;
  String? _currentLanguage;
  AudioState _state = const AudioState(
    playState: AudioPlayState.stopped,
    position: Duration.zero,
    duration: Duration.zero,
    speed: 1.0,
  );

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  bool get usingEdgeTts => false;
  double get speed => _speed;
  AudioState get currentState => _state;

  final _stateController = StreamController<AudioState>.broadcast();
  Stream<AudioState> get stateStream => _stateController.stream;

  static Future<void> bootstrap() async {
    await _instance.init();
  }

  Future<void> init() async {
    if (_isInitialized) return;
    final existingFuture = _initFuture;
    if (existingFuture != null) {
      await existingFuture;
      return;
    }

    final initFuture = _performInit();
    _initFuture = initFuture;
    try {
      await initFuture;
    } finally {
      _initFuture = null;
    }
  }

  Future<void> _performInit() async {
    await _initFallbackTts();
    await _initAudioHandler();
    await _configureAudioSession();
    await _loadSavedSpeed();
    await _applySpeed(emitState: false);
    _isInitialized = true;
    _emitState();
  }

  Future<void> _initFallbackTts() async {
    if (_ttsInitialized) return;

    await _tts.init();
    await _ttsStateSubscription?.cancel();
    _ttsStateSubscription = _tts.stateStream.listen(_handleFallbackTtsState);
    _ttsInitialized = true;
    DebugLog().log('[AudioService] TTS fallback initialisé ✅');
  }

  Future<void> _initAudioHandler() async {
    if (_audioHandler != null) return;

    try {
      _audioHandler = await audio_svc.AudioService.init(
        builder: () => AppAudioHandler(),
        config: const audio_svc.AudioServiceConfig(
          androidNotificationChannelId: 'com.appvoyage.app_voyage.audio',
          androidNotificationChannelName: 'Lecture audio',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );
    } catch (error, stackTrace) {
      DebugLog().log('[AudioService] échec init audio_service: $error');
      debugPrintStack(stackTrace: stackTrace);
      _audioHandler = null;
      return;
    }

    await _handlerPlaybackSubscription?.cancel();
    _handlerPlaybackSubscription = _audioHandler!.playbackState.listen(
      _handleHandlerPlaybackState,
    );

    await _handlerMediaItemSubscription?.cancel();
    _handlerMediaItemSubscription = _audioHandler!.mediaItem.listen(
      _handleHandlerMediaItem,
    );
    DebugLog().log('[AudioService] audio_service handler initialisé ✅');
  }

  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      ));

      await _interruptionSubscription?.cancel();
      _interruptionSubscription =
          session.interruptionEventStream.listen((event) {
            if (event.begin) {
              _shouldResumeAfterInterruption = _isPlaying;
              if (_isPlaying || _isPaused) {
                unawaited(pause());
              }
              return;
            }

            if (event.type == AudioInterruptionType.pause &&
                _shouldResumeAfterInterruption &&
                _isPaused) {
              _shouldResumeAfterInterruption = false;
              unawaited(resume());
            } else {
              _shouldResumeAfterInterruption = false;
            }
          });
    } catch (error, stackTrace) {
      DebugLog().log('[AudioService] échec config audio session: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> playScript(String scriptId, {String? poiName}) async {
    await init();
    final script = await _supabase.getScript(scriptId);
    if (script == null) return;

    final text = script['content'] as String;
    final language = script['language'] as String? ?? 'fr';

    await play(
      scriptId: scriptId,
      text: text,
      language: language,
      poiName: poiName,
    );
  }

  Future<void> playText(
    String text, {
    String language = 'fr',
    String? poiName,
    models.Point? poi,
  }) async {
    await play(
      scriptId: null,
      text: text,
      language: language,
      poiName: poiName,
      poi: poi,
    );
  }

  Future<void> play({
    required String text,
    required String language,
    String? scriptId,
    String? poiName,
    models.Point? poi,
  }) async {
    await init();
    final resolvedScriptId = scriptId ?? 'preview-${text.hashCode}';
    final estimatedDuration = _estimateDuration(text);
    final handler = _audioHandler;

    await stop(keepMetadata: true, emitState: false);
    _currentText = text;
    _currentLanguage = language;
    _state = _state.copyWith(
      playState: AudioPlayState.stopped,
      position: Duration.zero,
      duration: estimatedDuration,
      speed: _speed,
      currentPoiName: poiName,
      currentPoi: poi,
      currentScriptId: resolvedScriptId,
    );
    _emitState();

    try {
      if (handler != null) {
        await handler.customAction('speak', {
          'text': text,
          'language': language,
          'title': poiName ?? 'Lecture audio',
          'mediaId': resolvedScriptId,
          'durationMs': estimatedDuration.inMilliseconds,
        });
        return;
      }

      await _tts.setSpeechRate(_speechRateForSpeed(_speed));
      await _tts.speak(text, language: language);
    } catch (error, stackTrace) {
      DebugLog().log('[AudioService] échec lecture TTS: $error');
      debugPrintStack(stackTrace: stackTrace);
      _finishPlayback(resetPosition: true);
    }
  }

  Duration _estimateDuration(String text) {
    final words = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
    final seconds = ((words * 0.4) / _speed).round();
    return Duration(seconds: seconds <= 0 ? 1 : seconds);
  }

  void _handleHandlerPlaybackState(audio_svc.PlaybackState playbackState) {
    final nextPlayState = _mapHandlerPlayState(playbackState);
    final nextPosition = nextPlayState == AudioPlayState.stopped
        ? Duration.zero
        : _state.position;

    _isPlaying = nextPlayState == AudioPlayState.playing;
    _isPaused = nextPlayState == AudioPlayState.paused;

    if (_isPlaying) {
      _startPositionTimer();
    } else {
      _stopPositionTimer();
    }

    _state = _state.copyWith(
      playState: nextPlayState,
      position: nextPosition,
      speed: _speed,
    );
    _emitState();
  }

  void _handleHandlerMediaItem(audio_svc.MediaItem? item) {
    if (item == null) return;
    _state = _state.copyWith(
      currentPoiName: item.title,
      currentScriptId: item.id,
      duration: item.duration ?? _state.duration,
    );
    _emitState();
  }

  void _handleFallbackTtsState(TtsState ttsState) {
    if (_audioHandler != null) return;

    late final AudioPlayState nextPlayState;
    switch (ttsState) {
      case TtsState.playing:
        nextPlayState = AudioPlayState.playing;
        break;
      case TtsState.paused:
        nextPlayState = AudioPlayState.paused;
        break;
      case TtsState.stopped:
        nextPlayState = AudioPlayState.stopped;
        break;
    }

    _isPlaying = nextPlayState == AudioPlayState.playing;
    _isPaused = nextPlayState == AudioPlayState.paused;

    if (_isPlaying) {
      _startPositionTimer();
    } else {
      _stopPositionTimer();
    }

    _state = _state.copyWith(
      playState: nextPlayState,
      position: nextPlayState == AudioPlayState.stopped
          ? Duration.zero
          : _state.position,
      speed: _speed,
    );
    _emitState();
  }

  AudioPlayState _mapHandlerPlayState(audio_svc.PlaybackState playbackState) {
    if (playbackState.processingState == audio_svc.AudioProcessingState.idle ||
        playbackState.processingState ==
            audio_svc.AudioProcessingState.completed) {
      return AudioPlayState.stopped;
    }
    if (playbackState.processingState ==
            audio_svc.AudioProcessingState.loading ||
        playbackState.processingState ==
            audio_svc.AudioProcessingState.buffering) {
      return AudioPlayState.stopped;
    }
    if (playbackState.playing) {
      return AudioPlayState.playing;
    }
    return AudioPlayState.paused;
  }

  void _finishPlayback({required bool resetPosition}) {
    _stopPositionTimer();
    _isPlaying = false;
    _isPaused = false;
    _state = _state.copyWith(
      playState: AudioPlayState.stopped,
      position: resetPosition ? Duration.zero : _state.position,
    );
    _emitState();
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(_positionTick, (_) {
      final nextPosition = _state.position + _positionTick;
      final cappedPosition = nextPosition > _state.duration
          ? _state.duration
          : nextPosition;
      _state = _state.copyWith(position: cappedPosition);
      _emitState();
    });
  }

  void _stopPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  void _emitState() {
    if (_stateController.isClosed) return;
    DebugLog().log('[AudioService] state=${_state.playState} poi=${_state.currentPoiName}');
    _stateController.add(_state);
  }

  Future<void> _loadSavedSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSpeed = prefs.getDouble(_speedPrefKey);
    _speed = _normalizeSpeed(savedSpeed);
    _state = _state.copyWith(speed: _speed);
  }

  double _normalizeSpeed(double? speed) {
    if (speed == null) return 1.0;
    for (final value in _speedToSpeechRate.keys) {
      if ((value - speed).abs() < 0.001) {
        return value;
      }
    }
    return 1.0;
  }

  double _speechRateForSpeed(double speed) {
    return _speedToSpeechRate[_normalizeSpeed(speed)] ?? _speedToSpeechRate[1.0]!;
  }

  Future<void> _applySpeed({bool emitState = true}) async {
    final speechRate = _speechRateForSpeed(_speed);
    if (_audioHandler != null) {
      await _audioHandler!.customAction('setSpeechRate', {'rate': speechRate});
    } else {
      await _tts.setSpeechRate(speechRate);
    }

    final updatedDuration = _currentText == null
        ? _state.duration
        : _estimateDuration(_currentText!);
    final cappedPosition = _state.position > updatedDuration
        ? updatedDuration
        : _state.position;
    _state = _state.copyWith(
      speed: _speed,
      duration: updatedDuration,
      position: cappedPosition,
    );
    if (emitState) {
      _emitState();
    }
  }

  Future<void> setSpeed(double speed) async {
    await init();
    _speed = _normalizeSpeed(speed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_speedPrefKey, _speed);
    await _applySpeed();
  }

  Future<void> setSpeechRate(double rate) async {
    final entry = _speedToSpeechRate.entries.firstWhere(
      (item) => (item.value - rate).abs() < 0.001,
      orElse: () => const MapEntry(1.0, 0.52),
    );
    await setSpeed(entry.key);
  }

  Future<void> pause() async {
    await init();
    if (_audioHandler != null) {
      await _audioHandler!.pause();
      return;
    }
    await _tts.pause();
  }

  Future<void> resume() async {
    if (_state.playState == AudioPlayState.stopped) {
      await replayCurrent();
      return;
    }
    await init();
    if (_audioHandler != null) {
      await _audioHandler!.play();
      return;
    }
    await _tts.resume();
  }

  Future<void> replayCurrent() async {
    final text = _currentText;
    if (text == null || text.isEmpty) return;
    await play(
      text: text,
      language: _currentLanguage ?? 'fr',
      scriptId: _state.currentScriptId,
      poiName: _state.currentPoiName,
      poi: _state.currentPoi,
    );
  }

  Future<void> stop({
    bool keepMetadata = false,
    bool emitState = true,
  }) async {
    await init();
    _shouldResumeAfterInterruption = false;

    if (_audioHandler != null) {
      await _audioHandler!.stop();
    } else {
      await _tts.stop();
    }

    _stopPositionTimer();
    _isPlaying = false;
    _isPaused = false;
    _state = _state.copyWith(
      playState: AudioPlayState.stopped,
      position: Duration.zero,
      clearCurrentPoiName: !keepMetadata,
      clearCurrentPoi: !keepMetadata,
      clearCurrentScriptId: !keepMetadata,
    );
    if (!keepMetadata) {
      _currentText = null;
      _currentLanguage = null;
    }
    if (emitState) {
      _emitState();
    }
  }

  Future<void> downloadCityAudios({
    required String cityId,
    required void Function(int current, int total) onProgress,
  }) async {
    for (final lang in ['fr', 'en', 'es']) {
      final scripts = await SupabaseService.getScriptsForCity(cityId, lang);
      await _edgeTts.downloadAll(
        scripts: scripts,
        onProgress: onProgress,
      );
    }
  }

  Future<double> getCacheSizeMB() async {
    final bytes = await _edgeTts.getCacheSize();
    return bytes / (1024 * 1024);
  }

  Future<void> clearCache() async {
    await _edgeTts.clearCache();
  }

  void dispose() {
    _positionTimer?.cancel();
    _interruptionSubscription?.cancel();
    _handlerPlaybackSubscription?.cancel();
    _handlerMediaItemSubscription?.cancel();
    _ttsStateSubscription?.cancel();
    _stateController.close();
    _isInitialized = false;
    _initFuture = null;
    _audioHandler = null;
    _ttsInitialized = false;
  }
}
