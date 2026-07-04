import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../config/constants.dart';
import 'debug_log.dart';
import 'tile_math.dart';

/// Cache disque des tuiles de carte (Sprint 5 — offline).
///
/// Deux alimentations:
/// 1. **Passive**: chaque tuile affichée est écrite sur disque
///    ([CachedTileProvider]) — revoir une zone déjà parcourue fonctionne
///    hors ligne.
/// 2. **Active**: « Télécharger la ville » précharge la zone des POIs
///    ([downloadArea]) pour les zooms utiles.
///
/// La clé de cache ignore le sous-domaine `{s}` (a/b/c/d) pour que les
/// tuiles préchargées matchent celles demandées en direct.
class MapTileCache {
  MapTileCache._();

  static Directory? _cacheDir;
  static final http.Client _http = http.Client();

  static const String _userAgent = 'app_voyage (com.rayv.appvoyage)';

  /// À appeler au démarrage (main) — prépare le dossier de cache.
  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      final base = await getApplicationSupportDirectory();
      final dir = Directory('${base.path}/${AppConstants.mapCacheDir}');
      await dir.create(recursive: true);
      _cacheDir = dir;
    } catch (error) {
      DebugLog().log('[TileCache] init failed: $error');
    }
  }

  static bool get isReady => _cacheDir != null;

  /// Fichier de cache pour une URL de tuile (clé sans sous-domaine).
  static File _fileFor(String url) {
    final key = url.replaceFirst(RegExp(r'//[a-d]\.'), '//');
    final hash = md5.convert(utf8.encode(key)).toString();
    return File('${_cacheDir!.path}/$hash.png');
  }

  /// Lire la tuile du disque, sinon la télécharger puis l'écrire.
  static Future<Uint8List> readOrFetch(String url) async {
    final dir = _cacheDir;
    if (dir != null) {
      final file = _fileFor(url);
      try {
        if (await file.exists() && await file.length() > 0) {
          return file.readAsBytes();
        }
      } catch (_) {}
      final bytes = await _fetch(url);
      try {
        await file.writeAsBytes(bytes, flush: false);
      } catch (_) {}
      return bytes;
    }
    return _fetch(url);
  }

  static Future<Uint8List> _fetch(String url) async {
    final response = await _http.get(
      Uri.parse(url),
      headers: const {'User-Agent': _userAgent},
    );
    if (response.statusCode != 200) {
      throw HttpException('tile ${response.statusCode}', uri: Uri.parse(url));
    }
    return response.bodyBytes;
  }

  /// Précharger les tuiles couvrant [south]/[west]/[north]/[east] pour les
  /// zooms [minZoom]..[maxZoom]. Retourne le nombre de tuiles traitées.
  /// [urlFor] doit produire la même URL que la couche affichée (thème +
  /// retina) — voir MapTiles.resolvedUrl.
  static Future<void> downloadArea({
    required double south,
    required double west,
    required double north,
    required double east,
    required int minZoom,
    required int maxZoom,
    required String Function(int z, int x, int y) urlFor,
    required void Function(int done, int total) onProgress,
    bool Function()? isCancelled,
  }) async {
    if (_cacheDir == null) return;
    final tiles = TileMath.tilesForBounds(
      south: south,
      west: west,
      north: north,
      east: east,
      minZoom: minZoom,
      maxZoom: maxZoom,
    );
    var done = 0;
    for (final (z, x, y) in tiles) {
      if (isCancelled?.call() ?? false) return;
      try {
        await readOrFetch(urlFor(z, x, y));
      } catch (error) {
        // Une tuile manquée ne bloque pas le téléchargement.
        DebugLog().log('[TileCache] tuile $z/$x/$y: $error');
      }
      done++;
      onProgress(done, tiles.length);
    }
  }

  /// Nombre de tuiles qu'un téléchargement couvrirait (pour l'UI).
  static int countTiles({
    required double south,
    required double west,
    required double north,
    required double east,
    required int minZoom,
    required int maxZoom,
  }) {
    return TileMath.tilesForBounds(
      south: south,
      west: west,
      north: north,
      east: east,
      minZoom: minZoom,
      maxZoom: maxZoom,
    ).length;
  }

  /// Taille du cache tuiles (octets).
  static Future<int> cacheSize() async {
    final dir = _cacheDir;
    if (dir == null) return 0;
    var total = 0;
    try {
      await for (final entity in dir.list()) {
        if (entity is File) total += await entity.length();
      }
    } catch (_) {}
    return total;
  }
}

/// TileProvider flutter_map qui lit/écrit le cache disque.
class CachedTileProvider extends TileProvider {
  CachedTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return _CachedTileImage(url: getTileUrl(coordinates, options));
  }
}

class _CachedTileImage extends ImageProvider<_CachedTileImage> {
  const _CachedTileImage({required this.url});

  final String url;

  @override
  Future<_CachedTileImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_CachedTileImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    _CachedTileImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadCodec(decode),
      scale: 1.0,
      debugLabel: url,
    );
  }

  Future<ui.Codec> _loadCodec(ImageDecoderCallback decode) async {
    final bytes = await MapTileCache.readOrFetch(url);
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) => other is _CachedTileImage && other.url == url;

  @override
  int get hashCode => url.hashCode;
}
