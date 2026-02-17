import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/constants.dart';

/// Service Supabase
/// Gestion de la connexion et des requêtes

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
  
  // Récupérer toutes les villes
  static Future<List<Map<String, dynamic>>> getCities() async {
    final response = await client
        .from('cities')
        .select()
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }
  
  // Récupérer les parcours d'une ville
  static Future<List<Map<String, dynamic>>> getTours(String cityId) async {
    final response = await client
        .from('tours')
        .select()
        .eq('city_id', cityId)
        .eq('status', 'published')
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }
  
  // Récupérer les points d'un parcours
  static Future<List<Map<String, dynamic>>> getPoints(String tourId) async {
    final response = await client
        .from('points')
        .select()
        .eq('tour_id', tourId)
        .order('order_index');
    return List<Map<String, dynamic>>.from(response);
  }
  
  // Récupérer les scripts d'un point
  static Future<List<Map<String, dynamic>>> getScripts(String pointId, String language) async {
    final response = await client
        .from('scripts')
        .select()
        .eq('point_id', pointId)
        .eq('language', language);
    return List<Map<String, dynamic>>.from(response);
  }
}
