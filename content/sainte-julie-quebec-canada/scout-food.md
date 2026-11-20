# 🔍 POIs trouvés: Sainte-Julie — food
> Date: 2026-11-20
> City ID: 9ed9f927-ed8e-4d9c-bcab-55c489de1555
> City: Sainte-Julie / Sainte-Julie
> Coordonnées centre: 45.593062, -73.339594
> Pays: CA | Région: Montérégie
> Status: EN ATTENTE DE VALIDATION

**Méthode :** deux types de POIs. (1) L'histoire alimentaire du village, tirée des archives de la Ville et de la toponymie. (2) Des commerces actuels, retenus seulement s'ils sont **ouverts en 2026** (preuve datée) et ont une **histoire documentée** (site officiel, presse locale). Les chaînes sont exclues.

**Doublons :** aucun avec les 21 POIs déjà en BD. La Coop (1590) est à environ 35 m de l'Hôtel du village (POI histoire, 1600) : déclenchements voisins, gérés par la file d'attente de l'app.

---

## POI 1: La Coop Ste-Julie (ancienne boulangerie du village)
- 📍 **GPS:** 45.5950127, -73.3371638 (Nominatim, 1590 rue Principale)
- 🏠 **Adresse:** 1590, rue Principale, Sainte-Julie, QC (aujourd'hui BMR, Agiska Coopérative)
- 🏷️ **Catégories:** food, histoire
- 🏛️ **Type:** shop
- 📏 **Rayon déclenchement:** 40m
- 💡 **Hook:** Une coopérative née en 1943 sous le nom de Syndicat avicole Ste-Julie, qui a racheté la boulangerie du village, sa concurrente directe. Le pain se cuisait là où se trouve aujourd'hui le stationnement.
- 📖 **Anecdote:** La boulangerie, un bâtiment de bois de 20 pieds sur 35, vendait aussi de la moulée et des grains pour les animaux ; elle a été démolie au début des années 1960 avec la maison du boulanger. La Coop ajoute un magasin général en 1945, une meunerie en 1956 (fermée en 1989, remplacée par une quincaillerie), un centre de jardin en 1974. Elle fusionne avec La Coop Comax le 25 novembre 2017, aujourd'hui Agiska Coopérative.
- 📚 **Source:** https://saintejulie.ca/la-ville/decouvrir-la-ville/portail-de-la-ville/patrimoine-immobilier (section Coop) ; http://web.archive.org/web/20220128061326/https://www.comax.coop/nouvelles/92-fusion-entre-la-coop-comax-et-la-coop-ste-julie.html ; https://www.shopping-canada.com/stores-brands/bmr/quebec/ste-julie/bmr-agiska-cooperative-ste-julie
- 🔎 **À vérifier (checker):** la Ville situe la Coop « au milieu du siècle dernier » sur l'avenue Jules-Choquet ; la Coop actuelle est au 1590, rue Principale, et le circuit patrimonial associe le 1590 à « La boulangerie » et « La Coop ». Confirmer que le stationnement visé est bien celui du 1590.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "La Coop Ste-Julie", "en": "La Coop Ste-Julie"},
  "lat": 45.5950127,
  "lng": -73.3371638,
  "trigger_radius_m": 40,
  "type": "shop",
  "categories": ["food", "histoire"],
  "image_url": null,
  "logistics": {
    "parking": "Stationnement de la Coop (BMR)",
    "toilets": null,
    "photo_spot": null,
    "tips": "Aujourd'hui une quincaillerie BMR : l'histoire se raconte surtout au stationnement, où se trouvait la boulangerie"
  }
}
```

## POI 2: Le petit marché de Sainte-Julie
- 📍 **GPS:** 45.5925495, -73.3375277 (Nominatim, 550 boul. Saint-Joseph ; la Ville situe le marché « dans le passage entre l'église et le presbytère, à proximité du 550 »)
- 🏠 **Adresse:** passage entre l'église et le presbytère, près du 550, boulevard Saint-Joseph, Sainte-Julie, QC
- 🏷️ **Catégories:** food, vie-locale
- 🏛️ **Type:** shop
- 📏 **Rayon déclenchement:** 60m
- 💡 **Hook:** L'été, tous les jeudis de 16 h à 19 h, plus d'une vingtaine de producteurs et marchands s'installent entre l'église et le presbytère, en plein Vieux-Village.
- 📖 **Anecdote:** Lancé en 2014 comme projet pilote de marché public, il est rebaptisé « Le petit marché » en 2021. En 2026, pour sa 12e édition et le 175e anniversaire de la ville, on pouvait y monter à bord du Julie-Express pour une balade historique dans le Vieux-Village. Prestations musicales et produits à déguster chaque semaine.
- 📚 **Source:** https://saintejulie.ca/actualites/2026/06/22/le-petit-marche-de-sainte-julie-est-de-retour-tous-les-jeudis-des-le-2-juillet ; https://lareleve.qc.ca/2014/03/16/des-projets-pilotes-de-marche-public-et-de-retablissement-automatique-du-service-delectricite-a-sainte-julie/ ; https://lareleve.qc.ca/2021/06/25/le-marche-public-de-sainte-julie-de-retour-avec-un-nouveau-nom-et-de-nombreux-produits-frais/
- 🔎 **À vérifier (checker):** POI saisonnier. Le script ne doit pas promettre de dates précises pour les années futures (« Programmation 2027 à venir »).
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Le petit marché", "en": "Le petit marché (farmers' market)"},
  "lat": 45.5925495,
  "lng": -73.3375277,
  "trigger_radius_m": 60,
  "type": "shop",
  "categories": ["food", "vie-locale"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": "Les étals avec l'église en arrière-plan",
    "tips": "Saisonnier : les jeudis en fin de journée, de juillet à septembre (vérifier la programmation de la Ville)"
  }
}
```

