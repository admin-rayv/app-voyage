# 🏗️ ARCHITECTURE — App Voyage

> Documentation technique: données, workflows, stack

---

## Modèle de données

### Entités principales

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    City     │────<│   Parcours  │────<│    Point    │
└─────────────┘     └─────────────┘     └─────────────┘
                           │                   │
                           │                   │
                    ┌──────▼──────┐     ┌──────▼──────┐
                    │   Audio     │     │   Audio     │
                    │ (intro/outro)│     │  (contenu)  │
                    └─────────────┘     └─────────────┘
```

### City (Ville)
| Champ | Type | Description |
|-------|------|-------------|
| id | UUID | Identifiant unique |
| name | string | Nom de la ville |
| country | string | Pays |
| region | string | Province/État |
| center_lat | float | Latitude du centre |
| center_lng | float | Longitude du centre |
| timezone | string | Fuseau horaire |
| languages | string[] | Langues disponibles |
| created_at | timestamp | Date de création |

### Parcours (Route/Tour)
| Champ | Type | Description |
|-------|------|-------------|
| id | UUID | Identifiant unique |
| city_id | UUID | FK → City |
| name | object | {fr: "...", en: "..."} |
| description | object | {fr: "...", en: "..."} |
| theme | string | "historical", "cultural", "food", "art"... |
| difficulty | string | "easy", "moderate", "challenging" |
| duration_min | int | Durée estimée en minutes |
| distance_m | int | Distance en mètres |
| transport_modes | string[] | ["walk", "bike", "car"] |
| is_premium | boolean | Gratuit ou payant |
| price_cad | float | Prix si premium (nullable) |
| intro_audio_id | UUID | FK → Audio (intro du parcours) |
| outro_audio_id | UUID | FK → Audio (conclusion) |
| cover_image_url | string | Image de couverture |
| status | string | "draft", "review", "published" |
| created_at | timestamp | |
| published_at | timestamp | |

### Point (Point d'intérêt)
| Champ | Type | Description |
|-------|------|-------------|
| id | UUID | Identifiant unique |
| parcours_id | UUID | FK → Parcours |
| order | int | Position dans le parcours (1, 2, 3...) |
| name | object | {fr: "...", en: "..."} |
| lat | float | Latitude |
| lng | float | Longitude |
| trigger_radius_m | int | Rayon de déclenchement (défaut: 30m) |
| type | string | "building", "monument", "area", "viewpoint"... |
| audio_id | UUID | FK → Audio |
| duration_sec | int | Durée de l'audio en secondes |
| image_url | string | Photo du lieu (optionnel) |
| created_at | timestamp | |

### Audio
| Champ | Type | Description |
|-------|------|-------------|
| id | UUID | Identifiant unique |
| language | string | "fr", "en", "es" |
| script | text | Texte du script (pour référence) |
| voice_id | string | ID de la voix utilisée (ElevenLabs) |
| file_url | string | URL du fichier audio (storage) |
| file_size_bytes | int | Taille pour calcul download |
| duration_sec | int | Durée en secondes |
| status | string | "generating", "ready", "error" |
| created_at | timestamp | |

### User & Payments
> ⏳ **Reporté** — On utilise Supabase Auth natif pour l'authentification.
> Les tables User/Purchase seront ajoutées quand on implémente les paiements.

---

## Workflow de génération du contenu

### Vue d'ensemble

```
┌──────────────────────────────────────────────────────────────────┐
│                    WORKFLOW DE CRÉATION                          │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. RECHERCHE        2. SCRIPT           3. AUDIO               │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐          │
│  │ Identifier  │───>│ Générer     │───>│ Générer     │          │
│  │ les POIs    │    │ scripts AI  │    │ audio TTS   │          │
│  └─────────────┘    └─────────────┘    └─────────────┘          │
│        │                  │                  │                   │
│        ▼                  ▼                  ▼                   │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐          │
│  │ Coordonnées │    │ Review &    │    │ Upload      │          │
│  │ GPS         │    │ édition     │    │ storage     │          │
│  └─────────────┘    └─────────────┘    └─────────────┘          │
│                                              │                   │
│  4. VALIDATION                               │                   │
│  ┌─────────────────────────────────────────┐│                   │
│  │ Test sur le terrain (marcher le         ││                   │
│  │ parcours, ajuster les trigger radius)   ││                   │
│  └─────────────────────────────────────────┘│                   │
│                           │                  │                   │
│                           ▼                  ▼                   │
│                    ┌─────────────────────────┐                   │
│                    │      PUBLICATION        │                   │
│                    └─────────────────────────┘                   │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### Étape 1: Recherche & Identification des POIs

