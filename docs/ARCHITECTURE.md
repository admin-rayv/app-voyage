# 🏗️ ARCHITECTURE — App Voyage

> Documentation technique: données, workflows, stack

---

## Modèle de données

### Vue d'ensemble

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    City     │────<│    Tour     │────<│    Point    │
└─────────────┘     └─────────────┘     └─────────────┘
                                              │
                                              │
                                        ┌─────▼─────┐
                                        │  Script   │
                                        │ (par lang)│
                                        └───────────┘
```

**Principe clé:** On stocke les **scripts texte**, pas les fichiers audio. L'audio est **généré à la demande** via ElevenLabs et mis en cache localement sur l'appareil.

---

### City (Ville)

| Champ | Type | Description |
|-------|------|-------------|
| id | UUID | Identifiant unique |
| slug | string | URL-friendly (ex: "montreal") |
| name | JSONB | `{"fr": "Montréal", "en": "Montreal"}` |
| country | string | Code pays (CA) |
| region | string | Province/État (QC) |
| center_lat | float | Latitude du centre |
| center_lng | float | Longitude du centre |
| timezone | string | Fuseau horaire |
| available_languages | string[] | ["fr", "en", "es"] |
| created_at | timestamp | |
| updated_at | timestamp | |

---

### Tour (Parcours)

| Champ | Type | Description |
|-------|------|-------------|
| id | UUID | Identifiant unique |
| city_id | UUID | FK → City |
| slug | string | URL-friendly |
| name | JSONB | `{"fr": "...", "en": "..."}` |
| description | JSONB | `{"fr": "...", "en": "..."}` |
| theme | string | "historical", "haunted", "foodie", "art" |
| difficulty | string | "easy", "moderate", "challenging" |
| duration_min | int | Durée estimée en minutes |
| distance_m | int | Distance en mètres |
| transport_modes | string[] | ["walk", "bike", "car"] |
| is_free | boolean | Gratuit ou payant |
| price_cad | float | Prix si payant (nullable) |
| cover_image_url | string | Image de couverture |
| status | string | "draft", "review", "published" |
| created_at | timestamp | |
| updated_at | timestamp | |
| published_at | timestamp | |

---

### Point (Point d'intérêt)

| Champ | Type | Description |
|-------|------|-------------|
| id | UUID | Identifiant unique |
| tour_id | UUID | FK → Tour |
| order_index | int | Position dans le parcours (1, 2, 3...) |
| name | JSONB | `{"fr": "...", "en": "..."}` |
| lat | float | Latitude |
| lng | float | Longitude |
| trigger_radius_m | int | Rayon de déclenchement (défaut: 30m) |
| type | string | "building", "monument", "park", "viewpoint" |
| image_url | string | Photo du lieu (optionnel) |
| logistics | JSONB | Voir détail ci-dessous |
| created_at | timestamp | |
| updated_at | timestamp | |

**Champ `logistics` (JSONB):**
```json
{
  "parking": "Stationnement Champ-de-Mars à 200m",
  "toilets": "Toilettes publiques au Marché Bonsecours",
  "photo_spot": "Meilleur angle depuis le coin sud-est",
  "tips": "Éviter entre 12h-14h (très achalandé)"
}
```

---

### Script (Contenu audio par langue)

> **C'est la table clé!** On stocke le texte, pas l'audio.

| Champ | Type | Description |
|-------|------|-------------|
| id | UUID | Identifiant unique |
| point_id | UUID | FK → Point |
| language | string | "fr", "en", "es" |
| content | text | **Le script complet à narrer** |
| voice_id | string | ID voix ElevenLabs pour cette langue |
| voice_settings | JSONB | `{"stability": 0.5, "clarity": 0.75}` |
| estimated_duration_sec | int | Durée estimée (~150 mots = 60 sec) |
| word_count | int | Nombre de mots (calculé) |
| persona | string | "jacques", "sarah", "narrator" |
| created_at | timestamp | |
| updated_at | timestamp | |

**Index:**
- `(point_id, language)` — UNIQUE
- `point_id` — Pour récupérer tous les scripts d'un point

**Exemple de contenu:**
```
Tu vois ce bâtiment juste devant toi? C'est l'Hôtel de Ville de Montréal. 
Construit en 1878, il a failli disparaître dans un incendie en 1922. 

