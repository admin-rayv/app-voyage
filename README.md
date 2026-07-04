# 🎧 App Voyage

> Guide audio géolocalisé — "Un ami historien passionné dans tes écouteurs"

Application mobile Flutter qui lit des scripts audio géolocalisés via les voix natives du téléphone. 100% offline après téléchargement.

---

## 🚀 Setup rapide

### Prérequis

- **Flutter** ≥ 3.11 (`flutter --version`)
- **Xcode** ≥ 15 (pour iOS)
- **Android Studio** (pour Android)
- **Git**

### Installation

```bash
# 1. Cloner le repo
git clone https://github.com/admin-rayv/app-voyage.git
cd app-voyage

# 2. Installer les dépendances
flutter pub get

# 3. Lancer sur un simulateur
flutter run
```

### Variables d'environnement

Le projet utilise `lib/config/constants.dart` pour la config. Les clés Supabase y sont déjà configurées pour l'environnement de développement.

Pour un nouvel environnement:
```dart
// lib/config/constants.dart
static const String supabaseUrl = 'https://VOTRE_PROJET.supabase.co';
static const String supabaseAnonKey = 'VOTRE_ANON_KEY';
```

**Cartes:** aucune clé requise — l'app utilise OpenStreetMap via `flutter_map` (gratuit, sans compte).

### Permissions requises

**iOS** (`ios/Runner/Info.plist`):
- `NSLocationWhenInUseUsageDescription` — GPS pour détecter les POIs proches
- `NSLocationAlwaysUsageDescription` — GPS en arrière-plan

**Android** (`android/app/src/main/AndroidManifest.xml`):
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `ACCESS_BACKGROUND_LOCATION`

---

## 🏗️ Architecture

```
Supabase (cities, points, scripts)
        ↓ texte
  AudioService → AppAudioHandler (audio_service) → flutter_tts → Voix native
        ↑                                            (contrôles lock screen,
  GeofencingService → DiscoveryPlaybackService        audio en background)
  (GPS auto-trigger)   (notifications + auto-play)
```

**POI-first:** Les POIs sont autonomes (liés à une ville, pas à un tour). Chaque POI a un script auto-contenu par langue (FR, EN, ES).

