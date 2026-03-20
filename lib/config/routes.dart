import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/active_tour_screen.dart';
import '../models/city.dart';
import '../screens/home_screen.dart';
import '../screens/map_screen.dart';
import '../screens/poi_detail_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/tour_detail_screen.dart';
import '../widgets/app_shell.dart';
import 'route_data.dart';

/// App Voyage - Routes
/// Configuration de la navigation

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
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
        GoRoute(
          path: '/tour/:tourId',
          name: 'tourDetail',
          builder: (context, state) {
            final tourId = state.pathParameters['tourId']!;
            return TourDetailScreen(tourId: tourId);
          },
        ),
        GoRoute(
          path: '/tour/:tourId/active',
          name: 'activeTour',
          builder: (context, state) {
            final tourId = state.pathParameters['tourId']!;
            return ActiveTourScreen(tourId: tourId);
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page non trouvée: ${state.uri}'),
    ),
  ),
);
