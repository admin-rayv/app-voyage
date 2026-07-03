import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';

/// Couche de tuiles partagée par toutes les cartes de l'app.
///
/// Tuiles raster CARTO (données OpenStreetMap) — gratuites, sans clé API,
/// support retina ({r} → @2x) et variante sombre. On n'utilise PAS
/// tile.openstreetmap.org: leur politique d'usage interdit les apps
/// distribuées en production.
///
/// L'attribution « © OpenStreetMap contributors © CARTO » est une
/// obligation légale (ODbL) — toujours inclure [attribution] dans les
/// children de FlutterMap.
class MapTiles {
  MapTiles._();

  static const String _lightUrl =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
  static const String _darkUrl =
      'https://{s}.basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}{r}.png';
  static const List<String> _subdomains = ['a', 'b', 'c', 'd'];

  /// Couche de tuiles adaptée au thème (claire/sombre) et à la densité
  /// d'écran (retina).
  static TileLayer tileLayer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TileLayer(
      urlTemplate: isDark ? _darkUrl : _lightUrl,
      subdomains: _subdomains,
      userAgentPackageName: 'com.rayv.appvoyage',
      retinaMode: RetinaMode.isHighDensity(context),
    );
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
          '© CARTO',
          onTap: () => launchUrl(
            Uri.parse('https://carto.com/attributions'),
            mode: LaunchMode.externalApplication,
          ),
        ),
      ],
    );
  }
}
