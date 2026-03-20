import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/audio_state.dart';
import '../services/audio_service.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  static const double height = 92;

  @override
  Widget build(BuildContext context) {
    final audioService = AudioService();

    return StreamBuilder<AudioState>(
      initialData: audioService.currentState,
      stream: audioService.stateStream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? audioService.currentState;
        final isVisible = state.playState == AudioPlayState.playing ||
            state.playState == AudioPlayState.paused;
        final duration = state.duration;
        final progress = duration.inMilliseconds <= 0
            ? 0.0
            : (state.position.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0);

        return IgnorePointer(
          ignoring: !isVisible,
          child: SafeArea(
            top: false,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              offset: isVisible ? Offset.zero : const Offset(0, 1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isVisible ? 1 : 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Material(
                    elevation: 10,
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: height,
                      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('🏛️', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  state.currentPoiName ?? 'Lecture audio',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (state.playState ==
                                      AudioPlayState.playing) {
                                    audioService.pause();
                                  } else {
                                    audioService.resume();
                                  }
                                },
                                icon: Icon(
                                  state.playState == AudioPlayState.playing
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                                tooltip: state.playState ==
                                        AudioPlayState.playing
                                    ? 'Pause'
                                    : 'Reprendre',
                              ),
                              IconButton(
                                onPressed: audioService.stop,
                                icon: const Icon(Icons.close),
                                tooltip: 'Arrêter',
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    minHeight: 6,
                                    value: progress,
                                    backgroundColor: AppTheme.primaryColor
                                        .withValues(alpha: 0.14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${_formatDuration(state.position)} / ${_formatDuration(duration)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
