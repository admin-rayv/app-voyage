# 🔍 POIs trouvés: Sainte-Julie — histoire
> Date: 2026-11-20
> City ID: À CRÉER
> City: Sainte-Julie / Sainte-Julie
> Coordonnées centre: 45.5930624, -73.3395943
> Pays: CA | Région: Montérégie
> Status: EN ATTENTE DE VALIDATION

**Méthode :** sources officielles en priorité : Répertoire du patrimoine culturel du Québec (RPCQ, fiches de l'inventaire MRC de Marguerite-D'Youville 2014, qui citent Odette Lemerise, *Sainte-Julie et ses demeures d'antan*) et site de la Ville de Sainte-Julie (histoire, portail des archives). GPS tiré des fiches RPCQ quand elles existent, sinon Nominatim (geocode.py).

**Note :** la plupart de ces bâtiments sont des **résidences privées**. Les scripts devront inviter à regarder depuis le trottoir.

---

## POI 1: Église de Sainte-Julie
- 📍 **GPS:** 45.592833, -73.339139 (exacte, fiche RPCQ)
- 🏠 **Adresse:** 1686, rue Principale, Sainte-Julie, QC
- 🏷️ **Catégories:** histoire, architecture
- 🏛️ **Type:** church
- 📏 **Rayon déclenchement:** 40m
- 💡 **Hook:** Toute la ville est née ici. En 1848, une veuve, Julie Gauthier dite Saint-Germain, donne le terrain de la chapelle à condition que la paroisse porte le nom de sa sainte patronne. C'est pour ça que la ville s'appelle Sainte-Julie.
- 📖 **Anecdote:** L'église actuelle (1901-1902, architecte Georges-Alphonse Monette) a été bâtie en partie sur l'ancien cimetière, ce qui a obligé à déplacer des sépultures. Les plans d'origine prévoyaient un transept, des rosaces et un chevet arrondi, mais ils ont été simplifiés parce que trop chers. Inaugurée le 30 novembre 1902, elle abrite un tableau d'Ozias Leduc, *Le martyre de sainte Julie*. Citée immeuble patrimonial par la Ville le 15 mai 2024 ; le presbytère voisin (1893, architecte Alfred Préfontaine) a reçu le même statut en novembre 2026.
- 📚 **Source:** https://www.patrimoine-culturel.gouv.qc.ca/rpcq/detail.do?methode=consulter&id=124811&type=bien ; https://saintejulie.ca/profil-et-histoire/histoire-de-la-ville ; https://saintejulie.ca/la-ville/decouvrir-la-ville/portail-de-la-ville/religion ; http://lareleve.qc.ca/2026/11/03/presbytere-cite-immeuble-patrimonial-eglise-sainte-julie-classee-a/
- ⚠️ **À vérifier (checker):** La Relève dit l'église « classée A par Québec », ce que la fiche RPCQ ne montre pas. Dates de la chapelle : 1848 (Ville) ou 1849 selon d'autres sources. Ne pas confondre avec « 1686 », qui est l'adresse.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Église de Sainte-Julie", "en": "Sainte-Julie Church"},
  "lat": 45.592833,
  "lng": -73.339139,
  "trigger_radius_m": 40,
  "type": "church",
  "categories": ["histoire", "architecture"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": "Depuis le trottoir d'en face, rue Principale, pour avoir le clocher et la façade en entier",
    "tips": "L'église est un lieu de culte actif : intérieur accessible surtout autour des messes"
  }
}
```

## POI 2: Ancienne école du village (Couvent Saint-Joseph)
- 📍 **GPS:** 45.593611, -73.338889 (exacte, fiche RPCQ)
- 🏠 **Adresse:** 611, boulevard Saint-Joseph, Sainte-Julie, QC
- 🏷️ **Catégories:** histoire, architecture
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 40m
- 💡 **Hook:** L'école du village de 1920, où les classes étaient au rez-de-chaussée et les institutrices logeaient à l'étage. De 1944 à 1958, elle devient le Couvent Saint-Joseph, tenu par les religieuses de Saint-Joseph de Saint-Hyacinthe.
- 📖 **Anecdote:** Le petit clocheton sur le toit est plus vieux que l'école : il date de 1884 et vient de l'école précédente. Et la cloche du village a voyagé : elle a sonné sur la chapelle de 1852 à 1902, a été prêtée à l'école en 1904 et y est restée jusqu'en 1964, avant d'être installée au clocher de l'église en 1971. En 1985, les marguilliers ont refusé de la rendre à l'ancien propriétaire de l'école.
- 📚 **Source:** https://www.patrimoine-culturel.gouv.qc.ca/rpcq/detail.do?methode=consulter&id=201258&type=bien ; https://saintejulie.ca/la-ville/decouvrir-la-ville/portail-de-la-ville/religion
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Ancienne école du village", "en": "Former Village School"},
  "lat": 45.593611,
  "lng": -73.338889,
  "trigger_radius_m": 40,
  "type": "building",
  "categories": ["histoire", "architecture"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": "Face au bâtiment sur le boulevard Saint-Joseph, en cadrant le clocheton",
    "tips": "Levez les yeux vers le clocheton de 1884"
  }
}
```

