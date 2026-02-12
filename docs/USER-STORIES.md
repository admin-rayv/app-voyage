# 📖 User Stories — App Voyage

## Format

```
En tant que [utilisateur],
je veux [action],
pour [bénéfice].
```

Priorité: 🔴 Must (MVP) | 🟡 Should (V1) | 🟢 Could (V2+)

---

## Épic 1: Découverte & Navigation

### 🔴 US-101: Voir la carte de la ville
> En tant que touriste,  
> je veux voir une carte interactive de la ville,  
> pour visualiser où je suis et ce qu'il y a autour.

**Critères d'acceptation:**
- [ ] Carte centrée sur ma position GPS
- [ ] Points d'intérêt visibles sur la carte
- [ ] Zoom in/out fluide

---

### 🔴 US-102: Voir les parcours disponibles
> En tant que touriste,  
> je veux voir la liste des parcours disponibles,  
> pour choisir celui qui m'intéresse.

**Critères d'acceptation:**
- [ ] Liste avec nom, durée, distance, thème
- [ ] Preview du parcours sur la carte
- [ ] Indication gratuit/premium

---

### 🔴 US-103: Démarrer un parcours
> En tant que touriste,  
> je veux démarrer un parcours,  
> pour commencer ma visite guidée.

**Critères d'acceptation:**
- [ ] Bouton "Démarrer" clair
- [ ] Instruction pour se rendre au point de départ
- [ ] Transition vers mode "visite active"

---

### 🟡 US-104: Voir ma progression
> En tant que touriste en visite,  
> je veux voir ma progression dans le parcours,  
> pour savoir combien il reste.

**Critères d'acceptation:**
- [ ] Barre de progression ou X/Y points
- [ ] Points visités vs à venir sur la carte
- [ ] Temps estimé restant

---

## Épic 2: Audio & Contenu

### 🔴 US-201: Écouter l'audio automatiquement
> En tant que touriste qui marche,  
> je veux que l'audio se déclenche automatiquement quand j'arrive près d'un point,  
> pour ne pas avoir à toucher mon téléphone.

**Critères d'acceptation:**
- [ ] Déclenchement basé sur géofence (~30m)
- [ ] Notification/vibration avant lecture
- [ ] Audio joue même si app en background

---

### 🔴 US-202: Contrôler la lecture audio
> En tant que touriste,  
> je veux pouvoir pause/play/rewind l'audio,  
> pour réécouter ou faire une pause.

**Critères d'acceptation:**
- [ ] Boutons play/pause accessibles
- [ ] Rewind 15 secondes
- [ ] Skip au prochain point (optionnel)

---

### 🔴 US-203: Télécharger un parcours offline
> En tant que touriste,  
> je veux télécharger un parcours avant ma visite,  
> pour ne pas dépendre du réseau mobile.

**Critères d'acceptation:**
- [ ] Bouton "Télécharger" par parcours
- [ ] Indicateur de progression
- [ ] Fonctionne 100% offline après download

---

### 🟡 US-204: Choisir la langue
> En tant que touriste anglophone,  
> je veux choisir la langue de l'audio,  
> pour comprendre le contenu.

**Critères d'acceptation:**
- [ ] Sélecteur FR/EN
- [ ] Audios disponibles dans les deux langues
- [ ] Préférence sauvegardée

---

## Épic 3: Sync Multi-Appareils

### 🟡 US-301: Créer une session de groupe
> En tant que guide de mon groupe,  
> je veux créer une session partagée,  
> pour que mes amis/famille écoutent la même chose.

**Critères d'acceptation:**
- [ ] Bouton "Créer session"
- [ ] Code/lien à partager
- [ ] Voir qui a rejoint

---

### 🟡 US-302: Rejoindre une session
> En tant que membre d'un groupe,  
> je veux rejoindre la session du host,  
> pour écouter le même audio en sync.

**Critères d'acceptation:**
- [ ] Entrer code ou scanner QR
- [ ] Confirmation de connexion
- [ ] Audio sync automatique avec le host

---

### 🟡 US-303: Contrôler le groupe (Host)
> En tant que host,  
> je veux contrôler la lecture pour tout le groupe,  
> pour garder tout le monde ensemble.

**Critères d'acceptation:**
- [ ] Play/pause affecte tout le groupe
- [ ] Indicateur "vous êtes le host"
- [ ] Possibilité de passer le contrôle

---

## Épic 4: Modes de Transport

### 🔴 US-401: Mode piéton (défaut)
> En tant que piéton,  
> je veux une expérience optimisée pour la marche,  
> pour profiter des détails à chaque arrêt.

**Critères d'acceptation:**
- [ ] Points rapprochés (50-200m)
- [ ] Suggestions "arrête-toi ici"
- [ ] Géofence petit rayon

---

### 🟡 US-402: Mode vélo
> En tant que cycliste,  
> je veux une expérience adaptée au vélo,  
> pour écouter sans m'arrêter tout le temps.

**Critères d'acceptation:**
- [ ] Points plus espacés
- [ ] Narration plus courte
- [ ] Pas de "arrête-toi"

---

### 🟢 US-403: Mode auto
> En tant que passager en voiture,  
> je veux une narration continue style road trip,  
> pour découvrir les quartiers qu'on traverse.

**Critères d'acceptation:**
- [ ] Narration fluide entre les zones
- [ ] Détection de vitesse (>30km/h)
- [ ] Contenu adapté (quartiers, pas bâtiments)

---

## Épic 5: Compte & Paiements

### 🟡 US-501: Créer un compte
> En tant que nouvel utilisateur,  
> je veux créer un compte facilement,  
> pour sauvegarder mes parcours et préférences.

**Critères d'acceptation:**
- [ ] Sign up email ou social (Google/Apple)
- [ ] Optionnel pour parcours gratuits
- [ ] Requis pour achats

---

### 🟡 US-502: Acheter un parcours premium
> En tant que touriste,  
> je veux acheter un parcours premium,  
> pour accéder à plus de contenu.

**Critères d'acceptation:**
- [ ] Prix clair avant achat
- [ ] Paiement in-app (Apple/Google Pay)
- [ ] Accès immédiat après paiement

---

### 🟢 US-503: Acheter un pack ville
> En tant que touriste qui reste plusieurs jours,  
> je veux acheter tous les parcours d'une ville,  
> pour avoir un rabais.

**Critères d'acceptation:**
- [ ] Bundle avec discount visible
- [ ] Unlock tous les parcours de la ville

---

## Épic 6: Contenu & Parcours

### 🔴 US-601: Parcours Vieux-Montréal
> Premier parcours pour le prototype/MVP.

**Contenu requis:**
- [ ] ~10-15 points d'intérêt
- [ ] ~45-60 min de marche
- [ ] Audio FR + EN
- [ ] Thème: Histoire coloniale à aujourd'hui

---

### 🟡 US-602: Parcours Mile-End
> Quartier artistique et trendy.

**Contenu requis:**
- [ ] Street art, cafés historiques, culture juive
- [ ] Ton plus décontracté

---

### 🟡 US-603: Parcours Mont-Royal
> Nature en ville.

**Contenu requis:**
- [ ] Histoire du parc, points de vue, Tam-Tams

---

*Ajouter plus de parcours selon les priorités*

---

*Dernière mise à jour: 2026-02-12*