## POI 3: Brûlerie Mlle Café
- 📍 **GPS:** 45.5937094, -73.3353263 (Nominatim, 509 avenue Jules-Choquet)
- 🏠 **Adresse:** 509, avenue Jules-Choquet, local i, Sainte-Julie, QC
- 🏷️ **Catégories:** food
- 🏛️ **Type:** restaurant
- 📏 **Rayon déclenchement:** 30m
- 💡 **Hook:** Une brûlerie fondée par une chanteuse : Caroline Riverin, originaire de Shipshaw au Saguenay, choriste avec ses sœurs pendant la tournée 50 World Tour de Lara Fabian. Ses mélanges portent des noms musicaux : Le Jazz, Le Blues, Le Jingle Bell.
- 📖 **Anecdote:** Membre fondatrice des spectacles Québec Issime (« Céline Dion à la Bolduc », « Cow-boys, de Willie à Dolly »…), elle cherchait le mélange parfait et a fini par torréfier elle-même. Tout est torréfié sur place. Lauréate du prix Commerce du Défi OSEntreprendre de la MRC en avril 2017 ; badge « Meilleur café 2025 » de Restaurant Guru.
- 📚 **Source:** https://mllecafe.com/a-propos/ ; https://mllecafe.com ; https://lareleve.qc.ca/2017/04/07/la-mrc-souligne-laudace-de-ses-entrepreneurs-locaux/
- 🔎 **À vérifier (checker):** le prix 2017 (article de La Relève lu par l'agent de recherche, non relu directement).
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Brûlerie Mlle Café", "en": "Brûlerie Mlle Café"},
  "lat": 45.5937094,
  "lng": -73.3353263,
  "trigger_radius_m": 30,
  "type": "restaurant",
  "categories": ["food"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Café à emporter préparé par les baristas sur place ; sacs de café en vente"
  }
}
```

## POI 4: La Broue Shop
- 📍 **GPS:** 45.575677, -73.3277075 (Nominatim, 1950 chemin du Fer-à-Cheval)
- 🏠 **Adresse:** 1950, chemin du Fer-à-Cheval (Les Halles du Domaine), Sainte-Julie, QC
- 🏷️ **Catégories:** food
- 🏛️ **Type:** restaurant
- 📏 **Rayon déclenchement:** 40m
- 💡 **Hook:** La brasserie artisanale de Guy Dubois, où l'on déguste des bières brassées sur place. Son but, selon La Relève : « donner une couleur brassicole à notre région ». Sur la carte, une ale blonde porte le nom de la ville : la Petite Julie.
- 📖 **Anecdote:** Lauréate du prix Commerce du Défi OSEntreprendre de la MRC de Marguerite-D'Youville le 7 avril 2016. La carte va de la Petite Julie (ale blonde, 4,8 %) au Noir comme la nuit, un stout impérial à 11 %.
- 📚 **Source:** https://lareleve.qc.ca/2016/04/11/sept-entreprises-de-la-mrc-de-marguerite-dyouville-accedent-au-niveau-regional/ ; https://www.broueshop.com/
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "La Broue Shop", "en": "La Broue Shop"},
  "lat": 45.575677,
  "lng": -73.3277075,
  "trigger_radius_m": 40,
  "type": "restaurant",
  "categories": ["food"],
  "image_url": null,
  "logistics": {
    "parking": "Stationnement des Halles du Domaine",
    "toilets": null,
    "photo_spot": null,
    "tips": "Palette de dégustation pour goûter plusieurs bières ; la carte change selon les brassins"
  }
}
```

