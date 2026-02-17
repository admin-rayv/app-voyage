import 'package:flutter/material.dart';

/// Écran de parcours actif avec carte et audio

class ActiveTourScreen extends StatelessWidget {
  final String tourId;
  
  const ActiveTourScreen({super.key, required this.tourId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parcours en cours'),
      ),
      body: Center(
        child: Text('Tour actif: $tourId\n\n🚧 En construction...'),
      ),
    );
  }
}
