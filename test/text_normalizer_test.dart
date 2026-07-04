import 'package:flutter_test/flutter_test.dart';

import 'package:app_voyage/config/text_normalizer.dart';

void main() {
  group('TextNormalizer — recherche sans accents', () {
    test('normalise minuscules et accents FR/ES', () {
      expect(TextNormalizer.normalize('Église Saint-Lambert'),
          'eglise saint-lambert');
      expect(TextNormalizer.normalize('Château d\'Eau'), 'chateau d\'eau');
      expect(TextNormalizer.normalize('Cañón Français'), 'canon francais');
      expect(TextNormalizer.normalize('Cœur'), 'coeur');
    });

    test('matches: la saisie sans accents trouve le nom accentué', () {
      expect(TextNormalizer.matches('Église Saint-Lambert', 'eglise'), isTrue);
      expect(TextNormalizer.matches('Église Saint-Lambert', 'EGLISE'), isTrue);
      expect(TextNormalizer.matches('Église Saint-Lambert', 'lambert'), isTrue);
      expect(TextNormalizer.matches('Église Saint-Lambert', 'manoir'), isFalse);
    });

    test('requête vide ou espaces matche tout', () {
      expect(TextNormalizer.matches('Manoir', ''), isTrue);
      expect(TextNormalizer.matches('Manoir', '   '), isTrue);
    });
  });
}
