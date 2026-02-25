# 🎧 App Voyage — Guide Audio Géolocalisé

> "Un ami historien passionné dans tes écouteurs"

---

## Vision

Une application mobile qui transforme chaque promenade en ville en une expérience immersive. Tu te balades librement et **découvres des points d'intérêt (POIs) autour de toi** — l'audio se déclenche automatiquement quand tu t'approches d'un lieu. Comme si un ami local passionné t'accompagnait et te racontait l'histoire, la culture et les secrets de chaque endroit.

**Ce qui nous différencie:**
- 🎯 **Sync groupe** — Seule app avec écoute synchronisée (familles, couples, amis)
- 🎭 **Personnalité forte** — Pas une voix robot, un vrai personnage attachant
- 🇨🇦 **Focus Québec** — Contenu local de qualité en français
- 🗺️ **Découverte libre** — Pas de parcours imposé, tu explores à ton rythme
- 🚶🚴🚗 **Multi-transport** — Fonctionne à pied, vélo ET auto (rayon de déclenchement adaptatif)

---

## Approche: POI-First 🎯

**Les POIs sont l'unité de base.** Chaque point d'intérêt est indépendant, autonome, avec son propre script audio. L'utilisateur n'a pas besoin de "suivre un parcours" — il se promène librement et les POIs se déclenchent automatiquement par proximité GPS.

| Approche | Description |
|----------|-------------|
| **Phase 1 (maintenant)** | Collecter TOUS les POIs d'une ville → tester le GPS/geofencing → l'utilisateur explore librement |
| **Phase 2 (V2)** | Regrouper les POIs en **tours curatés** (collections thématiques) → parcours optionnels payants |

**Pourquoi POI-first?**
- ✅ Meilleur pour tester le GPS/geofencing naturellement
- ✅ Expérience plus organique (découverte vs suivre des ordres)
- ✅ Meilleur data collection (voir quels POIs sont populaires)
- ✅ Couvre toute une ville, pas juste des clusters marchables
- ✅ Fonctionne pour tous les modes de transport sans redesign

---

## Problème résolu

| Problème actuel | Notre solution |
|-----------------|----------------|
| Audioguides traditionnels = ennuyants, robotiques | Ton "ami passionné", personnages attachants |
| Guides humains = chers, pas toujours dispo | Disponible 24/7, prix accessible |
| Apps existantes = sans personnalité | Narration vivante avec émotions |
| Groupe = chacun son téléphone, désync | **Mode Host**: tout le monde écoute ensemble |
| Roaming = coûteux à l'étranger | 100% offline après téléchargement |
| BaladoDécouverte = gratuit mais boring | On vend du **divertissement**, pas de l'éducation sèche |
| Parcours fixes = rigides, pas adaptés | **Exploration libre** — tu vas où tu veux |

---

## Équipe

| Rôle | Personne | Responsabilités |
|------|----------|-----------------|
| **Product Owner** | Pierre Raymond | Vision produit, contenu, validation, tests terrain |
| **Lead technique** | Camélia Raymond | Architecture, développement, intégration |

---

## Cibles

### Audiences prioritaires

| Audience | Priorité | Besoins | Willingness to pay |
|----------|----------|---------|-------------------|
| **Touristes** | ⭐⭐⭐ | Découvrir une ville, ne rien manquer, immersion | Élevée (vacation mindset) |
| **Groupes (familles, couples)** | ⭐⭐⭐ | Expérience partagée, pas chacun dans son coin | Élevée (valeur perçue) |
| **Locaux curieux** | ⭐⭐ | Redécouvrir leur ville, impressionner des visiteurs | Moyenne |
| **Écoles/groupes éducatifs** | ⭐ | Sorties scolaires interactives | B2B potentiel |

### Persona principal: "Marie & Thomas"
- Couple de Français, 35-45 ans
- 5 jours à Montréal pour la première fois
- Veulent voir les incontournables + spots cachés
- N'aiment pas les tours en groupe de 30 personnes
- Veulent écouter ENSEMBLE (pas chacun son téléphone)
- Budget: prêts à payer pour une bonne expérience

---

## Stratégie de lancement (Go-to-Market)

### Phase 1: Saint-Lambert = Bac à sable 🧪
- Collecter TOUS les POIs de Saint-Lambert
- Tester le GPS/geofencing avec de vrais points d'intérêt
- L'utilisateur se promène librement, les POIs se déclenchent
- **Objectif:** Valider la techno de déclenchement automatique

### Phase 2: Montréal = POIs par quartier 🎯
**Collecter les POIs de Montréal par quartier/thème:**