## POI 3: Premier presbytère
- 📍 **GPS:** 45.5926275, -73.3403984 (Nominatim ; la fiche RPCQ donne le même point que le 1718)
- 🏠 **Adresse:** 1724, rue Principale, Sainte-Julie, QC
- 🏷️ **Catégories:** histoire
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 30m
- 💡 **Hook:** La maison du premier curé de Sainte-Julie, construite en 1850. Elle ne se trouvait pas ici : elle se dressait à l'emplacement de l'église actuelle.
- 📖 **Anecdote:** Quand un presbytère plus prestigieux est construit en 1893, l'ancien est vendu aux enchères le 22 avril 1894 et déplacé « section par section » jusqu'ici. Son premier occupant, l'abbé Joseph-Narcisse Théoret, arrivé en 1852, est mort en 1876 et a été inhumé dans le caveau de la première église.
- 📚 **Source:** https://www.patrimoine-culturel.gouv.qc.ca/rpcq/detail.do?methode=consulter&id=202061&type=bien ; https://saintejulie.ca/la-ville/decouvrir-la-ville/portail-de-la-ville/religion ; https://saintejulie.ca/la-ville/decouvrir-la-ville/portail-de-la-ville
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Premier presbytère", "en": "First Rectory"},
  "lat": 45.5926275,
  "lng": -73.3403984,
  "trigger_radius_m": 30,
  "type": "building",
  "categories": ["histoire"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Résidence privée : à admirer depuis le trottoir"
  }
}
```

## POI 4: Maison du sacristain (Maison de l'Entraide)
- 📍 **GPS:** 45.5927251, -73.3402523 (Nominatim)
- 🏠 **Adresse:** 1718, rue Principale, Sainte-Julie, QC
- 🏷️ **Catégories:** histoire
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 30m
- 💡 **Hook:** Construite en 1866 par la Fabrique pour loger le sacristain et sa famille. Depuis 1977, elle abrite la Maison de l'Entraide : la maison de l'Église est devenue celle de l'entraide.
- 📖 **Anecdote:** La donation de Julie Gauthier, en 1848, prévoyait déjà une maison pour le bedeau. Le premier bedeau, François Bessette, entre en fonction le 1er février 1852. La maison a été agrandie en 1904, puis encore en 1977 avec un entrepôt à l'arrière.
- 📚 **Source:** https://www.patrimoine-culturel.gouv.qc.ca/rpcq/detail.do?methode=consulter&id=124822&type=bien ; https://saintejulie.ca/profil-et-histoire/histoire-de-la-ville
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Maison du sacristain", "en": "Sexton's House"},
  "lat": 45.5927251,
  "lng": -73.3402523,
  "trigger_radius_m": 30,
  "type": "building",
  "categories": ["histoire"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Organisme communautaire en activité : respecter les usagers"
  }
}
```

