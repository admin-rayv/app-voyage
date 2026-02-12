# 🎧 App Voyage — Guide Audio Géolocalisé

> "Un ami historien passionné dans tes écouteurs"

---

## Vision

Une application mobile qui transforme chaque promenade en ville en une expérience immersive. Un guide audio intelligent qui réagit à ta position GPS et te raconte l'histoire, la culture et les secrets des lieux que tu traverses — comme si un ami local passionné t'accompagnait.

**Ce qui nous différencie:**
- 🎯 **Sync groupe** — Seule app avec écoute synchronisée (familles, couples, amis)
- 🎭 **Personnalité forte** — Pas une voix robot, un vrai personnage attachant
- 🇨🇦 **Focus Québec** — Contenu local de qualité en français
- 🚶🚴🚗 **Multi-transport** — Adapté à pied, vélo ET auto

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

### Phase 1: Sainte-Julie = Bac à sable 🧪
- Petit, contrôlable, proche de chez nous
- Tester géofencing voiture/vélo sans pression
- **Action:** Contacter la municipalité pour partenariat "Pilote technologique"
- Objectif: Valider la techno, pas monétiser

### Phase 2: Montréal = Parcours niches 🎯
**❌ NE PAS faire "Montréal" (trop vague, trop gros)**

**✅ Faire des parcours niches:**

| Parcours | Thème | Persona |
|----------|-------|---------|
| **Vieux-Montréal Hanté** 👻 | Légendes, mystères, crimes historiques | "Jacques" — fantôme d'un colon |
| **Plateau des Foodies** 🍕 | Restos, histoire culinaire, spots locaux | "Sarah" — étudiante foodie |
| **Mile-End Street Art** 🎨 | Murales, artistes, culture alternative | Artiste local passionné |
| **Montréal Souterrain** 🚇 | Architecture, histoire du RÉSO | Architecte curieux |
| **Vieux-Montréal Classique** 🏛️ | Histoire, architecture, incontournables | "Jacques" version historique |

### Phase 3: Expansion
- Autres quartiers Montréal
- Ville de Québec
- France (connexion familiale)

---

## Personas narrateurs (voix du guide)

Utiliser ElevenLabs pour créer des **personnages distincts**:

| Persona | Personnalité | Voix | Utilisation |
|---------|--------------|------|-------------|
| **Jacques** | Fantôme d'un colon, mystérieux mais chaleureux | Homme, 50s, accent québécois léger | Vieux-Montréal, historique |
| **Sarah** | Étudiante passionnée, énergique, gourmande | Femme, 25-30, dynamique | Plateau, Mile-End, foodie |
| **Le Narrateur** | Voix off cinématique, suspense | Neutre, profond | Parcours hantés, mystères |

**Astuce production:** Utiliser les prompts d'émotion ElevenLabs pour ajouter rires, soupirs, hésitations — c'est ce qui manque aux robots!

---

## Règles de contenu

### Format audio
| Règle | Valeur | Pourquoi |
|-------|--------|----------|
| Durée max par point | **90 secondes** | Les gens marchent, bruit ambiant, attention limitée |
| Durée min par point | 30 secondes | Assez pour dire quelque chose d'intéressant |
| Mots par minute | ~150 | Rythme naturel de conversation |
| Points par parcours | 10-15 | ~45-60 min total |

### Ton et style
- ✅ Tutoiement
- ✅ Questions rhétoriques ("Tu vois ce bâtiment?")
- ✅ Anecdotes et secrets
- ✅ Humour quand approprié
- ✅ Expressions locales
- ❌ Dates précises à répétition
- ❌ Style encyclopédique
- ❌ "Ce monument a été érigé en..."

### Contenu logistique (secret de Shaka Guide!)
Chaque point doit inclure si pertinent:
- 🅿️ Où se garer à proximité
- 🚻 Toilettes les plus proches
- ☕ Bon café/resto nearby
- 📸 Meilleur spot photo
- ⏱️ Temps suggéré sur place
- ⚠️ Attention particulière (traverse dangereuse, etc.)

**Exemple:**
> "Avant de continuer, petit tip: les meilleures toilettes publiques sont dans le Centre de commerce, juste là à droite. Et si t'as soif, le café Olimpico au coin fait le meilleur espresso du quartier. Je dis ça, je dis rien..."

---

## Business Model — Décidé ✅

### Modèle: Freemium "Unlock"

| Élément | Prix | Justification |
|---------|------|---------------|
| App | **Gratuit** | Réduire friction téléchargement |
| 5 premiers points | **Gratuit** | Teaser, prouver la qualité |
| Tour complet | **7.99$ CAD** | Milieu de marché, accessible |
| Pack "Tout Montréal" | **14.99$ CAD** | Inciter à acheter plus |
| Pack "Tout Québec" | **24.99$ CAD** | Pour les gros voyageurs |

### Pourquoi pas d'abonnement?
Les touristes sont là 3-5 jours. Ils ne veulent pas s'abonner à une app qu'ils utiliseront une fois.

### Revenue share (in-app purchases)
- Apple/Google prennent 30%
- Sur 7.99$ → on garde ~5.60$
- Objectif: 1000 ventes/mois = 5600$/mois (après 1 an)

### B2B (Phase 2)
- Approcher Tourisme Montréal, Tourisme Québec
- White-label pour offices de tourisme
- Prix: à négocier (forfait ou revenue share)

---

## Modes de transport

| Mode | Trigger radius | Style narration | Points/km |
|------|---------------|-----------------|-----------|
| **🚶 Pied** | 25-35m | Détaillé, "arrête-toi ici" | 5-8 |
| **🚴 Vélo** | 50-75m | Plus court, pas d'arrêts forcés | 2-4 |
| **🚗 Auto** | 100-200m | Continu, style podcast | 1-2 |

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
| **Backend** | Supabase | PostgreSQL + Auth + Realtime, gratuit au début |
| **Storage audio** | Cloudinary | 25GB gratuit, CDN, séparé de la DB |
| **TTS** | ElevenLabs | Voix naturelles, émotions |
| **Maps** | Mapbox | Offline maps, customisable |
| **Sync groupe** | Supabase Realtime | WebSockets intégrés |

### Notes techniques importantes
- Calcul de distance = **local** (Dart) pour fonctionner offline
- MP3 téléchargés en **cache local** au premier lancement (pas de streaming)
- Sync groupe = à la **seconde** (pas milliseconde) — suffisant pour narration
- Optimiser GPS polling pour économiser batterie

---

## Métriques de succès

### Proto (Sainte-Julie)
- [ ] 5 tests terrain complétés
- [ ] GPS trigger fonctionne >90% du temps
- [ ] Retours positifs sur le ton

### MVP (Vieux-Montréal)
- [ ] 50 beta testers
- [ ] 80% complètent le parcours
- [ ] Note moyenne >4.0
- [ ] Sync groupe fonctionne

### V1 (Launch)
- [ ] 500 téléchargements premier mois
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

*Dernière mise à jour: 2026-02-12*
