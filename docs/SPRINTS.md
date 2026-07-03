# 🏃 Définition des Sprints — App Voyage

> Focus initial: **Saint-Lambert** (bac à sable pour valider le GPS/geofencing)

---

## 📊 Statut actuel (2026-07-03, v0.6.0)

| Sprint | Contenu | Statut |
|--------|---------|--------|
| Sprint 0 | Setup + collecte POIs Saint-Lambert | ✅ **Fait** — 81 POIs, 243 scripts (dépasse l'objectif de 15-20) |
| Sprint 1 | Carte & POIs affichés | ✅ **Fait** — carte OSM, filtres, vue liste, détail POI |
| Sprint 2 | Lecture audio (tap) | ✅ **Fait** — mini-player, background, lock screen (pas de seek: limitation flutter_tts) |
| Sprint 3 | GPS auto-trigger | ✅ **Fait** — geofencing intelligent, notifications, POIs visités, cooldown |
| Revue de code | 20 correctifs (GPS arrière-plan, position live, voix, etc.) | ✅ **Fait** (v0.4.8) — voir CODE-REVIEW.md |
| Polish pré-terrain | Edge TTS branché, CARTO, clustering, dark mode, onboarding, splash | ✅ **Fait** (v0.5.x) |
| Sprint 4 | Test terrain Saint-Lambert | ⏳ **Prochaine étape** (humains requis 🚶) |
| Sprint 5 | Offline complet (sqflite) | 🔜 À venir |
| Sprint 7 | Multi-langue | ✅ **Fait en avance** (v0.6.0) — UI FR/EN/ES (gen-l10n), noms/catégories localisés, notifications localisées |
| Sprint 8 | Onboarding & permissions | ✅ **Fait en avance** (v0.5-0.6) — onboarding 4 écrans avec choix de langue, flow permissions localisé, section À propos |
| Sprint 9 | Sync groupe (mode Host) | ✅ **Développé** (v0.6.0) — sessions par code + QR, participants en direct (Presence), host contrôle la lecture (Broadcast). ⚠️ À tester à 2-3 appareils |

---

## Philosophie

- **Sprints de 2 semaines** (ajustable selon disponibilité)
- **Livrables concrets** à chaque fin de sprint
- **Test terrain** avant de passer au suivant
- **POI-first:** on collecte des POIs standalone, pas des parcours
- Saint-Lambert d'abord → petites villes Rive-Sud/Montérégie ensuite

---

## Phase 1: Prototype (Saint-Lambert) 🧪

**Objectif:** Valider que le GPS/geofencing fonctionne avec de vrais POIs. L'utilisateur se promène librement et les audios se déclenchent automatiquement.

### Sprint 0: Setup & Collecte des POIs
**Durée:** 1-2 semaines  
**Focus:** Mise en place de l'environnement + collecter TOUS les POIs de Saint-Lambert

#### Livrables
- [ ] Projet Flutter initialisé et configuré
- [ ] Repo GitHub avec CI/CD basic
- [ ] Projet Supabase créé et configuré
- [ ] Schéma de base de données implémenté (POI-first)
- [ ] flutter_tts intégré (voix native du téléphone)
- [ ] **Collecter TOUS les POIs de Saint-Lambert** (15-20 POIs)
- [ ] Scripts audio auto-contenus pour chaque POI
- [ ] POIs dans la DB avec coordonnées GPS précises
- [ ] Documentation technique de setup

#### Tâches détaillées

**Projet Flutter**
- [ ] `flutter create app_voyage`
- [ ] Structure de dossiers (lib/screens, lib/models, lib/services, etc.)
- [ ] Packages essentiels installés:
  - `supabase_flutter` (backend)
  - `mapbox_maps_flutter` (cartes)
  - `flutter_tts` (voix native)
  - `geolocator` (GPS)
  - `flutter_local_notifications`
- [ ] Configuration iOS (permissions, capabilities)
- [ ] Configuration Android (permissions, manifest)
- [ ] README technique avec instructions de setup

**Supabase**
- [ ] Créer projet Supabase
- [ ] Implémenter les tables:
  - `cities` (villes)
  - `points` (POIs standalone avec city_id)
  - `scripts` (contenu audio texte)
- [ ] Row Level Security (RLS) configuré
- [ ] Seed data: Saint-Lambert (ville + 15-20 POIs)

**Contenu Saint-Lambert**
- [ ] Collecter TOUS les POIs intéressants de Saint-Lambert
- [ ] Obtenir coordonnées GPS précises
- [ ] Catégoriser chaque POI (patrimoine, nature, maritime, etc.)
- [ ] Rédiger scripts audio auto-contenus (FR)
- [ ] Insérer dans Supabase

#### Critère de succès
> "Je peux voir tous les POIs de Saint-Lambert dans Supabase, avec leurs scripts auto-contenus et coordonnées GPS."

#### Estimation: 1-2 semaines

---

### Sprint 1: Carte & POIs affichés
**Durée:** 2 semaines  
**Focus:** Afficher une carte avec TOUS les POIs de Saint-Lambert

#### User Stories incluses
| ID | Story | Priorité |
|----|-------|----------|
| US-101 | Voir la carte de la ville | 🔴 Must |
| US-102 | Voir les POIs autour de moi | 🔴 Must |
| US-103 | Voir le détail d'un POI | 🔴 Must |

#### Livrables
- [ ] Écran carte avec Mapbox
- [ ] Position GPS de l'utilisateur affichée
- [ ] TOUS les POIs de Saint-Lambert affichés sur la carte
- [ ] Icônes distinctes par catégorie
- [ ] Tap sur un POI → voir détail (nom, description, catégorie)
- [ ] Filtre par catégorie (patrimoine, nature, etc.)

#### Critère de succès
> "Je peux ouvrir l'app, voir la carte de Saint-Lambert avec tous les POIs, filtrer par catégorie, et voir le détail de chacun."

#### Estimation: 2 semaines

---

### Sprint 2: Lecture audio (tap on POI)
**Durée:** 2 semaines  
**Focus:** Jouer un audio quand on tap sur un POI

#### User Stories incluses
| ID | Story | Priorité |
|----|-------|----------|
| US-202 | Déclenchement audio manuel (tap) | 🔴 Must |
| US-203 | Contrôles audio (play/pause/seek) | 🔴 Must |

#### Livrables
- [ ] Tap sur un POI → joue l'audio
- [ ] Mini-player avec play/pause
- [ ] Barre de progression
- [ ] Rewind 15 sec
- [ ] Audio fonctionne en background
- [ ] Contrôles sur lock screen

#### Critère de succès
> "Je peux taper sur n'importe quel POI et écouter son audio avec des contrôles fonctionnels."

#### Estimation: 2 semaines

---

### Sprint 3: GPS auto-trigger 🎯 (LE sprint clé!)
**Durée:** 2 semaines  
**Focus:** L'audio se déclenche automatiquement quand on s'approche d'un POI

#### User Stories incluses
| ID | Story | Priorité |
|----|-------|----------|
| US-104 | Activer le mode découverte | 🔴 Must |
| US-201 | Déclenchement audio GPS auto | 🔴 Must |

#### Livrables
- [ ] Bouton "Activer la découverte" (mode exploration)
- [ ] Géofencing: trigger audio quand on entre dans le rayon d'un POI
- [ ] Notification/vibration avant lecture
- [ ] Audio joue même si app en background
- [ ] Ne pas re-déclencher si déjà écouté
- [ ] Indicateur visuel des POIs déjà visités sur la carte

#### Critère de succès
> "Je me promène librement à Saint-Lambert avec le mode découverte activé. L'audio se déclenche automatiquement quand je passe près d'un POI."

#### Estimation: 2 semaines

---

### Sprint 4: Test terrain — Balade libre à Saint-Lambert
**Durée:** 1 semaine  
**Focus:** Marcher librement dans Saint-Lambert, tester les triggers

#### Livrables
- [ ] Test complet: se promener librement, sans itinéraire fixe (Pierre + Camélia)
- [ ] Tester différents trajets (pas toujours le même chemin)
- [ ] Liste des bugs identifiés
- [ ] Ajustements des rayons de géofencing par POI
- [ ] Corrections de timing audio
- [ ] Rapport de test documenté
- [ ] Données collectées: quels POIs se déclenchent bien, lesquels posent problème

#### Critère de succès
> "On a marché librement dans Saint-Lambert pendant 1-2 heures. Les audios se sont déclenchés automatiquement >80% du temps pour les POIs qu'on a croisés."

#### Estimation: 1 semaine

---

### Sprint 5: Offline & Polish prototype
**Durée:** 2 semaines  
**Focus:** Téléchargement offline des POIs + corrections post-test

#### User Stories incluses
| ID | Story | Priorité |
|----|-------|----------|
| US-204 | Téléchargement offline | 🔴 Must |
| US-105 | Voir les POIs visités | 🔴 Must |

#### Livrables
- [ ] Bouton "Télécharger les POIs de cette ville"
- [ ] Download: JSON (POIs) + MP3s (audios) + tiles carte
- [ ] Indicateur de progression
- [ ] Fonctionne 100% sans internet après download
- [ ] Historique des POIs visités (carte avec marqueurs vert/gris)
- [ ] Corrections des bugs du Sprint 4

#### Critère de succès
> "Je télécharge les POIs de Saint-Lambert en Wi-Fi, je coupe internet, et tout fonctionne — y compris le GPS auto-trigger."

#### Estimation: 2 semaines

---

## 🎯 Checkpoint: Fin Phase 1 (Prototype)

**Durée totale estimée:** 10-11 semaines

**Livrable:** App prototype fonctionnelle avec:
- Tous les POIs de Saint-Lambert (~15-20)
- Carte avec POIs par catégorie
- Audio auto-trigger par GPS (mode découverte)
- Lecture manuelle (tap)
- Mode offline
- Testé sur le terrain

**Décision:** Go/No-Go pour la Phase 2 (expansion villes Rive-Sud)

---

## Phase 2: MVP (Villes Rive-Sud + Features) 🏙️

> Commence seulement après validation du prototype Saint-Lambert

### Sprint 6: Contenu — 5 villes touristiques de la Rive-Sud / Montérégie
**Durée:** 3-4 semaines  
**Focus:** Créer le contenu pour 5 petites villes à potentiel touristique, utilisables pour approcher des partenariats municipaux.

#### Villes cibles (à confirmer)
1. **Saint-Bruno-de-Montarville** — Mont Saint-Bruno, parc national, village historique
2. **Mont-Saint-Hilaire** — Réserve de biosphère UNESCO, vignobles, arts
3. **Chambly** — Fort Chambly (lieu historique national), canal, brasseries
4. **Boucherville** — Îles-de-Boucherville (parc national), patrimoine Nouvelle-France
5. **Longueuil** — Co-cathédrale, vieux Longueuil, parc Michel-Chartrand

#### Livrables par ville
- [ ] 12-15 POIs avec coordonnées GPS précises
- [ ] Scripts audio auto-contenus FR + EN + ES
- [ ] Catégorisation par thématique
- [ ] Vérification factuelle (poi-checker)
- [ ] POIs et scripts dans Supabase

#### Stratégie partenariats
Ces villes servent de **démo concrète** pour approcher les offices de tourisme et municipalités. "Votre ville est déjà dans l'app — voulez-vous être partenaire officiel?"

#### Critère de succès
> "5 villes avec 12-15 POIs chacune dans Supabase, prêtes à être démontrées à des partenaires potentiels."

---

### Sprint 7: Multi-langue
**Durée:** 2 semaines  
**Focus:** Support FR + EN

#### User Stories incluses
| ID | Story | Priorité |
|----|-------|----------|
| US-205 | Choisir la langue | 🟡 Should |

#### Livrables
- [ ] Sélecteur de langue dans settings
- [ ] Audios FR et EN disponibles
- [ ] UI traduite
- [ ] Téléchargement par langue

---

### Sprint 8: Onboarding & Permissions
**Durée:** 1-2 semaines  
**Focus:** Première expérience utilisateur

#### User Stories incluses
| ID | Story | Priorité |
|----|-------|----------|
| US-901 | Onboarding | 🔴 Must |
| US-902 | Permissions GPS | 🔴 Must |
| US-903 | Page settings | 🟡 Should |

#### Livrables
- [ ] Écrans onboarding (3-4 slides)
- [ ] Demande permissions avec explication
- [ ] Page settings complète
- [ ] Gestion des refus de permission

---

### Sprint 9: Sync Groupe (Killer Feature)
**Durée:** 3 semaines  
**Focus:** Mode Host pour écoute synchronisée

#### User Stories incluses
| ID | Story | Priorité |
|----|-------|----------|
| US-301 | Créer session groupe | 🟡 Should |
| US-302 | Rejoindre session | 🟡 Should |
| US-303 | Sync lecture | 🟡 Should |

#### Livrables
- [ ] Bouton "Écouter ensemble"
- [ ] Génération code de session
- [ ] QR code partage
- [ ] Liste des participants
- [ ] Sync audio via Supabase Realtime
- [ ] Tests avec 2-3 appareils

---

### Sprint 10: Auth + Paiements
**Durée:** 2-3 semaines  
**Focus:** Comptes utilisateurs + monétisation

#### User Stories incluses
| ID | Story | Priorité |
|----|-------|----------|
| US-501 | Utiliser sans compte (mode gratuit limité) | 🟡 Should |
| US-502 | Créer un compte | 🟡 Should |
| US-503 | Acheter l'accès à une ville | 🟡 Should |

#### Livrables
- [ ] Auth Supabase (email + Google + Apple)
- [ ] Mode gratuit: 2-3 POIs par ville en preview
- [ ] In-App Purchase iOS
- [ ] In-App Purchase Android
- [ ] Achat par ville (7.99$ CAD) ou bundle (14.99$ CAD)
- [ ] Restauration des achats

---

### Sprint 11: Test & Polish MVP
**Durée:** 2 semaines  
**Focus:** Beta testing, corrections

#### Livrables
- [ ] Recrutement 20-50 beta testers
- [ ] Distribution TestFlight + Google Play Beta
- [ ] Collecte de feedback
- [ ] Corrections de bugs
- [ ] Optimisation performance

---

### Sprint 12: Launch Prep
**Durée:** 1-2 semaines  
**Focus:** Préparer le lancement

#### Livrables
- [ ] Screenshots App Store
- [ ] Description et métadonnées
- [ ] Politique de confidentialité
- [ ] Vidéo promo (optionnel)
- [ ] Soumission App Store + Google Play
- [ ] Plan marketing soft launch

---

## 🚀 Checkpoint: Fin Phase 2 (MVP)

**Durée totale estimée:** 14-18 semaines (après Phase 1)

**Livrable:** App MVP prête pour le public:
- Saint-Lambert (~81 POIs)
- 5 villes Rive-Sud/Montérégie (12-15 POIs chacune)
- Exploration libre avec GPS auto-trigger
- Filtrage par catégorie
- Mode offline
- Sync groupe
- Paiement par ville (7.99$ CAD)
- Sur App Store + Google Play

---

## Timeline globale estimée

```
Phase 1: Prototype Saint-Lambert
|----Sprint 0----|----Sprint 1----|----Sprint 2----|----Sprint 3----|--S4--|----Sprint 5----|
   Setup+POIs       Carte+POIs       Audio tap       GPS trigger     Test    Offline
   (1-2 sem)        (2 sem)          (2 sem)         (2 sem)        (1 sem)  (2 sem)

                                                                     Total: ~10-11 semaines

Phase 2: MVP Montréal + Features
|----Sprint 6----|---Sprint 7---|--Sprint 8--|-----Sprint 9-----|---Sprint 10---|--S11--|--S12--|
  5 villes RS      Multi-lang    Onboarding    Sync Groupe        Auth+Paie      Beta   Launch
  (3-4 sem)        (2 sem)       (1-2 sem)      (3 sem)           (2-3 sem)    (2 sem) (1-2 sem)

                                                                     Total: ~14-18 semaines
```

**Total Phase 1 + 2:** ~24-29 semaines (~6-7 mois)

---

## Notes importantes

### Flexibilité
- Les estimations sont des **approximations**
- Ajuster selon la vélocité réelle
- Sprints peuvent être plus courts si temps partiel

### Dépendances
- Sprint 1 dépend du Sprint 0 (POIs doivent être dans la DB)
- Sprint 3 dépend du Sprint 2 (audio doit fonctionner)
- Phase 2 dépend de Phase 1 (validation terrain du GPS trigger)

### Go/No-Go points
- Après Sprint 4: Le géofencing fonctionne-t-il assez bien en balade libre?
- Après Sprint 11: Les beta testers sont-ils satisfaits?

---

*Dernière mise à jour: 2026-07-03*
