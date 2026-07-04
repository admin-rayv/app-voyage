import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../config/constants.dart';
import 'debug_log.dart';

/// Cache offline des données Supabase (Sprint 5) — sqflite.
///
/// Chaque table stocke la ligne Supabase **en JSON brut** (colonne `json`)
/// plus les clés utiles aux requêtes locales. Le cache est alimenté en
/// write-through par `SupabaseService` (chaque lecture réseau réussie met
/// le cache à jour) et par le téléchargement de ville. En cas d'échec
/// réseau, `SupabaseService` répond depuis ce cache.
///
/// Non supporté sur le web (sqflite indisponible) — toutes les méthodes
/// deviennent des no-op qui retournent vide.
class OfflineStore {
  OfflineStore._();

  static final OfflineStore _instance = OfflineStore._();
  factory OfflineStore() => _instance;

  Database? _db;

  bool get isSupported => !kIsWeb;

  Future<Database?> get _database async {
    if (!isSupported) return null;
    if (_db != null) return _db;
    try {
      final dir = await getDatabasesPath();
      _db = await openDatabase(
        p.join(dir, AppConstants.offlineDbName),
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE cities(id TEXT PRIMARY KEY, json TEXT NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE points(id TEXT PRIMARY KEY, '
            'city_id TEXT NOT NULL, json TEXT NOT NULL)',
          );
          await db.execute('CREATE INDEX idx_points_city ON points(city_id)');
          await db.execute(
            'CREATE TABLE scripts(id TEXT PRIMARY KEY, '
            'point_id TEXT NOT NULL, language TEXT NOT NULL, '
            'json TEXT NOT NULL)',
          );
          await db.execute(
            'CREATE INDEX idx_scripts_point ON scripts(point_id)',
          );
          await db.execute(
            'CREATE TABLE meta(key TEXT PRIMARY KEY, value TEXT NOT NULL)',
          );
        },
      );
    } catch (error) {
      DebugLog().log('[OfflineStore] open failed: $error');
    }
    return _db;
  }

  // ── Écriture (write-through depuis SupabaseService) ──

  Future<void> upsertCities(List<Map<String, dynamic>> rows) async {
    final db = await _database;
    if (db == null || rows.isEmpty) return;
    final batch = db.batch();
    for (final row in rows) {
      final id = row['id'] as String?;
      if (id == null) continue;
      batch.insert(
        'cities',
        {'id': id, 'json': jsonEncode(row)},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await _commit(batch, 'upsertCities');
  }

  Future<void> upsertPoints(List<Map<String, dynamic>> rows) async {
    final db = await _database;
    if (db == null || rows.isEmpty) return;
    final batch = db.batch();
    for (final row in rows) {
      final id = row['id'] as String?;
      final cityId = row['city_id'] as String?;
      if (id == null || cityId == null) continue;
      batch.insert(
        'points',
        {'id': id, 'city_id': cityId, 'json': jsonEncode(row)},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await _commit(batch, 'upsertPoints');
  }

  Future<void> upsertScripts(List<Map<String, dynamic>> rows) async {
    final db = await _database;
    if (db == null || rows.isEmpty) return;
    final batch = db.batch();
    for (final row in rows) {
      final id = row['id'] as String?;
      final pointId = row['point_id'] as String?;
      final language = row['language'] as String?;
      if (id == null || pointId == null || language == null) continue;
      batch.insert(
        'scripts',
        {
          'id': id,
          'point_id': pointId,
          'language': language,
          'json': jsonEncode(row),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await _commit(batch, 'upsertScripts');
  }

  Future<void> _commit(Batch batch, String label) async {
    try {
      await batch.commit(noResult: true);
    } catch (error) {
      DebugLog().log('[OfflineStore] $label failed: $error');
    }
  }

  // ── Lecture (fallback hors ligne) ──

  Future<List<Map<String, dynamic>>> getCities() async {
    return _readAll('SELECT json FROM cities');
  }

  Future<List<Map<String, dynamic>>> getPoints(String cityId) async {
    return _readAll(
      'SELECT json FROM points WHERE city_id = ?',
      [cityId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllPoints() async {
    return _readAll('SELECT json FROM points');
  }

  Future<Map<String, dynamic>?> getPoint(String pointId) async {
    final rows = await _readAll(
      'SELECT json FROM points WHERE id = ?',
      [pointId],
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<Map<String, dynamic>?> getScript(
    String pointId,
    String language,
  ) async {
    final rows = await _readAll(
      'SELECT json FROM scripts WHERE point_id = ? AND language = ?',
      [pointId, language],
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, dynamic>>> getScriptsForPoint(String pointId) async {
    return _readAll(
      'SELECT json FROM scripts WHERE point_id = ?',
      [pointId],
    );
  }

  Future<List<Map<String, dynamic>>> getScriptsForCity(
    String cityId,
    String language,
  ) async {
    return _readAll(
      'SELECT s.json FROM scripts s JOIN points p ON p.id = s.point_id '
      'WHERE p.city_id = ? AND s.language = ?',
      [cityId, language],
    );
  }

  Future<List<Map<String, dynamic>>> _readAll(
    String sql, [
    List<Object?>? args,
  ]) async {
    final db = await _database;
    if (db == null) return const [];
    try {
      final rows = await db.rawQuery(sql, args);
      return rows
          .map(
            (r) =>
                Map<String, dynamic>.from(jsonDecode(r['json'] as String) as Map),
          )
          .toList();
    } catch (error) {
      DebugLog().log('[OfflineStore] read failed: $error');
      return const [];
    }
  }

  /// Taille de la base sur disque (octets) — via PRAGMA, sans dart:io
  /// (le fichier reste compatible compilation web).
  Future<int> databaseSize() async {
    final db = await _database;
    if (db == null) return 0;
    try {
      final pages = await db.rawQuery('PRAGMA page_count');
      final pageSize = await db.rawQuery('PRAGMA page_size');
      final count = pages.first.values.first as int? ?? 0;
      final size = pageSize.first.values.first as int? ?? 0;
      return count * size;
    } catch (error) {
      DebugLog().log('[OfflineStore] size failed: $error');
      return 0;
    }
  }

  /// Vider toutes les données hors ligne (réglages → stockage). Le cache
  /// se reconstruira automatiquement à la prochaine navigation en ligne.
  Future<void> clearAll() async {
    final db = await _database;
    if (db == null) return;
    try {
      await db.delete('scripts');
      await db.delete('points');
      await db.delete('cities');
      await db.delete('meta');
      await db.execute('VACUUM');
    } catch (error) {
      DebugLog().log('[OfflineStore] clear failed: $error');
    }
  }

  // ── Méta (date de téléchargement d'une ville, etc.) ──

  Future<void> setMeta(String key, String value) async {
    final db = await _database;
    if (db == null) return;
    try {
      await db.insert(
        'meta',
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error) {
      DebugLog().log('[OfflineStore] setMeta failed: $error');
    }
  }

  Future<String?> getMeta(String key) async {
    final db = await _database;
    if (db == null) return null;
    try {
      final rows = await db.query('meta', where: 'key = ?', whereArgs: [key]);
      return rows.isEmpty ? null : rows.first['value'] as String?;
    } catch (error) {
      DebugLog().log('[OfflineStore] getMeta failed: $error');
      return null;
    }
  }
}
