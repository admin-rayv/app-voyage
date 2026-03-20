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

        return Column(
          children: [
            Expanded(child: child),
            if (isVisible) const MiniPlayer(),
          ],
        );
      },
    );
  }
}
