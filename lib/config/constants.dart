/// Configuration globale de l'application
class AppConstants {
  // App Info
  static const String appName = 'App Voyage';
  static const String appVersion = '1.0.0';
  
  // Supabase
  static const String supabaseUrl = 'https://lfwnpyttyoefqvhfqajb.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxmd25weXR0eW9lZnF2aGZxYWpiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzMDc2NTAsImV4cCI6MjA4Njg4MzY1MH0.J2kmSaIvxhkqGucy9C4ZwbokDS2hU7uBXlb4kE8Ryao';
  
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
