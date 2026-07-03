# 🏗️ ARCHITECTURE — App Voyage

> Documentation technique: données, workflows, stack

*Dernière mise à jour: 2026-07-03*

---

## Modèle de données

### Vue d'ensemble

```
┌─────────────┐     ┌─────────────┐
│    City     │────<│    Point    │  ← POIs standalone, liés à une ville
└─────────────┘     └─────────────┘
                          │
                          │
                    ┌─────▼─────┐
                    │  Script   │
                    │ (par lang)│
                    └───────────┘
```

**Principes clés:**
- Les **POIs sont autonomes** — ils appartiennent à une ville (`city_id`), pas à un tour
- Les **scripts sont du texte** stocké dans Supabase
- L'audio est lu via **flutter_tts** (voix native du téléphone) — pas de génération MP3
- Chaque script est **auto-contenu** — fonctionne indépendamment, sans contexte des autres POIs

---

### City (Ville)

| Champ | Type | Description |
|-------|------|-------------|
| id | UUID | Identifiant unique |
| slug | string | URL-friendly (ex: "saint-lambert-quebec-canada") |
| name | JSONB | `{"fr": "Saint-Lambert", "en": "Saint Lambert"}` |
| country | string | Code pays (CA) |
| region | string | Province/État (QC) |
| center_lat | float | Latitude du centre |
| center_lng | float | Longitude du centre |
| timezone | string | Fuseau horaire |
| available_languages | string[] | ["fr", "en", "es"] |

---

### Point (Point d'intérêt) — Standalone

| Champ | Type | Description |
|-------|------|-------------|
| id | UUID | Identifiant unique |
| city_id | UUID | FK → City |
| name | JSONB | `{"fr": "...", "en": "..."}` |
| lat | float | Latitude |
| lng | float | Longitude |
| trigger_radius_m | int | Rayon de déclenchement (défaut: 40m) |
| type | string | "building", "monument", "park", "viewpoint" |
| categories | string[] | 7 catégories officielles (voir ci-dessous) |
| image_url | string | Photo du lieu (optionnel) |
| logistics | JSONB | Parking, toilettes, tips... |
| is_published | boolean | Visible dans l'app |

**Catégories officielles (7):**
```
histoire       → 🏛️ Patrimoine, personnages, événements
architecture   → 🏗️ Styles notables, bâtiments uniques
nature         → 🌿 Parcs, sentiers, fleuve, arbres
food           → 🍴 Restos, cafés, marchés
art            → 🎨 Murales, galeries, art public
insolite       → 👻 Légendes, secrets, weird facts
vie-locale     → 🏘️ Marchés, events, traditions
```

---

### Script (Contenu audio par langue)

| Champ | Type | Description |
|-------|------|-------------|
| id | UUID | Identifiant unique |
| point_id | UUID | FK → Point |
| language | string | "fr", "en", "es" |
| content | text | Le script complet (lu par TTS) |
| persona | string | "marco" (narrateur unique) |
| word_count | int | Calculé automatiquement |
| estimated_duration_sec | int | ~0.4 sec/mot |

**Contrainte:** `UNIQUE(point_id, language)` — un seul script par POI par langue.

---

## Audio: flutter_tts (voix native)

### Pourquoi flutter_tts?

| | flutter_tts | ElevenLabs |
|---|---|---|
| **Coût** | Gratuit | ~$0.24/script |
| **Offline** | ✅ Natif | ❌ API requise |
| **Latence** | Instantané | 1-3 sec de génération |
| **Qualité** | ⭐⭐⭐⭐ (voix Enhanced iOS) | ⭐⭐⭐⭐⭐ |
| **Maintenance** | Zéro | Edge Function + API key |

### Voix par langue

