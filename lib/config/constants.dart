/// Configuration globale de l'application
class AppConstants {
  // App Info
  static const String appName = 'App Voyage';
  static const String appVersion = '1.0.0';
  
  // Supabase (à configurer)
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Mapbox (à configurer)
  static const String mapboxAccessToken = 'YOUR_MAPBOX_TOKEN';
  
  // Audio settings
  static const int defaultTriggerRadiusMeters = 30;
  static const int bikeTriggerRadiusMeters = 60;
  static const int carTriggerRadiusMeters = 150;
  
  // GPS settings
  static const int gpsUpdateIntervalMs = 5000; // 5 seconds
  static const int gpsDistanceFilterMeters = 10;
  
  // Cache settings
  static const String audioCacheDir = 'audio_cache';
  static const String mapCacheDir = 'map_cache';
  
  // API endpoints
  static const String generateAudioFunction = 'generate-audio';
}
