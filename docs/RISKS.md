# ⚠️ Analyse de Risques — App Voyage

> Identification et mitigation des risques potentiels du projet

---

## Matrice de risques

| Probabilité ↓ / Impact → | 🟢 Faible | 🟡 Moyen | 🔴 Élevé |
|--------------------------|-----------|----------|----------|
| **Haute** | Surveiller | ⚠️ Priorité moyenne | 🚨 CRITIQUE |
| **Moyenne** | Accepter | Surveiller | ⚠️ Priorité moyenne |
| **Basse** | Accepter | Accepter | Surveiller |

---

## 🔴 Risques techniques

### T1. GPS imprécis ou trigger raté sur un POI
| Aspect | Détail |
|--------|--------|
| **Description** | L'audio ne se déclenche pas au bon moment quand l'utilisateur s'approche d'un POI (trop tôt, trop tard, pas du tout) |
| **Probabilité** | 🔴 Haute |
| **Impact** | 🔴 Élevé — Expérience utilisateur ruinée, reviews négatifs |
| **Cause** | GPS smartphone imprécis (~5-15m), bâtiments qui bloquent le signal, calibration du rayon par POI |

**Mitigation:**
- [ ] Tester chaque POI sur le terrain AVANT de lancer
- [ ] Algorithme intelligent: tenir compte vitesse + direction (comme GuideAlong)
- [ ] Rayon dynamique par POI (plus large pour les POIs en zone dense)
- [ ] Fallback: bouton manuel "Écouter" sur chaque POI
- [ ] Notification visuelle + vibration avant l'audio
- [ ] Si plusieurs POIs proches: prioriser le plus proche, file d'attente pour les autres

---

### T2. Batterie drainée rapidement
| Aspect | Détail |
|--------|--------|
| **Description** | GPS + audio + écran = téléphone mort en 2h |
| **Probabilité** | 🟡 Moyenne |
| **Impact** | 🟡 Moyen — Utilisateur frustré, exploration interrompue |

**Mitigation:**
- [ ] Utiliser geofencing natif (pas polling GPS constant)
- [ ] Mode "économie" qui réduit la précision
- [ ] Afficher estimation batterie restante ("~3h de découverte")
- [ ] Recommander de partir avec batterie pleine / power bank

---

### T3. Sync groupe qui lag ou désync
| Aspect | Détail |
|--------|--------|
| **Description** | Le mode Host ne synchronise pas bien entre les appareils |
| **Probabilité** | 🟡 Moyenne |
| **Impact** | 🔴 Élevé — C'est notre killer feature! |

**Mitigation:**
- [ ] Viser sync à la **seconde** (pas milliseconde) — suffisant pour narration
- [ ] Utiliser Supabase Realtime (WebSockets fiables)
- [ ] Fallback: si connexion perdue, chaque appareil continue indépendamment
- [ ] Tester avec mauvaise connexion (3G, zones mortes)

---

### T4. App rejetée par App Store / Google Play
| Aspect | Détail |
|--------|--------|
| **Description** | Apple ou Google refuse l'app pour diverses raisons |
| **Probabilité** | 🟢 Basse |
| **Impact** | 🔴 Élevé — Pas de distribution |

**Mitigation:**
- [ ] Lire les guidelines AVANT de développer
- [ ] Pas de contenu offensant
- [ ] Permissions justifiées (GPS, audio)
- [ ] Privacy policy en place
- [ ] Prévoir 1-2 semaines de délai review

---

### T5. Bugs après mise à jour OS (iOS/Android)
| Aspect | Détail |
|--------|--------|
| **Description** | Nouvelle version iOS/Android casse des fonctionnalités |
| **Probabilité** | 🟡 Moyenne |
| **Impact** | 🟡 Moyen |

**Mitigation:**
- [ ] Tester sur betas iOS/Android avant leur sortie
- [ ] Utiliser Flutter stable (pas bleeding edge)
- [ ] Monitoring des reviews pour détecter les problèmes vite

---

### T6. Trop de POIs submergent l'utilisateur
| Aspect | Détail |
|--------|--------|
| **Description** | Avec l'approche POI-first, une ville dense peut avoir 50-100+ POIs. L'utilisateur se sent submergé, ne sait pas par où commencer, reçoit trop de notifications. |
| **Probabilité** | 🟡 Moyenne |
| **Impact** | 🟡 Moyen — UX dégradée, utilisateur désinstalle |

