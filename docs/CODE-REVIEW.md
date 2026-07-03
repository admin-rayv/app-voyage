# 🔍 Revue de code — App Voyage v0.4.7

> Revue complète du code (lib/, configs Android/iOS, schéma SQL, CI) faite le 2026-07-03.
> Objectif: identifier les bugs et incohérences à adresser **avant le Sprint 4 (test terrain)**
> et le Sprint 5 (offline).

**Légende priorité:** 🚨 Bloquant avant Sprint 4 · 🔴 Important · 🟡 Moyen · 🟢 Mineur / dette

---

## ✅ Mise à jour 2026-07-03 — correctifs appliqués (v0.4.8)

Tous les constats ci-dessous ont été traités, **sauf deux qui restent ouverts**.
Vérifié par `flutter analyze` (0 issue) et `flutter test` (14 tests verts).

| # | Constat | Résolution |
|---|---------|------------|
| 1 | GPS arrière-plan | ✅ `AppleSettings`/`AndroidSettings` + foreground service geolocator; service flutter_foreground_task retiré du manifest |
| 2 | Position figée sur la carte | ✅ Stream de position pendant que l'écran carte est visible |
| 3 | Edge TTS non branché | ✅ **Branché en v0.5.0** (option A): lecture MP3 via just_audio avec fallback flutter_tts automatique, timeout 12 s, bouton « Télécharger les audios » par ville sur la carte. Cache invalidé par hash du contenu |
| 4 | POIs écoutés qui rejouent | ✅ Le geofencing est pré-alimenté avec les POIs visités (persistés); nouveau réglage « Rejouer les POIs déjà écoutés » pour les tests terrain; le compteur du bandeau ne compte que les vrais triggers de session |
| 5 | Test de voix = sélection | ✅ `previewVoice()` non persistant |
| 6 | Fuite de listeners (test voix) | ✅ Un seul abonnement, annulé dans dispose |
| 7 | Reprise Android depuis le début | ✅ Reprise au dernier offset réel (progressHandler) sur Android; reprise native conservée sur iOS — **à confirmer sur device au Sprint 4** |
| 8 | Progression estimée qui dérive | ✅ Recalée en continu sur les offsets réels du progressHandler |
| 9 | Notifications sans accents | ✅ Corrigé |
| 10 | Label Android « app_voyage » | ✅ « App Voyage » |
| 11 | Requête N+1 du home | ✅ 2 requêtes au total (villes + résumé city_id/catégories) |
| 12 | Permission micro + fetch inutilisées (iOS) | ✅ Retirées d'Info.plist |
| 13 | Dépendances mortes | ✅ Retirées: dio, permission_handler, just_audio, intl, riverpod_annotation, riverpod_generator, build_runner |
| 14 | Vestiges « tours » | ✅ Écrans stubs et routes supprimés (le schéma SQL V2 reste) |
| 15 | Constantes trigger inutilisées | ✅ Retirées (le rayon vient de la DB); constantes TTS réellement branchées |
| 16 | SupabaseService mi-statique | ✅ `getScript` statique |
| 17 | Clés en dur | ✅ `String.fromEnvironment` (surchargeables via `--dart-define`) |
| 18 | Logique geofencing non testée | ✅ Extraite dans `GeofenceMath` + 13 tests unitaires |
| 19 | Logs perdus après kill | ✅ Bouton « Copier » (logs + décisions géo) dans le panneau debug |
| 20 | Duplication `_basePoints` | ✅ Getter partagé |

**Reste ouvert:** la validation sur device de la reprise pause/resume en mode TTS
natif sur Android (#7, pendant le Sprint 4 — moins critique depuis que le chemin
principal est le MP3 Edge TTS, dont la pause/reprise est native via just_audio).

---

## 🚨 Bloquants avant le test terrain

### 1. Le GPS en arrière-plan ne peut pas fonctionner tel que configuré

**Fichiers:** `lib/services/location_service.dart:45`, `android/app/src/main/AndroidManifest.xml`

Le mode découverte est censé fonctionner téléphone en poche / écran verrouillé
(livrable Sprint 3: « Audio joue même si app en background »). Trois problèmes
empêchent ça:

