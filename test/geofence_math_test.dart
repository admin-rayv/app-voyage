import 'package:flutter_test/flutter_test.dart';
import 'package:app_voyage/services/geofence_math.dart';

void main() {
  group('GeofenceMath.confidenceForAccuracy', () {
    test('signal excellent (< 10 m) → confiance 1.0', () {
      expect(GeofenceMath.confidenceForAccuracy(3), 1.0);
      expect(GeofenceMath.confidenceForAccuracy(9.9), 1.0);
    });

    test('signal bon (10-19 m) → confiance 0.7', () {
      expect(GeofenceMath.confidenceForAccuracy(10), 0.7);
      expect(GeofenceMath.confidenceForAccuracy(19.9), 0.7);
    });

    test('signal moyen (20-30 m) → confiance 0.5', () {
      expect(GeofenceMath.confidenceForAccuracy(20), 0.5);
      expect(GeofenceMath.confidenceForAccuracy(30), 0.5);
    });

    test('signal douteux (> 30 m) → confiance 0.3', () {
      expect(GeofenceMath.confidenceForAccuracy(30.1), 0.3);
      expect(GeofenceMath.confidenceForAccuracy(100), 0.3);
    });
  });

  group('GeofenceMath.effectiveRadius', () {
    test('confiance parfaite → rayon inchangé', () {
      expect(
        GeofenceMath.effectiveRadius(
          triggerRadiusM: 40,
          confidence: 1.0,
          maxMultiplier: 2.0,
        ),
        40.0,
      );
    });

    test('confiance moyenne (0.5) → rayon élargi de 25 %', () {
      expect(
        GeofenceMath.effectiveRadius(
          triggerRadiusM: 40,
          confidence: 0.5,
          maxMultiplier: 2.0,
        ),
        50.0,
      );
    });

    test('confiance faible (0.3) → rayon élargi de 35 %', () {
      expect(
        GeofenceMath.effectiveRadius(
          triggerRadiusM: 40,
          confidence: 0.3,
          maxMultiplier: 2.0,
        ),
        closeTo(54.0, 0.001),
      );
    });

    test('le multiplicateur est borné par maxMultiplier', () {
      expect(
        GeofenceMath.effectiveRadius(
          triggerRadiusM: 40,
          confidence: 0.0,
          maxMultiplier: 1.2,
        ),
        closeTo(48.0, 0.001),
      );
    });
  });

  group('GeofenceMath.isApproaching', () {
    test('pas assez d\'échantillons → true (bénéfice du doute)', () {
      expect(GeofenceMath.isApproaching([]), isTrue);
      expect(GeofenceMath.isApproaching([50]), isTrue);
    });

    test('distances décroissantes → true', () {
      expect(GeofenceMath.isApproaching([50, 40, 30]), isTrue);
      expect(GeofenceMath.isApproaching([100, 80, 60, 45, 32]), isTrue);
    });

    test('distances croissantes (s\'éloigne) → false', () {
      expect(GeofenceMath.isApproaching([30, 40, 50]), isFalse);
      expect(GeofenceMath.isApproaching([32, 45, 60, 80]), isFalse);
    });

    test('quasi stationnaire (variation < 5 m) → true', () {
      expect(GeofenceMath.isApproaching([40, 41, 42]), isTrue);
      expect(GeofenceMath.isApproaching([50, 45, 52]), isTrue);
    });

    test('bruit GPS mais tendance décroissante → true', () {
      expect(GeofenceMath.isApproaching([60, 65, 50, 45, 40]), isTrue);
    });
  });
}