## POI 5: Le verger de Joseph-Antoine Véronneau (parc Joseph-Véronneau)
- 📍 **GPS:** 45.5749853, -73.3201425 (Nominatim, parc Joseph-Véronneau)
- 🏠 **Adresse:** parc Joseph-Véronneau, 620, rue Charles-De Gaulle, Sainte-Julie, QC
- 🏷️ **Catégories:** food, histoire
- 🏛️ **Type:** park
- 📏 **Rayon déclenchement:** 60m
- 💡 **Hook:** Ici s'étendaient les terres du « plus beau verger de Sainte-Julie ». Joseph-Antoine Véronneau (1880-1960) livrait ses pommes dans un camion Ford 32 vert à ridelles, avec l'inscription « J-Véronneau Pomiculteur » sur la portière.
- 📖 **Anecdote:** Au temps de la cueillette, son fils passait dans les rangs vendre une partie des pommes ; le reste partait aux marchés de Montréal. Ses terres, son érablière et son verger sont devenus une partie du Domaine des Hauts-Bois. La Ville a nommé le parc en sa mémoire en 1977, et la rue en 1984.
- 📚 **Source:** https://saintejulie.ca/profil-et-histoire/toponymie (Joseph-Véronneau)
- 🔎 **À vérifier (checker):** la source dit que ses terres formaient « une partie du territoire du Domaine des Hauts-Bois », sans préciser que le verger était exactement à l'emplacement du parc. Le script doit rester prudent.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Parc Joseph-Véronneau", "en": "Joseph-Véronneau Park"},
  "lat": 45.5749853,
  "lng": -73.3201425,
  "trigger_radius_m": 60,
  "type": "park",
  "categories": ["food", "histoire"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Parc de quartier avec jeux d'eau (depuis 2018) et patinoire l'hiver"
  }
}
```

---

## Écartés (et pourquoi)
| Lieu | Raison |
|------|--------|
| Bar laitier du Capitaine Maboule (1950, Fer-à-Cheval) | Son site affiche « Fermé temporairement » sans date de retour. Belle histoire (glaces de Raymel Viciedo, technologue laitier arrivé de Cuba en 2013) : à reprendre s'il rouvre. |
| Restaurant Ste-Julie Pizzeria (1646, rue Principale) | Statut incertain (« peut être temporairement fermée »). Le lot accueillait la salle du conseil (dès 1901) et la Banque Provinciale : piste pour **vie-locale** ou **histoire**. |
| Quartier Gourmand (1791, rue Principale) | Ouvert, très bien noté, mais aucune histoire documentée (fondation, fondateurs) |
| Med Pizza (1668, rue Saint-Louis) | Simple emplacement de l'ancien magasin général Borduas (fermé en 1959) |
| Beurrerie Beauchemin (570, boul. Saint-Joseph, 1899) | Une seule ligne dans les sources |
| Jardins Deslauriers, Jardins du Grand Côteau, boulangeries Pascal et Du Pain & des Rêves | Statut 2026 ou histoire non confirmés |
| Station des bières et fromagerie | Fermée en 2025 |
| Chaînes (Normandin, Benny & Co., Ben & Florentine…) | Exclues |

---
**Total:** 5 POIs trouvés
**Fichier:** content/sainte-julie-quebec-canada/scout-food.md