**Audio:** la lecture privilégie les **voix neurales Edge TTS** (MP3 générés gratuitement via l'API du navigateur Microsoft Edge, cachés localement — voix `fr-CA-Thierry` pour Marco), avec **fallback automatique** sur `flutter_tts` (voix native du téléphone) sans réseau ni cache. Bouton « Télécharger les audios » sur la carte pour pré-générer toute une ville en Wi-Fi. ⚠️ API non officielle — voir RISKS.md (T7).

**Cartes:** `flutter_map` avec tuiles **CARTO** (données OpenStreetMap) — gratuit, sans clé API, retina, clair/sombre, clustering des marqueurs, attribution intégrée.

**Mode découverte:** `GeofencingService` surveille la position GPS (rayon dynamique selon la précision, direction d'approche, debounce 3 s, cooldown global 30 s avec file d'attente) et déclenche la lecture automatique via `DiscoveryPlaybackService`.

→ Détail complet: [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md)

---

## 📁 Structure du projet

```
lib/
├── main.dart
├── config/
│   ├── constants.dart               # URLs, clés, settings GPS/audio
│   ├── categories.dart              # 7 catégories (labels, emojis, couleurs)
│   ├── routes.dart                  # go_router navigation
│   └── theme.dart                   # Thème Material
├── models/                          # Point, City, Script, AudioState...
├── screens/
│   ├── home_screen.dart             # Liste des villes
│   ├── map_screen.dart              # Carte + liste + mode découverte GPS
│   ├── poi_detail_screen.dart       # Détail POI + lecteur audio
│   ├── settings_screen.dart         # Langue, voix, vitesse, autoplay
│   └── debug_voices_screen.dart     # Debug des voix TTS
├── services/
│   ├── audio_service.dart           # Orchestration lecture (état global)
│   ├── audio_handler.dart           # Handler audio_service (background/lock screen)
│   ├── tts_service.dart             # Wrapper flutter_tts + sélection de voix
│   ├── edge_tts_service*.dart       # Génération MP3 Edge TTS (io + stub web)
│   ├── geofencing_service.dart      # Détection de proximité GPS (cœur du produit)
│   ├── discovery_playback_service.dart  # Auto-play sur trigger GPS
│   ├── location_service.dart        # Stream de position GPS
│   ├── permission_service.dart      # Flow permissions localisation
│   ├── notification_service.dart    # Notifications de proximité
│   ├── visited_poi_service.dart     # Progression POIs écoutés (persistée)
│   ├── user_preferences_service.dart # Préférences (langue, autoplay...)
│   ├── supabase_service.dart        # Requêtes Supabase
│   └── debug_log.dart               # Logs in-app + journal des décisions géo
└── widgets/
    ├── app_shell.dart               # Shell avec mini-player global
    ├── mini_player.dart             # Lecteur compact persistant
    ├── poi_list_item.dart           # Item de liste POI
    └── voice_setup_dialog.dart      # Guide d'installation des voix TTS
```

---

## 🗄️ Base de données (Supabase)

### Tables

| Table | Description | Entrées |
|-------|-------------|---------|
| `cities` | Villes disponibles | 1 (Saint-Lambert) |
| `points` | POIs avec GPS + catégories | 81 |
| `scripts` | Texte audio par langue | 243 (81 × 3 langues) |

### Catégories de POIs

| Catégorie | Icône | POIs |
|-----------|-------|------|
| histoire | 🏛️ | 29 |
| architecture | 🏗️ | 20 |
| art | 🎨 | 15 |
| nature | 🌿 | 14 |
| insolite | 👻 | 14 |
| food | 🍴 | 13 |
| vie-locale | 🏘️ | 12 |

---

## 🎙️ Comment ajouter un nouveau POI

### 1. Créer le contenu

Ajouter le POI dans le fichier scout de sa catégorie:
```
content/saint-lambert-quebec-canada/scout-[catégorie].md
```

### 2. Pipeline automatisé (skills)

```
poi-scout  → Recherche + GPS + vérification doublons
poi-writer → Rédaction scripts FR/EN/ES (ton Marco)
poi-checker → Vérification factuelle
poi-pusher → Insertion dans Supabase
```

### 3. Insertion manuelle (SQL)

```sql
-- Insérer le POI
INSERT INTO points (city_id, name, lat, lng, categories)
VALUES (
  'f1fba711-49fe-4b49-87e3-b49442c39e9c',  -- Saint-Lambert
  '{"fr": "Mon nouveau POI", "en": "My new POI"}',
  45.5000, -73.5100,
  ARRAY['histoire']
);

-- Insérer le script FR
INSERT INTO scripts (point_id, language, content, persona)
VALUES (
  'UUID_DU_POI',
  'fr',
  'Tu vois ce bâtiment? ...',
  'marco'
);
```

---

## 📖 Documentation

| Document | Contenu |
|----------|---------|
| [PROJECT.md](./PROJECT.md) | Vision, cibles, scope, équipe, business model |
| [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) | Stack technique, schéma DB, flux audio |
| [docs/SPRINTS.md](./docs/SPRINTS.md) | Définition des sprints et livrables |
| [docs/CONTENT-AUTOMATION.md](./docs/CONTENT-AUTOMATION.md) | Pipeline de création de contenu |
| [docs/USER-STORIES.md](./docs/USER-STORIES.md) | User stories détaillées |
| [docs/ROADMAP.md](./docs/ROADMAP.md) | Roadmap produit |
| [docs/CODE-REVIEW.md](./docs/CODE-REVIEW.md) | Revue de code — bugs et incohérences à adresser |

---

## 👥 Équipe

- **Pierre Raymond** — Product Owner
- **Camélia Raymond** — Lead Dev

---

## 📊 Status (v0.6.0)

✅ **Sprint 0** — Setup + contenu Saint-Lambert (81 POIs, 243 scripts)
✅ **Sprint 1** — Carte OSM + POIs + filtres par catégorie + vue liste
✅ **Sprint 2** — Lecture audio (tap), mini-player, background/lock screen
✅ **Sprint 3** — Mode découverte: GPS auto-trigger, notifications, POIs visités, cooldown
✅ **Revue de code** — 20 correctifs appliqués (GPS arrière-plan, position live, etc.) — voir [docs/CODE-REVIEW.md](./docs/CODE-REVIEW.md)
✅ **Polish pré-terrain (v0.5.0)** — voix Edge TTS branchées + téléchargement par ville, tuiles CARTO retina + attribution, clustering, cercles de rayon en mode découverte, dark mode, police Nunito, splash screen, onboarding, animations Hero, photos de villes (migration 002)
✅ **Sprint 7** — UI multilingue FR/EN/ES (flutter gen-l10n), noms et catégories localisés
✅ **Sprint 8** — Onboarding 4 écrans (avec choix de langue), permissions localisées, À propos
✅ **Sprint 9** — « Écouter ensemble »: sessions de groupe par code + QR via Supabase Realtime (host contrôle la lecture) — à valider à plusieurs appareils
⏳ **Sprint 4** — Test terrain à Saint-Lambert (balade libre) ← **prochaine étape humaine**
✅ **Rétention & confort terrain (v0.7.x)** — progression par ville sur l'accueil, favoris, ±10 s (MP3), reprise après interruption (appel/GPS), pause si écouteurs débranchés, guide batterie Android
✅ **Sprint 5** — Mode offline complet : cache write-through (sqflite) + tuiles de carte sur disque + « Télécharger la ville » (données + audios + carte)