**Input:** Ville + thème du parcours  
**Output:** Liste de points avec coordonnées GPS

| Qui | Quoi | Comment |
|-----|------|---------|
| AI (Claude) | Identifier 10-15 points d'intérêt | Recherche web, données historiques |
| AI | Obtenir coordonnées GPS précises | Google Maps, OpenStreetMap |
| Humain | Valider la sélection | Review, ajout/retrait de points |

**Format de sortie:**
```json
{
  "parcours": "Vieux-Montréal historique",
  "points": [
    {
      "order": 1,
      "name": "Place Jacques-Cartier",
      "lat": 45.5075,
      "lng": -73.5520,
      "type": "area",
      "why": "Point de départ idéal, cœur du Vieux-Montréal"
    }
  ]
}
```

### Étape 2: Génération des scripts

**Input:** Liste de points + ton souhaité  
**Output:** Scripts audio pour chaque point (FR + EN)

| Qui | Quoi | Comment |
|-----|------|---------|
| AI (Claude) | Générer script par point | Prompt avec ton "ami historien passionné" |
| AI | Traduire en anglais | Traduction naturelle, pas littérale |
| Humain | Review & édition | Corriger erreurs, ajuster le ton |

**Contraintes de script:**
- Durée: 60-90 secondes parlé (~150-200 mots)
- Ton: Conversationnel, passionné, anecdotes
- Éviter: Dates trop précises, info ennuyante
- Inclure: "Tu vois...", "Imagine...", questions rhétoriques

**Template de prompt:**
```
Tu es un guide touristique passionné d'histoire. Tu parles comme un ami 
qui fait découvrir sa ville à quelqu'un. Ton style:
- Conversationnel, pas académique
- Tu tutois
- Tu racontes des anecdotes, des secrets
- Tu poses des questions rhétoriques
- Tu utilises "Tu vois...", "Imagine...", "Le truc fou c'est..."

Génère un script audio de 150-200 mots pour: [POINT]
Contexte: [INFOS HISTORIQUES]
```

### Étape 3: Génération audio (TTS)

**Input:** Scripts validés  
**Output:** Fichiers MP3

| Qui | Quoi | Comment |
|-----|------|---------|
| AI (ElevenLabs) | Convertir script → audio | API TTS, voix sélectionnée |
| Système | Upload vers storage | Supabase Storage ou S3 |
| Système | Mettre à jour BD | URLs, durées, tailles |

**Configuration TTS:**
- Service: ElevenLabs (qualité supérieure)
- Voix FR: [À sélectionner - voix masculine chaleureuse?]
- Voix EN: [À sélectionner]
- Format: MP3 128kbps (bon ratio qualité/taille)
- Fallback: Google Cloud TTS (moins cher, moins naturel)

### Étape 4: Validation terrain

**Input:** Parcours complet dans l'app  
**Output:** Parcours validé et ajusté

| Qui | Quoi | Comment |
|-----|------|---------|
| Humain | Marcher le parcours | App en mode test |
| Humain | Noter les problèmes | Timing, radius, ordre |
| Humain | Ajuster | Modifier radius, réordonner points |

**Checklist validation:**
- [ ] L'audio se déclenche au bon moment
- [ ] Pas de chevauchement entre points trop proches
- [ ] Le parcours est logique (pas de retour en arrière)
- [ ] Durée totale correspond à l'estimé
- [ ] Audio audible même avec bruit ambiant

---

## Stack technique (proposition)

### Mobile App
| Composant | Technologie | Justification |
|-----------|-------------|---------------|
| Framework | React Native | JS/TS, une codebase iOS+Android |
| Navigation | React Navigation | Standard RN |
| State | Zustand | Simple, performant |
| Maps | react-native-maps + Mapbox | Customisation, offline |
| Audio | react-native-track-player | Background audio, lock screen |
| Géolocation | react-native-geolocation | Précision, background |
| Storage local | react-native-mmkv | Rapide, pour préfs |
| DB locale | WatermelonDB | Offline-first, sync |

