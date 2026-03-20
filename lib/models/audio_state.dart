import 'point.dart' as models;

class AudioState {
  final AudioPlayState playState;
  final Duration position;
  final Duration duration;
  final double speed;
  final String? currentPoiName;
  final models.Point? currentPoi;
  final String? currentScriptId;

  const AudioState({
    required this.playState,
    required this.position,
    required this.duration,
    required this.speed,
    this.currentPoiName,
    this.currentPoi,
    this.currentScriptId,
  });

  AudioState copyWith({
    AudioPlayState? playState,
    Duration? position,
    Duration? duration,
    double? speed,
    String? currentPoiName,
    bool clearCurrentPoiName = false,
    models.Point? currentPoi,
    bool clearCurrentPoi = false,
    String? currentScriptId,
    bool clearCurrentScriptId = false,
  }) {
    return AudioState(
      playState: playState ?? this.playState,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      currentPoiName: clearCurrentPoiName
          ? null
          : currentPoiName ?? this.currentPoiName,
      currentPoi: clearCurrentPoi ? null : currentPoi ?? this.currentPoi,
      currentScriptId: clearCurrentScriptId
          ? null
          : currentScriptId ?? this.currentScriptId,
    );
  }
}

enum AudioPlayState { playing, paused, stopped, loading }
