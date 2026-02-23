# 📖 User Stories — App Voyage

## Format

```
En tant que [utilisateur],
je veux [action],
pour [bénéfice].
```

**Priorité:**
- 🔴 **Must** (MVP) — Sans ça, l'app ne fonctionne pas
- 🟡 **Should** (V1) — Important pour le launch public
- 🟢 **Could** (V2+) — Nice to have, futur

**Estimation:** XS (2h) | S (4h) | M (1j) | L (2-3j) | XL (1sem+)

---

## Épic 1: Découverte & Navigation 🗺️

### 🔴 US-101: Voir la carte de la ville
**Estimation:** M

> En tant que touriste,  
> je veux voir une carte interactive de la ville,  
> pour visualiser où je suis et les POIs autour de moi.

**Critères d'acceptation:**
- [ ] Carte Mapbox centrée sur ma position GPS
- [ ] POIs visibles (icônes distinctes par catégorie)
- [ ] Zoom in/out fluide (pinch + boutons)
- [ ] Bouton "recentrer sur moi"
- [ ] Fonctionne **offline** après téléchargement des données
- [ ] Rotation de la carte selon orientation (optionnel)

**Notes techniques:**
- Utiliser Mapbox GL pour le rendu
- Tiles offline à télécharger avec les données de la ville
- Markers custom selon la catégorie de POI (patrimoine, nature, infrastructure, etc.)

---

### 🔴 US-102: Voir les POIs autour de moi
**Estimation:** M

> En tant que touriste,  
> je veux voir la liste des points d'intérêt autour de moi,  
> pour savoir ce qu'il y a à découvrir.

**Critères d'acceptation:**
- [ ] Liste des POIs triés par distance (du plus proche au plus loin)
- [ ] Chaque POI affiche: nom, catégorie, distance, mini-description
- [ ] Icône de catégorie (🏛️ patrimoine, 🌊 maritime, ⛪ religieux, etc.)
- [ ] Badge "Écouté ✓" si déjà visité
- [ ] Badge "Téléchargé" si audio en cache
- [ ] Tap sur un POI → détail du POI
- [ ] Indicateur de rayon: "X POIs à moins de 500m"

**Données affichées:**
```
🏛️ Maison Marsil — Patrimoine
📍 120m | ~1750 | ⏱️ 85s audio
[Écouté ✓]

⛪ Église Saint-Lambert — Religieux  
📍 340m | 1936-1938 | ⏱️ 80s audio
[Pas encore visité]
```

---

### 🔴 US-103: Voir le détail d'un POI
**Estimation:** S

> En tant que touriste,  
> je veux voir les détails d'un point d'intérêt,  
> pour savoir ce que je vais découvrir.

**Critères d'acceptation:**
- [ ] Nom, catégorie, description complète
- [ ] Position sur la carte (mini-carte)
- [ ] Infos pratiques: adresse, année de construction, type
- [ ] **Preview audio** (15-20 sec) — GRATUIT
- [ ] Bouton "Écouter" (ou "Télécharger" si pas en cache)
- [ ] Photos du lieu
- [ ] Distance depuis ma position actuelle
- [ ] Indicateur "Déjà visité" ou "Nouveau"

---

### 🔴 US-104: Activer le mode découverte
**Estimation:** M

> En tant que touriste,  
> je veux activer le mode découverte,  
> pour que les audios se déclenchent automatiquement quand je me promène.

**Critères d'acceptation:**
- [ ] Bouton "Explorer" bien visible sur l'écran principal
- [ ] Vérifier que les données de la ville sont téléchargées (sinon proposer download)
- [ ] Vérifier permissions GPS (sinon guider vers settings)
- [ ] Activer le geofencing sur tous les POIs non-écoutés à proximité
- [ ] Transition vers mode "découverte active" (carte + mini-player)
- [ ] L'utilisateur marche librement, pas de route imposée

**Gestion d'erreurs:**
- GPS désactivé → Message clair + lien vers settings
- Données pas téléchargées → Proposer download
- Batterie faible (<20%) → Warning + suggestion power bank

---

### 🔴 US-105: Voir mes POIs visités
**Estimation:** S

> En tant que touriste,  
> je veux voir la liste des POIs que j'ai déjà écoutés,  
> pour savoir ce que j'ai découvert et ce qu'il reste.