- **iOS:** `startTracking()` utilise un `LocationSettings` générique. Pour recevoir
  des positions en arrière-plan, geolocator exige `AppleSettings(allowBackgroundLocationUpdates: true,
  showBackgroundLocationIndicator: true)`. Sans ça, le stream se met en pause dès que
  l'app passe en background, même avec la permission « Toujours » et le
  `UIBackgroundModes: location` (qui est bien dans Info.plist).
- **Android:** aucun foreground service n'est démarré pour la localisation. Le stream
  geolocator meurt quand l'app est mise en veille par l'OS. Il faut
  `AndroidSettings(foregroundNotificationConfig: ForegroundNotificationConfig(...))`
  qui affiche une notification persistante et garde le process vivant.
- **Manifest incohérent:** le manifest déclare le service
  `com.pravera.flutter_foreground_task.service.ForegroundService`, mais le package
  `flutter_foreground_task` **n'est pas dans pubspec.yaml**. Cette entrée est morte —
  soit ajouter le package, soit (mieux) la retirer et utiliser le foreground service
  intégré de geolocator.

**Impact:** le test terrain Sprint 4 échouera dès que l'écran se verrouille — les
triggers ne se produiront que l'app ouverte à l'écran.

**Correctif suggéré:** dans `LocationService.startTracking()`, construire les settings
par plateforme (`AppleSettings` / `AndroidSettings` avec `foregroundNotificationConfig`),
et retirer le service flutter_foreground_task du manifest.

---

### 2. La position de l'utilisateur sur la carte n'est jamais rafraîchie

**Fichier:** `lib/screens/map_screen.dart:149`

`_getUserPosition()` est appelé une seule fois dans `initState`. Le point bleu reste
figé à la position d'ouverture de l'écran pendant toute la balade, et les distances
affichées dans la vue liste et les previews deviennent fausses au fur et à mesure
qu'on marche. Pour une app dont l'usage principal est « je me promène et je regarde
la carte », c'est très visible.

**Correctif suggéré:** s'abonner à un stream de position (celui du
`GeofencingService`/`LocationService` quand la découverte est active, ou un stream
léger sinon) et mettre à jour `_userPosition`. Bonus: option « suivre ma position »
qui recentre la carte.

---

## 🔴 Incohérences majeures à trancher

### 3. EdgeTtsService: 225 lignes de code mort jamais branché à la lecture

**Fichiers:** `lib/services/edge_tts_service.dart`, `lib/services/audio_service.dart:507-524`

Le service Edge TTS (génération MP3 via l'API WebSocket non officielle de Microsoft,
cache local, voix `fr-CA-ThierryNeural`) est complet, mais:

- `AudioService.playText()` route **toujours** vers flutter_tts — aucun chemin de code
  ne lit les MP3 générés;
- `downloadCityAudios()`, `getCacheSizeMB()`, `clearCache()` et `playScript()` ne sont
  appelés par **aucun écran**;
- `just_audio` (nécessaire pour lire les MP3) est déclaré dans pubspec mais jamais importé;
- le cache est indexé sur `md5(scriptId-language)` **sans hash du contenu** — si un
  script est corrigé dans Supabase, le vieil audio resterait servi pour toujours
  (PROJECT.md promettait une invalidation par hash du texte).

**Décision à prendre:**
- **Option A — brancher:** dans `playText`, tenter `EdgeTtsService.getAudioPath()` →
  lecture MP3 via just_audio → fallback flutter_tts si null. Ajouter le hash du contenu
  dans la clé de cache. Ajouter l'UI de téléchargement (et la limiter à la langue choisie,
  pas les 3). Accepter le risque d'API non officielle (RISKS.md T7).
- **Option B — retirer:** supprimer `edge_tts_service.dart`, les méthodes mortes
  d'AudioService, et les dépendances `just_audio` + `connectivity_plus` + `dio`.
  La qualité de voix redevient un sujet V2 (Azure TTS officiel, ElevenLabs).