## POI 5: Magasin Morin
- 📍 **GPS:** 45.5935026, -73.3394733 (Nominatim)
- 🏠 **Adresse:** 1693, rue Principale, Sainte-Julie, QC
- 🏷️ **Catégories:** histoire
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 30m
- 💡 **Hook:** En face de l'église, le premier magasin général « de grande envergure » du village, construit en 1894. L'édifice d'origine est toujours debout.
- 📖 **Anecdote:** À l'époque, le village vivait autour de l'église : magasins généraux, forges, beurrerie, hôtel. Le magasin Morin était le gros joueur, à quelques pas de la messe du dimanche.
- 📚 **Source:** https://saintejulie.ca/la-ville/decouvrir-la-ville/portail-de-la-ville/patrimoine-immobilier
- ⚠️ **À vérifier (checker):** la page de la Ville dit que la bâtisse « change d'enseigne et devient le magasin Borduas », mais décrit ensuite le magasin Borduas au 1668, rue Saint-Louis. Confirmer que le bâtiment existe encore.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Magasin Morin", "en": "Morin General Store"},
  "lat": 45.5935026,
  "lng": -73.3394733,
  "trigger_radius_m": 30,
  "type": "building",
  "categories": ["histoire"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": "Depuis le parvis de l'église, en face",
    "tips": null
  }
}
```

## POI 6: Hôtel du village
- 📍 **GPS:** 45.594702, -73.337392 (Nominatim)
- 🏠 **Adresse:** 1600, rue Principale, Sainte-Julie, QC
- 🏷️ **Catégories:** histoire
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 40m
- 💡 **Hook:** L'hôtel du village, apparu vers 1890 après des demandes de licence en 1880 et 1885. Incendié en 1927, reconstruit, puis transformé en complexe commercial en 1984.
- 📖 **Anecdote:** Dans les années 1950, l'hôtel avait une réputation agitée : désordres signalés en 1952, 1954 et 1956, au point qu'en 1954 on fait appel à la Sûreté provinciale pour maintenir l'ordre.
- 📚 **Source:** https://saintejulie.ca/la-ville/decouvrir-la-ville/portail-de-la-ville/patrimoine-immobilier ; https://saintejulie.ca/profil-et-histoire/circuit-patrimonial
- ⚠️ **À vérifier (checker):** l'adresse 1600 vient du titre de la photo du circuit patrimonial, pas du texte.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Hôtel du village", "en": "Village Hotel"},
  "lat": 45.594702,
  "lng": -73.337392,
  "trigger_radius_m": 40,
  "type": "building",
  "categories": ["histoire"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Aujourd'hui un immeuble commercial"
  }
}
```

## POI 7: Maison du docteur (ancienne beurrerie)
- 📍 **GPS:** 45.593158, -73.3399709 (Nominatim)
- 🏠 **Adresse:** 1715-1717, rue Principale, Sainte-Julie, QC
- 🏷️ **Catégories:** histoire
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 30m
- 💡 **Hook:** Avant d'être la maison du docteur, c'était la première beurrerie-fromagerie du village, ouverte à l'été 1881 par 13 citoyens actionnaires.
- 📖 **Anecdote:** Le terrain a été donné aux actionnaires par Louis Blain père le 6 octobre 1880. En 1903, la beurrerie est vendue 1 800 $ au docteur Jodoin ; sa veuve garde la maison jusqu'en 1949.
- 📚 **Source:** https://saintejulie.ca/profil-et-histoire/histoire-de-la-ville ; https://saintejulie.ca/la-ville/decouvrir-la-ville/portail-de-la-ville/patrimoine-immobilier ; https://saintejulie.ca/profil-et-histoire/circuit-patrimonial
- ⚠️ **À vérifier (checker):** confirmer que la « maison du docteur » du circuit (1715-1717) est bien le bâtiment de l'ancienne beurrerie (lot 285).
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Maison du docteur", "en": "The Doctor's House"},
  "lat": 45.593158,
  "lng": -73.3399709,
  "trigger_radius_m": 30,
  "type": "building",
  "categories": ["histoire"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Résidence privée : à admirer depuis le trottoir"
  }
}
```

## POI 8: Les maisons jumelles (téléphone et électricité)
- 📍 **GPS:** 45.5938544, -73.3386129 (point suggéré, entre le 1660 et le 1664)
- 🏠 **Adresse:** 1660 et 1664, rue Principale, Sainte-Julie, QC
- 🏷️ **Catégories:** histoire, insolite
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 30m
- 💡 **Hook:** Deux maisons voisines où la modernité est entrée au village : dans les années 1890, une petite centrale téléphonique s'installe dans la résidence du 1660 ; de décembre 1920 à 1929, « La Lumière électrique » produit l'électricité du village au 1664.
- 📖 **Anecdote:** Avant l'électricité, le village s'éclairait au gaz : en octobre 1912, la municipalité installe six becs de gaz publics, dont un devant l'hôtel de ville et un devant la banque. L'électricien Émile Lapointe obtient ensuite un privilège de 25 ans en 1921.
- 📚 **Source:** https://saintejulie.ca/la-ville/decouvrir-la-ville/portail-de-la-ville/patrimoine-immobilier ; https://saintejulie.ca/la-ville/decouvrir-la-ville/portail-de-la-ville ; https://saintejulie.ca/profil-et-histoire/circuit-patrimonial
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Les maisons jumelles", "en": "The Twin Houses"},
  "lat": 45.5938544,
  "lng": -73.3386129,
  "trigger_radius_m": 30,
  "type": "building",
  "categories": ["histoire", "insolite"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": "Depuis le trottoir d'en face, pour cadrer les deux maisons ensemble",
    "tips": "Résidences privées : à admirer depuis le trottoir"
  }
}
```