**Critères d'acceptation:**
- [ ] Liste des POIs écoutés avec date de visite
- [ ] POIs visités en vert sur la carte, non-visités en gris
- [ ] Statistiques: "X/Y POIs découverts dans cette ville"
- [ ] Barre de progression par catégorie
- [ ] Option "Voir les POIs restants" (filtrer non-visités)

---

### 🔴 US-106: Filtrer les POIs par catégorie
**Estimation:** S

> En tant que touriste avec des intérêts spécifiques,  
> je veux filtrer les POIs par catégorie,  
> pour ne voir que ce qui m'intéresse.

**Critères d'acceptation:**
- [ ] Filtres par catégorie: patrimoine, religieux, nature, infrastructure, commercial, etc.
- [ ] Toggle multi-catégories (sélection multiple)
- [ ] La carte se met à jour en temps réel (masquer les POIs hors filtre)
- [ ] La liste se met à jour aussi
- [ ] Préférence sauvegardée entre sessions
- [ ] Compteur par catégorie ("🏛️ Patrimoine (8)")
- [ ] Bouton "Tout afficher" pour reset

---

### 🟡 US-107: Mettre en pause / Reprendre la découverte
**Estimation:** S

> En tant que touriste,  
> je veux pouvoir mettre le mode découverte en pause,  
> pour faire une pause café sans déclencher d'audios.

**Critères d'acceptation:**
- [ ] Bouton "Pause" accessible
- [ ] Désactiver temporairement le geofencing
- [ ] Notification "Découverte en pause"
- [ ] Reprendre d'un tap
- [ ] Proposition de reprendre au prochain lancement de l'app

---

## Épic 2: Audio & Contenu 🎧

### 🔴 US-201: Déclenchement audio automatique par GPS
**Estimation:** L (critique, complexe)

> En tant que touriste qui se promène,  
> je veux que l'audio se déclenche automatiquement quand j'arrive près d'un POI,  
> pour ne pas avoir à toucher mon téléphone.

**Critères d'acceptation:**
- [ ] Déclenchement basé sur géofence (rayon configurable par POI)
- [ ] Algorithme intelligent: vitesse + direction (pas juste rayon)
- [ ] Notification/vibration **avant** lecture ("Tu approches: Maison Marsil")
- [ ] Audio joue même si app en **background**
- [ ] Contrôles sur lock screen (iOS/Android)
- [ ] Ne pas re-déclencher un POI déjà écouté (sauf si explicitement demandé)
- [ ] Si plusieurs POIs proches: prioriser le plus proche
- [ ] File d'attente: ne pas interrompre un audio en cours, jouer le suivant après

**Rayon par défaut:**
| Mode | Rayon trigger |
|------|---------------|
| Piéton | 30m |
| Vélo | 60m |
| Auto | 150m |

**Notes techniques:**
- Utiliser geofencing natif (pas polling constant)
- Calculer "time to arrival" basé sur vitesse
- Déclencher ~10-15 secondes avant arrivée physique

---

### 🔴 US-202: Déclenchement audio manuel (fallback)
**Estimation:** S

> En tant que touriste dont le GPS est imprécis,  
> je veux pouvoir déclencher l'audio manuellement,  
> pour ne pas rater un point d'intérêt.

**Critères d'acceptation:**
- [ ] Bouton "Écouter" sur chaque POI
- [ ] Tap sur un POI de la carte = jouer son audio
- [ ] Liste des POIs avec bouton play individuel
- [ ] Message si trop loin: "Tu sembles loin de ce POI. Écouter quand même?"

**Important:** Ce fallback est CRITIQUE car le GPS peut être imprécis en ville (bâtiments).

---

### 🔴 US-203: Contrôler la lecture audio
**Estimation:** M

> En tant que touriste,  
> je veux pouvoir contrôler la lecture audio,  
> pour réécouter ou faire une pause.

**Critères d'acceptation:**
- [ ] Play / Pause
- [ ] Rewind 15 secondes (bouton ou swipe)
- [ ] Forward 15 secondes
- [ ] Barre de progression avec seek
- [ ] Contrôles accessibles sur lock screen
- [ ] Contrôles dans notification (Android)
- [ ] Intégration Control Center (iOS)

**UX:** Mini-player sticky en bas de l'écran pendant la découverte.

---

### 🔴 US-204: Télécharger les POIs d'une ville (offline)
**Estimation:** M

> En tant que touriste sans data mobile,  
> je veux télécharger tous les POIs d'une ville avant ma visite,  
> pour ne pas dépendre du réseau.

