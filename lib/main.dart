import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/theme.dart';
import 'config/routes.dart';
import 'services/audio_service.dart';
import 'services/supabase_service.dart';

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
      builder: (context, child) => child ?? const SizedBox.shrink(),
    );
  }
}