## POI 9: Maison du forgeron
- 📍 **GPS:** 45.5935, -73.339833 (exacte, fiche RPCQ)
- 🏠 **Adresse:** 618, montée Sainte-Julie, Sainte-Julie, QC
- 🏷️ **Catégories:** histoire
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 30m
- 💡 **Hook:** Vers 1860, le forgeron Louis Sénécal choisit ce coin pour y installer sa forge, à l'entrée du village. Pendant 40 ans, on y a ferré les chevaux.
- 📖 **Anecdote:** En 1870, il vend tout à un autre forgeron, François-Xavier Robidoux, qui garde la forge jusqu'en 1902. La vente de la maison cette année-là met fin aux activités de forge sur ce site.
- 📚 **Source:** https://www.patrimoine-culturel.gouv.qc.ca/rpcq/detail.do?methode=consulter&id=201251&type=bien
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Maison du forgeron", "en": "The Blacksmith's House"},
  "lat": 45.5935,
  "lng": -73.339833,
  "trigger_radius_m": 30,
  "type": "building",
  "categories": ["histoire"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Résidence privée : à admirer depuis le trottoir"
  }
}
```

## POI 10: Magasin général Malo
- 📍 **GPS:** 45.593722, -73.340139 (exacte, fiche RPCQ)
- 🏠 **Adresse:** 630, montée Sainte-Julie, Sainte-Julie, QC
- 🏷️ **Catégories:** histoire
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 30m
- 💡 **Hook:** Le premier magasin général du village, construit entre 1858 et 1861 par le marchand Léon Malo. Une moitié de la maison servait de logement, l'autre de magasin.
- 📖 **Anecdote:** Un agrandissement a probablement changé la pente du toit : si la silhouette semble un peu inhabituelle, c'est pour ça.
- 📚 **Source:** https://www.patrimoine-culturel.gouv.qc.ca/rpcq/detail.do?methode=consulter&id=201252&type=bien ; https://saintejulie.ca/la-ville/decouvrir-la-ville/portail-de-la-ville/patrimoine-immobilier
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Magasin général Malo", "en": "Malo General Store"},
  "lat": 45.593722,
  "lng": -73.340139,
  "trigger_radius_m": 30,
  "type": "building",
  "categories": ["histoire"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Résidence privée : à admirer depuis le trottoir"
  }
}
```

