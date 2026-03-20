import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'models/audio_state.dart';
import 'services/audio_service.dart';
import 'services/supabase_service.dart';
import 'widgets/mini_player.dart';

/// App Voyage - Point d'entrée
/// Guide audio géolocalisé

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Supabase
  await SupabaseService.initialize();
  await AudioService().init();

  runApp(
    const ProviderScope(
      child: AppVoyage(),
    ),
  );
}

class AppVoyage extends StatelessWidget {
  const AppVoyage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'App Voyage',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
      builder: (context, child) => AppShell(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

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
            state.playState == AudioPlayState.paused;
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