| Langue | iOS (Apple Speech) | Android (Google TTS) |
|--------|-------------------|---------------------|
| 🇫🇷 FR | Amélie (québécois), Thomas | `fr-ca-x-cac-local` (défaut) |
| 🇬🇧 EN | Samantha, Daniel | `en-us-x-tpd-local` (défaut) |
| 🇪🇸 ES | Paulina, Jorge | Fallback auto |

La sélection de voix suit l'ordre: **choix utilisateur (Settings) → voix par défaut → première voix locale → première voix de la langue**. L'utilisateur peut tester et choisir sa voix par langue dans les Paramètres.

### Architecture audio (réelle, v0.4.x)

```
┌──────────────┐   ┌──────────────┐   ┌──────────────────┐   ┌─────────────┐
│   Supabase   │──>│ AudioService │──>│ AppAudioHandler  │──>│ flutter_tts │
│  (scripts)   │   │ (état global,│   │ (audio_service:  │   │ voix native │
└──────────────┘   │  singleton)  │   │  lock screen,    │   └─────────────┘
     texte         └──────────────┘   │  background)     │
                          │           └──────────────────┘
                          └── fallback: TtsService direct si audio_service échoue
```

1. L'UI (détail POI, carte, mode découverte) appelle `AudioService.playText(...)`
2. `AudioService` délègue à `AppAudioHandler` (package `audio_service`) qui gère la notification média, les contrôles lock screen et la lecture en background
3. Le handler configure la voix via `TtsService.configureVoiceForTts()` puis lit avec `flutter_tts`
4. La progression est **estimée** (~0.4 s/mot ÷ vitesse) — flutter_tts ne fournit pas de position réelle, donc pas de seek
5. Un POI est marqué "écouté" (`VisitedPoiService`, persisté) quand la lecture atteint 50 % ou se termine naturellement

### ⚠️ EdgeTtsService — présent mais non branché

`lib/services/edge_tts_service.dart` implémente la génération de MP3 via l'API **non officielle** de Microsoft Edge TTS (WebSocket + cache local, voix `fr-CA-ThierryNeural`). Ce code n'est **jamais utilisé pour la lecture** — `playText` va toujours vers flutter_tts — et les méthodes `downloadCityAudios`/`getAudioPath` ne sont appelées par aucun écran. Décision à prendre (voir CODE-REVIEW.md): le brancher (lecture MP3 via `just_audio` + fallback natif) ou le retirer.

### Mode découverte (GPS auto-trigger)

```
LocationService (stream GPS, filtre 10 m)
      ↓
GeofencingService
  • rayon effectif dynamique selon la précision GPS (jusqu'à 2× le rayon du POI)
  • direction d'approche (historique des 5 dernières positions)
  • debounce 3 s avant confirmation + hystérésis de sortie 20 m
  • cooldown global 30 s entre triggers + file d'attente (TTL 90 s) pour POIs qui se chevauchent
  • journal des décisions (TRIGGER/SKIP/WAIT/CANCELLED) consultable dans Settings 🐛
      ↓ POI déclenché
DiscoveryPlaybackService
  • vérifie les préférences (autoplay on/off, délai 0/3/5 s, vibration)
  • ignore si lecture manuelle en cours ou en pause
  • notification de proximité + haptique → lecture automatique
```

---

## Flux utilisateur

### Découverte des POIs

```
1. User ouvre l'app
2. Sélectionne une ville (Saint-Lambert)
3. Voit la carte avec tous les POIs
4. Filtre par catégorie (histoire, food, art...)
5. Tape sur un POI → voit la description
6. Clique "Écouter" → TTS lit le script
```

### Mode GPS (automatique)

```
1. User active le mode exploration
2. GPS détecte la position en continu
3. Quand user entre dans le rayon d'un POI (40m)
4. Notification + lecture automatique du script
5. Quand user s'éloigne → stop ou continue
```

### Téléchargement offline (Sprint 5 — pas encore implémenté)