**Mitigation:**
- [ ] **Catégories & filtres** — L'utilisateur choisit ce qui l'intéresse (patrimoine, food, art, etc.)
- [ ] **Notifications intelligentes** — Limiter le nombre de triggers par heure (pas spam)
- [ ] **Priorité POI** — Afficher les "incontournables" en premier, le reste en secondaire
- [ ] **Cool-down** après chaque audio (ne pas enchaîner 5 POIs en 2 minutes)
- [ ] **Mode "Top 10"** — Suggérer les POIs les mieux notés pour les pressés
- [ ] Ajuster la densité de POIs affichés selon le zoom de la carte

---

### T7. Dépendance à l'API non officielle Edge TTS
| Aspect | Détail |
|--------|--------|
| **Description** | Depuis v0.5.0, la lecture privilégie `EdgeTtsService`: API WebSocket non documentée de Microsoft Edge avec un token client codé en dur. Microsoft peut la couper, la modifier ou la bloquer sans préavis. Question de conditions d'utilisation également. |
| **Probabilité** | 🟡 Moyenne |
| **Impact** | 🟡 Moyen — l'app retombe automatiquement sur les voix natives (fallback en place, timeout 12 s) |

**Mitigation:**
- [x] Branché avec fallback flutter_tts automatique (offline, API down, timeout)
- [x] MP3 cachés localement — une coupure de l'API n'affecte pas les audios déjà téléchargés
- [ ] Surveiller les logs `[AudioService] Edge TTS erreur` pour détecter une coupure
- [ ] Si la coupure devient fréquente: migrer vers Azure Speech officiel (~5 $/ville, mêmes voix)

---

### T8. GPS/audio en arrière-plan non fonctionnel
| Aspect | Détail |
|--------|--------|
| **Description** | Le mode découverte doit fonctionner téléphone en poche / écran verrouillé. La config actuelle (geolocator sans `AppleSettings`/`AndroidSettings` spécifiques, pas de foreground service Android) ne le permet pas — le tracking s'arrête en arrière-plan. |
| **Probabilité** | 🔴 Haute (confirmé par revue de code) |
| **Impact** | 🔴 Élevé — invaliderait le test terrain Sprint 4 |