| Quartier | POIs estimés | Thèmes |
|----------|-------------|--------|
| **Vieux-Montréal** | 20-30 | Histoire, fantômes, architecture |
| **Plateau** | 15-25 | Street art, restos, culture |
| **Mile-End** | 10-20 | Musique, cafés, art |
| **Mont-Royal** | 10-15 | Nature, vues, histoire |
| **Centre-ville** | 15-25 | Architecture Art Déco, souterrain |

**V2:** Regrouper en tours curatés thématiques (ex: "Vieux-Montréal Hanté" = sélection de 10 POIs avec un narrateur mystérieux)

### Phase 3: Expansion
- Autres quartiers Montréal
- Ville de Québec
- France (connexion familiale)

---

## Persona narrateur: Marco

**Un seul narrateur pour toute l'app.** Marco, c'est ton ami qui voyage avec toi.

| Aspect | Description |
|--------|-------------|
| **Qui** | Un ami explorateur passionné par tout ce qui l'entoure |
| **Ton** | Conversationnel, curieux, cultivé sans être prétentieux, humour naturel |
| **Voix** | Homme ~30-35, chaleureux, accent québécois léger, rythme naturel |
| **Style** | Tutoiement, observations visuelles, anecdotes, tips pratiques |
| **Adapte son énergie** | Posé (monument solennel), excité (spot food), mystérieux (légende), émerveillé (nature) |

Marco est toujours là — chaque POI, chaque ville, chaque catégorie. L'utilisateur développe une relation avec lui.

**Astuce production:** Utiliser les prompts d'émotion ElevenLabs pour ajouter rires, soupirs, hésitations — c'est ce qui fait que Marco se sent réel, pas robot.

---

## Règles de contenu

### Format audio
| Règle | Valeur | Pourquoi |
|-------|--------|----------|
| Durée max par POI | **90 secondes** | Les gens marchent, bruit ambiant, attention limitée |
| Durée min par POI | 30 secondes | Assez pour dire quelque chose d'intéressant |
| Mots par minute | ~150 | Rythme naturel de conversation |

### Ton et style
- ✅ Tutoiement
- ✅ Questions rhétoriques ("Tu vois ce bâtiment?")
- ✅ Anecdotes et secrets
- ✅ Humour quand approprié
- ✅ Expressions locales
- ✅ **Scripts auto-contenus** (chaque POI se suffit à lui-même, pas de "continue vers...")
- ❌ Dates précises à répétition
- ❌ Style encyclopédique
- ❌ "Ce monument a été érigé en..."
- ❌ Références au POI précédent/suivant

### Contenu logistique (secret de Shaka Guide!)
Chaque POI doit inclure si pertinent:
- 🅿️ Où se garer à proximité
- 🚻 Toilettes les plus proches
- ☕ Bon café/resto nearby
- 📸 Meilleur spot photo
- ⏱️ Temps suggéré sur place
- ⚠️ Attention particulière (traverse dangereuse, etc.)

**Exemple:**
> "Petit tip: les meilleures toilettes publiques sont dans le Centre de commerce, juste là à droite. Et si t'as soif, le café Olimpico au coin fait le meilleur espresso du quartier. Je dis ça, je dis rien..."

---

## Business Model — Décidé ✅

### Modèle: Freemium POI-first

| Élément | Prix | Justification |
|---------|------|---------------|
| App | **Gratuit** | Réduire friction téléchargement |
| Tous les POIs | **Gratuit** (Phase 1) | Tester la techno, collecter des données d'usage |
| Tour curaté (V2) | **7.99$ CAD** | Collections thématiques avec narrateur dédié |
| Pack "Tout Montréal" (V2) | **14.99$ CAD** | Tous les tours d'une ville |
| Pack "Tout Québec" (V2) | **24.99$ CAD** | Pour les gros voyageurs |

### Pourquoi gratuit au début?
- On a besoin de DATA sur le GPS/geofencing avant de monétiser
- Les POIs gratuits attirent les utilisateurs → on voit quels POIs sont populaires
- Les tours curatés payants arrivent en V2 (collections de POIs avec un fil narratif)

### Revenue share (in-app purchases — V2)
- Apple/Google prennent 30%
- Sur 7.99$ → on garde ~5.60$
- Objectif: 1000 ventes/mois = 5600$/mois (après 1 an)

### B2B (Phase 3)
- Approcher Tourisme Montréal, Tourisme Québec
- White-label pour offices de tourisme
- Prix: à négocier (forfait ou revenue share)

---

## Modes de transport

Tous les modes fonctionnent de la même façon — seul le **rayon de déclenchement** change:

