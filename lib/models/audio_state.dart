import 'point.dart' as models;

class AudioState {
  final AudioPlayState playState;
  final Duration position;
  final Duration duration;
  final double speed;
  final AudioPlaybackSource playbackSource;
  final String? currentPoiName;
  final models.Point? currentPoi;
  final String? currentScriptId;

  const AudioState({
    required this.playState,
    required this.position,
    required this.duration,
    required this.speed,
    this.playbackSource = AudioPlaybackSource.manual,
    this.currentPoiName,
    this.currentPoi,
    this.currentScriptId,
  });

  AudioState copyWith({
    AudioPlayState? playState,
    Duration? position,
    Duration? duration,
    double? speed,
    AudioPlaybackSource? playbackSource,
    Object? currentPoiName = _sentinel,
    Object? currentPoi = _sentinel,
    Object? currentScriptId = _sentinel,
  }) {
    return AudioState(
      playState: playState ?? this.playState,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      playbackSource: playbackSource ?? this.playbackSource,
      currentPoiName: identical(currentPoiName, _sentinel)
          ? this.currentPoiName
          : currentPoiName as String?,
      currentPoi: identical(currentPoi, _sentinel)
          ? this.currentPoi
          : currentPoi as models.Point?,
      currentScriptId: identical(currentScriptId, _sentinel)
          ? this.currentScriptId
          : currentScriptId as String?,
    );
  }
}

enum AudioPlayState { playing, paused, stopped }

enum AudioPlaybackSource { manual, autoDiscovery }

const Object _sentinel = Object();
