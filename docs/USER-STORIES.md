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
> pour visualiser où je suis et ce qu'il y a autour.

**Critères d'acceptation:**
- [ ] Carte Mapbox centrée sur ma position GPS
- [ ] Points d'intérêt visibles (icônes distinctes par type)
- [ ] Zoom in/out fluide (pinch + boutons)
- [ ] Bouton "recentrer sur moi"
- [ ] Fonctionne **offline** après téléchargement du parcours
- [ ] Rotation de la carte selon orientation (optionnel)

**Notes techniques:**
- Utiliser Mapbox GL pour le rendu
- Tiles offline à télécharger avec le parcours
- Markers custom selon le type de POI

---

### 🔴 US-102: Voir les parcours disponibles
**Estimation:** M

> En tant que touriste,  
> je veux voir la liste des parcours disponibles,  
> pour choisir celui qui m'intéresse.

**Critères d'acceptation:**
- [ ] Liste avec: nom, durée, distance, thème, difficulté
- [ ] Image de couverture attractive
- [ ] Badge "Gratuit" ou prix affiché
- [ ] Badge "Téléchargé" si déjà en cache
- [ ] Preview du tracé sur mini-carte
- [ ] Filtres: par thème, durée, mode transport
- [ ] Note moyenne (quand on aura des reviews)

**Données affichées:**
```
🏛️ Vieux-Montréal Hanté
⏱️ 45 min | 📍 2.3 km | 👻 Mystère
⭐ 4.8 (124 avis)
[Téléchargé ✓]          [7.99$ CAD]
```

---

### 🔴 US-103: Voir le détail d'un parcours
**Estimation:** S

> En tant que touriste,  
> je veux voir les détails d'un parcours avant de le commencer,  
> pour savoir si ça m'intéresse.

**Critères d'acceptation:**
- [ ] Description complète du parcours
- [ ] Liste des points d'intérêt (avec preview)
- [ ] Carte du tracé complet
- [ ] Infos pratiques: durée, distance, dénivelé
- [ ] Mode(s) de transport recommandé(s)
- [ ] **Preview audio** (30 sec du premier point) — GRATUIT
- [ ] Bouton "Télécharger" ou "Acheter"
- [ ] Reviews utilisateurs (V1)

---

### 🔴 US-104: Démarrer un parcours
**Estimation:** M

> En tant que touriste,  
> je veux démarrer un parcours,  
> pour commencer ma visite guidée.

**Critères d'acceptation:**
- [ ] Bouton "Démarrer" bien visible
- [ ] Vérifier que le parcours est téléchargé (sinon proposer download)
- [ ] Vérifier permissions GPS (sinon guider vers settings)
- [ ] Afficher instruction pour rejoindre le point de départ
- [ ] Transition vers mode "visite active"
- [ ] Option "Démarrer au point le plus proche" (si pas au début)

**Gestion d'erreurs:**
- GPS désactivé → Message clair + lien vers settings
- Parcours pas téléchargé → Proposer download
- Batterie faible (<20%) → Warning + suggestion power bank

---

### 🔴 US-105: Voir ma progression
**Estimation:** S

> En tant que touriste en visite,  
> je veux voir ma progression dans le parcours,  
> pour savoir combien il me reste.

**Critères d'acceptation:**
- [ ] Barre de progression visuelle (X/Y points)
- [ ] Points visités en vert, à venir en gris sur la carte
- [ ] Temps estimé restant
- [ ] Distance restante
- [ ] Prochain point d'intérêt avec distance
- [ ] Option "Voir tous les points" (liste)

---

### 🟡 US-106: Mettre en pause / Reprendre
**Estimation:** S

> En tant que touriste,  
> je veux pouvoir mettre mon parcours en pause,  
> pour faire une pause café sans perdre ma progression.

**Critères d'acceptation:**
- [ ] Bouton "Pause" accessible
- [ ] Sauvegarder la progression (point actuel)
- [ ] Notification "Parcours en pause"
- [ ] Reprendre exactement où j'étais
- [ ] Proposition de reprendre au prochain lancement de l'app

---

### 🟡 US-107: Quitter un parcours
**Estimation:** XS

> En tant que touriste,  
> je veux pouvoir quitter un parcours en cours,  
> pour arrêter ma visite.

**Critères d'acceptation:**
- [ ] Bouton "Quitter" (avec confirmation)
- [ ] Sauvegarder progression pour reprendre plus tard
- [ ] Retour à l'écran d'accueil
- [ ] Option "Ne plus demander de confirmation"

---

## Épic 2: Audio & Contenu 🎧

