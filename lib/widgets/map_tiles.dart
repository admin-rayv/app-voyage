import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/map_tile_cache.dart';

/// Couche de tuiles partagée par toutes les cartes de l'app.
///
/// Tuiles raster auto-hébergées sur notre VPS (voyage.bjpr.ca/cartes) :
/// données OpenStreetMap (extrait Protomaps de la Rive-Sud de Montréal)
/// dessinées par tileserver-gl, styles clair/sombre en français, retina
/// ({r} → @2x). Voir docs/CARTES-AUTO-HEBERGEES.md.
///
/// (CARTO exige une clé depuis sept. 2026 ; tile.openstreetmap.org interdit
/// les apps distribuées en production.)
///
/// L'attribution « © OpenStreetMap contributors » est une obligation
/// légale (ODbL) — toujours inclure [attribution] dans les children de
/// FlutterMap.
class MapTiles {
  MapTiles._();

  static const String _base = 'https://voyage.bjpr.ca/cartes/styles';
  static const String _lightUrl = '$_base/light/{z}/{x}/{y}{r}.png';
  static const String _darkUrl = '$_base/dark/{z}/{x}/{y}{r}.png';

  /// Couche de tuiles adaptée au thème (claire/sombre) et à la densité
  /// d'écran (retina). Sur mobile, les tuiles passent par le cache disque
  /// ([MapTileCache]) — zones déjà vues et villes téléchargées dispo
  /// hors ligne.
  static TileLayer tileLayer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TileLayer(
      urlTemplate: isDark ? _darkUrl : _lightUrl,
      userAgentPackageName: 'com.rayv.appvoyage',
      retinaMode: RetinaMode.isHighDensity(context),
      tileProvider: !kIsWeb && MapTileCache.isReady
          ? CachedTileProvider()
          : NetworkTileProvider(),
    );
  }

  /// Résolveur d'URL de tuile identique à la couche affichée (même thème,
  /// même retina) — pour que « Télécharger la ville » remplisse exactement
  /// le cache que la carte lira ensuite. Capture le thème immédiatement:
  /// le closure retourné est utilisable après des await.
  static String Function(int z, int x, int y) tileUrlBuilder(
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final retina = RetinaMode.isHighDensity(context);
    final template = isDark ? _darkUrl : _lightUrl;
    return (z, x, y) => template
        .replaceFirst('{z}', '$z')
        .replaceFirst('{x}', '$x')
        .replaceFirst('{y}', '$y')
        .replaceFirst('{r}', retina ? '@2x' : '');
  }

  /// Attribution obligatoire — à placer en dernier child de FlutterMap.
  static Widget attribution() {
    return RichAttributionWidget(
      alignment: AttributionAlignment.bottomLeft,
      attributions: [
        TextSourceAttribution(
          '© OpenStreetMap contributors',
          onTap: () => launchUrl(
            Uri.parse('https://www.openstreetmap.org/copyright'),
            mode: LaunchMode.externalApplication,
          ),
        ),
        TextSourceAttribution(
          'Protomaps',
          onTap: () => launchUrl(
            Uri.parse('https://protomaps.com'),
            mode: LaunchMode.externalApplication,
          ),
        ),
      ],
    );
  }
}
