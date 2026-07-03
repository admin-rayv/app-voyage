# 🤖 AUTOMATISATION DU CONTENU — App Voyage

> Pipeline de création de contenu: Ville → Analyse → Collecter TOUS les POIs → Scripts

---

## Vision

**Objectif:** L'IA génère le contenu, les humains révisent et approuvent.

```
┌─────────────────────────────────────────────────────────────────┐
│                    PIPELINE DE CONTENU                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   🏙️ ANALYSE      →   📍 COLLECTER    →   📝 SCRIPTS   →  🏷️ TAGS │
│   VILLE               TOUS LES POIs       AUTO-CONTENUS   CATÉGORIES│
│                                                                 │
│   • C'est quoi le     • Patrimoine       • 60-90 sec     • patrimoine│
│     hook unique?      • Nature            chacun         • nature    │
│   • Petite/grande?    • Gastronomie     • Pas de         • food    │
│   • Thèmes?           • Art/culture       transitions   • art       │
│                       • Insolite        • Stand-alone    • insolite  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Approche POI-First

**Chaque POI est une unité indépendante.** On ne planifie pas de routes ni de parcours — on collecte TOUS les POIs intéressants d'une ville, on écrit un script autonome pour chacun, et on les tague par catégorie.

Les tours curatés (collections ordonnées) viendront en V2, une fois qu'on a la data d'usage.

### Paramètres par mode de transport

| Mode | Rayon trigger | Style narration |
|------|--------------|-----------------|
| 🚶 **Piéton** | 25-40m | Détaillé, "regarde autour de toi" |
| 🚴 **Vélo** | 50-75m | Plus concis, pas d'arrêts forcés |
| 🚗 **Auto** | 100-200m | Continu, style podcast |

**Note:** Le même POI fonctionne pour tous les modes — seul le rayon de déclenchement change.

---

## Étape 0: Analyse de la ville

**AVANT de chercher des POIs**, analyser la ville.

### Questions à répondre

```markdown
## Fiche d'analyse: {VILLE}

### Taille et potentiel
- Population: ?
- Superficie: ?
- Combien de POIs peut-on raisonnablement couvrir?

### Hook unique
- C'est quoi le truc SPÉCIAL de cette ville?
- Pourquoi un touriste irait LÀ plutôt qu'ailleurs?
- Qu'est-ce que les locaux diraient: "Ah, {ville}? C'est connu pour..."

### Zones d'intérêt
- Y a-t-il des quartiers distincts?
- Où sont concentrés les POIs potentiels?
- Quelles zones ont le plus de densité de points?

### Thèmes / Catégories
- Histoire/patrimoine?
- Gastronomie?
- Nature/parcs?
- Art/culture?
- Insolite/hanté?
- Architecture?

### Verdict
- [ ] GRANDE VILLE: 50+ POIs possibles, plusieurs quartiers
- [ ] VILLE MOYENNE: 15-30 POIs, quelques zones d'intérêt
- [ ] PETITE VILLE: 8-15 POIs, une zone principale
- [ ] SKIP: Pas assez de contenu intéressant
```

---

## Étape 1: Collecte de TOUS les POIs

### Approche systématique

Pour chaque ville, on collecte **tous** les POIs potentiels, pas juste ceux d'un thème ou d'un quartier. On ratisse large et on trie ensuite.

### Grandes villes (Montréal, Québec, etc.)

**Collecter par quartier, tagger par catégorie:**

| Quartier | POIs estimés | Catégories probables |
|----------|-------------|---------------------|
| Vieux-Montréal | 20-30 | histoire, architecture, insolite |
| Plateau | 15-25 | art, food, architecture |
| Mile End | 10-20 | art, food, nature |
| Mont-Royal | 10-15 | nature, histoire |
| Centre-ville | 15-25 | architecture, insolite |

### Petites villes (Saint-Lambert, Sainte-Julie, etc.)

**Collecter tout ce qui est intéressant:**

| Catégorie | POIs estimés |
|-----------|-------------|
| Patrimoine | 5-10 |
| Nature / vues | 3-5 |
| Gastronomie | 2-5 |
| Insolite | 1-3 |
| **Total** | **15-25** |

---

## Étape 2: Recherche de POIs

### Prompt AI pour recherche POIs

```markdown
Tu recherches des POIs pour l'app de guide audio à {ville}.

CONTEXTE:
- On veut collecter TOUS les POIs intéressants de la ville
- Chaque POI est indépendant (pas de parcours)
- L'audio se déclenche quand l'utilisateur passe à proximité

