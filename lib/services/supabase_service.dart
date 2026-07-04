import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/constants.dart';
import 'debug_log.dart';
import 'offline_store.dart';

/// Service Supabase — Requêtes vers la base de données, **offline-first**.
///
/// Architecture POI-first: les POIs sont standalone (city_id, pas tour_id).
///
/// Chaque lecture réseau réussie alimente le cache local ([OfflineStore],
/// write-through). En cas d'échec réseau (avion, itinérance coupée), la
/// méthode répond depuis le cache — l'app fonctionne donc hors ligne pour
/// tout ce qui a déjà été visité ou téléchargé (« Télécharger la ville »).
class SupabaseService {
  static SupabaseClient? _client;

  /// Au-delà, on considère le réseau indisponible et on passe au cache.
  static const Duration _networkTimeout = Duration(seconds: 8);

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  // ── Cities ──

  /// Récupérer toutes les villes.
  static Future<List<Map<String, dynamic>>> getCities() async {
    try {
      final response =
          await client.from('cities').select().order('name').timeout(
                _networkTimeout,
              );
      final rows = List<Map<String, dynamic>>.from(response);
      await OfflineStore().upsertCities(rows);
      return rows;
    } catch (error) {
      final cached = await OfflineStore().getCities();
      if (cached.isNotEmpty) {
        DebugLog().log('[Supabase] getCities → cache (${cached.length})');
        return cached;
      }
      rethrow;
    }
  }

  /// Récupérer une ville par slug.
  static Future<Map<String, dynamic>?> getCityBySlug(String slug) async {
    final response = await client
        .from('cities')
        .select()
        .eq('slug', slug)
        .maybeSingle();
    return response;
  }

  // ── Points (POIs) ──

  /// Récupérer tous les POIs publiés d'une ville.
  static Future<List<Map<String, dynamic>>> getPoints(String cityId) async {
    try {
      final response = await client
          .from('points')
          .select()
          .eq('city_id', cityId)
          .eq('is_published', true)
          .timeout(_networkTimeout);
      final rows = List<Map<String, dynamic>>.from(response);
      await OfflineStore().upsertPoints(rows);
      return rows;
    } catch (error) {
      final cached = await OfflineStore().getPoints(cityId);
      if (cached.isNotEmpty) {
        DebugLog().log('[Supabase] getPoints → cache (${cached.length})');
        return cached;
      }
      rethrow;
    }
  }

  /// Récupérer un résumé léger (id + city_id + catégories) de tous les
  /// POIs publiés, toutes villes confondues. Une seule requête pour
  /// l'écran d'accueil au lieu d'un fetch complet des POIs par ville.
  static Future<List<Map<String, dynamic>>> getPublishedPointSummaries() async {
    try {
      final response = await client
          .from('points')
          .select('id, city_id, categories')
          .eq('is_published', true)
          .timeout(_networkTimeout);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      final cached = await OfflineStore().getAllPoints();
      if (cached.isNotEmpty) {
        DebugLog().log('[Supabase] summaries → cache (${cached.length})');
        return cached
            .where((p) => p['is_published'] == true)
            .map(
              (p) => <String, dynamic>{
                'id': p['id'],
                'city_id': p['city_id'],
                'categories': p['categories'],
              },
            )
            .toList();
      }
      rethrow;
    }
  }

  /// Récupérer un POI par ID.
  static Future<Map<String, dynamic>?> getPoint(String pointId) async {
    try {
      final row = await client
          .from('points')
          .select()
          .eq('id', pointId)
          .maybeSingle()
          .timeout(_networkTimeout);
      if (row != null) {
        await OfflineStore().upsertPoints([row]);
      }
      return row;
    } catch (error) {
      final cached = await OfflineStore().getPoint(pointId);
      if (cached != null) {
        DebugLog().log('[Supabase] getPoint → cache');
        return cached;
      }
      rethrow;
    }
  }

  /// Récupérer les POIs d'une ville filtrés par catégorie.
  static Future<List<Map<String, dynamic>>> getPointsByCategory(
    String cityId,
    String category,
  ) async {
    final response = await client
        .from('points')
        .select()
        .eq('city_id', cityId)
        .eq('is_published', true)
        .contains('categories', [category]);
    return List<Map<String, dynamic>>.from(response);
  }

  // ── Scripts ──

  /// Récupérer un script par ID.
  static Future<Map<String, dynamic>?> getScript(String scriptId) async {
    final response = await client
        .from('scripts')
        .select()
        .eq('id', scriptId)
        .maybeSingle();
    return response;
  }

  /// Récupérer le script d'un POI dans une langue donnée.
  static Future<Map<String, dynamic>?> getScriptForPoint(
    String pointId,
    String language,
  ) async {
    try {
      final row = await client
          .from('scripts')
          .select()
          .eq('point_id', pointId)
          .eq('language', language)
          .maybeSingle()
          .timeout(_networkTimeout);
      if (row != null) {
        await OfflineStore().upsertScripts([row]);
      }
      return row;
    } catch (error) {
      final cached = await OfflineStore().getScript(pointId, language);
      if (cached != null) {
        DebugLog().log('[Supabase] getScriptForPoint → cache');
        return cached;
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getScriptForPointWithFallback(
    String pointId,
    List<String> languages,
  ) async {
    for (final language in languages) {
      try {
        final script = await getScriptForPoint(pointId, language);
        if (script != null) {
          return script;
        }
      } catch (_) {
        // Réseau ET cache muets pour cette langue — tenter la suivante.
      }
    }
    return null;
  }

  /// Récupérer les scripts d'un POI dans toutes les langues (léger:
  /// id/language/content). Utilisé par l'hôte d'une session de groupe pour
  /// relayer le contenu aux invités — qui n'ont pas accès à la ville.
  static Future<List<Map<String, dynamic>>> getScriptsForPoint(
    String pointId,
  ) async {
    try {
      final response = await client
          .from('scripts')
          .select('id, point_id, language, content')
          .eq('point_id', pointId)
          .timeout(_networkTimeout);
      final rows = List<Map<String, dynamic>>.from(response);
      await OfflineStore().upsertScripts(rows);
      return rows;
    } catch (error) {
      final cached = await OfflineStore().getScriptsForPoint(pointId);
      if (cached.isNotEmpty) {
        DebugLog().log('[Supabase] scriptsForPoint → cache');
        return cached;
      }
      rethrow;
    }
  }

  /// Récupérer tous les scripts d'une ville dans une langue (téléchargement
  /// de ville + audios offline).
  static Future<List<Map<String, dynamic>>> getScriptsForCity(
    String cityId,
    String language,
  ) async {
    try {
      final response = await client
          .from('scripts')
          .select('*, points!inner(city_id)')
          .eq('points.city_id', cityId)
          .eq('language', language)
          .timeout(_networkTimeout);
      final rows = List<Map<String, dynamic>>.from(response);
      await OfflineStore().upsertScripts(rows);
      return rows;
    } catch (error) {
      final cached = await OfflineStore().getScriptsForCity(cityId, language);
      if (cached.isNotEmpty) {
        DebugLog().log('[Supabase] scriptsForCity → cache (${cached.length})');
        return cached;
      }
      rethrow;
    }
  }
}
