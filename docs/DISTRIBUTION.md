# Distribution — de la beta QR aux stores

Ce guide couvre le chemin complet : signature release Android, Play Store,
iOS/App Store. Les textes prêts à coller sont dans
[STORE-LISTING.md](./STORE-LISTING.md).

**État actuel**
- ✅ Beta Android par QR (release GitHub, APK signé debug → release dès que la clé existe)
- ✅ Pages légales publiées : https://admin-rayv.github.io/app-voyage/
- ✅ CI iOS : vérifie que l'app compile pour iPhone (sans signature)
- ⏳ Clé de signature release ← **prochaine action (Pierre, ~15 min)**
- ⏳ Comptes développeur Google (25 $ US, une fois) et Apple (99 $ US/an)

---

## 1. La clé de signature Android (à faire une fois, ~15 min)

La clé prouve que chaque mise à jour vient bien de nous. **Si elle est
perdue, il devient impossible de mettre à jour l'app sur le Play Store** —
sauvegarde-la (gestionnaire de mots de passe + copie hors ligne).

### Générer la clé (sur ton ordinateur)

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
# Choisis un mot de passe fort (le même pour store et key, plus simple),
# nom: Pierre Raymond, organisation: Rayv, ville/province/pays.
```

> `keytool` vient avec Java/Android Studio. Sur Mac :
> `brew install openjdk` le fournit aussi.

### Donner la clé au CI (secrets GitHub)

Dans le repo GitHub → Settings → Secrets and variables → Actions →
« New repository secret », créer **4 secrets** :

| Secret | Valeur |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | le fichier encodé : `base64 -i upload-keystore.jks \| pbcopy` (Mac) ou `base64 -w0 upload-keystore.jks` (Linux) |
| `ANDROID_KEYSTORE_PASSWORD` | mot de passe du keystore |
| `ANDROID_KEY_ALIAS` | `upload` |
| `ANDROID_KEY_PASSWORD` | mot de passe de la clé |

C'est tout : au prochain build, le CI détecte les secrets et signe en
release automatiquement (voir `build-apk.yml`). Sans secrets, il retombe
sur la signature debug — rien ne casse.

⚠️ **Transition beta** : un APK release ne s'installe pas « par-dessus » un
APK debug (signatures différentes). Les testeurs actuels devront
désinstaller/réinstaller une fois. À faire avant d'élargir la beta.

### Build local signé (optionnel)

Créer `android/key.properties` (jamais commité — déjà dans .gitignore) :

```properties
storeFile=../upload-keystore.jks
storePassword=***
keyAlias=upload
keyPassword=***
```

---

## 2. Google Play (quand le cœur du produit est validé)

1. **Compte** : https://play.google.com/console — 25 $ US, une fois.
   Vérification d'identité requise (quelques jours).
2. **Fiche** : textes et réponses « sécurité des données » prêts dans
   [STORE-LISTING.md](./STORE-LISTING.md); captures à produire.
3. **Localisation en arrière-plan** : formulaire de déclaration + vidéo de
   ~30 s (texte prêt dans STORE-LISTING.md). C'est le point de contrôle le
   plus strict de Google — notre usage (guide audio géolocalisé) est un cas
   d'école légitime.
4. **Test fermé obligatoire** : les nouveaux comptes personnels doivent
   faire tester l'app par **12 testeurs pendant 14 jours** avant d'accéder
   à la production. À anticiper : famille, amis, voisins de Saint-Lambert.
5. **Format** : le Play Store veut un **App Bundle** (`flutter build
   appbundle`), pas un APK. Le jour venu, ajouter au workflow :
   `flutter build appbundle --release` et téléverser le `.aab`.

---

## 3. iOS / App Store

1. **Le CI compile déjà pour iPhone** (`build-ios.yml`,
   `--no-codesign`) : les régressions de compilation iOS sont détectées à
   chaque merge. La logique Flutter est partagée; ce qui reste à valider
   sur un vrai iPhone : GPS arrière-plan, audio en background, permissions.
2. **Compte Apple Developer** : https://developer.apple.com — 99 $ US/an.
3. **Build signé** : exige un Mac (Xcode) ou un service de build en nuage
   (Codemagic a un palier gratuit qui suffit pour commencer; GitHub
   Actions macOS fonctionne aussi avec les certificats en secrets).
4. **TestFlight** : l'équivalent Apple de notre QR — beta jusqu'à
   10 000 testeurs via un simple lien.
5. **Revue App Store** : notes pour l'équipe de revue prêtes dans
   STORE-LISTING.md (justification GPS arrière-plan + comment tester).
   `Info.plist` contient déjà les textes de permission et les
   UIBackgroundModes (audio + location).

---

## 4. Pages légales (fait ✅)

Publiées automatiquement depuis `legal/` par `.github/workflows/deploy-pages.yml` :

- Accueil / soutien : https://admin-rayv.github.io/app-voyage/
- Confidentialité : https://admin-rayv.github.io/app-voyage/confidentialite.html
- Conditions : https://admin-rayv.github.io/app-voyage/conditions.html

Ces URLs sont celles à coller dans les fiches des deux stores. Si le
contenu de l'app change (analytics, comptes, paiements), **mettre à jour la
politique d'abord**.

---

## Ordre recommandé

1. Générer la clé + secrets (15 min, dès maintenant si tu veux)
2. Sprint 4 terrain → itérer
3. Compte Google Play + captures + vidéo → test fermé (12 testeurs / 14 j)
4. En parallèle : compte Apple + premier build TestFlight
5. Production Play → App Store