### 🔴 US-201: Déclenchement audio automatique par GPS
**Estimation:** L (critique, complexe)

> En tant que touriste qui marche,  
> je veux que l'audio se déclenche automatiquement quand j'arrive près d'un point,  
> pour ne pas avoir à toucher mon téléphone.

**Critères d'acceptation:**
- [ ] Déclenchement basé sur géofence (rayon configurable)
- [ ] Algorithme intelligent: vitesse + direction (pas juste rayon)
- [ ] Notification/vibration **avant** lecture ("Prochain point dans 20m")
- [ ] Audio joue même si app en **background**
- [ ] Contrôles sur lock screen (iOS/Android)
- [ ] Ne pas re-déclencher si déjà écouté
- [ ] Priorité: ne pas interrompre un audio en cours

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
- [ ] Bouton "Je suis arrivé" sur chaque point
- [ ] Tap sur un point de la carte = jouer son audio
- [ ] Liste des points avec bouton play individuel
- [ ] Message si trop loin: "Tu sembles loin de ce point. Jouer quand même?"

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
- [ ] Skip au prochain point
- [ ] Barre de progression avec seek
- [ ] Contrôles accessibles sur lock screen
- [ ] Contrôles dans notification (Android)
- [ ] Intégration Control Center (iOS)

**UX:** Mini-player sticky en bas de l'écran pendant la visite.

---

### 🔴 US-204: Télécharger un parcours offline
**Estimation:** M

> En tant que touriste sans data mobile,  
> je veux télécharger un parcours avant ma visite,  
> pour ne pas dépendre du réseau.

**Critères d'acceptation:**
- [ ] Bouton "Télécharger" clair
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
- [ ] Bouton "Voir texte" sur chaque point
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
- Host envoie: `{action: "play", track_id: "xxx", timestamp: 45.2}`
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
- [ ] Chacun déclenche ses propres audios
- [ ] Indicateur "Marie écoute: Place Jacques-Cartier"
- [ ] Option de re-sync si on veut

---

## Épic 4: Modes de Transport 🚶🚴🚗

### 🔴 US-401: Sélectionner le mode de transport
**Estimation:** S

> En tant que touriste,  
> je veux indiquer si je suis à pied, à vélo ou en auto,  
> pour que l'expérience soit adaptée.

**Critères d'acceptation:**
- [ ] Sélecteur au démarrage du parcours
- [ ] Icônes claires: 🚶 🚴 🚗
- [ ] Préférence sauvegardée
- [ ] Possibilité de changer en cours de route
- [ ] Certains parcours = mode unique (ex: "Road trip Sainte-Julie" = auto only)

---

### 🔴 US-402: Mode piéton (défaut)
**Estimation:** M

> En tant que piéton,  
> je veux une expérience optimisée pour la marche,  
> pour profiter des détails à chaque arrêt.

**Critères d'acceptation:**
- [ ] Trigger radius: 25-35m
- [ ] Suggestions "Arrête-toi ici pour mieux voir"
- [ ] Directions: "Tourne à droite après l'église"
- [ ] Points rapprochés (50-200m entre chaque)
- [ ] Audio peut être long (~90 sec)

---

### 🟡 US-403: Mode vélo
**Estimation:** M

> En tant que cycliste,  
> je veux une expérience adaptée au vélo,  
> pour écouter sans m'arrêter tout le temps.

**Critères d'acceptation:**
- [ ] Trigger radius: 50-75m
- [ ] Narration plus courte (~60 sec max)
- [ ] Pas de "arrête-toi ici"
- [ ] Points plus espacés (200-500m)
- [ ] Option: alertes sonores "Point à gauche dans 100m"

---

### 🟢 US-404: Mode auto
**Estimation:** L

> En tant que passager en voiture,  
> je veux une narration continue style road trip,  
> pour découvrir les quartiers qu'on traverse.

**Critères d'acceptation:**
- [ ] Trigger radius: 100-200m
- [ ] Narration fluide (pas de pauses longues)
- [ ] Transitions entre les zones
- [ ] Contenu adapté: quartiers plutôt que bâtiments
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
> je veux pouvoir utiliser les parcours gratuits sans créer de compte,  
> pour commencer immédiatement.

**Critères d'acceptation:**
- [ ] Parcours gratuits accessibles sans login
- [ ] Données stockées localement
- [ ] Prompt "Créer un compte" pour sauvegarder progression
- [ ] Compte requis seulement pour achats

---

### 🟡 US-502: Créer un compte
**Estimation:** M

> En tant que touriste qui veut acheter,  
> je veux créer un compte facilement,  
> pour accéder aux parcours premium.

