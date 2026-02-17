import 'package:flutter/material.dart';

/// Écran de détail d'un parcours

class TourDetailScreen extends StatelessWidget {
  final String tourId;
  
  const TourDetailScreen({super.key, required this.tourId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du parcours'),
      ),
      body: Center(
        child: Text('Tour ID: $tourId\n\n🚧 En construction...'),
      ),
    );
  }
}
