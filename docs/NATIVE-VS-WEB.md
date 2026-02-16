# 📱 Analyse: App Native vs Web App

> Quelle plateforme est la meilleure pour App Voyage?

---

## Contexte

App Voyage est un guide audio géolocalisé qui nécessite:
- 📍 GPS en arrière-plan (background location)
- 🎧 Lecture audio en arrière-plan
- 📴 Fonctionnement offline
- 👥 Sync multi-appareils en temps réel
- 🔔 Notifications locales
- 💳 Paiements in-app

---

## Comparatif détaillé

### 1. GPS & Géolocalisation

| Critère | App Native (Flutter) | Web App (PWA) |
|---------|---------------------|---------------|
| GPS précision | ✅ Excellente (~5m) | ✅ Bonne (~5-10m) |
| GPS en background | ✅ **Oui** | ❌ **Non fiable** |
| Géofencing natif | ✅ APIs dédiées | ❌ Pas supporté |
| Wake up sur position | ✅ Oui | ❌ Non |

**Verdict:** 🏆 **App Native**

> Le GPS background est **CRITIQUE** pour notre use case. L'utilisateur doit pouvoir marcher avec le téléphone dans sa poche et recevoir l'audio automatiquement. **Une PWA ne peut pas faire ça de manière fiable.**

---

### 2. Audio

| Critère | App Native | Web App (PWA) |
|---------|------------|---------------|
| Lecture audio | ✅ Excellent | ✅ Bon |
| Audio en background | ✅ **Complet** | ⚠️ **Limité** |
| Lock screen controls | ✅ Natif | ⚠️ Partiel (Media Session API) |
| Écouteurs Bluetooth | ✅ Parfait | ✅ OK |
| Audio spatial | ✅ Possible | ❌ Très limité |

**Verdict:** 🏆 **App Native**

> Sur iOS Safari, l'audio en background se coupe souvent quand l'écran s'éteint ou que l'utilisateur switch d'app. C'est un deal-breaker pour un guide de visite.

---

### 3. Mode Offline

| Critère | App Native | Web App (PWA) |
|---------|------------|---------------|
| Stockage local | ✅ Illimité* | ⚠️ Limité (~50-100MB) |
| Persistance | ✅ Permanente | ⚠️ Peut être purgé par l'OS |
| Cartes offline | ✅ Facile (Mapbox) | ⚠️ Complexe |
| Service Workers | N/A | ✅ Oui |

**Verdict:** 🏆 **App Native**

> Les parcours avec audio peuvent faire 20-50MB. Safari purge agressivement le cache des PWA. Un utilisateur pourrait perdre son parcours téléchargé au pire moment (pendant le voyage).

---

### 4. Sync Multi-Appareils (Mode Host)

| Critère | App Native | Web App (PWA) |
|---------|------------|---------------|
| WebSockets | ✅ Stable | ✅ Stable |
| Background sync | ✅ Oui | ❌ Se déconnecte |
| Fiabilité | ✅ Haute | ⚠️ Moyenne |

**Verdict:** 🏆 **App Native** (léger avantage)

> La sync fonctionne bien dans les deux cas TANT QUE l'app est au premier plan. En background, la PWA perd la connexion.

---

### 5. Notifications

| Critère | App Native | Web App (PWA) |
|---------|------------|---------------|
| Push notifications | ✅ Oui | ⚠️ Pas sur iOS! |
| Notifications locales | ✅ Oui | ❌ Non sur iOS |
| Vibration | ✅ Oui | ⚠️ Limité |

**Verdict:** 🏆 **App Native**

> iOS ne supporte PAS les notifications pour les PWA. On ne peut pas alerter "Prochain point dans 50m" si l'app n'est pas ouverte.

---

### 6. Paiements

| Critère | App Native | Web App (PWA) |
|---------|------------|---------------|
| Apple Pay | ✅ In-App Purchase | ✅ Web Payment API |
| Google Pay | ✅ In-App Purchase | ✅ Web Payment API |
| Commission | ❌ 30% Apple/Google | ✅ ~3% Stripe |
| Friction | ⚠️ Compte requis | ✅ Plus fluide |

**Verdict:** 🏆 **Web App** (pour les paiements uniquement)

> Les paiements web évitent la commission de 30%. MAIS Apple force les apps avec contenu digital à utiliser In-App Purchase. Si on veut être sur l'App Store, on n'a pas le choix.

---

### 7. Distribution & Découvrabilité