**Critères d'acceptation:**
- [ ] Sign up avec email/mot de passe
- [ ] OU connexion Apple (iOS)
- [ ] OU connexion Google
- [ ] Vérification email (optionnel au début)
- [ ] Récupération de mot de passe
- [ ] Migration des données locales vers le compte

---

### 🟡 US-503: Acheter un parcours
**Estimation:** L

> En tant que touriste,  
> je veux acheter un parcours premium,  
> pour accéder au contenu complet.

**Critères d'acceptation:**
- [ ] Prix affiché clairement (7.99$ CAD)
- [ ] Paiement via Apple Pay / Google Pay
- [ ] In-App Purchase (requis par les stores)
- [ ] Confirmation d'achat
- [ ] Parcours débloqué immédiatement
- [ ] Restauration des achats si réinstallation
- [ ] Reçu par email

---

### 🟡 US-504: Acheter un pack ville
**Estimation:** M

> En tant que touriste qui reste plusieurs jours,  
> je veux acheter tous les parcours d'une ville,  
> pour avoir un rabais.

**Critères d'acceptation:**
- [ ] Bundle "Tout Montréal" visible
- [ ] Économie affichée ("Économisez 40%!")
- [ ] Prix: 14.99$ CAD
- [ ] Unlock tous les parcours actuels ET futurs de la ville
- [ ] Même flow de paiement

---

### 🟢 US-505: Historique d'achats
**Estimation:** S

> En tant qu'utilisateur,  
> je veux voir mes achats passés,  
> pour savoir ce que j'ai déjà.

**Critères d'acceptation:**
- [ ] Liste des parcours achetés
- [ ] Date d'achat
- [ ] Bouton "Restaurer achats"

---

## Épic 6: Contenu — Parcours Spécifiques 🎭

### 🔴 US-601: Parcours "Vieux-Montréal Classique"
**Estimation:** XL (contenu)

> Premier parcours pour le MVP — Le incontournable.

**Specs:**
| Aspect | Valeur |
|--------|--------|
| Points | 12-15 |
| Durée | ~50 min |
| Distance | ~2.5 km |
| Mode | Piéton |
| Langues | FR, EN |
| Persona | "Jacques" (historien chaleureux) |
| Prix | Teaser gratuit (5 pts), complet 7.99$ |

**Points d'intérêt suggérés:**
1. Place Jacques-Cartier (départ)
2. Hôtel de Ville
3. Château Ramezay
4. Place d'Armes
5. Basilique Notre-Dame
6. Vieux Séminaire
7. Place Royale
8. Pointe-à-Callière
9. Place d'Youville
10. Marché Bonsecours
11. Chapelle Notre-Dame-de-Bon-Secours
12. Rue Saint-Paul (fin)

**Contenu logistique à inclure:**
- Toilettes: Centre de commerce, Marché Bonsecours
- Parking: Champ-de-Mars, Vieux-Port
- Cafés: Crew Café, Olive et Gourmando
- Photo spots: Vue sur basilique depuis Place d'Armes

---

### 🟡 US-602: Parcours "Vieux-Montréal Hanté" 👻
**Estimation:** XL (contenu)

> Version mystère/légendes du Vieux-Montréal.

**Specs:**
| Aspect | Valeur |
|--------|--------|
| Points | 10 |
| Durée | ~40 min |
| Mode | Piéton (soir recommandé) |
| Persona | Narrateur mystérieux |
| Ton | Suspense, légendes, crimes historiques |

**Thèmes:**
- Fantômes du Château Ramezay
- La Dame Blanche
- Crimes de la Place d'Armes
- Passages secrets
- Cimetières oubliés

---

### 🟡 US-603: Parcours "Plateau des Foodies" 🍕
**Estimation:** XL (contenu)

> Découverte culinaire du Plateau Mont-Royal.

**Specs:**
| Aspect | Valeur |
|--------|--------|
| Points | 10-12 |
| Durée | ~45 min |
| Mode | Piéton |
| Persona | "Sarah" (étudiante foodie) |
| Ton | Énergique, recommendations perso |

**Inclure:**
- Histoire des restos iconiques
- Bagels: Fairmount vs St-Viateur
- Marchés: Jean-Talon
- Spots brunch
- Bars à vin

---

### 🔴 US-604: Parcours "Sainte-Julie Découverte" 🧪
**Estimation:** L (contenu)

> Parcours test pour valider la techno (bac à sable).

**Specs:**
| Aspect | Valeur |
|--------|--------|
| Points | 8-10 |
| Durée | ~30 min |
| Mode | Auto + Piéton |
| Objectif | Valider géofencing, pas monétiser |

---

