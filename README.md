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
static const String mapboxAccessToken = 'VOTRE_MAPBOX_TOKEN';
```

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
  AudioService → TtsService → flutter_tts → Voix native du téléphone
```

**POI-first:** Les POIs sont autonomes (liés à une ville, pas à un tour). Chaque POI a un script auto-contenu par langue (FR, EN, ES).

**Audio natif:** Pas de génération MP3, pas d'API TTS externe. `flutter_tts` utilise Apple Speech (iOS) ou Google TTS (Android) — gratuit, offline, instantané.

→ Détail complet: [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md)

---

## 📁 Structure du projet

```
lib/
├── main.dart
├── config/
│   ├── constants.dart          # URLs, clés, settings GPS/audio
│   ├── routes.dart             # go_router navigation
│   └── theme.dart              # Thème Material
├── models/                     # Data models
├── screens/
│   ├── home_screen.dart        # Liste des villes
│   ├── tour_detail_screen.dart # Détail d'une ville/catégorie
│   └── active_tour_screen.dart # Mode exploration GPS
└── services/
    ├── audio_service.dart      # Bridge scripts → TTS
    ├── tts_service.dart        # Wrapper flutter_tts (voix natives)
    ├── supabase_service.dart   # Requêtes Supabase
    └── location_service.dart   # GPS + geofencing
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

---

## 👥 Équipe

- **Pierre Raymond** — Product Owner
- **Camélia Raymond** — Lead Dev

---

## 📊 Status

✅ **Sprint 0** — Setup + contenu Saint-Lambert (81 POIs, 243 scripts)
⏳ **Sprint 1** — UI de base + lecture audio + carte