```
1. User sélectionne une ville + langue
2. App télécharge depuis Supabase:
   - Points (coords, noms, catégories)
   - Scripts (texte) pour la langue choisie
3. Stocke en SQLite local (sqflite — dépendance déjà déclarée)
4. Cache des tiles OSM (flutter_map supporte les tile providers custom)
5. TTS fonctionne nativement → pas besoin de MP3
```

**État actuel:** l'app lit les POIs et scripts directement depuis Supabase à chaque
écran — sans réseau, rien ne fonctionne encore. C'est le gros morceau du Sprint 5.

---

## Stack technique

### Mobile App (Flutter)

| Composant | Package | Rôle | Statut |
|-----------|---------|------|--------|
| Framework | Flutter | UI + logique native | ✅ Utilisé |
| Maps | **flutter_map + OSM** | Cartes (gratuit, sans clé API) | ✅ Utilisé — pivot depuis Mapbox |
| Audio TTS | flutter_tts | Lecture voix native | ✅ Utilisé (chemin principal) |
| Audio background | audio_service + audio_session | Lock screen, notification média | ✅ Utilisé |
| GPS | geolocator | Position + geofencing | ✅ Utilisé |
| Notifications | flutter_local_notifications | Alertes de proximité | ✅ Utilisé |
| Navigation | go_router | Routing | ✅ Utilisé |
| Prefs | shared_preferences | Settings, progression POIs | ✅ Utilisé |
| Connectivity | connectivity_plus | Détection réseau (Edge TTS) | ⚠️ Utilisé par du code non branché |
| Audio MP3 | just_audio | Lecture des MP3 Edge TTS | ❌ Déclaré, jamais utilisé |
| State | flutter_riverpod | State management | ⚠️ Déclaré, à peine utilisé (ProviderScope seulement) |
| DB locale | sqflite | Cache offline | ❌ Déclaré, pas encore utilisé (Sprint 5) |
| HTTP | dio | Requêtes API | ❌ Déclaré, jamais utilisé |
| Permissions | permission_handler | GPS, micro, notifs | ❌ Déclaré, jamais utilisé (géré par geolocator) |

### Backend (Supabase)

| Composant | Usage |
|-----------|-------|
| PostgreSQL | Tables cities, points, scripts |
| RLS | Sécurité row-level |
| Auth (V2) | Google/Apple Sign-In |
| Realtime (V2) | Sync mode Host |

---

## Structure du projet

```
app-voyage/
├── lib/
│   ├── main.dart
│   ├── config/
│   │   ├── constants.dart      # URLs, clés, settings GPS/audio
│   │   ├── categories.dart     # 7 catégories (labels, emojis, couleurs)
│   │   ├── routes.dart         # Navigation go_router
│   │   ├── route_data.dart     # Objets passés entre routes
│   │   └── theme.dart          # Thème Material
│   ├── models/                 # Point, City, Script, AudioState,
│   │                           # DiscoveryPlaybackResult
│   ├── screens/
│   │   ├── home_screen.dart    # Liste des villes
│   │   ├── map_screen.dart     # Carte + liste + mode découverte
│   │   ├── poi_detail_screen.dart
│   │   ├── settings_screen.dart
│   │   └── debug_voices_screen.dart
│   ├── services/
│   │   ├── audio_service.dart          # Orchestration lecture
│   │   ├── audio_handler.dart          # Handler background/lock screen
│   │   ├── tts_service.dart            # flutter_tts + sélection voix
│   │   ├── edge_tts_service.dart       # ⚠️ non branché (voir CODE-REVIEW)
│   │   ├── geofencing_service.dart     # Détection proximité GPS
│   │   ├── discovery_playback_service.dart
│   │   ├── location_service.dart
│   │   ├── permission_service.dart
│   │   ├── notification_service.dart
│   │   ├── visited_poi_service.dart
│   │   ├── user_preferences_service.dart
│   │   ├── supabase_service.dart
│   │   └── debug_log.dart
│   └── widgets/                # app_shell, mini_player, poi_list_item,
│                               # voice_setup_dialog
├── content/                    # Scripts source (markdown)
│   └── saint-lambert-quebec-canada/
│       ├── scout-histoire.md
│       ├── scout-architecture.md
│       ├── scout-nature.md
│       ├── scout-food.md
│       ├── scout-art.md
│       ├── scout-insolite.md
│       └── scout-vie-locale.md
├── skills/                     # Pipeline d'automatisation
│   ├── poi-scout/
│   ├── poi-writer/
│   ├── poi-checker/
│   └── poi-pusher/
├── supabase/
│   └── migrations/
│       └── 001_initial_schema.sql
├── docs/
│   ├── ARCHITECTURE.md         # ← Ce fichier
│   ├── CONTENT-AUTOMATION.md
│   ├── ROADMAP.md
│   ├── SPRINTS.md
│   └── USER-STORIES.md
└── pubspec.yaml
```

