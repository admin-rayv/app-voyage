import 'package:flutter_test/flutter_test.dart';

import 'package:app_voyage/services/tile_math.dart';

void main() {
  group('TileMath — coordonnées slippy map', () {
    test('références connues (openstreetmap wiki)', () {
      // (0,0) au zoom 0 et 1: une seule tuile / le coin des 4 tuiles.
      expect(TileMath.lngToX(0, 0), 0);
      expect(TileMath.latToY(0, 0), 0);
      expect(TileMath.lngToX(0, 1), 1);
      expect(TileMath.latToY(0, 1), 1);

      // Saint-Lambert (45.4959, -73.5075) au zoom 15 — valeurs calculées
      // avec la formule de référence OSM (implémentation Python croisée).
      expect(TileMath.lngToX(-73.5075, 15), 9693);
      expect(TileMath.latToY(45.4959, 15), 11723);
    });

    test('bornes: latitudes extrêmes restent dans [0, 2^z - 1]', () {
      expect(TileMath.latToY(89.9, 3), 0);
      expect(TileMath.latToY(-89.9, 3), 7);
      expect(TileMath.lngToX(180.0, 3), 7);
      expect(TileMath.lngToX(-180.0, 3), 0);
    });

    test('tilesForBounds couvre la boîte, zooms croissants', () {
      // Boîte de ~1.5 km autour de Saint-Lambert.
      final tiles = TileMath.tilesForBounds(
        south: 45.49,
        west: -73.52,
        north: 45.51,
        east: -73.50,
        minZoom: 13,
        maxZoom: 15,
      );

      // Chaque zoom contribue au moins une tuile, et le nombre de tuiles
      // par zoom ne décroît jamais (la boîte se découpe plus finement).
      for (var z = 13; z <= 15; z++) {
        final atZoom = tiles.where((t) => t.$1 == z).length;
        expect(atZoom, greaterThan(0), reason: 'zoom $z');
      }
      final at13 = tiles.where((t) => t.$1 == 13).length;
      final at15 = tiles.where((t) => t.$1 == 15).length;
      expect(at15, greaterThanOrEqualTo(at13));

      // Le POI central est couvert à chaque zoom.
      for (var z = 13; z <= 15; z++) {
        final x = TileMath.lngToX(-73.51, z);
        final y = TileMath.latToY(45.50, z);
        expect(tiles.contains((z, x, y)), isTrue, reason: 'zoom $z');
      }
    });

    test('une ville de la taille de Saint-Lambert reste raisonnable', () {
      final count = TileMath.tilesForBounds(
        south: 45.487,
        west: -73.53,
        north: 45.51,
        east: -73.49,
        minZoom: 13,
        maxZoom: 17,
      ).length;
      // Ordre de grandeur: quelques centaines de tuiles (~10-20 Mo), pas
      // des dizaines de milliers.
      expect(count, lessThan(1200));
      expect(count, greaterThan(50));
    });
  });
}
