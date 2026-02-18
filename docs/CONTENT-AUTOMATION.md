# 🤖 AUTOMATISATION DU CONTENU — App Voyage

> Pipeline de création de contenu: Thème → Quartier → Tour → POIs

---

## Vision

**Objectif:** L'IA génère le contenu, les humains révisent et approuvent.

```
┌─────────────────────────────────────────────────────────────────┐
│                    PIPELINE DE CONTENU                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   🏙️ ANALYSE      →   🎯 THÈMES     →   🚶 TOURS    →   📍 POIs │
│   VILLE               UNIQUES           MARCHABLES      DÉTAILS │
│                                                                 │
│   • C'est quoi le     • Quartiers       • Clusters      • GPS   │
│     hook unique?        intéressants      walkables     • Script│
│   • Petite/grande?    • Angles           • 2-3km max    • Audio │
│   • Besoins?            originaux        • 8-12 stops          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🚶 Contrainte #1: Piéton d'abord

Nos utilisateurs sont **à pied**. Un tour doit être marchable.

### Paramètres par mode

| Mode | Rayon | Distance totale | Durée | POIs |
|------|-------|-----------------|-------|------|
| 🚶 **Piéton standard** | 4-5 km | 5-8 km | 2-3h | 10-15 |
| 🚶 **Piéton zone dense** | 2-3 km | 3-5 km | 1.5-2h | 8-12 |
| 🚴 **Vélo** | 8-12 km | 12-18 km | 2-3h | 12-18 |
| 🚗 **Auto (road trip)** | 20+ km | Variable | 3-5h | 8-15 |

### Quand utiliser quel rayon?

| Zone | Rayon recommandé | Exemple |
|------|------------------|---------|
| **Ultra-dense** (tout proche) | 2-3 km | Vieux-Montréal, Vieux-Québec |
| **Urbain standard** | 4-5 km | Plateau, Mile End, Centre-ville |
| **Banlieue / ville moyenne** | 4-5 km | Sainte-Julie, Longueuil |
| **Nature / parc** | 3-5 km | Mont-Royal, Parc Jean-Drapeau |

### Autres paramètres

| Paramètre | Valeur | Raison |
|-----------|--------|--------|
| **Espacement** | 200-500m entre POIs | Assez pour marcher, pas trop pour s'ennuyer |
| **Boucle** | Retour au point de départ | Pratique pour stationnement |
| **Temps par POI** | ~5-8 min | Audio (90s) + observation + photos |

**Implication:** Un tour = un quartier/cluster marchable, PAS une ville entière.

---

## Étape 0: Analyse de la ville

**AVANT de chercher des POIs**, analyser la ville.

### Questions à répondre

```markdown
## Fiche d'analyse: {VILLE}

### Taille et potentiel
- Population: ?
- Superficie: ?
- Est-ce que ça vaut plusieurs tours ou un seul suffit?

### Hook unique
- C'est quoi le truc SPÉCIAL de cette ville?
- Pourquoi un touriste irait LÀ plutôt qu'ailleurs?
- Qu'est-ce que les locaux diraient: "Ah, {ville}? C'est connu pour..."

### Quartiers/zones marchables
- Y a-t-il des quartiers distincts?
- Où sont les zones piétonnes?
- Où peut-on stationner et marcher?

### Thèmes potentiels
- Histoire/patrimoine?
- Gastronomie?
- Nature/parcs?
- Art/culture?
- Insolite/hanté?
- Architecture?

