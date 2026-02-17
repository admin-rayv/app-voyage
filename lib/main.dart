import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'config/routes.dart';

/// App Voyage - Point d'entrée
/// Guide audio géolocalisé

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
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
    );
  }
}