Dans les deux cas, ne pas laisser l'ambiguïté traîner jusqu'au Sprint 5 (offline),
car le choix change ce qu'il faut mettre en cache.

### 4. Les POIs déjà écoutés re-déclenchent à chaque session

**Fichiers:** `lib/services/geofencing_service.dart:39`, `lib/screens/map_screen.dart:292`

Le Sprint 3 demandait « Ne pas re-déclencher si déjà écouté ». Or:

- `GeofencingService._alreadyTriggered` vit en mémoire seulement;
- `map_screen._enableDiscoveryMode()` appelle `resetTriggered()` à **chaque activation**;
- `VisitedPoiService` (qui persiste les POIs écoutés) n'est consulté ni par le
  geofencing ni par `DiscoveryPlaybackService`.

Résultat: on redémarre l'app (ou on toggle le mode découverte) → tous les POIs du
quartier rejouent. Pour un test terrain c'est peut-être voulu (on veut retester),
mais pour un vrai utilisateur c'est du spam.

**Correctif suggéré:** au démarrage du monitoring, initialiser `_alreadyTriggered`
avec `VisitedPoiService.visitedPoiIdsForCity(cityId)` (ou filtrer dans
`DiscoveryPlaybackService`), et offrir un réglage « rejouer les POIs déjà écoutés »
pour les tests.

---

## 🟡 Bugs réels (non bloquants)

### 5. Settings: tester une voix la sélectionne définitivement

**Fichier:** `lib/screens/settings_screen.dart:100-123`

`_testVoice()` appelle `_tts.setUserVoice(...)` qui **persiste** la voix dans
SharedPreferences. Appuyer sur ▶️ pour écouter une voix revient donc à la choisir,
même si l'utilisateur ne la sélectionne pas. Le test devrait appliquer la voix
temporairement (`applyVoiceToTts`) sans écrire la préférence.

### 6. Settings: fuite d'abonnements dans `_testVoice`

**Fichier:** `lib/screens/settings_screen.dart:118`

