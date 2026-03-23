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

/// Service audio simplifie.
/// Le handler expose l'etat de lecture, ce service ne fait que le relayer.
class AudioService {
  AudioService._internal();

  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  static const String _speedPrefKey = 'tts_speed';
  static final Map<double, double> _speedToSpeechRate = {
    0.75: 0.39,
    1.0: 0.52,
    1.25: 0.65,
    1.5: 0.78,
  };

  final TtsService _fallbackTts = TtsService();
  final EdgeTtsService _edgeTts = EdgeTtsService();
  final SupabaseService _supabase = SupabaseService();
  final StreamController<AudioState> _stateController =
      StreamController<AudioState>.broadcast();

  AppAudioHandler? _audioHandler;
  bool _isInitialized = false;
  Future<void>? _initFuture;
  bool _usingFallbackTts = false;
  double _speed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _currentText;
  String _currentLanguage = 'fr';
  String? _currentPoiName;
  models.Point? _currentPoi;
  String? _currentScriptId;
  audio_svc.PlaybackState _playbackState = audio_svc.PlaybackState();
  AudioState _state = const AudioState(
    playState: AudioPlayState.stopped,
    position: Duration.zero,
    duration: Duration.zero,
    speed: 1.0,
  );

  StreamSubscription<audio_svc.PlaybackState>? _playbackSubscription;
  StreamSubscription<audio_svc.MediaItem?>? _mediaItemSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<TtsState>? _fallbackStateSubscription;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;

  EdgeTtsService get edgeTts => _edgeTts;
  TtsService get tts => _fallbackTts;
  double get speed => _speed;
  AudioState get currentState => _state;
  Stream<AudioState> get stateStream => _stateController.stream;

  Future<void> init() async {
    if (_isInitialized) return;
    final existingFuture = _initFuture;
    if (existingFuture != null) {
      await existingFuture;
      return;
    }

    _initFuture = _performInit();
    try {
      await _initFuture;
    } finally {
      _initFuture = null;
    }
  }