**Mitigation:**
- [x] Corrigé en v0.4.8 (voir CODE-REVIEW.md, finding #1)
- [x] iOS: `AppleSettings(allowBackgroundLocationUpdates: true, showBackgroundLocationIndicator: true)`
- [x] Android: `AndroidSettings(foregroundNotificationConfig: ...)` — foreground service geolocator
- [ ] Tester explicitement écran verrouillé pendant le test terrain (Sprint 4)

---

## 🟠 Risques business / marché

### B1. BaladoDécouverte est gratuit
| Aspect | Détail |
|--------|--------|
| **Description** | Compétiteur local gratuit — pourquoi payer pour App Voyage? |
| **Probabilité** | 🔴 Haute |
| **Impact** | 🟡 Moyen |

**Mitigation:**
- [ ] **Différenciation par la qualité et le ton** — BaladoDécouverte est ennuyeux
- [ ] **Sync groupe** — ils ne l'ont pas
- [ ] **Découverte libre** — pas de parcours rigides à suivre
- [ ] **Marketing**: "Le guide que vous VOULEZ écouter"
- [ ] Offrir POIs teaser gratuits pour prouver la valeur

---

### B2. Marché trop petit
| Aspect | Détail |
|--------|--------|
| **Description** | Pas assez de touristes intéressés par des guides audio payants |
| **Probabilité** | 🟡 Moyenne |
| **Impact** | 🔴 Élevé — Pas de revenus |

**Mitigation:**
- [ ] Valider avec MVP minimal AVANT d'investir trop
- [ ] Commencer Montréal (gros volume touristes: ~11M/an)
- [ ] Cibler aussi les **locaux** qui redécouvrent leur ville via les POIs
- [ ] Pivoter vers B2B si B2C ne marche pas (vendre à Tourisme Montréal)
- [ ] Tracker métriques: téléchargements, POIs écoutés, conversion

---

### B3. Saisonnalité forte
| Aspect | Détail |
|--------|--------|
| **Description** | Tourisme Montréal = surtout été. Hiver = mort |
| **Probabilité** | 🔴 Haute |
| **Impact** | 🟡 Moyen — Revenus irréguliers |

**Mitigation:**
- [ ] Créer POIs "4 saisons" (Montréal souterrain en hiver!)
- [ ] Cibler aussi les **locaux** qui redécouvrent leur ville
- [ ] Diversifier géographiquement (villes avec tourisme année longue)

---

### B4. Copié par un gros joueur
| Aspect | Détail |
|--------|--------|
| **Description** | VoiceMap ou Google ajoute sync groupe / POI discovery |
| **Probabilité** | 🟢 Basse |
| **Impact** | 🔴 Élevé |

**Mitigation:**
- [ ] Exécuter vite, être le premier au Québec
- [ ] Construire une marque forte et fidélité
- [ ] Focus niche (Québec) plutôt que mondial
- [ ] Le contenu local est notre moat

---

### B5. Pricing mal calibré
| Aspect | Détail |
|--------|--------|
| **Description** | Trop cher = personne achète. Trop cheap = pas rentable |
| **Probabilité** | 🟡 Moyenne |
| **Impact** | 🟡 Moyen |

**Mitigation:**
- [ ] A/B tester différents prix
- [ ] Pack ville: ~14.99$ (accès à tous les POIs)
- [ ] Tour curaté (V2): ~7.99$ chacun
- [ ] Offrir bundle pour augmenter panier moyen
- [ ] Regarder la conversion, pas juste les downloads

---

## 🟡 Risques de contenu

### C1. Contenu incorrect ou obsolète
| Aspect | Détail |
|--------|--------|
| **Description** | Infos historiques fausses, bâtiment rénové, accès fermé |
| **Probabilité** | 🟡 Moyenne |
| **Impact** | 🟡 Moyen — Crédibilité atteinte |

**Mitigation:**
- [ ] Fact-check rigoureux avant publication de chaque POI
- [ ] Éviter les infos qui changent (horaires, prix) dans l'audio
- [ ] Mettre les infos variables dans l'app (texte updatable)
- [ ] Processus de mise à jour annuel par ville

---

### C2. Ton qui ne résonne pas
| Aspect | Détail |
|--------|--------|
| **Description** | Le style "ami historien" tombe flat, les gens trouvent ça cringe |
| **Probabilité** | 🟡 Moyenne |
| **Impact** | 🟡 Moyen |

**Mitigation:**
- [ ] Tester avec beta users AVANT de tout produire
- [ ] Itérer sur le ton avec feedback
- [ ] Avoir 2-3 styles de narration et voir ce qui marche
- [ ] Écouter les reviews attentivement

---

### C3. Voix AI détectée et rejetée
| Aspect | Détail |
|--------|--------|
| **Description** | Les utilisateurs détectent que c'est de l'IA et trouvent ça cheap |
| **Probabilité** | 🟡 Moyenne |
| **Impact** | 🟡 Moyen |

**Mitigation:**
- [ ] Utiliser ElevenLabs qualité max
- [ ] Ajouter des imperfections naturelles (hésitations, respirations)
- [ ] Ne pas cacher que c'est AI — être transparent
- [ ] Alternative: engager des narrateurs humains si budget permet

---

### C4. Problèmes de droits (images, musique)
| Aspect | Détail |
|--------|--------|
| **Description** | Utiliser du contenu protégé sans autorisation |
| **Probabilité** | 🟢 Basse |
| **Impact** | 🔴 Élevé — Poursuites légales |

**Mitigation:**
- [ ] Photos: utiliser ses propres photos ou Creative Commons
- [ ] Musique: royalty-free ou licences claires
- [ ] Textes historiques: domaine public ou paraphraser
- [ ] Documenter les sources

---

## 🔵 Risques d'équipe

### E1. Équipe de 2 personnes = bus factor
| Aspect | Détail |
|--------|--------|
| **Description** | Si Camélia ou Pierre est indisponible, le projet s'arrête |
| **Probabilité** | 🟡 Moyenne |
| **Impact** | 🔴 Élevé |

**Mitigation:**
- [ ] Documenter TOUT (c'est ce qu'on fait!)
- [ ] Code propre et commenté
- [ ] Git avec historique clair
- [ ] Chacun connaît les grandes lignes du travail de l'autre

---

### E2. Burnout
| Aspect | Détail |
|--------|--------|
| **Description** | Projet en plus du travail régulier = épuisement |
| **Probabilité** | 🟡 Moyenne |
| **Impact** | 🟡 Moyen — Projet abandonné |

**Mitigation:**
- [ ] Sprints réalistes (pas trop ambitieux)
- [ ] Célébrer les petites victoires
- [ ] Prendre des pauses
- [ ] Objectifs clairs et atteignables

---

### E3. Désaccord père-fille sur la direction
| Aspect | Détail |
|--------|--------|
| **Description** | Visions différentes, conflits sur les décisions |
| **Probabilité** | 🟢 Basse |
| **Impact** | 🟡 Moyen |

**Mitigation:**
- [ ] Rôles clairs définis (Pierre = PO, Camélia = Tech lead)
- [ ] Documentation des décisions
- [ ] Check-ins réguliers
- [ ] Rappel: c'est un projet, pas une source de stress familial

---

## 💰 Risques financiers

### F1. Coûts qui dérapent
| Aspect | Détail |
|--------|--------|
| **Description** | Supabase, Cloudinary, ElevenLabs, App Store fees... ça s'additionne |
| **Probabilité** | 🟡 Moyenne |
| **Impact** | 🟡 Moyen |

**Estimations mensuelles:**
| Service | Coût estimé |
|---------|-------------|
| Supabase | Gratuit → 25$/mo |
| Cloudinary | Gratuit → 20$/mo |
| ElevenLabs | ~50$/mo si production active |
| Apple Developer | 129$/an |
| Google Play | 25$ one-time |

**Mitigation:**
- [ ] Suivre les coûts de près
- [ ] Utiliser les tiers gratuits au max au début
- [ ] Ne pas over-engineer avant d'avoir des users

---

### F2. Pas de revenus avant longtemps
| Aspect | Détail |
|--------|--------|
| **Description** | Investissement en temps sans retour financier pendant des mois |
| **Probabilité** | 🔴 Haute |
| **Impact** | 🟡 Moyen — Motivation en baisse |

**Mitigation:**
- [ ] Accepter que c'est un side project au début
- [ ] Définir un "kill point" — si pas de traction après X mois, pivoter ou arrêter
- [ ] Garder les coûts bas
- [ ] Premiers revenus = validation, pas richesse

---

## 📋 Registre des risques — Résumé

| ID | Risque | Prob. | Impact | Priorité | Owner |
|----|--------|-------|--------|----------|-------|
| T8 | GPS arrière-plan non fonctionnel | 🔴 | 🔴 | 🚨 CRITIQUE | Camélia |
| T1 | GPS imprécis sur POI | 🔴 | 🔴 | 🚨 CRITIQUE | Camélia |
| T7 | API Edge TTS non officielle | 🟡 | 🟡 | 🟡 MOYENNE | Camélia |
| T3 | Sync groupe désync | 🟡 | 🔴 | ⚠️ HAUTE | Camélia |
| T6 | Trop de POIs submergent l'utilisateur | 🟡 | 🟡 | 🟡 MOYENNE | Camélia |
| B1 | BaladoDécouverte gratuit | 🔴 | 🟡 | ⚠️ HAUTE | Pierre |
| B2 | Marché trop petit | 🟡 | 🔴 | ⚠️ HAUTE | Pierre |
| B3 | Saisonnalité | 🔴 | 🟡 | ⚠️ HAUTE | Pierre |
| C1 | Contenu incorrect | 🟡 | 🟡 | 🟡 MOYENNE | Pierre |
| C2 | Ton qui résonne pas | 🟡 | 🟡 | 🟡 MOYENNE | Pierre |
| E1 | Bus factor (2 pers.) | 🟡 | 🔴 | ⚠️ HAUTE | Tous |
| F2 | Pas de revenus | 🔴 | 🟡 | 🟡 MOYENNE | Tous |
| T2 | Batterie | 🟡 | 🟡 | 🟡 MOYENNE | Camélia |
| T4 | App rejetée | 🟢 | 🔴 | 🟡 MOYENNE | Camélia |
| C3 | Voix AI rejetée | 🟡 | 🟡 | 🟡 MOYENNE | Pierre |

---

## Plan d'action immédiat

### Top 3 risques à adresser en priorité:

1. **T8 - GPS arrière-plan** → Corriger la config geolocator/foreground service AVANT le test terrain (Sprint 4)
2. **T1 - GPS imprécis sur POI** → Tester le géofencing par POI à Saint-Lambert (Sprint 4)
3. **T6 - Surcharge de POIs** → Catégories, filtres, notifications intelligentes (cooldown 30 s déjà en place)

---

*Dernière mise à jour: 2026-07-03*