---

## Données actuelles (Saint-Lambert)

| Table | Entrées |
|-------|---------|
| cities | 1 (Saint-Lambert) |
| points | 81 POIs (7 catégories) |
| scripts | 243 (81 × 3 langues: FR/EN/ES) |

---

## Schéma SQL

```sql
-- Cities
CREATE TABLE cities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  name JSONB NOT NULL,
  country TEXT NOT NULL,
  region TEXT,
  center_lat FLOAT NOT NULL,
  center_lng FLOAT NOT NULL,
  timezone TEXT DEFAULT 'America/Toronto',
  available_languages TEXT[] DEFAULT ARRAY['fr', 'en'],
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Points (POIs standalone)
CREATE TABLE points (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  city_id UUID REFERENCES cities(id) ON DELETE CASCADE,
  name JSONB NOT NULL,
  lat FLOAT NOT NULL,
  lng FLOAT NOT NULL,
  trigger_radius_m INT DEFAULT 40,
  type TEXT DEFAULT 'building',
  categories TEXT[] DEFAULT '{}',
  image_url TEXT,
  logistics JSONB DEFAULT '{}',
  is_published BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Scripts (texte lu par TTS)
CREATE TABLE scripts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  point_id UUID REFERENCES points(id) ON DELETE CASCADE,
  language TEXT NOT NULL,
  content TEXT NOT NULL,
  persona TEXT DEFAULT 'marco',
  word_count INT GENERATED ALWAYS AS (
    array_length(regexp_split_to_array(content, '\s+'), 1)
  ) STORED,
  estimated_duration_sec INT GENERATED ALWAYS AS (
    array_length(regexp_split_to_array(content, '\s+'), 1) * 0.4
  ) STORED,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(point_id, language)
);

-- Index
CREATE INDEX idx_points_city ON points(city_id);
CREATE INDEX idx_points_published ON points(city_id, is_published);
CREATE INDEX idx_points_categories ON points USING GIN(categories);
CREATE INDEX idx_scripts_point_lang ON scripts(point_id, language);
```

---

## V2: Tours (collections curatées)

> Feature future: les tours deviennent des "playlists" de POIs existants.

```sql
-- Tours (V2)
CREATE TABLE tours (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  city_id UUID REFERENCES cities(id) ON DELETE CASCADE,
  slug TEXT NOT NULL,
  name JSONB NOT NULL,
  description JSONB NOT NULL,
  theme TEXT NOT NULL,
  duration_min INT NOT NULL,
  distance_m INT NOT NULL,
  price_cad DECIMAL(10,2),
  status TEXT DEFAULT 'draft',
  UNIQUE(city_id, slug)
);

-- Tour-Points (jointure many-to-many)
CREATE TABLE tour_points (
  tour_id UUID REFERENCES tours(id) ON DELETE CASCADE,
  point_id UUID REFERENCES points(id) ON DELETE CASCADE,
  order_index INT NOT NULL,
  PRIMARY KEY (tour_id, point_id)
);
```
