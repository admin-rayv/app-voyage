# 🏗️ ARCHITECTURE — App Voyage

> Documentation technique: données, workflows, stack

*Dernière mise à jour: 2026-03-15*

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
| 🇫🇷 FR | Amélie (québécois), Thomas | Voix FR Google |
| 🇬🇧 EN | Samantha, Daniel | Voix EN Google |
| 🇪🇸 ES | Paulina, Jorge | Voix ES Google |

Le `TtsService` sélectionne automatiquement la meilleure voix disponible (Enhanced > Premium > Standard).

### Architecture audio

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   Supabase   │───>│ AudioService │───>│  TtsService  │
│  (scripts)   │    │   (bridge)   │    │ (flutter_tts)│
└──────────────┘    └──────────────┘    └──────────────┘
     texte              orchestre           voix native
```

1. `AudioService.playScript(scriptId)` — récupère le texte depuis Supabase
2. Détecte la langue du script (`fr`, `en`, `es`)
3. `TtsService.speak(text, language)` — lit le texte avec la voix native appropriée

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

### Téléchargement offline

```
1. User sélectionne une ville + langue
2. App télécharge depuis Supabase:
   - Points (coords, noms, catégories)
   - Scripts (texte) pour la langue choisie
3. Stocke en SQLite local
4. Télécharge tiles carte Mapbox (offline)
5. TTS fonctionne nativement → pas besoin de MP3
```

---

## Stack technique

### Mobile App (Flutter)

| Composant | Package | Rôle |
|-----------|---------|------|
| Framework | Flutter | UI + logique native |
| State | flutter_riverpod | State management |
| Maps | mapbox_maps_flutter | Cartes + offline tiles |
| Audio | flutter_tts | Lecture TTS native |
| GPS | geolocator | Position + geofencing |
| Permissions | permission_handler | GPS, micro, notifs |
| Navigation | go_router | Routing |
| HTTP | dio | Requêtes API |
| DB locale | sqflite | Cache offline |
| Storage | path_provider | Fichiers locaux |
| Prefs | shared_preferences | Settings user |
| Connectivity | connectivity_plus | Détection réseau |

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
│   │   ├── constants.dart      # URLs, clés, settings
│   │   ├── routes.dart         # Navigation go_router
│   │   └── theme.dart          # Thème Material
│   ├── models/                 # Data models (à créer)
│   ├── screens/
│   │   ├── home_screen.dart    # Liste des villes
│   │   ├── tour_detail_screen.dart
│   │   └── active_tour_screen.dart
│   └── services/
│       ├── audio_service.dart  # Bridge scripts → TTS
│       ├── tts_service.dart    # flutter_tts wrapper
│       ├── supabase_service.dart
│       └── location_service.dart
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