Le truc fou, c'est que c'est ici que le général de Gaulle a lancé son 
fameux "Vive le Québec libre!" en 1967, depuis ce balcon juste là. 
Imagine la scène... 

Petit conseil: si t'as le temps, jette un œil à l'intérieur. 
L'entrée est gratuite et le hall d'honneur vaut vraiment le détour.
```

---

### VoiceConfig (Configuration des voix)

| Champ | Type | Description |
|-------|------|-------------|
| id | UUID | |
| language | string | "fr", "en", "es" |
| persona | string | "jacques", "sarah", "narrator" |
| elevenlabs_voice_id | string | ID technique ElevenLabs |
| voice_name | string | Nom lisible |
| default_settings | JSONB | Settings par défaut |
| is_active | boolean | |

---

### AudioCache (Tracking du cache local — optionnel)

> Table pour tracker ce qui a été généré (côté serveur, optionnel)

| Champ | Type | Description |
|-------|------|-------------|
| id | UUID | |
| script_id | UUID | FK → Script |
| generated_at | timestamp | Dernière génération |
| duration_sec | int | Durée réelle de l'audio |
| file_hash | string | Hash pour invalidation cache |

---

## Workflow de génération audio

### Nouveau principe: Génération à la demande

```
┌─────────────────────────────────────────────────────────────────────┐
│                    WORKFLOW AUDIO                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  CRÉATION (une seule fois)                                          │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐          │
│  │  Recherche   │───>│   Rédiger    │───>│   Traduire   │          │
│  │    POIs      │    │  Script FR   │    │   EN, ES...  │          │
│  └──────────────┘    └──────────────┘    └──────────────┘          │
│                             │                    │                  │
│                             ▼                    ▼                  │
│                      ┌─────────────────────────────┐                │
│                      │   Stocker dans Supabase     │                │
│                      │   (table scripts - TEXTE)   │                │
│                      └─────────────────────────────┘                │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  UTILISATION (à chaque téléchargement)                              │
│                                                                     │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐          │
│  │ User clique  │───>│ Edge Function│───>│  ElevenLabs  │          │
│  │ "Télécharger"│    │ (Supabase)   │    │     API      │          │
│  └──────────────┘    └──────────────┘    └──────────────┘          │
│                                                 │                   │
│                                                 ▼                   │
│                                          ┌──────────────┐          │
│                                          │   Audio MP3   │          │
│                                          │   (stream)    │          │
│                                          └──────────────┘          │
│                                                 │                   │
│                                                 ▼                   │
│                                          ┌──────────────┐          │
│                                          │ Cache local  │          │
│                                          │  (device)    │          │
│                                          └──────────────┘          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Avantages de cette approche

| Avantage | Explication |
|----------|-------------|
| ✅ **Multi-langue facile** | Ajouter une langue = traduire le texte, pas re-générer des MP3 |
| ✅ **Pas de stockage cloud** | Pas de Cloudinary, pas de S3, pas de coûts de stockage |
| ✅ **Contenu toujours à jour** | Modifier un script → audio mis à jour au prochain download |
| ✅ **Voix modifiable** | Changer de voix sans re-générer manuellement |
| ✅ **Scalable** | 100 langues = juste du texte dans la DB |

### Inconvénients gérables

| Inconvénient | Solution |
|--------------|----------|
| Coût TTS par génération | Cache agressif côté device + hash pour éviter re-génération |
| Temps de téléchargement | Génération parallèle + progress bar |
| Dépendance ElevenLabs | Fallback Google Cloud TTS si nécessaire |

---

## Flux de téléchargement d'un parcours

