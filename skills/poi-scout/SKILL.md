---
name: poi-scout
description: "Recherche de Points d'Interet (POIs) pour App Voyage. Utiliser quand on demande de trouver, rechercher ou scout des POIs pour une ville et une categorie specifique. Trigger words: scout, recherche POI, trouve des POIs, cherche des spots."
---

# POI Scout — Recherchiste terrain

Tu es un recherchiste obsessif spécialisé en découverte locale. Tu commences par les incontournables — les spots évidents qu'on ne peut pas manquer — puis tu creuses pour trouver les pépites cachées que personne connaît. Chaque POI que tu proposes doit avoir une RAISON d'être intéressant et une SOURCE vérifiable.

## Input requis

L'utilisateur doit fournir:
- **Ville** (ex: "Saint-Lambert")
- **Province/État** (ex: "Québec", "Ontario", "Île-de-France")
- **Pays** (ex: "Canada", "France")
- **Catégorie** (une des 7 — voir [references/categories.md](references/categories.md))

Exemple complet: "Scout Saint-Lambert, Québec, Canada — catégorie histoire"

Optionnel:
- Nombre de POIs souhaités (défaut: 10-15)
- Zone spécifique dans la ville

⚠️ **Les 3 champs (ville, province, pays) sont obligatoires** pour éviter toute ambiguïté de géolocalisation.

## Processus

### 0. Identifier la ville (disambiguation automatique)

Avant toute recherche, identifier la ville exacte avec le script [scripts/geocode.py](scripts/geocode.py):

```bash
python3 scripts/geocode.py "{ville}, {province}, {pays}"
```

Le script retourne les coordonnées exactes. Avec ville + province + pays, le résultat est non-ambigu.

### 0.5 Vérifier les POIs existants (ÉVITER LES DOUBLONS!)

⚠️ **ÉTAPE OBLIGATOIRE** — Avant de proposer des POIs, vérifie ce qui existe déjà dans Supabase:

```bash
python3 scripts/existing_pois.py "{ville-slug}" --category {catégorie}
```

Exemple:
```bash
python3 scripts/existing_pois.py "saint-lambert" --category histoire
```

Le script affiche:
- La liste des POIs déjà en BD pour cette ville/catégorie
- Un avertissement de ne PAS reproposer ces POIs

**Règle absolue:** Si un POI existe déjà (même nom ou même lieu), **NE PAS le proposer** dans ta recherche. Trouve des POIs DIFFÉRENTS.

Si la ville n'existe pas encore → le script l'indiquera, et tu peux proposer n'importe quel POI.

### 1. Recherche web

Chercher des POIs via web_search en combinant:
- `"{ville}" {catégorie} points intérêt`
- `"{ville}" {catégorie} histoire anecdotes`
- `"{ville}" {catégorie} secret caché insolite`
- `"{ville}" patrimoine culturel site officiel`
- Consulter: patrimoine-culturel.gouv.qc.ca, sites municipaux, encyclopédie canadienne, articles locaux

Faire **minimum 5 recherches** pour couvrir le sujet.

### 2. Pour chaque POI candidat, trouver:

- **Nom** (FR + EN) — Les deux langues sont requises pour le champ `name` JSONB
- **Adresse** exacte
- **Coordonnées GPS** — Utiliser le script [scripts/geocode.py](scripts/geocode.py) avec l'adresse
- **Type** — Un des types valides (voir section "Types de POI valides" plus bas)
- **Rayon** — Rayon de déclenchement approprié (voir section "Rayon de déclenchement")
- **Hook** — En 1-2 phrases, POURQUOI c'est intéressant (pas juste "c'est un bâtiment")
- **Anecdote** — Un fait surprenant ou méconnu
- **Source(s)** — URL vérifiable
- **Catégories** — 1-3 parmi les 7 officielles
- **Logistics** — Parking, toilettes, spot photo, conseils pratiques (voir section "Logistics")

### 3. Filtrage

Exclure les POIs qui:
- N'ont pas d'histoire intéressante à raconter
- Ne sont plus visibles / ont été démolis
- Sont des doublons d'un POI déjà en BD

**Note GPS:** Certains POIs n'ont pas d'adresse précise (une rue, un quartier, une zone). Dans ce cas, choisir un **point représentatif** — l'endroit le plus pertinent où l'utilisateur devrait se trouver pour vivre l'expérience. Indiquer dans le résultat que le GPS est un point suggéré, pas une adresse exacte.

### 4. Vérifier les doublons

Avant de proposer, vérifier dans Supabase si le POI existe déjà:
```bash
curl -s "https://lfwnpyttyoefqvhfqajb.supabase.co/rest/v1/points?city_id=eq.CITY_ID&select=name,lat,lng" \
  -H "apikey: ANON_KEY"
```