### Verdict
- [ ] MULTI-TOURS: Grande ville, plusieurs thèmes/quartiers possibles
- [ ] TOUR UNIQUE: Petite ville, un tour complet suffit
- [ ] SKIP: Pas assez de contenu pour justifier un tour
```

---

## Étape 1: Structure des tours (AVANT les POIs)

### Grandes villes (Montréal, Québec, etc.)

**Approche: Thèmes × Quartiers**

| Quartier | Thèmes possibles |
|----------|------------------|
| Vieux-Montréal | 👻 Hanté, 🏛️ Histoire, 🍷 Gastro |
| Plateau | 🎨 Street Art, 🍴 Foodies, 🏠 Architecture |
| Mile End | 🎵 Musique, ☕ Cafés, 🎨 Art |
| Mont-Royal | 🌿 Nature, 🏃 Sport, 📸 Vues |

**Résultat possible:**
- Tour 1: Vieux-Montréal Hanté (8 POIs, ~90 min)
- Tour 2: Plateau Foodies (10 POIs, ~2h)
- Tour 3: Mile End Street Art (8 POIs, ~75 min)
- Bundle: "Découverte Montréal" (3 tours, 14.99$)

### Petites villes (Sainte-Julie, etc.)

**Approche: Tour unique ou thématique simple**

Questions:
1. Y a-t-il assez pour PLUSIEURS tours? (Probablement non)
2. Quel est le SEUL angle intéressant?
3. Est-ce qu'un seul tour de 8-12 POIs couvre l'essentiel?

**Résultat possible:**
- Tour unique: "Découverte Sainte-Julie" (8 POIs, patrimoine + nature)
- OU 2 micro-tours si quartiers distincts

---

## Étape 2: Identification des clusters marchables

Une fois les thèmes identifiés, trouver les **clusters**.

```
┌─────────────────────────────────────────────────────────────────┐
│                     CARTE DE LA VILLE                           │
│                                                                 │
│         ┌──────────┐                                            │
│         │ Cluster A│ ← Zone marchable #1                        │
│         │  ★ ★ ★   │   (centre-ville historique)                │
│         │   ★ ★    │   8 POIs, rayon 1.5km                      │
│         └──────────┘                                            │
│                           ┌──────────┐                          │
│                           │ Cluster B│ ← Zone marchable #2      │
│                           │  ★ ★     │   (parc + nature)        │
│                           │ ★        │   5 POIs, rayon 1km      │
│                           └──────────┘                          │
│                                                                 │
│  ⚠️ Gap trop grand = voiture nécessaire = 2 tours séparés     │
└─────────────────────────────────────────────────────────────────┘
```

**Règles:**
- Si >1km entre deux clusters → tours séparés
- Si POIs trop éparpillés → sélectionner les meilleurs dans un rayon walkable
- Chaque tour = 1 cluster = 1 zone de stationnement

---

## Étape 3: Recherche de POIs (par cluster/thème)

**Seulement après avoir défini le thème et le cluster.**

### Prompt AI pour recherche POIs

```markdown
Tu recherches des POIs pour un tour audio à {ville}.

CONTEXTE DU TOUR:
- Thème: {theme}
- Quartier/Zone: {quartier}
- Rayon maximum: {rayon_km}km depuis {point_central}
- Nombre de POIs cible: 8-12

CRITÈRES DE SÉLECTION:
1. **Pertinence au thème** — Le POI doit supporter le thème du tour
2. **Marchabilité** — Accessible à pied depuis les autres POIs
3. **Intérêt narratif** — Il y a une histoire à raconter (pas juste "c'est un building")
4. **Visibilité** — L'auditeur peut VOIR quelque chose (pas un site démoli)

EXCLURE:
- POIs fermés au public sans intérêt extérieur
- Lieux trop éloignés du cluster
- Sites génériques sans histoire locale

OUTPUT:
Pour chaque POI candidat:
- Nom
- Coordonnées GPS
- Distance du point central
- Pourquoi c'est pertinent au thème
- Hook narratif (1 phrase accrocheuse)
- Sources
```

### Format de sortie

```json
{
  "tour": {
    "ville": "Sainte-Julie",
    "theme": "Patrimoine et Nature",
    "quartier": "Centre-ville",
    "point_central": {"lat": 45.5847, "lng": -73.3361},
    "rayon_km": 4
  },
  "pois_candidats": [
    {
      "nom": "Église Sainte-Julie",
      "lat": 45.5847,
      "lng": -73.3361,
      "distance_centre": "0m",
      "pertinence_theme": "Bâtiment patrimonial central, construit 1852",
      "hook": "Le clocher qu'on voit a été reconstruit après avoir été frappé par la foudre en 1923",
      "sources": ["ville.sainte-julie.qc.ca", "patrimoine-culturel.gouv.qc.ca"],
      "ordre_suggere": 1
    }
  ],
  "parcours_suggere": "Église → Parc → Maison ancestrale → ...",
  "stationnement_recommande": "Parking de l'église (gratuit)",
  "duree_estimee": "75-90 minutes"
}
```

---

## Étape 4: Génération des scripts

### Prompt template

```markdown
Tu es un guide touristique passionné qui raconte l'histoire de {ville}.

CONTEXTE DU TOUR:
- Thème: {theme}
- Ce POI est le #{ordre} sur {total} du parcours
- POI précédent: {poi_precedent}
- POI suivant: {poi_suivant}

TON STYLE:
- Tu tutoies l'auditeur
- Tu es enthousiaste mais pas surexcité  
- Tu racontes des anecdotes, pas des dates sèches
- Tu poses des questions rhétoriques ("Tu vois ce bâtiment?")
- Tu donnes des conseils pratiques
- Tu fais des références à ce que l'auditeur peut VOIR

CONTRAINTES:
- Maximum 150-180 mots (60-90 secondes parlé)
- Commence par capter l'attention (hook)
- Termine par une transition vers le prochain point
- Inclus au moins une anecdote surprenante
- Mentionne un détail visuel à observer

INFORMATIONS SUR LE POI:
- Nom: {poi_name}
- Type: {poi_type}
- Histoire: {poi_history}
- Anecdotes connues: {poi_anecdotes}
- Ce qu'on peut voir: {poi_visual_elements}
- Direction vers prochain POI: {direction_next}

