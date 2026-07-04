import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/city.dart';
import '../screens/group_listen_screen.dart';
import '../screens/home_screen.dart';
import '../screens/map_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/poi_detail_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/app_shell.dart';
import 'route_data.dart';

/// App Voyage - Routes
/// Configuration de la navigation.
/// [initialLocation] = '/onboarding' au premier lancement (voir main.dart).
GoRouter createAppRouter({String initialLocation = '/'}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    // Onboarding hors du shell (pas de mini-player par-dessus)
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    // Écran invité « Visite en cours » — hors du shell: il a sa propre
    // représentation du lecteur, pas besoin du mini-player par-dessus.
    GoRoute(
      path: '/group',
      name: 'groupListen',
      builder: (context, state) => const GroupListenScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/map',
          name: 'map',
          builder: (context, state) {
            final city = state.extra;
            if (city is! City) {
              throw ArgumentError(
                'La route map attend un objet City via extra.',
              );
            }
            return MapScreen(city: city);
          },
        ),
        GoRoute(
          path: '/poi',
          name: 'poiDetail',
          builder: (context, state) {
            final data = state.extra;
            if (data is! PoiDetailRouteData) {
              throw ArgumentError(
                'La route poiDetail attend un objet PoiDetailRouteData via extra.',
              );
            }
            return PoiDetailScreen(
              poi: data.poi,
              userPosition: data.userPosition,
            );
          },
        ),
        // Les routes /tour/* (tours curatés) reviendront en V2 —
        // voir le schéma `tours`/`tour_points` dans ARCHITECTURE.md.
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page non trouvée: ${state.uri}'),
    ),
  ),
);
