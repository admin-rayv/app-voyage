import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/constants.dart';

/// Service Supabase — Requêtes vers la base de données.
///
/// Architecture POI-first: les POIs sont standalone (city_id, pas tour_id).

class SupabaseService {
  static SupabaseClient? _client;

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
    final response = await client.from('cities').select().order('name');
    return List<Map<String, dynamic>>.from(response);
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
    final response = await client
        .from('points')
        .select()
        .eq('city_id', cityId)
        .eq('is_published', true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Récupérer un résumé léger (city_id + catégories) de tous les POIs
  /// publiés, toutes villes confondues. Une seule requête pour l'écran
  /// d'accueil au lieu d'un fetch complet des POIs par ville.
  static Future<List<Map<String, dynamic>>> getPublishedPointSummaries() async {
    final response = await client
        .from('points')
        .select('city_id, categories')
        .eq('is_published', true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Récupérer un POI par ID (utilisé par la sync de groupe).
  static Future<Map<String, dynamic>?> getPoint(String pointId) async {
    return client.from('points').select().eq('id', pointId).maybeSingle();
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
    final response = await client
        .from('scripts')
        .select()
        .eq('point_id', pointId)
        .eq('language', language)
        .maybeSingle();
    return response;
  }

  static Future<Map<String, dynamic>?> getScriptForPointWithFallback(
    String pointId,
    List<String> languages,
  ) async {
    for (final language in languages) {
      final script = await getScriptForPoint(pointId, language);
      if (script != null) {
        return script;
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
    final response = await client
        .from('scripts')
        .select('id, language, content')
        .eq('point_id', pointId);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Récupérer tous les scripts d'une ville dans une langue (pour offline sync).
  static Future<List<Map<String, dynamic>>> getScriptsForCity(
    String cityId,
    String language,
  ) async {
    final response = await client
        .from('scripts')
        .select('*, points!inner(city_id)')
        .eq('points.city_id', cityId)
        .eq('language', language);
    return List<Map<String, dynamic>>.from(response);
  }
}
