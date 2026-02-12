# 🏃 Définition des Sprints — App Voyage

> Focus initial: **Sainte-Julie** (bac à sable pour valider la techno)

---

## Philosophie

- **Sprints de 2 semaines** (ajustable selon disponibilité)
- **Livrables concrets** à chaque fin de sprint
- **Test terrain** avant de passer au suivant
- Sainte-Julie d'abord → Montréal ensuite

---

## Phase 1: Prototype (Sainte-Julie) 🧪

**Objectif:** Valider que la techno fonctionne avant d'investir dans le contenu Montréal.

### Sprint 0: Setup & Fondations
**Durée:** 1-2 semaines  
**Focus:** Mise en place de l'environnement de développement et de la base de données

#### Livrables
- [ ] Projet Flutter initialisé et configuré
- [ ] Repo GitHub avec CI/CD basic
- [ ] Projet Supabase créé et configuré
- [ ] Schéma de base de données implémenté
- [ ] Compte Cloudinary configuré pour les audios
- [ ] Compte ElevenLabs configuré
- [ ] Données Sainte-Julie dans la DB (POIs, parcours)
- [ ] Documentation technique de setup

#### Tâches détaillées

**Projet Flutter**
- [ ] `flutter create app_voyage`
- [ ] Structure de dossiers (lib/screens, lib/models, lib/services, etc.)
- [ ] Packages essentiels installés:
  - `supabase_flutter` (backend)
  - `mapbox_maps_flutter` (cartes)
  - `just_audio` (lecteur audio)
  - `geolocator` (GPS)
  - `flutter_local_notifications`
- [ ] Configuration iOS (permissions, capabilities)
- [ ] Configuration Android (permissions, manifest)
- [ ] README technique avec instructions de setup

**Supabase**
- [ ] Créer projet Supabase
- [ ] Implémenter les tables:
  - `cities` (villes)
  - `tours` (parcours)
  - `points` (POIs)
  - `audio_files` (références audio)
- [ ] Row Level Security (RLS) configuré
- [ ] Seed data: Sainte-Julie (ville + 1 parcours + 8-10 POIs)

**Cloudinary**
- [ ] Créer folder `app-voyage/sainte-julie`
- [ ] Tester upload d'un MP3
- [ ] Documenter la convention de nommage

**Contenu Sainte-Julie**
- [ ] Rechercher 8-10 points d'intérêt à Sainte-Julie
- [ ] Obtenir coordonnées GPS précises
- [ ] Rédiger scripts audio (FR) — style "ami passionné"
- [ ] Générer audios avec ElevenLabs
- [ ] Uploader sur Cloudinary
- [ ] Insérer dans Supabase

#### Critère de succès
> "Je peux voir les données de Sainte-Julie dans Supabase, et les fichiers audio sont accessibles sur Cloudinary."

#### Estimation: 1-2 semaines

---

### Sprint 1: Carte & Navigation de base
**Durée:** 2 semaines  
**Focus:** Afficher une carte avec les POIs de Sainte-Julie

#### User Stories incluses
| ID | Story | Priorité |
|----|-------|----------|
| US-101 | Voir la carte de la ville | 🔴 Must |
| US-102 | Voir les parcours disponibles | 🔴 Must |
| US-103 | Voir le détail d'un parcours | 🔴 Must |

