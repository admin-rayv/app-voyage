import 'package:flutter_test/flutter_test.dart';
import 'package:app_voyage/services/group_session_service.dart';

void main() {
  group('GroupSessionService — codes de session', () {
    test('generateCode produit 6 caractères de l\'alphabet non ambigu', () {
      final service = GroupSessionService();
      for (var i = 0; i < 50; i++) {
        final code = service.generateCode();
        expect(code.length, GroupSessionService.codeLength);
        expect(GroupSessionService.isValidCode(code), isTrue);
        // Pas de caractères ambigus
        expect(code.contains(RegExp('[ILO01]')), isFalse);
      }
    });

    test('normalizeCode nettoie la saisie utilisateur', () {
      expect(GroupSessionService.normalizeCode(' marc42 '), 'MARC42');
      expect(GroupSessionService.normalizeCode('ma-rc 42'), 'MARC42');
      expect(GroupSessionService.normalizeCode('AB\nCD23'), 'ABCD23');
    });

    test('isValidCode rejette les mauvaises formes', () {
      expect(GroupSessionService.isValidCode('MARC42'), isTrue);
      expect(GroupSessionService.isValidCode('MARC'), isFalse); // trop court
      expect(GroupSessionService.isValidCode('MARC422'), isFalse); // trop long
      expect(GroupSessionService.isValidCode('MARC0!'), isFalse); // 0 + symbole
      expect(GroupSessionService.isValidCode('MARCJI'), isFalse); // I ambigu
    });

    test('deux codes générés sont (presque toujours) différents', () {
      final service = GroupSessionService();
      final codes = {for (var i = 0; i < 100; i++) service.generateCode()};
      expect(codes.length, greaterThan(95));
    });
  });

  group('GroupSessionService — script relayé par l\'hôte (mode invité)', () {
    const scripts = {
      'fr': {'id': 'sc-fr', 'content': 'Tu vois ce bâtiment?'},
      'en': {'id': 'sc-en', 'content': 'See this building?'},
      'es': {'id': 'sc-es', 'content': '¿Ves este edificio?'},
    };

    test('choisit la langue préférée du membre', () {
      final script = GroupSessionService.pickRelayedScript(
        Map<String, dynamic>.from(scripts),
        'es',
      );
      expect(script?.id, 'sc-es');
      expect(script?.language, 'es');
      expect(script?.content, '¿Ves este edificio?');
    });

    test('fallback fr → en si la langue préférée manque', () {
      final sansEs = Map<String, dynamic>.from(scripts)..remove('es');
      expect(
        GroupSessionService.pickRelayedScript(sansEs, 'es')?.language,
        'fr',
      );

      final enSeulement = <String, dynamic>{'en': scripts['en']};
      expect(
        GroupSessionService.pickRelayedScript(enSeulement, 'es')?.language,
        'en',
      );
    });

    test('dernier recours: n\'importe quelle langue disponible', () {
      final autre = <String, dynamic>{
        'de': {'id': 'sc-de', 'content': 'Siehst du dieses Gebäude?'},
      };
      expect(
        GroupSessionService.pickRelayedScript(autre, 'fr')?.language,
        'de',
      );
    });

    test('ignore les contenus vides et les entrées malformées', () {
      final douteux = <String, dynamic>{
        'fr': {'id': 'sc-fr', 'content': '   '},
        'en': 'pas-une-map',
        'es': {'id': 'sc-es', 'content': '¿Ves este edificio?'},
      };
      expect(
        GroupSessionService.pickRelayedScript(douteux, 'fr')?.language,
        'es',
      );

      expect(GroupSessionService.pickRelayedScript({}, 'fr'), isNull);
    });
  });
}