```
┌─────────────────────────────────────────────────────────────────┐
│                  TÉLÉCHARGEMENT PARCOURS                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. User sélectionne langue (FR)                                │
│  2. User clique "Télécharger"                                   │
│                     │                                           │
│                     ▼                                           │
│  3. App récupère métadonnées du parcours (Supabase)             │
│     - Tour info                                                 │
│     - Points (coords, noms)                                     │
│     - Scripts FR pour chaque point                              │
│                     │                                           │
│                     ▼                                           │
│  4. Pour chaque script:                                         │
│     ┌─────────────────────────────────────────┐                 │
│     │  a. Check cache local (hash du script)  │                 │
│     │     → Si existe et hash identique: skip │                 │
│     │                                         │                 │
│     │  b. Sinon: appeler Edge Function        │                 │
│     │     → POST /functions/v1/generate-audio │                 │
│     │     → Body: { script_id, language }     │                 │
│     │                                         │                 │
│     │  c. Edge Function:                      │                 │
│     │     → Récupère script depuis DB         │                 │
│     │     → Appelle ElevenLabs API            │                 │
│     │     → Retourne stream audio             │                 │
│     │                                         │                 │
│     │  d. App sauvegarde MP3 localement       │                 │
│     │     → /app/cache/tour-{id}/point-{n}.mp3│                 │
│     └─────────────────────────────────────────┘                 │
│                     │                                           │
│                     ▼                                           │
│  5. Télécharger tiles carte Mapbox (offline)                    │
│                     │                                           │
│                     ▼                                           │
│  6. Marquer parcours comme "téléchargé"                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Edge Function: generate-audio

```typescript
// supabase/functions/generate-audio/index.ts

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { script_id } = await req.json()
  
  // 1. Récupérer le script depuis Supabase
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )
  
  const { data: script } = await supabase
    .from('scripts')
    .select('content, voice_id, voice_settings')
    .eq('id', script_id)
    .single()
  
  // 2. Appeler ElevenLabs
  const response = await fetch(
    `https://api.elevenlabs.io/v1/text-to-speech/${script.voice_id}`,
    {
      method: 'POST',
      headers: {
        'xi-api-key': Deno.env.get('ELEVENLABS_API_KEY')!,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        text: script.content,
        model_id: 'eleven_multilingual_v2',
        voice_settings: script.voice_settings
      })
    }
  )
  
  // 3. Streamer l'audio vers le client
  return new Response(response.body, {
    headers: {
      'Content-Type': 'audio/mpeg',
      'Cache-Control': 'public, max-age=31536000' // 1 an
    }
  })
})
```

---

## Gestion du cache local (device)

### Structure de cache

```
/app_data/
└── cache/
    └── tours/
        └── {tour_id}/
            ├── manifest.json      # Hash des scripts pour invalidation
            ├── point_001_fr.mp3
            ├── point_002_fr.mp3
            └── ...
```

### Manifest.json

```json
{
  "tour_id": "abc-123",
  "language": "fr",
  "downloaded_at": "2026-02-17T10:00:00Z",
  "points": [
    {
      "point_id": "point-001",
      "script_hash": "sha256:abc123...",
      "file": "point_001_fr.mp3",
      "duration_sec": 65
    }
  ]
}
```

### Logique d'invalidation

```dart
// Pseudo-code Flutter

