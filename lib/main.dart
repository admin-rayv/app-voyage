import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme.dart';
import 'config/routes.dart';
import 'l10n/l10n.dart';
import 'screens/onboarding_screen.dart';
import 'services/audio_service.dart';
import 'services/map_tile_cache.dart';
import 'services/notification_service.dart';
import 'services/supabase_service.dart';

/// App Voyage - Point d'entrée
/// Guide audio géolocalisé

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Supabase
  await SupabaseService.initialize();

  // Cache disque des tuiles de carte (offline) — no-op sur le web.
  await MapTileCache.init();

  // Initialiser l'audio avant de construire l'UI.
  try {
    await AudioService().init();
  } catch (e) {
    debugPrint('[main] AudioService.init() failed: $e');
  }

  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('[main] NotificationService.init() failed: $e');
  }

  // Onboarding au premier lancement seulement.
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool(OnboardingScreen.prefKey) ?? false;

  runApp(
    ProviderScope(
      child: AppVoyage(
        router: createAppRouter(
          initialLocation: onboardingDone ? '/' : '/onboarding',
        ),
      ),
    ),
  );
}

class AppVoyage extends StatelessWidget {
  const AppVoyage({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'App Voyage',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      // UI localisée FR/EN/ES — suit la langue du téléphone (défaut: FR).
      // La langue des audios est un réglage séparé (UserPreferencesService).
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) => child ?? const SizedBox.shrink(),
    );
  }
}
