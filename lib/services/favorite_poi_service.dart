import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/point.dart';

/// Favoris — POIs que l'utilisateur veut retrouver (persistés localement).
///
/// Même patron que VisitedPoiService: singleton + ValueNotifier pour que
/// l'UI (cœurs, filtre favoris) se mette à jour en direct.
class FavoritePoiService {
  FavoritePoiService._internal();

  static final FavoritePoiService _instance = FavoritePoiService._internal();
  factory FavoritePoiService() => _instance;

  static const String _storageKey = 'favorite_poi_ids';

  final ValueNotifier<Set<String>> _favoritesNotifier =
      ValueNotifier<Set<String>>(const {});

  SharedPreferences? _prefs;
  Future<void>? _initFuture;

  ValueListenable<Set<String>> get listenable => _favoritesNotifier;

  Future<void> init() async {
    final existingFuture = _initFuture;
    if (existingFuture != null) {
      await existingFuture;
      return;
    }
    _initFuture = _performInit();
    try {
      await _initFuture;
    } finally {
      _initFuture = null;
    }
  }

  Future<void> _performInit() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    _favoritesNotifier.value =
        prefs.getStringList(_storageKey)?.toSet() ?? <String>{};
  }

  bool isFavorite(String poiId) => _favoritesNotifier.value.contains(poiId);

  bool isFavoritePoint(Point poi) => isFavorite(poi.id);

  int get count => _favoritesNotifier.value.length;

  /// Basculer le favori — retourne le nouvel état (true = favori).
  Future<bool> toggle(String poiId) async {
    await init();

    final current = _favoritesNotifier.value;
    final updated = <String>{...current};
    final nowFavorite = !updated.remove(poiId);
    if (nowFavorite) {
      updated.add(poiId);
    }
    _favoritesNotifier.value = updated;

    await _prefs!.setStringList(_storageKey, updated.toList()..sort());
    return nowFavorite;
  }
}
