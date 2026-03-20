import 'package:flutter/material.dart';

import '../models/audio_state.dart';
import '../services/audio_service.dart';
import 'mini_player.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final audioService = AudioService();

    return StreamBuilder<AudioState>(
      initialData: audioService.currentState,
      stream: audioService.stateStream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? audioService.currentState;
        final isVisible = state.playState == AudioPlayState.playing ||
            state.playState == AudioPlayState.paused ||
            state.playState == AudioPlayState.loading;
        final extraBottomInset = isVisible ? MiniPlayer.height + 12 : 0.0;
        final mediaQuery = MediaQuery.of(context);
        final adjustedData = mediaQuery.copyWith(
          padding: mediaQuery.padding.copyWith(
            bottom: mediaQuery.padding.bottom + extraBottomInset,
          ),
          viewPadding: mediaQuery.viewPadding.copyWith(
            bottom: mediaQuery.viewPadding.bottom + extraBottomInset,
          ),
        );

        return MediaQuery(
          data: adjustedData,
          child: Stack(
            children: [
              child,
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MiniPlayer(),
              ),
            ],
          ),
        );
      },
    );
  }
}