Génère le script audio en français québécois.
```

---

## Étape 5: Traduction

**Stratégie par langue:**
- **FR → EN:** AI + révision légère
- **FR → ES:** AI + révision par hispanophone
- **Autres:** AI seul (MVP)

---

## Workflow complet

### Pour une nouvelle ville

```
1. ANALYSE
   └── Remplir la fiche d'analyse de la ville
   └── Décision: multi-tours, tour unique, ou skip?

2. STRUCTURE
   └── Définir les thèmes intéressants
   └── Identifier les clusters marchables (carte)
   └── Créer 1 tour par cluster/thème

3. POIs
   └── Pour chaque tour, rechercher 10-15 POIs candidats
   └── Filtrer à 8-12 POIs marchables
   └── Définir l'ordre du parcours
   └── Identifier stationnement + toilettes + cafés

4. SCRIPTS
   └── Générer scripts pour chaque POI
   └── Révision humaine
   └── Traduction

5. AUDIO
   └── TTS via ElevenLabs (on-demand)
   └── Test du parcours complet
```

---

## Application: Sainte-Julie

### Analyse rapide

- **Population:** ~30,000
- **Superficie:** ~49 km²
- **Hook unique:** Ville de banlieue avec patrimoine agricole, proche nature
- **Verdict:** Probablement **1-2 tours max**

### Clusters potentiels

1. **Centre-ville** — Église, mairie, parc central, bâtiments patrimoniaux
2. **Mont Saint-Bruno** — Si on inclut (mais c'est une autre ville...)
3. **Zone nature** — Parcs, sentiers?

### Approche recommandée

**Option A: Un seul tour "Découverte Sainte-Julie"**
- 10-12 POIs dans un rayon de 4-5km du centre
- Mix patrimoine + nature + anecdotes locales
- ~75-90 minutes de marche

**Option B: Skip pour le MVP**
- Commencer directement par Montréal (plus de contenu)
- Sainte-Julie = test technique seulement (3-5 POIs factices)

---

## Application: Montréal

### Thèmes × Quartiers (exemples)

| # | Tour | Quartier | Thème | POIs estimés |
|---|------|----------|-------|--------------|
| 1 | Vieux-Montréal Hanté | Vieux-Mtl | 👻 Fantômes | 10 |
| 2 | Plateau Foodies | Plateau | 🍴 Gastro | 12 |
| 3 | Mile End Street Art | Mile End | 🎨 Art | 8 |
| 4 | Mont-Royal Secrets | Mont-Royal | 🌿 Nature | 8 |
| 5 | Architecture Art Déco | Centre-ville | 🏛️ Archi | 10 |

### Bundles possibles

- **Bundle "Découverte Montréal"** — Tours 1-3 (14.99$)
- **Bundle "Montréal Complet"** — Tous les tours (29.99$)
- **Tours individuels** — 7.99$ chacun

---

## Interface de révision: Trello

### Structure du board

```
BOARD: "Contenu App Voyage"

LISTES:
[Analyse]        [À générer]    [À réviser]    [Approuvé]    [En prod]

CARTES:
┌─────────────────────┐
│ 📊 Fiche: Montréal  │  ← Analyse de ville
│    Labels: analyse  │
└─────────────────────┘

┌─────────────────────┐
│ 🗺️ Tour: Vieux-Mtl │  ← Structure du tour
│    Hanté            │
│    Labels: structure│
└─────────────────────┘

┌─────────────────────┐
│ 📍 POI: Château     │  ← POI individuel
│    Ramezay          │
│    Labels: poi      │
└─────────────────────┘
```

### Format carte POI

```
Titre: [POI] {nom} — {tour}

Description:
📍 Coordonnées: {lat}, {lng}
🚶 Ordre dans tour: #{n}
📏 Distance du précédent: {x}m

📝 Script FR:
---
{script_complet}
---

📝 Script EN:
---
{traduction}
---

📚 Sources:
- {source1}
- {source2}

🗺️ Directions vers prochain:
{directions}

✏️ Notes de révision:
[Commentaires ici]
```

---

## Estimation des coûts

| Tâche | Coût/unité | Pour 1 tour (10 POIs) |
|-------|------------|----------------------|
| Analyse ville | ~$0.10 | $0.10 |
| Recherche POIs | ~$0.08/POI | $0.80 |
| Script FR | ~$0.05/POI | $0.50 |
| Traduction EN | ~$0.03/POI | $0.30 |
| **Total** | | **~$1.70/tour** |

**Coût négligeable** comparé au temps humain économisé.

---

## Checklist nouvelle ville

- [ ] Remplir fiche d'analyse
- [ ] Décision: nombre de tours?
- [ ] Identifier clusters marchables (carte)
- [ ] Pour chaque tour:
  - [ ] Définir thème + quartier
  - [ ] Point central + rayon
  - [ ] Recherche POIs (15 candidats)
  - [ ] Sélection finale (8-12)
  - [ ] Ordre du parcours
  - [ ] Stationnement + logistique
  - [ ] Scripts FR
  - [ ] Révision
  - [ ] Traduction EN
  - [ ] Test terrain

---

*Document mis à jour le 2026-02-18 — Approche thème-first + piéton-first*