CRITÈRES DE SÉLECTION:
1. **Intérêt narratif** — Il y a une histoire à raconter (pas juste "c'est un building")
2. **Visibilité** — L'auditeur peut VOIR quelque chose (pas un site démoli)
3. **Géolocalisation précise** — On peut placer un point GPS dessus
4. **Diversité** — Mix de catégories (histoire, nature, food, art, insolite)

EXCLURE:
- POIs fermés au public sans intérêt extérieur
- Lieux trop génériques sans histoire locale
- Sites qui nécessitent un billet d'entrée pour être appréciés

CATÉGORIES À UTILISER (les 7 officielles):
- histoire (patrimoine, personnages, événements passés)
- architecture (style notable, bâtiments uniques, infrastructure, écluses, ponts)
- nature (parcs, vues, espaces verts, fleuve)
- food (restos iconiques, marchés, culture food)
- art (street art, galeries, murales)
- insolite (histoires bizarres, légendes, hantés)
- vie-locale (marchés hebdo, events récurrents, traditions)

OUTPUT:
Pour chaque POI candidat:
- Nom
- Coordonnées GPS
- Catégories (1-3)
- Pourquoi c'est intéressant
- Hook narratif (1 phrase accrocheuse)
- Sources
```

### Format de sortie

```json
{
  "city": "Saint-Lambert",
  "total_pois": 15,
  "pois": [
    {
      "nom": "Église Saint-Lambert",
      "lat": 45.5004,
      "lng": -73.5139,
      "categories": ["histoire", "architecture"],
      "hook": "Une des premières églises Dom Bellot au Québec, reconstruite après un incendie en 1936",
      "sources": ["patrimoine-culturel.gouv.qc.ca"],
      "type": "church",
      "trigger_radius_m": 40
    }
  ]
}
```

---

## Étape 3: Génération des scripts

### Règle #1: Scripts auto-contenus

Chaque script doit fonctionner **indépendamment**. L'utilisateur peut arriver de n'importe quelle direction, à n'importe quel moment. Pas de:
- ❌ "Continue vers le prochain point..."
- ❌ "Comme on a vu au point précédent..."
- ❌ "Tu te souviens de l'église tout à l'heure?"
- ✅ "Tu vois ce bâtiment devant toi?"
- ✅ "Regarde autour de toi..."
- ✅ Script complet qui se suffit à lui-même

### Prompt template

```markdown
Tu es un guide touristique passionné qui raconte l'histoire de {ville}.

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
- Le script est AUTO-CONTENU (pas de référence à d'autres POIs)
- Inclus au moins une anecdote surprenante
- Mentionne un détail visuel à observer
- Termine par un petit conseil pratique ou un fait mémorable

INFORMATIONS SUR LE POI:
- Nom: {poi_name}
- Type: {poi_type}
- Catégories: {poi_categories}
- Histoire: {poi_history}
- Anecdotes connues: {poi_anecdotes}
- Ce qu'on peut voir: {poi_visual_elements}

Génère le script audio en français québécois.
```

---

## Étape 4: Tagging et catégorisation

Chaque POI reçoit 1-3 catégories parmi les **7 catégories officielles**:

| Slug | Emoji | Description |
|------|-------|-------------|
| `histoire` | 🏛️ | Patrimoine, personnages, événements passés |
| `architecture` | 🏗️ | Styles notables, bâtiments uniques, infrastructure |
| `nature` | 🌿 | Parcs, sentiers, fleuve, arbres |
| `food` | 🍴 | Restos, cafés, marchés, histoire culinaire |
| `art` | 🎨 | Murales, galeries, spectacles, art public |
| `insolite` | 👻 | Légendes, secrets, weird facts, hanté |
| `vie-locale` | 🏘️ | Marchés hebdo, events récurrents, traditions, spots communautaires |

```sql
-- Exemples de tagging
UPDATE points SET categories = ARRAY['histoire', 'architecture'] 
  WHERE name->>'fr' = 'Église Saint-Lambert';

UPDATE points SET categories = ARRAY['architecture', 'histoire'] 
  WHERE name->>'fr' = 'Vue sur le Pont Victoria';

UPDATE points SET categories = ARRAY['histoire', 'insolite'] 
  WHERE name->>'fr' = 'Maison Marsil';

UPDATE points SET categories = ARRAY['vie-locale', 'food'] 
  WHERE name->>'fr' = 'Marché du jeudi';
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
   └── Identifier les zones d'intérêt et thèmes

2. COLLECTE
   └── Rechercher TOUS les POIs intéressants
   └── Coordonnées GPS précises
   └── Catégoriser chaque POI

3. SCRIPTS
   └── Générer script auto-contenu pour chaque POI
   └── Révision humaine
   └── Traduction

4. PUBLICATION
   └── Set is_published = true pour les POIs validés
   └── Test terrain (marcher dans la ville, vérifier les triggers)

5. V2: CURATION
   └── Identifier les POIs populaires (analytics)
   └── Créer des tours curatés (collections thématiques)
   └── Ajouter transitions narratives pour les tours
```

---

## Application: Saint-Lambert — ✅ COMPLÉTÉ

### Analyse rapide

- **Population:** ~23,500
- **Superficie:** ~7.5 km²
- **Hook unique:** Musée vivant d'architecture québécoise, née de "Mouillepied"
- **Verdict:** **PETITE VILLE** — 15-20 POIs estimés au départ

### Résultat final (2026-07)

**81 POIs publiés, 243 scripts (FR/EN/ES)** — bien au-delà de l'estimation initiale.
Le pipeline complet (poi-scout → poi-writer → poi-checker → poi-pusher) a été rodé
sur cette ville. Fichiers sources dans `content/saint-lambert-quebec-canada/`.

| Catégorie | POIs |
|-----------|------|
| histoire 🏛️ | 29 |
| architecture 🏗️ | 20 |
| art 🎨 | 15 |
| nature 🌿 | 14 |
| insolite 👻 | 14 |
| food 🍴 | 13 |
| vie-locale 🏘️ | 12 |

*(Un POI peut avoir plusieurs catégories.)*

---

## Application: Montréal

### POIs par quartier (estimations)

| Quartier | POIs estimés | Catégories principales |
|----------|-------------|----------------------|
| Vieux-Montréal | 25+ | histoire, architecture, insolite |
| Plateau | 20+ | art, food, architecture |
| Mile End | 15+ | art, food |
| Mont-Royal | 10+ | nature, histoire |
| Centre-ville | 20+ | architecture, insolite |
| **Total** | **90+** | |

### V2: Tours curatés (futurs)

| Tour | POIs sélectionnés | Prix |
|------|------------------|------|
| "Vieux-Montréal Hanté" 👻 | 10 POIs insolite/histoire | 7.99$ |
| "Plateau Foodies" 🍕 | 12 POIs food | 7.99$ |
| "Mile-End Street Art" 🎨 | 8 POIs art | 7.99$ |
| Bundle "Découverte Montréal" | 3 tours | 14.99$ |

---

## Interface de révision: Trello

### Structure du board

```
BOARD: "Contenu App Voyage"

LISTES:
[Analyse]        [À rédiger]    [À réviser]    [Approuvé]    [Publié]

CARTES:
┌─────────────────────┐
│ 📊 Fiche: Montréal  │  ← Analyse de ville
│    Labels: analyse  │
└─────────────────────┘

┌─────────────────────┐
│ 📍 POI: Château     │  ← POI individuel
│    Ramezay          │
│    Labels: histoire│
│    Labels: insolite │
└─────────────────────┘
```

### Format carte POI

```
Titre: [POI] {nom} — {ville}

Description:
📍 Coordonnées: {lat}, {lng}
🏷️ Catégories: {categories}
📏 Rayon trigger: {radius}m

📝 Script FR:
---
{script_complet_auto_contenu}
---

📝 Script EN:
---
{traduction}
---

📚 Sources:
- {source1}
- {source2}

🗺️ Infos logistiques:
- Parking: {parking}
- Toilettes: {toilets}
- Photo spot: {photo}

✏️ Notes de révision:
[Commentaires ici]
```

---

## Estimation des coûts

| Tâche | Coût/unité | Pour 1 ville (20 POIs) |
|-------|------------|----------------------|
| Analyse ville | ~$0.10 | $0.10 |
| Recherche POIs | ~$0.08/POI | $1.60 |
| Script FR | ~$0.05/POI | $1.00 |
| Traduction EN | ~$0.03/POI | $0.60 |
| **Total** | | **~$3.30/ville** |

**Coût négligeable** comparé au temps humain économisé.

---

## Checklist nouvelle ville

- [ ] Remplir fiche d'analyse
- [ ] Identifier zones d'intérêt et thèmes
- [ ] Collecter TOUS les POIs candidats
- [ ] Pour chaque POI:
  - [ ] Coordonnées GPS précises
  - [ ] Catégories (1-3)
  - [ ] Script FR auto-contenu
  - [ ] Révision
  - [ ] Traduction EN
  - [ ] Infos logistiques
- [ ] Set is_published = true pour les validés
- [ ] Test terrain (marcher dans la ville)

---

*Document mis à jour le 2026-02-23 — Approche POI-first (tours curatés = V2)*
