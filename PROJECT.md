# 🎧 App Voyage — Guide Audio Géolocalisé

> "Un ami historien passionné dans tes écouteurs"

## Vision

Une application mobile qui transforme chaque promenade en ville en une expérience immersive. Un guide audio intelligent qui réagit à ta position GPS et te raconte l'histoire, la culture et les secrets des lieux que tu traverses — comme si un ami local passionné t'accompagnait.

## Problème résolu

- Les audioguides traditionnels sont ennuyants et rigides
- Les guides touristiques humains sont chers et pas toujours disponibles
- Les apps existantes manquent de personnalité et de fluidité
- Voyager en groupe = tout le monde sur des apps différentes

## Solution

- Contenu audio pré-généré par AI, validé sur le terrain
- Narration naturelle style "ami qui te parle"
- Fonctionne offline (téléchargement des parcours)
- Sync multi-appareils pour les groupes (mode Host)
- Adapté au mode de transport (pied, vélo, auto)

---

## Équipe

- **Pierre Raymond** — Product Owner
- **Camélia Raymond** — Lead technique & Développement

## Cibles

| Audience | Priorité | Besoins |
|----------|----------|---------|
| Touristes | ⭐⭐⭐ | Découvrir une nouvelle ville, immersion culturelle |
| Locaux curieux | ⭐⭐ | Redécouvrir leur ville, apprendre l'histoire |
| Groupes (familles, amis) | ⭐⭐ | Expérience partagée synchronisée |

## Villes cibles (MVP)

1. **Montréal, QC** — Ville principale, beaucoup de contenu potentiel
2. **Sainte-Julie, QC** — Test local, plus petit scope

## Langues

- 🇫🇷 Français (priorité)
- 🇬🇧 Anglais
- 🇪🇸 Espagnol (future?)

---

## Personnalité du guide

**Ton:** Ami passionné d'histoire — pas un prof ennuyant, mais quelqu'un qui *trip* sur ce qu'il raconte.

**Exemples de style:**
- ❌ "Ce bâtiment a été construit en 1893 par l'architecte Jean-Baptiste Leclerc."
- ✅ "Tu vois ce bâtiment-là? 1893. Le gars qui l'a construit, Jean-Baptiste Leclerc, était un personnage! Il paraît qu'il a refusé de mettre des escaliers parce qu'il trouvait ça 'trop prévisible'. Finalement, la ville l'a forcé... mais il a quand même caché un escalier secret. Personne sait où il est!"

---

## Questions ouvertes

### 💰 Business Model (à décider)

| Option | Pros | Cons |
|--------|------|------|
| **Freemium** (1 parcours gratuit, reste payant) | Acquisition facile | Conversion incertaine |
| **Pay per city** (4.99$/ville) | Simple, clair | Friction à l'achat |
| **Abonnement** (9.99$/mois) | Revenus récurrents | Dur à justifier si voyage rare |
| **B2B** (vendre aux offices de tourisme) | Gros contrats | Cycle de vente long |
| **Hybrid** (B2C freemium + B2B white-label) | Meilleur des deux mondes | Plus complexe |

**Recommandation:** Commencer B2C freemium pour valider, puis approcher B2B.

### 🚶‍♂️🚴‍♂️🚗 Modes de transport (à designer)

| Mode | Comportement suggéré |
|------|---------------------|
| **Pied** | Détails fins, peut s'arrêter, points d'intérêt rapprochés (50-200m) |
| **Vélo** | Points plus espacés (200-500m), narration plus courte, moins de "arrête-toi ici" |
| **Auto** | Narration continue style podcast/road trip, quartiers plutôt que bâtiments |

**Idée:** Slider ou sélection au début du parcours. L'app adapte le contenu automatiquement.

---

## Technologie (à valider)

| Composant | Option envisagée |
|-----------|------------------|
| App mobile | React Native ou Flutter |
| Backend | Supabase (auth, DB, storage audio) |
| Audio | Fichiers MP3 pré-générés (ElevenLabs?) |
| Maps | Mapbox ou Google Maps |
| Géofencing | Native APIs (background location) |
| Sync multi-appareils | WebSockets / Supabase Realtime |

---

## Nom de l'app (brainstorm)

- **Wandr** (wander + r)
- **LocalVoice**
- **CityWhisper**
- **GuideMe**
- **Écho** (français)
- **Compagnon**
- **[À brainstormer ensemble]**

---

## Documents liés

- [ROADMAP.md](./docs/ROADMAP.md) — Versions et planning
- [REQUIREMENTS.md](./docs/REQUIREMENTS.md) — Fonctionnalités détaillées
- [USER-STORIES.md](./docs/USER-STORIES.md) — Stories par épic

---

*Dernière mise à jour: 2026-02-12*