Future<void> downloadTour(String tourId, String language) async {
  // 1. Récupérer les scripts actuels
  final scripts = await supabase
    .from('scripts')
    .select('id, point_id, content')
    .eq('tour.id', tourId)
    .eq('language', language);
  
  // 2. Charger le manifest local (si existe)
  final manifest = await loadManifest(tourId);
  
  for (final script in scripts) {
    final currentHash = sha256(script.content);
    final cachedHash = manifest?.getHash(script.point_id);
    
    // 3. Générer seulement si nouveau ou modifié
    if (cachedHash != currentHash) {
      final audio = await generateAudio(script.id);
      await saveToCache(tourId, script.point_id, audio);
      manifest.updateHash(script.point_id, currentHash);
    }
  }
  
  await saveManifest(tourId, manifest);
}
```

---

## Stack technique mise à jour

### Mobile App (Flutter)

| Composant | Technologie | Note |
|-----------|-------------|------|
| Framework | Flutter | Performance native |
| State | Riverpod | State management |
| Maps | Mapbox | Offline maps |
| Audio | just_audio | Background + lock screen |
| GPS | geolocator | Background location |
| Cache | path_provider + sqflite | Stockage local |
| HTTP | dio | Requêtes API |

### Backend (Supabase)

| Composant | Technologie | Note |
|-----------|-------------|------|
| Database | PostgreSQL | Scripts stockés en texte |
| Auth | Supabase Auth | Google/Apple Sign-In |
| Edge Functions | Deno | Génération audio |
| Realtime | Supabase Realtime | Sync groupe |

### Externe

| Composant | Technologie | Note |
|-----------|-------------|------|
| TTS | ElevenLabs | Voix naturelles |
| TTS Fallback | Google Cloud TTS | Si ElevenLabs down |
| Traduction | Claude/GPT | Pour nouvelles langues |

### Ce qu'on n'utilise PLUS

| ❌ Avant | Pourquoi supprimé |
|----------|-------------------|
| Cloudinary | Plus de stockage MP3 cloud |
| Table audio_files | Remplacée par scripts |
| Upload manuel MP3 | Génération automatique |

---

## Coûts estimés

### ElevenLabs (TTS)

| Métrique | Valeur |
|----------|--------|
| Prix | ~$0.30 / 1000 caractères |
| Script moyen | ~800 caractères (150 mots) |
| Coût par script | ~$0.24 |
| Parcours (10 points) | ~$2.40 |
| Parcours 3 langues | ~$7.20 |

**Avec cache:** Chaque script n'est généré qu'une fois par utilisateur. Si 1000 users téléchargent le même parcours FR, le coût est de $2.40 total (pas $2400).

**Stratégie:** Pré-générer les audios les plus populaires côté serveur pour réduire les coûts.

### Supabase

| Élément | Coût |
|---------|------|
| Database (500MB) | Gratuit |
| Edge Functions | Gratuit (500k invocations/mois) |
| Au-delà | ~$25/mois |

---

## Ajout d'une nouvelle langue

### Processus simplifié

1. **Traduire les scripts** (humain ou AI)
   ```sql
   INSERT INTO scripts (point_id, language, content, voice_id)
   SELECT point_id, 'es', '[TRADUCTION ESPAGNOLE]', 'voice_es_maria'
   FROM scripts WHERE language = 'fr';
   ```

2. **Configurer la voix**
   ```sql
   INSERT INTO voice_config (language, persona, elevenlabs_voice_id)
   VALUES ('es', 'narrator', 'VOICE_ID_ESPAGNOL');
   ```

3. **Ajouter la langue à la ville**
   ```sql
   UPDATE cities 
   SET available_languages = array_append(available_languages, 'es')
   WHERE slug = 'montreal';
   ```

4. **Terminé!** Les utilisateurs peuvent maintenant télécharger en espagnol.

---

## Schéma SQL complet

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

-- Tours
CREATE TABLE tours (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  city_id UUID REFERENCES cities(id) ON DELETE CASCADE,
  slug TEXT NOT NULL,
  name JSONB NOT NULL,
  description JSONB NOT NULL,
  theme TEXT NOT NULL,
  difficulty TEXT DEFAULT 'easy',
  duration_min INT NOT NULL,
  distance_m INT NOT NULL,
  transport_modes TEXT[] DEFAULT ARRAY['walk'],
  is_free BOOLEAN DEFAULT false,
  price_cad DECIMAL(10,2),
  cover_image_url TEXT,
  status TEXT DEFAULT 'draft',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  published_at TIMESTAMPTZ,
  UNIQUE(city_id, slug)
);

-- Points
CREATE TABLE points (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tour_id UUID REFERENCES tours(id) ON DELETE CASCADE,
  order_index INT NOT NULL,
  name JSONB NOT NULL,
  lat FLOAT NOT NULL,
  lng FLOAT NOT NULL,
  trigger_radius_m INT DEFAULT 30,
  type TEXT DEFAULT 'building',
  image_url TEXT,
  logistics JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(tour_id, order_index)
);

-- Scripts (NOUVELLE TABLE CLÉ)
CREATE TABLE scripts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  point_id UUID REFERENCES points(id) ON DELETE CASCADE,
  language TEXT NOT NULL,
  content TEXT NOT NULL,
  voice_id TEXT NOT NULL,
  voice_settings JSONB DEFAULT '{"stability": 0.5, "clarity": 0.75}',
  persona TEXT DEFAULT 'narrator',
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

-- Voice Config
CREATE TABLE voice_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  language TEXT NOT NULL,
  persona TEXT NOT NULL,
  elevenlabs_voice_id TEXT NOT NULL,
  voice_name TEXT NOT NULL,
  default_settings JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  UNIQUE(language, persona)
);

-- Index pour performance
CREATE INDEX idx_scripts_point_lang ON scripts(point_id, language);
CREATE INDEX idx_points_tour ON points(tour_id);
CREATE INDEX idx_tours_city ON tours(city_id);
CREATE INDEX idx_tours_status ON tours(status);
```

---

*Dernière mise à jour: 2026-02-17*