**Critères d'acceptation:**
- [ ] Bouton "Télécharger [ville]" clair
- [ ] Afficher taille du download (~20-50 MB)
- [ ] Barre de progression pendant download
- [ ] Download en background (peut quitter l'écran)
- [ ] Notification quand terminé
- [ ] Télécharge: audio MP3 + données JSON + tiles carte
- [ ] Fonctionne **100% offline** après
- [ ] Option "Télécharger sur Wi-Fi uniquement"

**Gestion d'erreurs:**
- Pas de connexion → Message clair
- Download interrompu → Reprendre où c'était
- Pas assez d'espace → Message avec taille requise

---

### 🟡 US-205: Choisir la langue de l'audio
**Estimation:** S

> En tant que touriste anglophone,  
> je veux choisir la langue de l'audio,  
> pour comprendre le contenu.

**Critères d'acceptation:**
- [ ] Sélecteur FR / EN dans les settings
- [ ] Sélecteur au moment du téléchargement
- [ ] Audios disponibles dans les deux langues
- [ ] Préférence sauvegardée
- [ ] Possibilité de télécharger plusieurs langues

---

### 🟡 US-206: Ajuster la vitesse de lecture
**Estimation:** XS

> En tant que touriste pressé,  
> je veux ajuster la vitesse de lecture,  
> pour écouter plus vite ou plus lentement.

**Critères d'acceptation:**
- [ ] Options: 0.75x, 1x, 1.25x, 1.5x
- [ ] Préférence sauvegardée
- [ ] Accessible pendant la lecture

---

### 🟢 US-207: Transcription texte de l'audio
**Estimation:** S

> En tant que personne malentendante,  
> je veux voir la transcription de l'audio,  
> pour suivre le contenu.

**Critères d'acceptation:**
- [ ] Bouton "Voir texte" sur chaque POI
- [ ] Texte synchronisé avec l'audio (karaoké style)
- [ ] Accessible même sans jouer l'audio

---

## Épic 3: Sync Multi-Appareils 👥

> **Note:** C'est notre KILLER FEATURE. Detour l'avait, personne d'autre ne l'a.

### 🟡 US-301: Créer une session de groupe (Host)
**Estimation:** L

> En tant que guide de mon groupe,  
> je veux créer une session partagée,  
> pour que mes amis/famille écoutent la même chose.

**Critères d'acceptation:**
- [ ] Bouton "Écouter ensemble" bien visible
- [ ] Génération d'un code à 6 chiffres (ou QR code)
- [ ] Voir qui a rejoint (liste des noms/appareils)
- [ ] Notification quand quelqu'un rejoint
- [ ] Max 10 appareils par session (limite technique)
- [ ] Host peut "kick" quelqu'un

**UX Flow:**
1. Host appuie "Écouter ensemble"
2. Code affiché: "ABC-123"
3. Partage via Messages, WhatsApp, ou montrer l'écran
4. Voir "Marie a rejoint", "Thomas a rejoint"
5. Host appuie "Commencer"

---

### 🟡 US-302: Rejoindre une session (Membre)
**Estimation:** M

> En tant que membre d'un groupe,  
> je veux rejoindre la session du host,  
> pour écouter le même audio en sync.

**Critères d'acceptation:**
- [ ] Bouton "Rejoindre une session"
- [ ] Entrer code 6 chiffres OU scanner QR
- [ ] Confirmation "Vous avez rejoint la session de Pierre"
- [ ] Audio sync automatique avec le host
- [ ] Indicateur "Connecté au groupe"
- [ ] Déconnexion automatique si host termine

---

### 🟡 US-303: Synchronisation de la lecture
**Estimation:** L

> En tant que membre d'un groupe,  
> je veux que l'audio soit synchronisé avec celui du host,  
> pour qu'on vive la même expérience ensemble.

**Critères d'acceptation:**
- [ ] Host play/pause → tout le monde play/pause
- [ ] Sync à la **seconde** (pas milliseconde nécessaire)
- [ ] Si connexion perdue → continuer indépendamment
- [ ] Rejoindre en cours → sync au timestamp actuel
- [ ] Indicateur visuel de sync (icône "groupe")

**Notes techniques:**
- Utiliser Supabase Realtime (WebSockets)
- Host envoie: `{action: "play", poi_id: "xxx", timestamp: 45.2}`
- Membres ajustent leur position
- Heartbeat toutes les 5 sec pour re-sync

---

### 🟡 US-304: Transférer le contrôle Host
**Estimation:** S

> En tant que host fatigué,  
> je veux passer le contrôle à quelqu'un d'autre,  
> pour que quelqu'un d'autre guide le groupe.

**Critères d'acceptation:**
- [ ] Option "Passer le contrôle" dans le menu
- [ ] Sélectionner un membre de la liste
- [ ] Confirmation du nouveau host
- [ ] Notification à tous "Marie est maintenant le guide"

---

### 🟢 US-305: Mode "Chacun son rythme"
**Estimation:** M

> En tant que groupe avec des marcheurs à différentes vitesses,  
> je veux un mode où chacun avance à son rythme,  
> mais où on peut voir où sont les autres.

**Critères d'acceptation:**
- [ ] Voir la position des autres membres sur la carte
- [ ] Chacun déclenche ses propres audios par proximité
- [ ] Indicateur "Marie écoute: Maison Marsil"
- [ ] Option de re-sync si on veut

---

## Épic 4: Modes de Transport 🚶🚴🚗

### 🔴 US-401: Sélectionner le mode de transport
**Estimation:** S

> En tant que touriste,  
> je veux indiquer si je suis à pied, à vélo ou en auto,  
> pour que le rayon de déclenchement soit adapté.

**Critères d'acceptation:**
- [ ] Sélecteur au lancement du mode découverte
- [ ] Icônes claires: 🚶 🚴 🚗
- [ ] Préférence sauvegardée
- [ ] Possibilité de changer en cours de route
- [ ] Ajuste le rayon de trigger automatiquement

---

### 🔴 US-402: Mode piéton (défaut)
**Estimation:** M

> En tant que piéton,  
> je veux une expérience optimisée pour la marche,  
> pour profiter des détails à chaque arrêt.

**Critères d'acceptation:**
- [ ] Trigger radius: 25-35m
- [ ] Audio peut être long (~90 sec)
- [ ] Notifications discrètes mais claires
- [ ] Priorité au POI le plus proche si plusieurs dans le rayon

---

### 🟡 US-403: Mode vélo
**Estimation:** M

> En tant que cycliste,  
> je veux une expérience adaptée au vélo,  
> pour écouter sans m'arrêter tout le temps.

**Critères d'acceptation:**
- [ ] Trigger radius: 50-75m
- [ ] Notifications anticipées (déclencher plus tôt)
- [ ] Option: alertes sonores "POI à gauche dans 100m"

---

### 🟢 US-404: Mode auto
**Estimation:** L

> En tant que passager en voiture,  
> je veux découvrir les POIs le long de ma route,  
> pour enrichir mon trajet.

**Critères d'acceptation:**
- [ ] Trigger radius: 100-200m
- [ ] Narration adaptée (pas de "arrête-toi ici")
- [ ] Détection auto si vitesse >30km/h
- [ ] Compatible CarPlay / Android Auto

---

### 🟢 US-405: Détection automatique du mode
**Estimation:** M

> En tant que touriste qui alterne marche et vélo,  
> je veux que l'app détecte automatiquement mon mode,  
> pour ne pas avoir à changer manuellement.

**Critères d'acceptation:**
- [ ] Analyse de la vitesse moyenne
- [ ] <7 km/h = piéton
- [ ] 7-25 km/h = vélo
- [ ] >25 km/h = auto
- [ ] Notification "On dirait que tu es passé en vélo"
- [ ] Option de désactiver l'auto-détection

---

## Épic 5: Compte & Paiements 💳

### 🟡 US-501: Utiliser l'app sans compte
**Estimation:** S

> En tant que touriste pressé,  
> je veux pouvoir découvrir les POIs gratuits sans créer de compte,  
> pour commencer immédiatement.

**Critères d'acceptation:**
- [ ] POIs gratuits accessibles sans login
- [ ] Données stockées localement
- [ ] Prompt "Créer un compte" pour sauvegarder progression
- [ ] Compte requis seulement pour achats

---

### 🟡 US-502: Créer un compte
**Estimation:** M

> En tant que touriste qui veut accéder à tout,  
> je veux créer un compte facilement,  
> pour accéder au contenu premium.

**Critères d'acceptation:**
- [ ] Sign up avec email/mot de passe
- [ ] OU connexion Apple (iOS)
- [ ] OU connexion Google
- [ ] Vérification email (optionnel au début)
- [ ] Récupération de mot de passe
- [ ] Migration des données locales vers le compte

---

### 🟡 US-503: Acheter un pack ville
**Estimation:** L

> En tant que touriste,  
> je veux acheter l'accès complet à tous les POIs d'une ville,  
> pour débloquer tout le contenu.

**Critères d'acceptation:**
- [ ] Prix affiché clairement (ex: 14.99$ CAD pour Montréal)
- [ ] Paiement via Apple Pay / Google Pay
- [ ] In-App Purchase (requis par les stores)
- [ ] Confirmation d'achat
- [ ] Tous les POIs de la ville débloqués immédiatement
- [ ] Restauration des achats si réinstallation
- [ ] Reçu par email

---

### 🟢 US-504: Acheter un tour curaté (V2)
**Estimation:** M

> En tant que touriste qui veut une expérience guidée,  
> je veux acheter un tour thématique,  
> pour avoir un parcours curé avec transitions narratives.

**Critères d'acceptation:**
- [ ] Tour = collection ordonnée de POIs avec narration de liaison
- [ ] Prix: 7.99$ CAD par tour
- [ ] Preview du tour (POIs inclus, durée, thème)
- [ ] Inclus si pack ville acheté
- [ ] Même flow de paiement

---

### 🟢 US-505: Historique d'achats
**Estimation:** S

> En tant qu'utilisateur,  
> je veux voir mes achats passés,  
> pour savoir ce que j'ai déjà.

**Critères d'acceptation:**
- [ ] Liste des villes / tours achetés
- [ ] Date d'achat
- [ ] Bouton "Restaurer achats"

---

## Épic 6: Contenu — POIs par Ville 🎭

> **Approche POI-first:** On collecte des POIs individuels par ville. Chaque POI est autonome avec son propre script audio. Les tours curatés viennent en V2.

### 🔴 US-601: POIs Saint-Lambert (bac à sable) 🧪
**Estimation:** L (contenu)

> Première ville pour valider la techno (bac à sable GPS/geofencing).

**Specs:**
| Aspect | Valeur |
|--------|--------|
| POIs | 15-20 (couvrir toute la ville) |
| Catégories | Patrimoine, religieux, nature, infrastructure, commercial |
| Langues | FR (EN en V1) |
| Audio total | ~15-20 min |
| Objectif | Valider le geofencing, pas monétiser |

**POIs identifiés:**
- Église Saint-Lambert (patrimoine, religieux)
- Église anglicane Saint-Barnabas (patrimoine, religieux)
- Parc du Village (nature, histoire)
- Maison Marsil (patrimoine)
- Vue sur le Pont Victoria (histoire, infrastructure)
- Écluse de Saint-Lambert (infrastructure, maritime)
- Avenue Victoria (histoire, commercial)
- King Cottages (patrimoine, architecture)
- Maison Sharpe (patrimoine)
- Passerelle cyclable (infrastructure, nature)
- + autres à identifier lors de la validation terrain

---

### 🟡 US-602: POIs Montréal — Vieux-Montréal
**Estimation:** XL (contenu)

> Premier secteur de Montréal — le plus touristique.

**Specs:**
| Aspect | Valeur |
|--------|--------|
| POIs | 20-30 |
| Catégories | Patrimoine, religieux, gastronomie, art, histoire |
| Langues | FR, EN |
| Persona | "Jacques" (historien chaleureux) |
| Prix | Teaser gratuit (5 POIs), reste payant |

**POIs suggérés:**
- Place Jacques-Cartier
- Hôtel de Ville
- Château Ramezay
- Place d'Armes
- Basilique Notre-Dame
- Vieux Séminaire
- Place Royale
- Pointe-à-Callière
- Place d'Youville
- Marché Bonsecours
- Chapelle Notre-Dame-de-Bon-Secours
- Rue Saint-Paul
- + cafés, spots photo, toilettes (POIs pratiques)

**Contenu logistique à inclure:**
- Toilettes: Centre de commerce, Marché Bonsecours
- Parking: Champ-de-Mars, Vieux-Port
- Cafés: Crew Café, Olive et Gourmando
- Photo spots: Vue sur basilique depuis Place d'Armes

---

### 🟡 US-603: POIs Montréal — Plateau Mont-Royal
**Estimation:** XL (contenu)

> Découverte culinaire et culturelle du Plateau.

**Specs:**
| Aspect | Valeur |
|--------|--------|
| POIs | 15-20 |
| Catégories | Gastronomie, art, culture, patrimoine |
| Persona | "Sarah" (étudiante foodie) |
| Ton | Énergique, recommendations perso |

**Inclure:**
- Bagels: Fairmount vs St-Viateur
- Marchés: Jean-Talon
- Murales / street art
- Spots brunch emblématiques
- Bars à vin, terrasses

---

### 🟢 US-604: POIs Montréal — Mile-End Street Art 🎨
**Estimation:** XL (contenu)

> Art urbain et culture alternative.

---

### 🟢 US-605: POIs Montréal — Souterrain / RÉSO 🚇
**Estimation:** XL (contenu)

> Le RÉSO, architecture, histoire.

---

### 🟢 US-606: POIs Montréal — Légendes & Mystères 👻 (V2 tour)
**Estimation:** XL (contenu)

> Version mystère/légendes — idéal comme tour curaté V2.

**Thèmes:**
- Fantômes du Château Ramezay
- La Dame Blanche
- Crimes de la Place d'Armes
- Passages secrets
- Cimetières oubliés

---

## Épic 7: Optimisation & Performance ⚡

### 🔴 US-701: Optimisation batterie
**Estimation:** M

> En tant que touriste,  
> je veux que l'app ne vide pas ma batterie,  
> pour pouvoir explorer toute la journée.

**Critères d'acceptation:**
- [ ] GPS polling optimisé (geofencing natif, pas polling constant)
- [ ] Mode économie si batterie <20%
- [ ] Estimation "Batterie suffisante pour X heures de découverte"
- [ ] Warning si batterie trop basse
- [ ] Max 15% de batterie par heure d'utilisation

---

### 🟡 US-702: Afficher l'estimation batterie
**Estimation:** S

> En tant que touriste,  
> je veux savoir combien de temps je peux explorer avec ma batterie restante,  
> pour planifier ma promenade.

**Critères d'acceptation:**
- [ ] Indicateur au lancement: "✓ Batterie suffisante (~3h de découverte)" ou "⚠️ Batterie faible"
- [ ] Estimation basée sur: consommation moyenne × batterie restante

---

### 🟡 US-703: Mode économie d'énergie
**Estimation:** M

> En tant que touriste avec batterie faible,  
> je veux un mode économie,  
> pour continuer ma découverte quand même.

**Critères d'acceptation:**
- [ ] Activation auto si batterie <20%
- [ ] Réduire fréquence GPS
- [ ] Désactiver animations
- [ ] Écran plus sombre
- [ ] Notification "Mode économie activé"

---

## Épic 8: Feedback & Amélioration 📝

### 🟡 US-801: Noter un POI
**Estimation:** S

> En tant que touriste qui a écouté un POI,  
> je veux noter ce point d'intérêt,  
> pour aider les futurs utilisateurs.

**Critères d'acceptation:**
- [ ] Prompt après l'écoute d'un POI
- [ ] Note 1-5 étoiles
- [ ] Commentaire optionnel
- [ ] "Pas maintenant" possible

---

### 🟡 US-802: Signaler un problème
**Estimation:** S

> En tant que touriste,  
> je veux signaler un problème sur un POI,  
> pour aider à améliorer l'app.

**Critères d'acceptation:**
- [ ] Bouton "Signaler" sur chaque POI
- [ ] Types: GPS imprécis, Info incorrecte, Audio problème, Autre
- [ ] Envoi avec contexte (position, POI concerné)
- [ ] Confirmation "Merci pour votre feedback"

---

### 🟢 US-803: Suggérer un nouveau POI
**Estimation:** XS

> En tant que local,  
> je veux suggérer un point d'intérêt,  
> pour enrichir le contenu de ma ville.

**Critères d'acceptation:**
- [ ] Formulaire simple
- [ ] Ville, catégorie, nom, description
- [ ] Position GPS (auto depuis localisation)
- [ ] Email de contact

---

## Épic 9: Onboarding & Settings ⚙️

### 🔴 US-901: Onboarding premier lancement
**Estimation:** M

> En tant que nouvel utilisateur,  
> je veux comprendre comment fonctionne l'app,  
> pour bien l'utiliser.

**Critères d'acceptation:**
- [ ] 3-4 écrans max
- [ ] Expliquer: déclenchement auto par GPS, mode découverte, offline
- [ ] Demander permission GPS
- [ ] Demander permission notifications
- [ ] Skip possible
- [ ] Ne pas montrer si déjà vu

---

### 🔴 US-902: Demande de permissions
**Estimation:** S

> En tant qu'utilisateur,  
> je veux comprendre pourquoi l'app a besoin de ma position,  
> pour accepter en confiance.

**Critères d'acceptation:**
- [ ] Explication AVANT la popup système
- [ ] "Pour déclencher l'audio automatiquement quand tu t'approches d'un POI"
- [ ] Bouton "Autoriser" → popup système
- [ ] Gestion du refus avec explication

---

### 🟡 US-903: Page settings
**Estimation:** M

> En tant qu'utilisateur,  
> je veux accéder aux paramètres,  
> pour personnaliser mon expérience.

**Critères d'acceptation:**
- [ ] Langue (app)
- [ ] Langue audio par défaut
- [ ] Mode transport par défaut
- [ ] Catégories de POIs favorites (pré-filtre)
- [ ] Notifications on/off
- [ ] Téléchargement Wi-Fi uniquement
- [ ] Mode économie batterie
- [ ] Compte (connexion/déconnexion)
- [ ] Gérer stockage (supprimer données de villes)
- [ ] À propos / Version
- [ ] Politique de confidentialité
- [ ] Support / Contact

---

## 🟢 Épic 10: Tours Curatés (V2) 🎭

> **Reporté en V2.** Les tours deviennent des collections thématiques de POIs avec un ordre suggéré et des transitions narratives. Les POIs restent standalone — les tours ajoutent une couche d'expérience guidée par-dessus.

### 🟢 US-1001: Voir les tours disponibles
**Estimation:** M

> En tant que touriste qui veut une expérience guidée,  
> je veux voir les tours thématiques disponibles,  
> pour choisir celui qui m'intéresse.

**Critères d'acceptation:**
- [ ] Liste avec: nom, thème, durée, distance, nombre de POIs
- [ ] Image de couverture attractive
- [ ] Badge "Gratuit" ou prix affiché
- [ ] Preview du tracé sur mini-carte
- [ ] Filtres: par thème, durée, mode transport

---

### 🟢 US-1002: Suivre un tour guidé
**Estimation:** M

> En tant que touriste,  
> je veux suivre un tour guidé étape par étape,  
> pour avoir une narration continue et un parcours optimisé.

**Critères d'acceptation:**
- [ ] Afficher le tracé du tour sur la carte
- [ ] Navigation vers le prochain POI
- [ ] Transitions narratives entre les POIs
- [ ] Barre de progression (X/Y POIs du tour)
- [ ] Option "Voir en mode libre" (désactiver le guidage)
- [ ] Intro et conclusion du tour (narration dédiée)

---

### 🟢 US-1003: Voir la progression d'un tour
**Estimation:** S

> En tant que touriste en tour,  
> je veux voir ma progression,  
> pour savoir combien il me reste.

**Critères d'acceptation:**
- [ ] Barre de progression visuelle (X/Y POIs)
- [ ] Temps estimé restant
- [ ] Distance restante
- [ ] Prochain POI avec distance

---

## Résumé par priorité

### 🔴 MVP (Must Have) — 16 stories
| ID | Story | Estimation |
|----|-------|------------|
| US-101 | Carte de la ville | M |
| US-102 | POIs autour de moi | M |
| US-103 | Détail d'un POI | S |
| US-104 | Mode découverte | M |
| US-105 | POIs visités | S |
| US-106 | Filtrer par catégorie | S |
| US-201 | Trigger audio GPS auto | L |
| US-202 | Trigger audio manuel | S |
| US-203 | Contrôles audio | M |
| US-204 | Téléchargement offline | M |
| US-401 | Sélection mode transport | S |
| US-402 | Mode piéton | M |
| US-601 | POIs Saint-Lambert (test) | L |
| US-701 | Optimisation batterie | M |
| US-901 | Onboarding | M |
| US-902 | Permissions | S |

### 🟡 V1 (Should Have) — 18 stories
Sync groupe, paiements pack ville, POIs Montréal, mode vélo, etc.

### 🟢 V2+ (Could Have) — 12 stories
Mode auto, détection auto, tours curatés, suggestions POIs, etc.

---

*Dernière mise à jour: 2026-02-23*