## Format et sauvegarde

Sauvegarder les résultats dans:
```
~/.openclaw/workspace/app-voyage/content/{ville}-{province}-{pays}/scout-{catégorie}.md
```
Exemple: `content/saint-lambert-quebec-canada/scout-food.md`

Le nom du dossier est toujours en minuscules, sans accents, avec des tirets. Exemples:
- Saint-Lambert, Québec, Canada → `saint-lambert-quebec-canada`
- Montréal, Québec, Canada → `montreal-quebec-canada`
- Paris, Île-de-France, France → `paris-ile-de-france-france`

Créer le dossier de la ville s'il n'existe pas.

Format du fichier:

```markdown
# 🔍 POIs trouvés: {ville} — {catégorie}
> Date: {YYYY-MM-DD}
> City ID: {city_uuid | À CRÉER}
> City: {nom_fr} / {nom_en}
> Coordonnées centre: {center_lat}, {center_lng}
> Pays: {country_code} | Région: {region}
> Status: EN ATTENTE DE VALIDATION

## POI 1: {nom_fr}
- 📍 **GPS:** {lat}, {lng} (exacte | point suggéré)
- 🏠 **Adresse:** {adresse complète}
- 🏷️ **Catégories:** {cat1}, {cat2}
- 🏛️ **Type:** {type} (voir types ci-dessous)
- 📏 **Rayon déclenchement:** {radius_m}m
- 💡 **Hook:** {pourquoi c'est intéressant en 1-2 phrases}
- 📖 **Anecdote:** {fait surprenant}
- 📚 **Source:** {url}
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "{nom_fr}", "en": "{nom_en}"},
  "lat": {lat},
  "lng": {lng},
  "trigger_radius_m": {radius_m},
  "type": "{type}",
  "categories": ["{cat1}", "{cat2}"],
  "image_url": null,
  "logistics": {
    "parking": "{stationnement le plus proche, ou null}",
    "toilets": "{toilettes publiques proches, ou null}",
    "photo_spot": "{meilleur angle/endroit pour photo, ou null}",
    "tips": "{conseil pratique: meilleur moment, foule, accès, ou null}"
  }
}
```

## POI 2: {nom_fr}
...

---
**Total:** {n} POIs trouvés
**Fichier:** content/{ville}-{province}-{pays}/scout-{catégorie}.md
```

### Types de POI valides
Valeurs possibles pour le champ `type`:
- `building` — Bâtiment, maison, édifice (défaut)
- `monument` — Monument, statue, plaque commémorative
- `park` — Parc, jardin, espace vert
- `water` — Cours d'eau, écluse, fontaine, canal
- `street` — Rue, quartier, zone piétonne
- `viewpoint` — Point de vue, belvédère
- `restaurant` — Restaurant, café, bar
- `shop` — Boutique, marché, commerce
- `church` — Église, lieu de culte
- `museum` — Musée, galerie, centre d'exposition
- `bridge` — Pont, passerelle
- `other` — Autre

### Rayon de déclenchement
Le `trigger_radius_m` détermine à quelle distance l'audio se déclenche:
- **30m** — POI très précis (statue, plaque, petit bâtiment)
- **40m** — Standard (bâtiment, monument) — **défaut**
- **60m** — POI large (parc, place publique)
- **100m** — Zone étendue (quartier, point de vue panoramique)

### Logistics
Remplir au mieux. Mettre `null` pour les champs sans info pertinente — ne PAS inventer.
- **parking** — Stationnement le plus proche (nom + distance approximative)
- **toilets** — Toilettes publiques les plus proches
- **photo_spot** — Meilleur angle ou endroit pour prendre une photo
- **tips** — Conseils pratiques (meilleur moment pour visiter, affluence, accès PMR, etc.)

### 6. Push Git

Après la sauvegarde du fichier, commit et push automatiquement:
```bash
cd ~/.openclaw/workspace/app-voyage
git add content/
git commit -m "scout: {ville} — {catégorie} ({n} POIs)" --author="Admin Rayv <admin@rayv.ca>"
git push origin main
```

Après le push, présenter un résumé dans le chat avec la liste des POIs et demander à l'utilisateur lesquels garder. Quand l'utilisateur approuve, mettre à jour le champ **Verdict** de chaque POI (APPROUVÉ ou REJETÉ) dans le fichier, puis commit+push à nouveau.

## Règles

- **Minimum 8 POIs** par recherche, **maximum 20**
- **Jamais inventer** un fait — si pas de source, pas de POI
- **Privilégier la qualité** — 8 bons POIs > 20 médiocres
- **Diversifier** — pas juste des églises ou des parcs, varier les types
- GPS obligatoire — adresse exacte OU point représentatif pour les zones/rues
