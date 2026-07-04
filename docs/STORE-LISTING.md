# Fiche store — textes prêts à coller

Textes pour Google Play et l'App Store, en français et en anglais.
Le processus (comptes, clés, étapes) est dans [DISTRIBUTION.md](./DISTRIBUTION.md).

---

## Identité

| Champ | Valeur |
|---|---|
| Nom de l'app | **App Voyage** |
| Catégorie | Voyages (Play: *Travel & Local* · App Store: *Travel*) |
| Classification | Tous publics / 4+ |
| Site web | https://admin-rayv.github.io/app-voyage/ |
| Politique de confidentialité | https://admin-rayv.github.io/app-voyage/confidentialite.html |
| Courriel de soutien | admin@rayv.ca |
| Tarif | Gratuit (achats intégrés à venir: packs villes) |

---

## Google Play

### Description courte (max 80 caractères)

**FR** (66 c.) :
> Guide audio géolocalisé — un ami historien dans tes écouteurs.

**EN** (63 c.) :
> Location-aware audio guide — a historian friend in your ears.

### Description longue (max 4000 caractères)

**FR** :

> **Promène-toi. Marco s'occupe du reste.**
>
> App Voyage transforme ta marche en visite guidée : quand tu approches d'un lieu qui a une histoire, ton guide audio se déclenche tout seul, dans tes écouteurs. Pas de parcours imposé, pas d'écran à surveiller — tu explores librement, téléphone en poche.
>
> 🗺️ **Explore sans contrainte**
> Tous les points d'intérêt de la ville sont sur la carte : histoire, architecture, art, nature, lieux insolites, bonnes adresses, vie locale. Va où tu veux, dans l'ordre que tu veux.
>
> 📍 **Le mode découverte**
> Active-le, range ton téléphone et marche. Dès que tu entres dans le rayon d'un point d'intérêt, Marco te raconte l'histoire du lieu — anecdotes, personnages, détails que même les gens du coin ignorent.
>
> 🎙️ **Une vraie voix, pas un robot**
> Des voix neurales naturelles en français (accent québécois!), en anglais et en espagnol. Chacun choisit sa langue.
>
> 📴 **100 % hors ligne**
> Télécharge la ville en Wi-Fi : les guides, les voix et la carte fonctionnent ensuite sans réseau. Parfait en itinérance.
>
> 👥 **Écouter ensemble**
> En famille ou entre amis : une personne guide, tout le groupe entend le même lieu en même temps — chacun dans sa langue.
>
> ❤️ **Ta collection**
> Suis ta progression ville par ville, garde tes coups de cœur en favoris.
>
> **Première ville : Saint-Lambert (Québec)** — 81 points d'intérêt, plus de 4 heures d'audio. D'autres villes de la Rive-Sud de Montréal arrivent.
>
> Ta vie privée : pas de compte, pas de pub, pas de pistage. Ta position est traitée sur ton téléphone et ne quitte jamais ton appareil.

**EN** :

> **Just walk. Marco does the rest.**
>
> App Voyage turns your walk into a guided tour: when you get close to a place with a story, your audio guide starts on its own, right in your ears. No fixed route, no screen to watch — explore freely with your phone in your pocket.
>
> 🗺️ **Explore without constraints** — every point of interest on one map: history, architecture, art, nature, hidden gems, food, local life.
>
> 📍 **Discovery mode** — turn it on, pocket your phone, and walk. Enter a point's radius and Marco tells you the story: anecdotes, characters, details even locals don't know.
>
> 🎙️ **A real voice, not a robot** — natural neural voices in French (Québec accent!), English and Spanish.
>
> 📴 **100% offline** — download a city on Wi-Fi: guides, voices and the map all work with no network. Perfect while roaming.
>
> 👥 **Listen together** — one person leads, the whole group hears the same place at the same time — each in their own language.
>
> ❤️ **Your collection** — track your progress city by city, keep favorites.
>
> **First city: Saint-Lambert (Québec)** — 81 points of interest, 4+ hours of audio. More South Shore cities coming.
>
> Privacy: no account, no ads, no tracking. Your location is processed on your phone and never leaves your device.

### Formulaire « Sécurité des données » (réponses)

| Question | Réponse |
|---|---|
| L'app collecte-t-elle des données ? | **Non** — la position est traitée sur l'appareil, jamais transmise |
| Partage de données avec des tiers | Non |
| Données chiffrées en transit | Oui (HTTPS/WSS pour le contenu) |
| Suppression des données possible | Les données locales se suppriment en désinstallant |
| Localisation | Utilisée **sur l'appareil seulement** pour déclencher l'audio; pas de collecte |

### Déclaration « localisation en arrière-plan » (formulaire Play Console)

> App Voyage est un guide audio géolocalisé : sa fonction principale (« mode
> découverte ») déclenche automatiquement la narration d'un lieu quand
> l'utilisateur s'en approche à pied, l'écran verrouillé et le téléphone en
> poche. L'accès à la position en arrière-plan est indispensable à cette
> fonction centrale, activée explicitement par l'utilisateur (interrupteur
> dans l'app + permission « Toujours »). La position est traitée localement
> et n'est jamais transmise hors de l'appareil.

Vidéo de démonstration exigée : filmer (~30 s) l'activation du mode
découverte → écran verrouillé → l'audio se déclenche en marchant près d'un
POI, avec la notification visible.

---

## App Store (Apple)

| Champ | Valeur |
|---|---|
| Sous-titre (30 c.) | FR : « Un ami historien à l'oreille » · EN : "A historian in your ears" |
| Mots-clés (100 c.) | FR : `guide audio,visite,balade,histoire,patrimoine,tourisme,GPS,audioguide,québec,saint-lambert` |
| | EN : `audio guide,walking tour,history,heritage,travel,GPS,audioguide,quebec,offline,local` |

Description longue : reprendre la version Play ci-dessus.

### App Privacy (questionnaire Apple)

- **Data Not Collected** (aucune donnée collectée) — la position est
  traitée sur l'appareil (« processing on device »), rien n'est lié à
  l'identité, pas de tracking. C'est la meilleure étiquette possible.

### Notes pour la revue Apple (champ « Notes »)

> Location (Always) powers the core feature: hands-free audio narration
> triggered when the user walks near a point of interest, screen locked.
> Location is processed on-device only and never transmitted. Background
> audio plays the narration. To test: enable "discovery mode" on the map
> of Saint-Lambert, QC — or use the simulator's GPX route near
> 45.5004, -73.5139 (Église Saint-Lambert).

---

## Captures d'écran à produire (les deux stores)

1. Carte de Saint-Lambert avec les marqueurs colorés + clusters
2. Mode découverte actif (bandeau + cercles de rayon)
3. Détail d'un POI avec le lecteur et le texte
4. Accueil avec la carte de ville, progression « X/81 écoutés »
5. « Écouter ensemble » (code + QR + participants)
6. Réglages (langues/voix) ou onboarding

Formats : téléphone 6,7" (1290×2796) obligatoire chez Apple; Play accepte
16:9 à 2:1. Le harnais visuel (`tool/visual_test/`) peut générer des bases
propres en fr/en/es.
