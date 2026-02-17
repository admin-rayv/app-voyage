import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/tour_detail_screen.dart';
import '../screens/active_tour_screen.dart';

/// App Voyage - Routes
/// Configuration de la navigation

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
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
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page non trouvée: ${state.uri}'),
    ),
  ),
);