| Mode | Trigger radius | Style narration | Détection |
|------|---------------|-----------------|-----------|
| **🚶 Pied** | 25-40m | Détaillé, "regarde autour de toi" | Vitesse <7 km/h |
| **🚴 Vélo** | 50-75m | Plus concis, pas d'arrêts forcés | Vitesse 7-25 km/h |
| **🚗 Auto** | 100-200m | Style podcast, continu | Vitesse >25 km/h |

### Algorithme intelligent (comme GuideAlong)
- Ne pas juste utiliser un rayon fixe
- Tenir compte de la **vitesse** et **direction**
- Calculer le "time to trigger" pour que l'audio commence au bon moment
- Si vitesse > 30km/h → passer en mode auto automatiquement

---

## Langues

| Langue | Priorité | Status |
|--------|----------|--------|
| 🇫🇷 Français | ⭐⭐⭐ | MVP |
| 🇬🇧 Anglais | ⭐⭐⭐ | MVP |
| 🇪🇸 Espagnol | ⭐ | V2+ |

### Stratégie multi-langue
- Audio FR + EN pré-générés (ElevenLabs haute qualité)
- Autres langues = TTS device natif (qualité OK, gratuit)
- Textes UI traduits dans toutes les langues

---

## Stack technique — Décidé ✅

| Composant | Choix | Justification |
|-----------|-------|---------------|
| **Mobile** | Flutter | Performance native, GPS/audio background |
| **Backend** | Supabase | PostgreSQL + Auth + Realtime + Edge Functions |
| **TTS** | ElevenLabs | Voix naturelles, génération à la demande |
| **Maps** | Mapbox | Offline maps, customisable |
| **Sync groupe** | Supabase Realtime | WebSockets intégrés |

### Architecture audio — Scripts, pas MP3 🆕

**Principe:** On stocke les **scripts texte** dans la DB, pas les fichiers audio.
L'audio est **généré à la demande** via ElevenLabs lors du téléchargement.

| Avantage | Explication |
|----------|-------------|
| Multi-langue facile | Ajouter une langue = traduire le texte |
| Pas de stockage cloud | Plus besoin de Cloudinary/S3 |
| Mises à jour instantanées | Modifier script → audio mis à jour |
| Scalable | 100 langues = juste du texte dans la DB |

### Notes techniques importantes
- Calcul de distance = **local** (Dart) pour fonctionner offline
- Audio généré via **Edge Function** puis mis en **cache local** sur l'appareil
- Cache invalidé via **hash du script** (si texte change → re-génération)
- Sync groupe = à la **seconde** (pas milliseconde) — suffisant pour narration
- Optimiser GPS polling pour économiser batterie
- **Cache par ville** (pas par tour) — on télécharge tous les POIs d'une région

---

## Métriques de succès

### Proto (Saint-Lambert)
- [ ] GPS trigger fonctionne >90% du temps
- [ ] 5 tests terrain complétés (marche libre)
- [ ] Retours positifs sur le ton des scripts

### MVP (Montréal)
- [ ] 50+ POIs publiés
- [ ] 50 beta testers
- [ ] Données d'usage: quels POIs sont écoutés
- [ ] Note moyenne >4.0

### V1 (Launch)
- [ ] 500 téléchargements premier mois
- [ ] Premiers tours curatés (V2)
- [ ] 10% conversion gratuit → payant
- [ ] Note App Store >4.2

### V2 (Growth)
- [ ] 5000 téléchargements
- [ ] Premiers revenus B2B
- [ ] 3+ villes couvertes

---

## Nom de l'app — À décider

| Nom | Pros | Cons |
|-----|------|------|
| **App Voyage** | Clair, français | Générique |
| **Wandr** | Moderne, court | Anglais |
| **Écho** | Poétique, français | Peut-être trop vague |
| **Compagnon** | Chaleureux, français | Long |
| **CityWhisper** | Évocateur | Anglais |
| **VoixLocale** | Français, descriptif | Un peu long |

**À brainstormer avec Pierre**

---

## Documents liés

| Document | Contenu |
|----------|---------|
| [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) | Modèle de données, workflows, stack |
| [docs/COMPETITIVE-ANALYSIS.md](./docs/COMPETITIVE-ANALYSIS.md) | Analyse des compétiteurs |
| [docs/RISKS.md](./docs/RISKS.md) | Analyse de risques |
| [docs/ROADMAP.md](./docs/ROADMAP.md) | Phases et timeline |
| [docs/USER-STORIES.md](./docs/USER-STORIES.md) | Stories détaillées par épic |

---

*Dernière mise à jour: 2026-02-23*
