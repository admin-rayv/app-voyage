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
}
