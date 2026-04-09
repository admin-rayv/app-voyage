import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/point.dart';

class VisitedPoiService {
  VisitedPoiService._internal();

  static final VisitedPoiService _instance = VisitedPoiService._internal();
  factory VisitedPoiService() => _instance;

  static const String _citiesKey = 'visited_poi_city_ids';
  static const String _visitedKeyPrefix = 'visited_poi_ids_';

  final ValueNotifier<Map<String, Set<String>>> _visitedByCityNotifier =
      ValueNotifier<Map<String, Set<String>>>(const {});

  SharedPreferences? _prefs;
  Future<void>? _initFuture;

  ValueListenable<Map<String, Set<String>>> get listenable =>
      _visitedByCityNotifier;

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

    final cityIds = prefs.getStringList(_citiesKey) ?? const <String>[];
    final visitedByCity = <String, Set<String>>{};
    for (final cityId in cityIds) {
      visitedByCity[cityId] =
          prefs.getStringList(_storageKey(cityId))?.toSet() ?? <String>{};
    }

    _visitedByCityNotifier.value = visitedByCity;
  }

  Set<String> visitedPoiIdsForCity(String cityId) {
    return Set<String>.unmodifiable(
      _visitedByCityNotifier.value[cityId] ?? const <String>{},
    );
  }

  int visitedCountForCity(String cityId) {
    return _visitedByCityNotifier.value[cityId]?.length ?? 0;
  }

  bool isVisited(String poiId, {String? cityId}) {
    if (cityId != null) {
      return _visitedByCityNotifier.value[cityId]?.contains(poiId) ?? false;
    }

    for (final ids in _visitedByCityNotifier.value.values) {
      if (ids.contains(poiId)) {
        return true;
      }
    }
    return false;
  }

  bool isVisitedPoint(Point poi) {
    return isVisited(poi.id, cityId: poi.cityId);
  }

  Future<void> markVisited(String poiId, {required String cityId}) async {
    await init();

    final current = _visitedByCityNotifier.value[cityId] ?? const <String>{};
    if (current.contains(poiId)) {
      return;
    }

    final updatedCitySet = <String>{...current, poiId};
    final updated = <String, Set<String>>{
      ..._visitedByCityNotifier.value,
      cityId: updatedCitySet,
    };

    _visitedByCityNotifier.value = updated;

    final prefs = _prefs!;
    final cityIds =
        (prefs.getStringList(_citiesKey) ?? const <String>[]).toSet()
          ..add(cityId);
    await prefs.setStringList(_citiesKey, cityIds.toList()..sort());
    await prefs.setStringList(
      _storageKey(cityId),
      updatedCitySet.toList()..sort(),
    );
  }

  Future<void> markVisitedForPoint(Point poi) async {
    await markVisited(poi.id, cityId: poi.cityId);
  }

  Future<void> resetVisited([String? cityId]) async {
    await init();
    final prefs = _prefs!;

    if (cityId != null) {
      final updated = <String, Set<String>>{..._visitedByCityNotifier.value}
        ..remove(cityId);
      _visitedByCityNotifier.value = updated;

      final cityIds = (prefs.getStringList(_citiesKey) ?? const <String>[])
          .where((id) => id != cityId)
          .toList();
      await prefs.setStringList(_citiesKey, cityIds);
      await prefs.remove(_storageKey(cityId));
      return;
    }

    final existingCityIds = prefs.getStringList(_citiesKey) ?? const <String>[];
    for (final existingCityId in existingCityIds) {
      await prefs.remove(_storageKey(existingCityId));
    }
    await prefs.remove(_citiesKey);
    _visitedByCityNotifier.value = const {};
  }

  String _storageKey(String cityId) => '$_visitedKeyPrefix$cityId';
}