## POI 11: La maison déménagée du maire Comtois
- 📍 **GPS:** 45.593972, -73.340417 (exacte, fiche RPCQ)
- 🏠 **Adresse:** 637, montée Sainte-Julie, Sainte-Julie, QC
- 🏷️ **Catégories:** histoire, insolite
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 30m
- 💡 **Hook:** Une maison construite avant 1861… ailleurs. Elle se trouvait sur la rue Principale, près du chemin du Fer-à-Cheval, et a été déménagée ici en 1953.
- 📖 **Anecdote:** De 1908 à 1939, c'était la maison du maire Louis Comtois. À Sainte-Julie, déménager une maison n'avait rien d'exceptionnel : le premier presbytère, la maison du 913, chemin du Fer-à-Cheval et un camp de bûcherons de la Gatineau ont tous fait le voyage.
- 📚 **Source:** https://www.patrimoine-culturel.gouv.qc.ca/rpcq/detail.do?methode=consulter&id=201253&type=bien
- ⚠️ **À vérifier (checker):** le circuit patrimonial titre aussi une photo « 711 — La maison Comtois ». Vérifier qu'il n'y a pas deux maisons Comtois.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "La maison déménagée", "en": "The House That Moved"},
  "lat": 45.593972,
  "lng": -73.340417,
  "trigger_radius_m": 30,
  "type": "building",
  "categories": ["histoire", "insolite"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Résidence privée : à admirer depuis le trottoir"
  }
}
```

## POI 12: La poste vagabonde
- 📍 **GPS:** 45.594111, -73.340611 (exacte, fiche RPCQ du 645)
- 🏠 **Adresse:** 645, montée Sainte-Julie (et 654, juste en face), Sainte-Julie, QC
- 🏷️ **Catégories:** histoire, insolite
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 40m
- 💡 **Hook:** Au village, le bureau de poste n'avait pas d'adresse fixe : il déménageait chez le maître de poste. Le 645 l'a accueilli deux fois, de 1913 à 1922, puis de 1950 à 1955.
- 📖 **Anecdote:** Entre-temps, le comptoir postal est passé au 654, juste en face (1923-1925), une maison de 1907 où ont vécu deux maires, Joseph-Antoine Morin et Armand Savaria. De 1955 à 1960, il loge au 913, chemin du Fer-à-Cheval. Le premier bureau de poste de Sainte-Julie avait été ouvert en 1854 par Honoré Provost.
- 📚 **Source:** https://www.patrimoine-culturel.gouv.qc.ca/rpcq/detail.do?methode=consulter&id=201254&type=bien ; https://www.patrimoine-culturel.gouv.qc.ca/rpcq/detail.do?methode=consulter&id=201255&type=bien ; https://www.patrimoine-culturel.gouv.qc.ca/rpcq/detail.do?methode=consulter&id=201245&type=bien ; https://saintejulie.ca/profil-et-histoire/histoire-de-la-ville
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "La poste vagabonde", "en": "The Wandering Post Office"},
  "lat": 45.594111,
  "lng": -73.340611,
  "trigger_radius_m": 40,
  "type": "building",
  "categories": ["histoire", "insolite"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Le 645 est aujourd'hui un commerce ; le 654, en face, est une résidence privée"
  }
}
```

## POI 13: La maison poussée par un stationnement
- 📍 **GPS:** 45.603583, -73.327944 (exacte, fiche RPCQ)
- 🏠 **Adresse:** 913, chemin du Fer-à-Cheval, Sainte-Julie, QC
- 🏷️ **Catégories:** histoire, insolite
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 40m
- 💡 **Hook:** Construite entre 1913 et 1916 sur la rue Principale, cette maison a été déménagée ici en 1976 parce que sa voisine, la Caisse populaire, voulait agrandir son stationnement.
- 📖 **Anecdote:** Elle a aussi fait partie de la tournée de la poste : de 1955 à 1960, c'est elle qui logeait le comptoir postal du village.
- 📚 **Source:** https://www.patrimoine-culturel.gouv.qc.ca/rpcq/detail.do?methode=consulter&id=201245&type=bien
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "La maison du 913, Fer-à-Cheval", "en": "The House on Fer-à-Cheval"},
  "lat": 45.603583,
  "lng": -73.327944,
  "trigger_radius_m": 40,
  "type": "building",
  "categories": ["histoire", "insolite"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Résidence privée sur une artère passante : mieux en vélo ou en voiture"
  }
}
```

## POI 14: Maison Savaria
- 📍 **GPS:** 45.596778, -73.328389 (exacte, fiche RPCQ)
- 🏠 **Adresse:** 1100, chemin du Fer-à-Cheval, Sainte-Julie, QC
- 🏷️ **Catégories:** histoire, architecture
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 40m
- 💡 **Hook:** Les Savaria possèdent ces terres depuis 1862, et la maison appartient toujours à la famille. Le nom revient partout à Sainte-Julie : l'hôtel de ville (Centre municipal Louis-Armand-Savaria), la salle de spectacle Maurice-Savaria, la rue Savaria.
- 📖 **Anecdote:** La maison à mansarde actuelle a été construite en 1923 pour Joseph Savaria par Sigsmond Brunelle, charpentier de Sainte-Julie, à la place d'une première maison de 1850. Un maire, Armand Savaria, a aussi habité au 654, montée Sainte-Julie.
- 📚 **Source:** https://www.patrimoine-culturel.gouv.qc.ca/rpcq/detail.do?methode=consulter&id=201244&type=bien ; https://saintejulie.ca/profil-et-histoire/histoire-de-la-ville
- ⚠️ **À vérifier (checker):** liens de parenté entre Joseph, Armand, Louis-Armand et Maurice Savaria non établis. Ne pas les affirmer dans le script.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Maison Savaria", "en": "Savaria House"},
  "lat": 45.596778,
  "lng": -73.328389,
  "trigger_radius_m": 40,
  "type": "building",
  "categories": ["histoire", "architecture"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Résidence privée : mieux en vélo ou en voiture"
  }
}
```