#### Livrables
- [ ] Écran carte avec Mapbox
- [ ] Position GPS de l'utilisateur affichée
- [ ] POIs de Sainte-Julie affichés sur la carte
- [ ] Liste des parcours (1 pour l'instant)
- [ ] Écran détail du parcours
- [ ] Navigation entre les écrans

#### Critère de succès
> "Je peux ouvrir l'app, voir la carte de Sainte-Julie, voir le parcours disponible, et voir ses points d'intérêt."

#### Estimation: 2 semaines

---

### Sprint 2: Lecture audio basique
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
> "Je peux taper sur un point d'intérêt et écouter son audio avec des contrôles fonctionnels."

#### Estimation: 2 semaines

---

### Sprint 3: Géofencing automatique
**Durée:** 2 semaines  
**Focus:** L'audio se déclenche automatiquement quand on s'approche d'un POI

#### User Stories incluses
| ID | Story | Priorité |
|----|-------|----------|
| US-104 | Démarrer un parcours | 🔴 Must |
| US-105 | Voir ma progression | 🔴 Must |
| US-201 | Déclenchement audio GPS auto | 🔴 Must |

#### Livrables
- [ ] Bouton "Démarrer le parcours"
- [ ] Mode visite active
- [ ] Géofencing: trigger audio à ~50m du POI
- [ ] Notification/vibration avant lecture
- [ ] Barre de progression du parcours
- [ ] Points visités vs à venir sur la carte

#### Critère de succès
> "Je démarre le parcours et je marche vers un POI. L'audio se déclenche automatiquement quand je m'approche."

#### Estimation: 2 semaines

---

### Sprint 4: Test terrain Sainte-Julie
**Durée:** 1 semaine  
**Focus:** Tester le prototype dans la vraie vie, corriger les bugs

#### Livrables
- [ ] Test complet du parcours Sainte-Julie (Pierre + Camélia)
- [ ] Liste des bugs identifiés
- [ ] Ajustements des rayons de géofencing
- [ ] Corrections de timing audio
- [ ] Rapport de test documenté

#### Critère de succès
> "On a marché le parcours Sainte-Julie de bout en bout, l'audio s'est déclenché correctement >80% du temps."

#### Estimation: 1 semaine

---

### Sprint 5: Offline & Polish prototype
**Durée:** 2 semaines  
**Focus:** Téléchargement offline + corrections post-test

#### User Stories incluses
| ID | Story | Priorité |
|----|-------|----------|
| US-204 | Téléchargement offline | 🔴 Must |
| US-401 | Sélection mode transport | 🔴 Must |

#### Livrables
- [ ] Bouton "Télécharger le parcours"
- [ ] Download: JSON + MP3s + tiles carte
- [ ] Indicateur de progression
- [ ] Fonctionne 100% sans internet après download
- [ ] Sélecteur de mode (piéton par défaut)
- [ ] Corrections des bugs du Sprint 4

#### Critère de succès
> "Je télécharge le parcours en Wi-Fi, je coupe internet, et tout fonctionne."

#### Estimation: 2 semaines

---

## 🎯 Checkpoint: Fin Phase 1 (Prototype)

**Durée totale estimée:** 10-11 semaines

**Livrable:** App prototype fonctionnelle avec:
- 1 parcours Sainte-Julie complet
- Carte + navigation
- Audio auto-trigger par GPS
- Mode offline
- Testé sur le terrain

**Décision:** Go/No-Go pour la Phase 2 (MVP Montréal)

---

## Phase 2: MVP (Montréal) 🏙️

> Commence seulement après validation du prototype Sainte-Julie

### Sprint 6: Contenu Vieux-Montréal
**Durée:** 2-3 semaines  
**Focus:** Créer le premier parcours Montréal

#### Livrables
- [ ] Recherche: 12-15 POIs Vieux-Montréal
- [ ] Scripts audio FR + EN
- [ ] Génération audio (2 voix: Jacques FR, narrateur EN)
- [ ] Upload Cloudinary
- [ ] Données dans Supabase
- [ ] Infos logistiques (parking, toilettes, cafés)

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

### Sprint 10: Comptes & Paiements
**Durée:** 2-3 semaines  
**Focus:** Monétisation

#### User Stories incluses
| ID | Story | Priorité |
|----|-------|----------|
| US-501 | Utiliser sans compte | 🟡 Should |
| US-502 | Créer un compte | 🟡 Should |
| US-503 | Acheter un parcours | 🟡 Should |

#### Livrables
- [ ] Auth Supabase (email + Google + Apple)
- [ ] In-App Purchase iOS
- [ ] In-App Purchase Android
- [ ] Parcours gratuit (5 POIs) vs premium
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
- 1 parcours Sainte-Julie
- 1 parcours Vieux-Montréal (FR + EN)
- Mode offline
- Sync groupe
- Paiements
- Sur App Store + Google Play

---

## Timeline globale estimée

```
Phase 1: Prototype Sainte-Julie
|----Sprint 0----|----Sprint 1----|----Sprint 2----|----Sprint 3----|--S4--|----Sprint 5----|
     Setup          Carte           Audio           Géofencing      Test    Offline
    (1-2 sem)      (2 sem)         (2 sem)         (2 sem)        (1 sem)  (2 sem)

                                                                    Total: ~10-11 semaines

Phase 2: MVP Montréal  
|---Sprint 6---|---Sprint 7---|--Sprint 8--|-----Sprint 9-----|---Sprint 10---|--S11--|--S12--|
   Contenu       Multi-lang    Onboarding    Sync Groupe        Paiements      Beta   Launch
  (2-3 sem)      (2 sem)       (1-2 sem)      (3 sem)           (2-3 sem)    (2 sem) (1-2 sem)

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
- Sprint 1 dépend du Sprint 0 (DB doit être prête)
- Sprint 3 dépend du Sprint 2 (audio doit fonctionner)
- Phase 2 dépend de Phase 1 (validation terrain)

### Go/No-Go points
- Après Sprint 4: Le géofencing fonctionne-t-il assez bien?
- Après Sprint 11: Les beta testers sont-ils satisfaits?

---

*Dernière mise à jour: 2026-02-12*