### Backend
| Composant | Technologie | Justification |
|-----------|-------------|---------------|
| Base de données | Supabase (PostgreSQL) | Gratuit, facile, realtime |
| Auth | Supabase Auth | Google/Apple Sign-In natif |
| **Storage audio** | **Cloudinary** | 25GB gratuit, CDN, séparé de la DB |
| API | Supabase auto-generated | REST + Realtime |
| Sync multi-appareils | Supabase Realtime | WebSockets intégrés |

> **Note:** Cloudinary pour les audios permet de ne pas surcharger Supabase Storage 
> et offre un CDN performant pour le streaming/download.

### Génération contenu
| Composant | Technologie | Justification |
|-----------|-------------|---------------|
| Scripts | Claude API | Qualité, ton naturel |
| TTS | ElevenLabs API | Voix très naturelles |
| Backup TTS | Google Cloud TTS | Moins cher si besoin |

### Infra
| Composant | Technologie |
|-----------|-------------|
| CI/CD | GitHub Actions |
| Distribution iOS | TestFlight → App Store |
| Distribution Android | Google Play Console |

---

## Flux utilisateur détaillé

### Premier lancement

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Splash    │────>│ Onboarding  │────>│ Permissions │
│   Screen    │     │  (3 slides) │     │    GPS      │
└─────────────┘     └─────────────┘     └─────────────┘
                                              │
                    ┌─────────────┐           │
                    │   Home      │<──────────┘
                    │  (carte)    │
                    └─────────────┘
```

### Parcours utilisateur principal

```
HOME (carte)
    │
    ├──> [Voir parcours disponibles]
    │         │
    │         ▼
    │    LISTE PARCOURS
    │         │
    │         ├──> [Sélectionner un parcours]
    │         │         │
    │         │         ▼
    │         │    DÉTAIL PARCOURS
    │         │    - Description
    │         │    - Durée/distance
    │         │    - Preview carte
    │         │    - [Télécharger] si pas offline
    │         │    - [Démarrer]
    │         │         │
    │         │         ▼
    │         │    MODE VISITE ACTIVE
    │         │    - Carte avec position
    │         │    - Points à venir
    │         │    - Contrôles audio
    │         │    - [Quitter parcours]
    │         │         │
    │         │         ├──> [Arrivée zone POI]
    │         │         │         │
    │         │         │         ▼
    │         │         │    🔔 Notification
    │         │         │    ▶️ Audio auto-play
    │         │         │         │
    │         │         │         ▼
    │         │         │    (Continuer vers prochain)
    │         │         │
    │         │         └──> [Fin du parcours]
    │         │                   │
    │         │                   ▼
    │         │              ÉCRAN FIN
    │         │              - Félicitations
    │         │              - Stats (temps, distance)
    │         │              - [Retour home]
    │         │
    │         └──> [Retour]
    │
    └──> [Paramètres]
              │
              ▼
         SETTINGS
         - Langue (FR/EN)
         - Mode transport
         - Volume/notifications
         - Compte (V1)
```

---

## Décisions techniques

| Question | Décision | Justification |
|----------|----------|---------------|
| **Framework mobile** | **Flutter** | Meilleure performance native, idéal pour GPS/audio background à long terme |
| **Maps** | Mapbox | Plus customisable, supporte offline maps |
| **Storage audio** | Cloudinary | 25GB gratuit, CDN, séparé de Supabase |
| **Auth** | Supabase Auth natif | Pas de table User custom pour l'instant |
| Format audio | MP3 128kbps | Compatibilité universelle |

### Pourquoi Flutter > React Native pour ce projet

| Critère | Flutter | React Native |
|---------|---------|--------------|
| Performance GPS background | ✅ Natif | ⚠️ Bridge JS |
| Audio background + lock screen | ✅ Natif | ⚠️ Libs tierces |
| Compilation | ARM natif | JavaScript bridge |
| Long terme | Google maintient | Meta... moyennement |
| Courbe d'apprentissage | Dart (nouveau) | JS (connu) |

Flutter demande d'apprendre Dart, mais pour une app avec beaucoup de features natives (GPS, audio, notifications), c'est le meilleur choix à long terme.

## Questions ouvertes restantes

| Question | Options | Status |
|----------|---------|--------|
| Voix TTS française? | Tester plusieurs voix ElevenLabs | **À tester** |
| Radius trigger par défaut? | 20m? 30m? 50m? | **À tester terrain** |
| Nom de l'app? | Wandr, CityWhisper, Écho... | **À décider** |

---

*Dernière mise à jour: 2026-02-12*