  Future<void> _performInit() async {
    await _loadSavedSpeed();
    await _configureAudioSession();

    try {
      final handler = await audio_svc.AudioService.init(
        builder: () => AppAudioHandler(),
        config: const audio_svc.AudioServiceConfig(
          androidNotificationChannelId: 'com.appvoyage.app_voyage.audio',
          androidNotificationChannelName: 'Lecture audio',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );
      _audioHandler = handler as AppAudioHandler;
      _usingFallbackTts = false;
      await _audioHandler!.setSpeed(_speechRateForSpeed(_speed));
      _bindHandlerStreams();
      DebugLog().log('[AudioService] audio_service initialise');
    } catch (error, stackTrace) {
      DebugLog().log('[AudioService] fallback TTS: $error');
      debugPrintStack(stackTrace: stackTrace);
      await _fallbackTts.init();
      _usingFallbackTts = true;
      await _fallbackTts.setSpeechRate(_speechRateForSpeed(_speed));
      await _fallbackStateSubscription?.cancel();
      _fallbackStateSubscription =
          _fallbackTts.stateStream.listen(_handleFallbackState);
    }

    _isInitialized = true;
    _emitState();
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
          session.interruptionEventStream.listen((event) async {
            if (!event.begin) return;
            if (_state.playState == AudioPlayState.playing) {
              await pause();
            }
          });
    } catch (error, stackTrace) {
      DebugLog().log('[AudioService] session audio indisponible: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _bindHandlerStreams() {
    final handler = _audioHandler;
    if (handler == null) return;

    _playbackState = handler.playbackState.value;

    _playbackSubscription?.cancel();
    _playbackSubscription = handler.playbackState.listen((playbackState) {
      _playbackState = playbackState;
      _emitState();
    });

    _mediaItemSubscription?.cancel();
    _mediaItemSubscription = handler.mediaItem.listen((item) {
      if (item == null) return;
      _duration = item.duration ?? _duration;
      _currentPoiName = item.title;
      _emitState();
    });

    _positionSubscription?.cancel();
    _positionSubscription = audio_svc.AudioService.position.listen((position) {
      _position = position;
      _emitState();
    });
  }

  Future<void> playScript(String scriptId, {String? poiName}) async {
    await init();
    final script = await _supabase.getScript(scriptId);
    if (script == null) return;

    await playText(
      script['content'] as String? ?? '',
      language: script['language'] as String? ?? 'fr',
      poiName: poiName,
      scriptId: scriptId,
    );
  }

  Future<void> playText(
    String text, {
    String language = 'fr',
    String? poiName,
    models.Point? poi,
    String? scriptId,
  }) async {
    await init();
    if (text.trim().isEmpty) return;

    DebugLog().log('[AudioService] playText start lang=$language');

    _currentText = text;
    _currentLanguage = language;
    _currentPoiName = poiName ?? 'Lecture audio';
    _currentPoi = poi;
    _currentScriptId = scriptId ?? 'tts-${text.hashCode}';
    _duration = _estimateDuration(text);
    _position = Duration.zero;

    DebugLog().log(
      '[AudioService] playText poi=$_currentPoiName lang=$language fallback=$_usingFallbackTts',
    );

    if (_audioHandler != null) {
      DebugLog().log('[AudioService] playText -> handler');
      await _audioHandler!.speakText(
        text,
        language,
        _currentPoiName ?? 'Lecture audio',
        poi,
        _duration,
      );
      DebugLog().log('[AudioService] playText -> handler ok');
      _emitState();
      return;
    }

    DebugLog().log('[AudioService] playText -> fallback');
    await _fallbackTts.setLanguage(language);
    await _fallbackTts.setSpeechRate(_speechRateForSpeed(_speed));
    await _fallbackTts.speak(text, language: language);
    _state = _state.copyWith(
      playState: AudioPlayState.playing,
      position: Duration.zero,
      duration: _duration,
      speed: _speed,
      currentPoiName: _currentPoiName,
      currentPoi: _currentPoi,
      currentScriptId: _currentScriptId,
    );
    _emitState();
  }

  Future<void> pause() async {
    await init();
    if (_audioHandler != null) {
      await _audioHandler!.pause();
      return;
    }
    await _fallbackTts.stop();
    _state = _state.copyWith(playState: AudioPlayState.paused);
    _emitState();
  }

  Future<void> resume() async {
    await init();
    if (_audioHandler != null) {
      _position = Duration.zero;
      await _audioHandler!.play();
      return;
    }
    if ((_currentText ?? '').isEmpty) return;
    await _fallbackTts.speak(_currentText!, language: _currentLanguage);
    _state = _state.copyWith(
      playState: AudioPlayState.playing,
      position: Duration.zero,
    );
    _emitState();
  }

  Future<void> replayCurrent() async {
    final text = _currentText;
    if (text == null || text.isEmpty) return;
    await playText(
      text,
      language: _currentLanguage,
      poiName: _currentPoiName,
      poi: _currentPoi,
      scriptId: _currentScriptId,
    );
  }

  Future<void> stop() async {
    await init();
    if (_audioHandler != null) {
      await _audioHandler!.stop();
    } else {
      await _fallbackTts.stop();
    }

    _position = Duration.zero;
    _duration = Duration.zero;
    _currentText = null;
    _currentLanguage = 'fr';
    _currentPoiName = null;
    _currentPoi = null;
    _currentScriptId = null;
    _state = _state.copyWith(
      playState: AudioPlayState.stopped,
      position: Duration.zero,
      duration: Duration.zero,
      currentPoiName: null,
      currentPoi: null,
      currentScriptId: null,
    );
    _emitState();
  }

  Future<void> setSpeed(double speed) async {
    await init();
    _speed = _normalizeSpeed(speed);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_speedPrefKey, _speed);

    final speechRate = _speechRateForSpeed(_speed);
    if (_audioHandler != null) {
      await _audioHandler!.setSpeed(speechRate);
    } else {
      await _fallbackTts.setSpeechRate(speechRate);
    }

    if (_currentText != null) {
      _duration = _estimateDuration(_currentText!);
      if (_position > _duration) {
        _position = _duration;
      }
    }

    _emitState();
  }

  Future<void> setSpeechRate(double rate) async {
    final entry = _speedToSpeechRate.entries.firstWhere(
      (item) => (item.value - rate).abs() < 0.001,
      orElse: () => const MapEntry(1.0, 0.52),
    );
    await setSpeed(entry.key);
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

  void _handleFallbackState(TtsState state) {
    switch (state) {
      case TtsState.playing:
        _state = _state.copyWith(playState: AudioPlayState.playing);
        break;
      case TtsState.paused:
        _state = _state.copyWith(playState: AudioPlayState.paused);
        break;
      case TtsState.stopped:
        _state = _state.copyWith(
          playState: AudioPlayState.stopped,
          position: Duration.zero,
        );
        break;
    }
    _emitState();
  }

  AudioPlayState _mapPlayState(audio_svc.PlaybackState playbackState) {
    if (playbackState.processingState == audio_svc.AudioProcessingState.idle ||
        playbackState.processingState ==
            audio_svc.AudioProcessingState.completed) {
      return AudioPlayState.stopped;
    }
    return playbackState.playing
        ? AudioPlayState.playing
        : AudioPlayState.paused;
  }

  void _emitState() {
    if (_stateController.isClosed) return;

    if (_audioHandler != null) {
      final playState = _mapPlayState(_playbackState);
      final position = playState == AudioPlayState.stopped
          ? (_playbackState.processingState ==
                  audio_svc.AudioProcessingState.completed
              ? _duration
              : Duration.zero)
          : _position;

      _state = AudioState(
        playState: playState,
        position: position,
        duration: _duration,
        speed: _speed,
        currentPoiName: _currentPoiName,
        currentPoi: _currentPoi,
        currentScriptId: _currentScriptId,
      );
    } else {
      _state = _state.copyWith(
        speed: _speed,
        duration: _duration,
        currentPoiName: _currentPoiName,
        currentPoi: _currentPoi,
        currentScriptId: _currentScriptId,
      );
    }

    DebugLog().log(
      '[AudioService] state=${_state.playState} position=${_state.position.inMilliseconds} poi=${_state.currentPoiName}',
    );
    _stateController.add(_state);
  }

  Future<void> _loadSavedSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    _speed = _normalizeSpeed(prefs.getDouble(_speedPrefKey));
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
    return _speedToSpeechRate[_normalizeSpeed(speed)] ?? 0.52;
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
    _playbackSubscription?.cancel();
    _mediaItemSubscription?.cancel();
    _positionSubscription?.cancel();
    _fallbackStateSubscription?.cancel();
    _interruptionSubscription?.cancel();
    _stateController.close();
    _isInitialized = false;
    _audioHandler = null;
  }
}
