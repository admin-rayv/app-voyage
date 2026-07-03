import 'package:flutter/material.dart';

/// Constantes pour les catégories de POIs.
///
/// Centralise les noms, emojis et couleurs des 7 catégories.

class CategoryConfig {
  final String key;
  final String labelFr;
  final String labelEn;
  final String labelEs;
  final String emoji;
  final Color color;

  const CategoryConfig({
    required this.key,
    required this.labelFr,
    required this.labelEn,
    required this.labelEs,
    required this.emoji,
    required this.color,
  });

  String label(String lang) {
    switch (lang) {
      case 'en':
        return labelEn;
      case 'es':
        return labelEs;
      default:
        return labelFr;
    }
  }
}

class Categories {
  static const List<CategoryConfig> all = [
    CategoryConfig(
      key: 'histoire',
      labelFr: 'Histoire',
      labelEn: 'History',
      labelEs: 'Historia',
      emoji: '🏛️',
      color: Color(0xFF1565C0), // bleu foncé
    ),
    CategoryConfig(
      key: 'architecture',
      labelFr: 'Architecture',
      labelEn: 'Architecture',
      labelEs: 'Arquitectura',
      emoji: '🏗️',
      color: Color(0xFF546E7A), // gris bleuté
    ),
    CategoryConfig(
      key: 'nature',
      labelFr: 'Nature',
      labelEn: 'Nature',
      labelEs: 'Naturaleza',
      emoji: '🌿',
      color: Color(0xFF2E7D32), // vert
    ),
    CategoryConfig(
      key: 'food',
      labelFr: 'Food',
      labelEn: 'Food',
      labelEs: 'Comida',
      emoji: '🍴',
      color: Color(0xFFEF6C00), // orange
    ),
    CategoryConfig(
      key: 'art',
      labelFr: 'Art',
      labelEn: 'Art',
      labelEs: 'Arte',
      emoji: '🎨',
      color: Color(0xFF7B1FA2), // violet
    ),
    CategoryConfig(
      key: 'insolite',
      labelFr: 'Insolite',
      labelEn: 'Unusual',
      labelEs: 'Insólito',
      emoji: '👻',
      color: Color(0xFFC62828), // rouge
    ),
    CategoryConfig(
      key: 'vie-locale',
      labelFr: 'Vie locale',
      labelEn: 'Local life',
      labelEs: 'Vida local',
      emoji: '🏘️',
      color: Color(0xFF00838F), // turquoise
    ),
  ];

  /// Trouver une catégorie par clé.
  static CategoryConfig? byKey(String key) {
    try {
      return all.firstWhere((c) => c.key == key);
    } catch (_) {
      return null;
    }
  }

  /// Couleur par défaut si la catégorie n'est pas trouvée.
  static const Color defaultColor = Color(0xFF9E9E9E);
}