### 🟢 US-605: Parcours "Mile-End Street Art" 🎨
**Estimation:** XL (contenu)

> Art urbain et culture alternative.

---

### 🟢 US-606: Parcours "Montréal Souterrain" 🚇
**Estimation:** XL (contenu)

> Le RÉSO, architecture, histoire.

---

## Épic 7: Optimisation & Performance ⚡

### 🔴 US-701: Optimisation batterie
**Estimation:** M

> En tant que touriste,  
> je veux que l'app ne vide pas ma batterie,  
> pour pouvoir faire tout le parcours.

**Critères d'acceptation:**
- [ ] GPS polling optimisé (pas chaque seconde)
- [ ] Mode économie si batterie <20%
- [ ] Estimation "Batterie suffisante pour ce parcours"
- [ ] Warning si batterie trop basse pour terminer
- [ ] Max 15% de batterie par heure d'utilisation

---

### 🟡 US-702: Afficher l'estimation batterie
**Estimation:** S

> En tant que touriste,  
> je veux savoir si j'ai assez de batterie pour le parcours,  
> pour éviter de tomber en panne.

**Critères d'acceptation:**
- [ ] Indicateur au démarrage: "✓ Batterie suffisante" ou "⚠️ Batterie faible"
- [ ] Estimation basée sur: durée parcours × consommation moyenne

---

### 🟡 US-703: Mode économie d'énergie
**Estimation:** M

> En tant que touriste avec batterie faible,  
> je veux un mode économie,  
> pour finir mon parcours quand même.

**Critères d'acceptation:**
- [ ] Activation auto si batterie <20%
- [ ] Réduire fréquence GPS
- [ ] Désactiver animations
- [ ] Écran plus sombre
- [ ] Notification "Mode économie activé"

---

## Épic 8: Feedback & Amélioration 📝

### 🟡 US-801: Noter un parcours
**Estimation:** S

> En tant que touriste qui a terminé,  
> je veux noter le parcours,  
> pour aider les futurs utilisateurs.

**Critères d'acceptation:**
- [ ] Prompt à la fin du parcours
- [ ] Note 1-5 étoiles
- [ ] Commentaire optionnel
- [ ] "Pas maintenant" possible

---

### 🟡 US-802: Signaler un problème
**Estimation:** S

> En tant que touriste,  
> je veux signaler un problème,  
> pour aider à améliorer l'app.

**Critères d'acceptation:**
- [ ] Bouton "Signaler" sur chaque point
- [ ] Types: GPS imprécis, Info incorrecte, Audio problème, Autre
- [ ] Envoi avec contexte (position, parcours, point)
- [ ] Confirmation "Merci pour votre feedback"

---

### 🟢 US-803: Suggérer un nouveau parcours
**Estimation:** XS

> En tant que local,  
> je veux suggérer une idée de parcours,  
> pour enrichir le contenu.

**Critères d'acceptation:**
- [ ] Formulaire simple
- [ ] Ville, thème, description
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
- [ ] Expliquer: GPS auto, offline, sync groupe
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
- [ ] "Pour déclencher l'audio automatiquement, on a besoin de ta position"
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
- [ ] Notifications on/off
- [ ] Téléchargement Wi-Fi uniquement
- [ ] Mode économie batterie
- [ ] Compte (connexion/déconnexion)
- [ ] Gérer stockage (supprimer parcours téléchargés)
- [ ] À propos / Version
- [ ] Politique de confidentialité
- [ ] Support / Contact

---

## Résumé par priorité

### 🔴 MVP (Must Have) — 16 stories
| ID | Story | Estimation |
|----|-------|------------|
| US-101 | Carte de la ville | M |
| US-102 | Liste des parcours | M |
| US-103 | Détail d'un parcours | S |
| US-104 | Démarrer un parcours | M |
| US-105 | Voir ma progression | S |
| US-201 | Trigger audio GPS auto | L |
| US-202 | Trigger audio manuel | S |
| US-203 | Contrôles audio | M |
| US-204 | Téléchargement offline | M |
| US-401 | Sélection mode transport | S |
| US-402 | Mode piéton | M |
| US-601 | Parcours Vieux-Mtl Classique | XL |
| US-604 | Parcours Sainte-Julie (test) | L |
| US-701 | Optimisation batterie | M |
| US-901 | Onboarding | M |
| US-902 | Permissions | S |

### 🟡 V1 (Should Have) — 20 stories
Sync groupe, paiements, autres modes, etc.

### 🟢 V2+ (Could Have) — 8 stories
Mode auto, détection auto, suggestions, etc.

---

*Dernière mise à jour: 2026-02-12*