| Critère | App Native | Web App (PWA) |
|---------|------------|---------------|
| App Store / Play Store | ✅ Oui | ❌ Non |
| Découvrabilité | ✅ Recherche dans les stores | ⚠️ SEO uniquement |
| Installation | ⚠️ Téléchargement | ✅ Instantané |
| Mises à jour | ⚠️ Via les stores | ✅ Automatiques |
| Confiance utilisateur | ✅ "C'est une vraie app" | ⚠️ "C'est un site?" |

**Verdict:** ⚖️ **Mixte**

> Les touristes cherchent souvent "audio guide Montreal" sur l'App Store. Être présent là est important. Mais le SEO web fonctionne aussi.

---

### 8. Développement & Coûts

| Critère | App Native (Flutter) | Web App (PWA) |
|---------|---------------------|---------------|
| Codebase unique | ✅ iOS + Android | ✅ Tous navigateurs |
| Compétences requises | Dart/Flutter | JavaScript/React |
| Coût Apple Developer | ❌ 129$/an | ✅ 0$ |
| Coût Google Play | ❌ 25$ one-time | ✅ 0$ |
| Temps de développement | ⚠️ Plus long | ✅ Plus rapide |
| Review App Store | ⚠️ 1-2 semaines | ✅ Instantané |

**Verdict:** 🏆 **Web App** (pour le développement)

> Une PWA est plus rapide à développer et déployer. Pas de review, pas de frais. Mais les limitations techniques sont bloquantes pour notre use case.

---

## Tableau récapitulatif

| Critère | Poids | App Native | Web App |
|---------|-------|------------|---------|
| GPS background | ⭐⭐⭐⭐⭐ | ✅ | ❌ |
| Audio background | ⭐⭐⭐⭐⭐ | ✅ | ⚠️ |
| Offline robuste | ⭐⭐⭐⭐ | ✅ | ⚠️ |
| Notifications | ⭐⭐⭐ | ✅ | ❌ |
| Sync groupe | ⭐⭐⭐ | ✅ | ⚠️ |
| Paiements | ⭐⭐ | ⚠️ | ✅ |
| Distribution | ⭐⭐ | ✅ | ⚠️ |
| Coût dev | ⭐ | ⚠️ | ✅ |

---

## 🎯 Recommandation: **App Native (Flutter)**

### Pourquoi?

1. **GPS background = obligatoire**
   - C'est le cœur de l'expérience. Sans ça, l'utilisateur doit garder l'app ouverte et regarder son écran. Ça tue l'immersion.

2. **Audio background = obligatoire**
   - Les gens veulent écouter avec le téléphone dans leur poche. iOS Safari coupe l'audio trop facilement.

3. **Offline = critique pour les touristes**
   - Roaming coûteux, zones sans signal. Le cache PWA n'est pas assez fiable.

4. **Confiance utilisateur**
   - "Télécharge l'app" inspire plus confiance que "Ajoute ce site à ton écran d'accueil".

5. **Flutter = le meilleur des deux mondes**
   - Un seul codebase pour iOS + Android
   - Performance native
   - Accès à toutes les APIs natives

---

## Alternative: Approche Hybride

On pourrait envisager:

### Phase 1: App Native (MVP)
- Toutes les fonctionnalités critiques
- App Store + Google Play
- Expérience optimale

### Phase 2: Site Web compagnon
- Landing page marketing
- Aperçu des parcours (sans audio)
- Achat en ligne (redirect vers app)
- SEO pour découvrabilité

### Phase 3: PWA "Lite" (optionnel)
- Version web simplifiée
- Pour les utilisateurs qui refusent d'installer
- Fonctionnalités réduites (pas de background)
- "Pour la meilleure expérience, téléchargez l'app"

---

## Comparaison avec les compétiteurs

| App | Plateforme | Pourquoi? |
|-----|-----------|-----------|
| VoiceMap | Native (iOS/Android) | GPS background obligatoire |
| izi.TRAVEL | Native (iOS/Android) | Offline + GPS |
| GuideAlong | Native (iOS/Android) | GPS précis pour auto |
| Shaka Guide | Native (iOS/Android) | Audio background |
| Detour (RIP) | Native | Sync groupe + audio |

**100% des compétiteurs sérieux sont en app native.** Aucun n'a réussi avec une PWA pour ce use case.

---

## Conclusion

**App Native avec Flutter reste le bon choix.**

Les limitations des PWA pour:
- GPS background ❌
- Audio background ❌ (iOS)
- Notifications ❌ (iOS)
- Stockage fiable ❌

...sont des deal-breakers pour un guide audio géolocalisé.

Le surcoût de développement natif est justifié par une expérience utilisateur nettement supérieure.

---

*Dernière mise à jour: 2026-02-16*
