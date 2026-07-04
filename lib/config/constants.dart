/// Configuration globale de l'application
class AppConstants {
  // App Info
  static const String appName = 'App Voyage';
  static const String appVersion = '0.7.1';

  // Supabase — surchargeables par environnement via --dart-define:
  //   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  // (la clé anon est publique par design — la sécurité vient du RLS)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://lfwnpyttyoefqvhfqajb.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxmd25weXR0eW9lZnF2aGZxYWpiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzMDc2NTAsImV4cCI6MjA4Njg4MzY1MH0.J2kmSaIvxhkqGucy9C4ZwbokDS2hU7uBXlb4kE8Ryao',
  );

  // GPS settings
  // Note: le rayon de déclenchement par POI vient de la DB
  // (points.trigger_radius_m, défaut 40 m). Les rayons vélo/auto seront
  // réintroduits avec les modes de transport (V2).
  static const int gpsDistanceFilterMeters = 10;
  static const int geofenceDebounceSec = 3;
  static const int geofenceTriggerCooldownSec = 30;
  static const int geofenceQueuedCandidateTtlSec = 90;
  static const double gpsMinConfidence = 0.4;
  static const double geofenceMaxRadiusMultiplier = 2.0;
  static const int positionHistorySize = 10;

  // Cache settings (Sprint 5 — offline)
  static const String mapCacheDir = 'map_cache';
  static const String offlineDbName = 'app_voyage.db';

  // TTS settings
  static const double defaultSpeechRate = 0.52;
  static const double defaultPitch = 1.05;
  static const String defaultLanguage = 'fr-CA';

  // Vitesse UI (0.75x-1.5x) → speech rate flutter_tts.
  // Pour les MP3 (Edge TTS via just_audio), la vitesse UI s'applique
  // directement (1.0 = vitesse normale).
  static final Map<double, double> speedToSpeechRate = {
    0.75: 0.39,
    1.0: 0.52,
    1.25: 0.65,
    1.5: 0.78,
  };
}
