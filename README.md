# 🎧 App Voyage

> Guide audio géolocalisé — "Un ami historien passionné dans tes écouteurs"

## Documentation

| Document | Contenu |
|----------|---------|
| [PROJECT.md](./PROJECT.md) | Vision, cibles, scope, équipe |
| [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) | Modèle de données, workflows, stack technique |
| [docs/COMPETITIVE-ANALYSIS.md](./docs/COMPETITIVE-ANALYSIS.md) | Analyse des compétiteurs (VoiceMap, izi.TRAVEL, etc.) |
| [docs/RISKS.md](./docs/RISKS.md) | **Analyse de risques et mitigation** |
| [docs/ROADMAP.md](./docs/ROADMAP.md) | Phases et timeline |
| [docs/USER-STORIES.md](./docs/USER-STORIES.md) | User stories par épic |

## Status

🚧 **Phase 0: Discovery** — Définition du projet en cours

## Équipe

- **Pierre Raymond** — Product Owner
- **Camélia Raymond** — Lead technique & Développement

## Stack

- **Mobile:** Flutter
- **Backend:** Supabase (PostgreSQL + Auth + Realtime)
- **Audio storage:** Cloudinary
- **TTS:** ElevenLabs
- **Maps:** Mapbox

## Top 3 Risques identifiés

1. 🚨 GPS imprécis / trigger raté
2. ⚠️ Compétition gratuite (BaladoDécouverte)
3. ⚠️ Sync groupe qui désync
