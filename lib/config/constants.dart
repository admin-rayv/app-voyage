/// Configuration globale de l'application
class AppConstants {
  // App Info
  static const String appName = 'App Voyage';
  static const String appVersion = '0.7.6';

  // Supabase — surchargeables par environnement via --dart-define:
  //   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  // (la clé anon est publique par design — la sécurité vient du RLS)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://voyagedb.bjpr.ca', // BD auto-hébergée (docs/BD-AUTO-HEBERGEE.md)
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiAiSFMyNTYiLCAidHlwIjogIkpXVCJ9.eyJyb2xlIjogImFub24iLCAiaXNzIjogInN1cGFiYXNlIiwgImlhdCI6IDE3OTUyODA0NjgsICJleHAiOiAyMTEwNjQwNDY4fQ.6JgiUCwNlWgIgoMm6md-6dLTq2NfWBf9jya6c_CoZ4Y',
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
