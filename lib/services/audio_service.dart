import 'dart:async';
import 'package:audio_service/audio_service.dart' as audio_svc;
import 'package:flutter/foundation.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/audio_state.dart';
import '../models/point.dart' as models;
import 'audio_handler.dart';
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
  final AudioPlayer _player = AudioPlayer();

  TtsService get tts => _tts;
  EdgeTtsService get edgeTts => _edgeTts;

  bool _isInitialized = false;
  StreamSubscription<TtsState>? _ttsStateSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;
  AppAudioHandler? _audioHandler;
  Timer? _positionTimer;
  bool _shouldResumeAfterInterruption = false;

  bool _isPlaying = false;
  bool _isPaused = false;
  bool _usingEdgeTts = false;
  double _speed = 1.0;
  String? _currentText;
  AudioState _state = const AudioState(
    playState: AudioPlayState.stopped,
    position: Duration.zero,
    duration: Duration.zero,
    speed: 1.0,
  );

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  bool get usingEdgeTts => _usingEdgeTts;
  double get speed => _speed;
  AudioState get currentState => _state;

  final _stateController = StreamController<AudioState>.broadcast();
  Stream<AudioState> get stateStream => _stateController.stream;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      _audioHandler =
          await audio_svc.AudioService.init(
                builder: () => AppAudioHandler(
                  onPlayRequested: _resumeFromSystemControls,
                  onPauseRequested: () => pause(),
                  onStopRequested: () => stop(),
                ),
                config: const audio_svc.AudioServiceConfig(
                  androidNotificationChannelId:
                      'com.appvoyage.audio.playback',
                  androidNotificationChannelName: 'Lecture audio',
                  androidNotificationIcon: 'mipmap/ic_launcher',
                  androidNotificationOngoing: false,
                  androidStopForegroundOnPause: false,
                ),
              )
              as AppAudioHandler;
      debugPrint('[AudioService] audio_service init success');
    } catch (e, stackTrace) {
      debugPrint('[AudioService] audio_service init failed: $e');
      debugPrint('$stackTrace');
      _audioHandler = null;
    }

    await _tts.init();
    await _configureAudioSession();
    await _loadSavedSpeed();
    await _applySpeed();

    _ttsStateSubscription = _tts.stateStream.listen(_handleTtsState);
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (!_usingEdgeTts) return; // Seulement quand on utilise Edge TTS
      if (state.processingState == ProcessingState.completed) {
        _finishPlayback(resetPosition: true);
      } else if (state.playing) {
        _setPlaybackState(AudioPlayState.playing);
      } else if (!state.playing &&
          state.processingState == ProcessingState.ready) {
        _setPlaybackState(AudioPlayState.paused);
      }
    });
    _emitState();
  }

  Future<void> _setSessionActive(bool active) async {
    final session = await AudioSession.instance;
    await session.setActive(active);
    debugPrint('[AudioService] audio_session active=$active');
  }

  Future<void> _configureAudioSession() async {
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
    _interruptionSubscription = session.interruptionEventStream.listen((event) {
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
    _currentText = text;
    _audioHandler?.setCurrentMediaItem(
      poiName: poiName,
      duration: estimatedDuration,
      scriptId: resolvedScriptId,
    );

    _state = _state.copyWith(
      playState: AudioPlayState.loading,
      position: Duration.zero,
      duration: estimatedDuration,
      speed: _speed,
      currentPoiName: poiName,
      currentPoi: poi,
      currentScriptId: resolvedScriptId,
    );
    _emitState();

    await stop(keepMetadata: true, emitState: false);
    await _setSessionActive(true);

    _state = _state.copyWith(
      playState: AudioPlayState.loading,
      position: Duration.zero,
      duration: estimatedDuration,
      speed: _speed,
      currentPoiName: poiName,
      currentPoi: poi,
      currentScriptId: resolvedScriptId,
    );
    _emitState();

    final audioPath = await _edgeTts.getAudioPath(
      scriptId: resolvedScriptId,
      text: text,
      language: language,
    );

    if (audioPath != null) {
      _usingEdgeTts = true;
      try {
        await _player.setFilePath(audioPath);
        final actualDuration = _player.duration;
        if (actualDuration != null) {
          _state = _state.copyWith(duration: actualDuration);
          _audioHandler?.setCurrentMediaItem(
            poiName: poiName,
            duration: actualDuration,
            scriptId: resolvedScriptId,
          );
          _emitState();
        }
        await _player.play();
        return;
      } catch (_) {
        _usingEdgeTts = false;
      }
    }

    _usingEdgeTts = false;
    await _tts.speak(text, language: language);
  }

  void _handleTtsState(TtsState state) {
    if (_usingEdgeTts) return;

    switch (state) {
      case TtsState.playing:
        _setPlaybackState(AudioPlayState.playing);
        break;
      case TtsState.paused:
        _setPlaybackState(AudioPlayState.paused);
        break;
      case TtsState.stopped:
        _finishPlayback(resetPosition: true);
        break;
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

  void _setPlaybackState(AudioPlayState playState) {
    _isPlaying = playState == AudioPlayState.playing;
    _isPaused = playState == AudioPlayState.paused;

    if (playState == AudioPlayState.playing) {
      _startPositionTimer();
    } else {
      _stopPositionTimer();
    }

    _state = _state.copyWith(
      playState: playState,
      speed: _speed,
    );
    _emitState();
  }

  void _finishPlayback({required bool resetPosition}) {
    unawaited(_setSessionActive(false));
    _stopPositionTimer();
    _isPlaying = false;
    _isPaused = false;
    _usingEdgeTts = false;
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
    _audioHandler?.updatePlaybackState(_state);
    if (!_stateController.isClosed) {
      debugPrint('[AudioService] state=${_state.playState} poi=${_state.currentPoiName} usingEdge=$_usingEdgeTts');
      _stateController.add(_state);
    }
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

  Future<void> _applySpeed() async {
    await _player.setSpeed(_speed);
    await _tts.setSpeechRate(_speechRateForSpeed(_speed));
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
    if (_currentText != null) {
      _audioHandler?.setCurrentMediaItem(
        poiName: _state.currentPoiName,
        duration: updatedDuration,
        scriptId: _state.currentScriptId,
      );
    }
    _emitState();
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
    await _setSessionActive(false);
    if (_usingEdgeTts) {
      await _player.pause();
    } else {
      await _tts.pause();
    }
  }

  Future<void> resume() async {
    await init();
    await _setSessionActive(true);
    if (_usingEdgeTts) {
      await _player.play();
    } else {
      await _tts.resume();
    }
  }

  Future<void> _resumeFromSystemControls() async {
    if (_state.playState == AudioPlayState.stopped) {
      return;
    }
    await resume();
  }

  Future<void> stop({
    bool keepMetadata = false,
    bool emitState = true,
  }) async {
    _shouldResumeAfterInterruption = false;
    await _setSessionActive(false);
    if (_usingEdgeTts) {
      await _player.stop();
    }
    await _tts.stop();
    _stopPositionTimer();
    _isPlaying = false;
    _isPaused = false;
    _usingEdgeTts = false;
    _state = _state.copyWith(
      playState: AudioPlayState.stopped,
      position: Duration.zero,
      clearCurrentPoiName: !keepMetadata,
      clearCurrentPoi: !keepMetadata,
      clearCurrentScriptId: !keepMetadata,
    );
    if (!keepMetadata) {
      _currentText = null;
      _audioHandler?.clearMediaItem();
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
    _playerStateSubscription?.cancel();
    _ttsStateSubscription?.cancel();
    _player.dispose();
    _tts.dispose();
    _stateController.close();
    _isInitialized = false;
  }
}
