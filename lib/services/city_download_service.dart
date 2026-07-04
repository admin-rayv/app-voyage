import '../models/point.dart';
import 'audio_service.dart';
import 'debug_log.dart';
import 'map_tile_cache.dart';
import 'offline_store.dart';
import 'supabase_service.dart';

/// « Télécharger la ville » (Sprint 5) — pack offline complet:
///
/// 1. **Données**: villes + POIs + scripts des 3 langues → [OfflineStore]
/// 2. **Audios**: MP3 Edge TTS de la langue préférée → cache audio
/// 3. **Tuiles**: la carte autour des POIs (zooms 13-17) → [MapTileCache]
///
/// À faire en Wi-Fi; ensuite la ville fonctionne entièrement sans réseau
/// (la voix neurale incluse).
class CityDownloadService {
  CityDownloadService._();

  static const List<String> _allLanguages = ['fr', 'en', 'es'];
  static const int _minZoom = 13;
  static const int _maxZoom = 17;

  /// Marge autour de la boîte des POIs (~300 m) pour que la carte reste
  /// utilisable en marchant en périphérie.
  static const double _boundsMargin = 0.003;

  /// Télécharge le pack complet. [onProgress] reçoit la progression
  /// agrégée (données + audios + tuiles). [tileUrlFor] doit résoudre les
  /// URLs comme la couche affichée (voir MapTiles.tileUrlBuilder).
  static Future<void> downloadCity({
    required String cityId,
    required List<Point> points,
    required String audioLanguage,
    required String Function(int z, int x, int y) tileUrlFor,
    required void Function(int done, int total) onProgress,
    bool Function()? isCancelled,
  }) async {
    if (points.isEmpty) return;

    var south = points.first.lat, north = points.first.lat;
    var west = points.first.lng, east = points.first.lng;
    for (final poi in points) {
      if (poi.lat < south) south = poi.lat;
      if (poi.lat > north) north = poi.lat;
      if (poi.lng < west) west = poi.lng;
      if (poi.lng > east) east = poi.lng;
    }
    south -= _boundsMargin;
    north += _boundsMargin;
    west -= _boundsMargin * 1.4; // la longitude « rétrécit » avec la latitude
    east += _boundsMargin * 1.4;

    final tilesTotal = MapTileCache.countTiles(
      south: south,
      west: west,
      north: north,
      east: east,
      minZoom: _minZoom,
      maxZoom: _maxZoom,
    );

    // Phase 1 — données (villes + scripts des 3 langues; les POIs sont
    // déjà upsertés par le getPoints de l'écran carte).
    final scriptsByLang = <String, List<Map<String, dynamic>>>{};
    for (final lang in _allLanguages) {
      if (isCancelled?.call() ?? false) return;
      try {
        scriptsByLang[lang] =
            await SupabaseService.getScriptsForCity(cityId, lang);
      } catch (error) {
        DebugLog().log('[CityDownload] scripts $lang: $error');
        scriptsByLang[lang] = const [];
      }
    }
    try {
      await SupabaseService.getCities(); // write-through → cache villes
    } catch (_) {}

    final audioScripts = scriptsByLang[audioLanguage] ?? const [];
    final dataSteps = _allLanguages.length;
    final total = dataSteps + audioScripts.length + tilesTotal;
    var done = dataSteps;
    onProgress(done, total);

    // Phase 2 — audios Edge TTS (langue préférée).
    if (isCancelled?.call() ?? false) return;
    await AudioService().edgeTts.downloadAll(
          scripts: audioScripts,
          isCancelled: isCancelled,
          onProgress: (current, _) {
            onProgress(done + current, total);
          },
        );
    done += audioScripts.length;

    // Phase 3 — tuiles de carte.
    if (isCancelled?.call() ?? false) return;
    await MapTileCache.downloadArea(
      south: south,
      west: west,
      north: north,
      east: east,
      minZoom: _minZoom,
      maxZoom: _maxZoom,
      urlFor: tileUrlFor,
      isCancelled: isCancelled,
      onProgress: (tilesDone, _) {
        onProgress(done + tilesDone, total);
      },
    );

    if (!(isCancelled?.call() ?? false)) {
      await OfflineStore().setMeta(
        'city_downloaded_$cityId',
        DateTime.now().toIso8601String(),
      );
      DebugLog().log(
        '[CityDownload] pack complet: ${audioScripts.length} audios, '
        '$tilesTotal tuiles',
      );
    }
  }
}
