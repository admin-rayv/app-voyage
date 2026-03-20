import 'package:audio_service/audio_service.dart' as audio_svc;

import '../models/audio_state.dart';

/// Handler natif pour exposer les contrôles média système.
class AppAudioHandler extends audio_svc.BaseAudioHandler {
  AppAudioHandler({
    required Future<void> Function() onPlayRequested,
    required Future<void> Function() onPauseRequested,
    required Future<void> Function() onStopRequested,
  }) : _onPlayRequested = onPlayRequested,
       _onPauseRequested = onPauseRequested,
       _onStopRequested = onStopRequested;

  final Future<void> Function() _onPlayRequested;
  final Future<void> Function() _onPauseRequested;
  final Future<void> Function() _onStopRequested;

  audio_svc.MediaItem? _currentItem;

  @override
  Future<void> play() => _onPlayRequested();

  @override
  Future<void> pause() => _onPauseRequested();

  @override
  Future<void> stop() => _onStopRequested();

  void setCurrentMediaItem({
    required String? poiName,
    required Duration duration,
    String? scriptId,
  }) {
    final resolvedTitle = (poiName == null || poiName.trim().isEmpty)
        ? 'Lecture audio'
        : poiName.trim();
    _currentItem = audio_svc.MediaItem(
      id: scriptId ?? resolvedTitle,
      title: resolvedTitle,
      artist: 'App Voyage',
      duration: duration,
    );
    mediaItem.add(_currentItem);
  }

  void clearMediaItem() {
    _currentItem = null;
    mediaItem.add(null);
  }

  void updatePlaybackState(AudioState state) {
    final controls = _controlsFor(state.playState);
    playbackState.add(
      audio_svc.PlaybackState(
        controls: controls,
        systemActions: const {
          audio_svc.MediaAction.play,
          audio_svc.MediaAction.pause,
          audio_svc.MediaAction.stop,
        },
        androidCompactActionIndices: List<int>.generate(
          controls.length > 2 ? 2 : controls.length,
          (index) => index,
        ),
        processingState: _processingStateFor(state.playState),
        playing: state.playState == AudioPlayState.playing,
        updatePosition: state.position,
        bufferedPosition: state.duration,
        speed: state.speed,
      ),
    );
  }

  List<audio_svc.MediaControl> _controlsFor(AudioPlayState playState) {
    switch (playState) {
      case AudioPlayState.playing:
        return const [
          audio_svc.MediaControl.pause,
          audio_svc.MediaControl.stop,
        ];
      case AudioPlayState.loading:
        return const [audio_svc.MediaControl.stop];
      case AudioPlayState.paused:
      case AudioPlayState.stopped:
        return const [
          audio_svc.MediaControl.play,
          audio_svc.MediaControl.stop,
        ];
    }
  }

  audio_svc.AudioProcessingState _processingStateFor(
    AudioPlayState playState,
  ) {
    switch (playState) {
      case AudioPlayState.loading:
        return audio_svc.AudioProcessingState.loading;
      case AudioPlayState.playing:
      case AudioPlayState.paused:
        return audio_svc.AudioProcessingState.ready;
      case AudioPlayState.stopped:
        return audio_svc.AudioProcessingState.idle;
    }
  }
}