## POI 15: Le camp de bûcherons de la Gatineau
- 📍 **GPS:** 45.562426, -73.3221787 (Nominatim ; la fiche RPCQ a une faute de latitude, 43° au lieu de 45°)
- 🏠 **Adresse:** 130, rue Bellevue, Sainte-Julie, QC
- 🏷️ **Catégories:** histoire, insolite
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 40m
- 💡 **Hook:** Une maison en bois pièce sur pièce construite entre 1900 et 1920… dans la vallée de la Gatineau, comme poste de bûcherons. Elle a été démontée, vendue et reconstruite ici en 1976.
- 📖 **Anecdote:** C'est un certain monsieur Pichet, de Sainte-Agathe-des-Monts, qui l'a démontée. Le toit à croupes a été refait lors de la reconstruction.
- 📚 **Source:** https://www.patrimoine-culturel.gouv.qc.ca/rpcq/detail.do?methode=consulter&id=201243&type=bien
- ⚠️ **À vérifier (checker):** la seule source de la fiche est « le propriétaire actuel ».
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Le camp de bûcherons", "en": "The Lumberjack Camp"},
  "lat": 45.562426,
  "lng": -73.3221787,
  "trigger_radius_m": 40,
  "type": "building",
  "categories": ["histoire", "insolite"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Résidence privée dans un secteur résidentiel : à admirer depuis la rue"
  }
}
```

## POI 16: Maison de 1830, chemin de la Belle-Rivière
- 📍 **GPS:** 45.609306, -73.369833 (exacte, fiche RPCQ)
- 🏠 **Adresse:** 1891, chemin de la Belle-Rivière, Sainte-Julie, QC
- 🏷️ **Catégories:** histoire, architecture
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 60m
- 💡 **Hook:** Construite vers 1830, cette maison est plus vieille que la paroisse elle-même (1850-1851). C'est la plus ancienne date de construction de l'inventaire patrimonial de Sainte-Julie.
- 📖 **Anecdote:** À l'époque, il n'y avait ni église ni village ici : seulement des terres agricoles le long des rangs. Vers 1900, on lui a ajouté une lucarne-pignon et un agrandissement ; le garage, bâti entre 1952 et 1976, est devenu un espace habitable.
- 📚 **Source:** https://www.patrimoine-culturel.gouv.qc.ca/rpcq/detail.do?methode=consulter&id=201242&type=bien
- ⚠️ **À vérifier (checker):** la fiche dit « aurait été construite en 1830 » ; le script doit garder ce conditionnel. « Plus ancienne de l'inventaire » vaut pour les fiches RPCQ lues, pas forcément pour toute la ville.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Maison de la Belle-Rivière", "en": "Belle-Rivière House"},
  "lat": 45.609306,
  "lng": -73.369833,
  "trigger_radius_m": 60,
  "type": "building",
  "categories": ["histoire", "architecture"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Résidence privée en zone rurale : POI pensé pour le vélo ou la voiture"
  }
}
```

---

## Écartés (et pourquoi)
| Lieu | Raison |
|------|--------|
| Remise à grains de Lionel Pepin (effondrement du 28 déc. 1929, 4 jeunes morts) | Bâtiment disparu ; histoire forte → à reconsidérer en **insolite** |
| Écrasement d'un CF-100 sur une maison (1968) et d'un Vampire (1953) | Lieux imprécis → à reconsidérer en **insolite** |
| Hôtel de ville (Centre Louis-Armand-Savaria, ancien édifice industriel) | Plus pertinent en **vie-locale** |
| Parc de l'Abbé-Théoret | Histoire de l'abbé intégrée au POI 3 |
| Presbytère de 1893 | Adresse et GPS non confirmés ; intégré au POI 1 |
| 1315 et 1360, rang de la Vallée ; 1361, Belle-Rivière ; 670, montée Sainte-Julie | Aucune histoire à raconter dans les sources |

---
**Total:** 16 POIs trouvés
**Fichier:** content/sainte-julie-quebec-canada/scout-histoire.md