Chaque test de voix ajoute un nouveau listener sur `_tts.stateStream` sans jamais
l'annuler — après 10 tests, 10 listeners actifs. Garder une seule
`StreamSubscription` (champ d'état) et la réutiliser/annuler.

### 7. Pause/reprise sur Android probablement cassée (reprend du début)

**Fichier:** `lib/services/audio_handler.dart:158-166`

Le mécanisme de reprise s'appuie sur le comportement iOS de flutter_tts
(`pause()` mémorise la position, `speak()` reprend au `pauseRangeStart`). Sur
Android, ce comportement n'est pas garanti — la reprise risque de relire le script
depuis le début pendant que la barre de progression continue où elle était
(désynchronisation). À vérifier sur device Android au Sprint 4; si confirmé,
mémoriser la position estimée et tronquer le texte à la reprise côté Dart.

### 8. Progression basée sur une durée estimée, jamais recalée

**Fichiers:** `lib/services/audio_service.dart:373-381`, `lib/services/audio_handler.dart:272-281`

La durée = `mots × 0.4 s ÷ vitesse` et la position avance par timer de 500 ms.
Si la voix réelle parle plus lentement/vite, la barre atteint 100 % avant la fin
(ou l'inverse). Acceptable pour le proto — mais c'est aussi l'assiette du marquage
« visité à 50 % », donc un POI lu vite pourrait ne jamais être marqué. À garder en tête.

### 9. Textes de notifications sans accents

**Fichier:** `lib/services/notification_service.dart:331-351`

« Tu es a proximite ! », « L audio demarre maintenant » — les notifications
supportent l'UTF-8, les accents peuvent être rétablis (« Tu es à proximité ! »).

### 10. Nom d'app Android = « app_voyage »

**Fichier:** `android/app/src/main/AndroidManifest.xml` (`android:label="app_voyage"`)

Le nom affiché sous l'icône sera `app_voyage`. Mettre `App Voyage` avant de
distribuer le moindre APK à des testeurs.

### 11. Home: requête N+1 pour compter les POIs

**Fichier:** `lib/screens/home_screen.dart:35-59`

`_loadCities()` télécharge **tous les POIs de chaque ville** (81 lignes complètes
pour Saint-Lambert) juste pour afficher le compte et les catégories. OK avec 1 ville,
lent et coûteux avec les 6 villes de la Phase 2. Prévoir une vue SQL ou une RPC
(`select city_id, count(*), array_agg(distinct ...)`).

### 12. Permission micro déclarée sans usage (risque de rejet App Store)

**Fichier:** `ios/Runner/Info.plist`

`NSMicrophoneUsageDescription` est déclarée « pour une fonctionnalité future ».
Apple rejette régulièrement les apps déclarant des permissions non utilisées.
À retirer jusqu'à ce que la feature existe. (Même logique pour `UIBackgroundModes:
fetch`, non utilisé.)

---

## 🟢 Mineur / dette technique

13. **Dépendances déclarées jamais importées:** `dio`, `permission_handler`,
    `just_audio` (lié au point 3), `riverpod_annotation`/`riverpod_generator`
    (riverpod n'est utilisé que pour le `ProviderScope` de main.dart). À élaguer
    ou à adopter réellement.
14. **Écrans/routes vestiges de l'ère « tours »:** `tour_detail_screen.dart` et
    `active_tour_screen.dart` sont des stubs « 🚧 En construction » avec leurs routes
    `/tour/:tourId`. Rien ne pointe vers eux. À supprimer (le schéma V2 `tours` en DB
    suffit comme préparation) ou à assumer.
15. **Constantes trigger non utilisées:** `AppConstants.defaultTriggerRadiusMeters (30)`,
    `bikeTriggerRadiusMeters`, `carTriggerRadiusMeters` ne sont référencés nulle part —
    le rayon vient de la DB (`trigger_radius_m`, défaut 40). Incohérence 30 vs 40 à
    clarifier quand le mode vélo/auto arrivera.
16. **`SupabaseService` mi-statique mi-instance:** `getScript()` est une méthode
    d'instance alors que tout le reste est statique — d'où le `_supabase` instancié
    dans AudioService. Uniformiser.
17. **Clés Supabase en dur dans le code:** l'anon key est publique par design (RLS
    protège les données), donc pas une fuite, mais prévoir `--dart-define` pour
    gérer plusieurs environnements en Phase 2 (et pour ne pas committer la future
    clé service dans les scripts du pipeline).
18. **Test unique superficiel:** `widget_test.dart` vérifie seulement que le titre
    s'affiche. Le geofencing (`_isApproaching`, `_calculateEffectiveRadius`,
    debounce/cooldown/queue) est de la logique pure très testable — des tests unitaires
    ici rendraient les réglages terrain beaucoup plus sûrs.
19. **`DebugLog` non persisté:** les logs et décisions géo (500 max) sont perdus si
    l'app est tuée. Pour le Sprint 4, envisager un export (partage de fichier) pour
    analyser les balades après coup.
20. **`_showList` et « Non écoutés seulement »:** le filtre « Non écoutés » recalcule
    `basePoints` deux fois (`_filteredPoints` + `_buildFilterBar`) — pas un bug,
    juste une petite duplication.

---

## Récapitulatif — ordre d'attaque suggéré

| # | Quoi | Quand |
|---|------|-------|
| 1 | GPS arrière-plan (AppleSettings/AndroidSettings + foreground service) | **Avant Sprint 4** |
| 2 | Position utilisateur live sur la carte | **Avant Sprint 4** |
| 10 | Label Android « App Voyage » | Avant de distribuer un APK |
| 4 | Ne pas re-déclencher les POIs écoutés (ou réglage explicite) | Avant Sprint 4 (décision produit) |
| 5, 6 | Bugs settings voix | Sprint 4 (rapide) |
| 7 | Vérifier pause/resume Android sur device | Pendant Sprint 4 |
| 3 | Décision Edge TTS: brancher ou retirer | Avant Sprint 5 (offline) |
| 11 | RPC compte de POIs | Avant Phase 2 (multi-villes) |
| 12-20 | Dette technique | Au fil de l'eau |

---

*Revue faite le 2026-07-03 sur v0.4.7 (commit bf96498).*
