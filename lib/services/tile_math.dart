import 'dart:math' as math;

/// Math des tuiles « slippy map » (XYZ) — logique pure, testée unitairement.
class TileMath {
  TileMath._();

  /// Colonne de tuile pour une longitude au zoom donné.
  static int lngToX(double lng, int zoom) {
    final n = 1 << zoom;
    final x = ((lng + 180.0) / 360.0 * n).floor();
    return x.clamp(0, n - 1);
  }

  /// Rangée de tuile pour une latitude (Web Mercator) au zoom donné.
  static int latToY(double lat, int zoom) {
    final n = 1 << zoom;
    final latRad = lat * math.pi / 180.0;
    final y =
        ((1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) /
                2.0 *
                n)
            .floor();
    return y.clamp(0, n - 1);
  }

  /// Liste des coordonnées (z, x, y) couvrant la boîte [south]-[north] ×
  /// [west]-[east] pour chaque zoom de [minZoom] à [maxZoom] inclus.
  static List<(int, int, int)> tilesForBounds({
    required double south,
    required double west,
    required double north,
    required double east,
    required int minZoom,
    required int maxZoom,
  }) {
    final tiles = <(int, int, int)>[];
    for (var z = minZoom; z <= maxZoom; z++) {
      final xMin = lngToX(west, z);
      final xMax = lngToX(east, z);
      // Web Mercator: y croît vers le sud.
      final yMin = latToY(north, z);
      final yMax = latToY(south, z);
      for (var x = xMin; x <= xMax; x++) {
        for (var y = yMin; y <= yMax; y++) {
          tiles.add((z, x, y));
        }
      }
    }
    return tiles;
  }
}
