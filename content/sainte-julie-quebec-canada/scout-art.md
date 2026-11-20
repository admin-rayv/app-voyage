# 🔍 POIs trouvés: Sainte-Julie — art
> Date: 2026-11-20
> City ID: 9ed9f927-ed8e-4d9c-bcab-55c489de1555
> City: Sainte-Julie / Sainte-Julie
> Coordonnées centre: 45.593062, -73.339594
> Pays: CA | Région: Montérégie
> Status: EN ATTENTE DE VALIDATION

**Méthode :** recherche large d'emblée. Liste officielle du ministère de la Culture (Politique d'intégration des arts à l'architecture, Montérégie, 1961-2026 : 9 œuvres à Sainte-Julie), pages Vie culturelle de la Ville, toponymie (thèmes « peintres québécois » et « artistes québécois »).

**Déjà en BD :** le tableau d'Ozias Leduc, *Le martyre de sainte Julie*, est raconté dans le POI Église de Sainte-Julie.

---

## POI 1: La Spirale du savoir (bibliothèque)
- 📍 **GPS:** 45.587112, -73.326067 (OSM, bibliothèque, 1600 ch. du Fer-à-Cheval)
- 🏠 **Adresse:** bibliothèque municipale, 1600, chemin du Fer-à-Cheval, Sainte-Julie, QC (œuvre à l'intérieur)
- 🏷️ **Catégories:** art
- 🏛️ **Type:** museum
- 📏 **Rayon déclenchement:** 25m
- 💡 **Hook:** Sous le puits de lumière de la bibliothèque est suspendue « La Spirale du savoir », une sculpture en acrylique transparent d'Annie Thibault (2006) : une spirale de gouttes de rosée qui rappelle la structure de l'ADN.
- 📖 **Anecdote:** L'artiste s'est inspirée d'une ancienne théorie biologique selon laquelle la vie sur Terre viendrait de la dissémination de poussières d'étoiles, des spores de champignons. Ses « sporées », avec des dômes et des lentilles qui agissent comme des télescopes ou des microscopes selon le point de vue, invitent à relier l'infiniment grand et l'infiniment petit. L'œuvre a été réalisée dans le cadre de la Politique d'intégration des arts à l'architecture. La bibliothèque accueille aussi les expositions du Fonds du patrimoine artistique : créé en 1990, il permet à la Ville d'acheter une œuvre d'un artiste local chaque année ; une quarantaine d'œuvres sont exposées en permanence dans les bâtiments municipaux.
- 📚 **Source:** https://saintejulie.ca/sports-loisirs-et-culture/vie-culturelle/oeuvre-d-art-public ; https://saintejulie.ca/sports-loisirs-et-culture/vie-culturelle/expositions-du-fonds-du-patrimoine-artistique ; https://cdn-contenu.quebec.ca/cdn-contenu/adm/min/culture-communications/documents/oeuvres-art/LI-oeuvres-art-public-region-16.pdf (IA-16-331, intérieur)
- 🔎 **À vérifier (checker):** POI voisin de « Hôtel de ville et bibliothèque » (déjà en BD, vie-locale) : le script ne doit pas répéter l'histoire de la bibliothèque.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {
    "fr": "La Spirale du savoir",
    "en": "The Spiral of Knowledge"
  },
  "lat": 45.587112,
  "lng": -73.326067,
  "trigger_radius_m": 25,
  "type": "museum",
  "categories": [
    "art"
  ],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": "Sous le puits de lumière",
    "tips": "Œuvre à l'intérieur : entrer dans la bibliothèque pendant les heures d'ouverture"
  }
}
```

## POI 2: Le quartier des peintres
- 📍 **GPS:** 45.5788, -73.32135 (Nominatim, parc Jordi-Bonet ; rues Alfred-Pellan, Suzor-Coté, Marc-Aurèle-Fortin et Normand-Hudon à moins de 200 m)
- 🏠 **Adresse:** parc Jordi-Bonet et rues voisines, Sainte-Julie, QC
- 🏷️ **Catégories:** art
- 🏛️ **Type:** street
- 📏 **Rayon déclenchement:** 120m
- 💡 **Hook:** Un petit quartier où les rues portent les noms de grands peintres du Québec : Alfred Pellan, Marc-Aurèle Fortin, Suzor-Coté, Normand Hudon. Au centre, un parc dédié à Jordi Bonet, céramiste et muraliste né à Barcelone, qui a vécu plusieurs années à Mont-Saint-Hilaire, juste à côté.
- 📖 **Anecdote:** Jordi Bonet (1932-1979) arrive à Montréal en 1955 ; ses œuvres monumentales vont de Montréal à Québec, d'Ottawa à Toronto, de Vancouver au Japon et jusqu'au palais royal de Djeddah. Alfred Pellan (1906-1988) remporte en 1935 le premier prix du Salon de l'art mural de Paris et devient en 1955 le premier Canadien à exposer seul au Musée national d'art moderne. Suzor-Coté (1869-1937) voulait être chanteur : après une opération à la gorge, il se tourne vers la peinture et la sculpture. Marc-Aurèle Fortin (1888-1970) obtient une médaille de bronze à la foire mondiale de New York en 1939. Normand Hudon (1929-1997) a été caricaturiste au Devoir et à La Presse.
- 📚 **Source:** https://saintejulie.ca/profil-et-histoire/toponymie (Jordi-Bonet ; Alfred-Pellan ; Suzor-Coté ; Marc-Aurèle-Fortin ; Normand-Hudon)
- 🔎 **À vérifier (checker):** le thème officiel de la Ville est « peintres québécois » (Pellan, Bonet, Fortin, Hudon) ; Suzor-Coté est voisin mais sa fiche est tronquée sur le thème. « Musée national d'art moderne » : la source dit « Musée national de l'art moderne » (Paris, implicite).
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {
    "fr": "Le quartier des peintres",
    "en": "The Painters' Quarter"
  },
  "lat": 45.5788,
  "lng": -73.32135,
  "trigger_radius_m": 120,
  "type": "street",
  "categories": [
    "art"
  ],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Quartier résidentiel : à pied ou à vélo"
  }
}
```

## POI 3: Le quartier des artistes de la scène
- 📍 **GPS:** 45.58552, -73.34714 (Nominatim, parc Denise-Pelletier ; rues Olivier-Guimond, Jean-Duceppe, Guy-Sanche, Yoland-Guérard et Marcel-Gamache à moins de 250 m)
- 🏠 **Adresse:** parc Denise-Pelletier et rues voisines, Sainte-Julie, QC
- 🏷️ **Catégories:** art
- 🏛️ **Type:** street
- 📏 **Rayon déclenchement:** 130m
- 💡 **Hook:** Ici, les rues saluent les grandes figures de la scène et de la télé québécoises : Denise Pelletier, Olivier Guimond, Jean Duceppe, Marcel Gamache, Yoland Guérard… et Guy Sanche, le créateur de Bobino.
- 📖 **Anecdote:** Guy Sanche (1936-1988) a été Bobino pendant 26 ans à Radio-Canada, avec sa petite sœur la marionnette Bobinette, « championne de la poire à eau et des pétards à la farine » ; il a écrit plus de 5 000 textes. Olivier Guimond (1914-1971), fils des artistes de vaudeville Effie MacDonald et Olivier Guimond dit Ti-Zoune, devient en 1958 le comique le plus populaire du Québec, puis la vedette de Cré Basile. Denise Pelletier (1923-1976) a donné son nom à un théâtre et au prix annuel d'interprétation du Québec. Jean Duceppe (1923-1990) a commencé sa carrière en répondant à une petite annonce, et jouait au théâtre à 18 ans.
- 📚 **Source:** https://saintejulie.ca/profil-et-histoire/toponymie (Denise-Pelletier ; Guy-Sanche ; Olivier-Guimond ; Jean-Duceppe ; Marcel-Gamache ; Yoland-Guérard)
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {
    "fr": "Le quartier des artistes de la scène",
    "en": "The Performers' Quarter"
  },
  "lat": 45.58552,
  "lng": -73.34714,
  "trigger_radius_m": 130,
  "type": "street",
  "categories": [
    "art"
  ],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Quartier résidentiel : à pied ou à vélo"
  }
}
```

## POI 4: La salle Maurice-Savaria
- 📍 **GPS:** 45.580987, -73.345956 (OSM, école secondaire du Grand-Coteau)
- 🏠 **Adresse:** école secondaire du Grand-Coteau, 2029, rue Borduas, Sainte-Julie, QC
- 🏷️ **Catégories:** art, vie-locale
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 60m
- 💡 **Hook:** La salle de spectacle de la ville est cachée dans une école secondaire : la salle Maurice-Savaria, inaugurée le 21 janvier 1995 dans l'école du Grand-Coteau, où se produisent plusieurs artistes de renom selon la Ville.
- 📖 **Anecdote:** L'école elle-même a été inaugurée le 4 octobre 1994. Son nom rappelle « le Grand Coteau », l'ancienne appellation du territoire de Sainte-Julie dès 1750. Le nom de la salle s'ajoute à ceux qui honorent la famille Savaria (rue Savaria, Centre municipal Louis-Armand-Savaria). Selon la liste du ministère de la Culture, une installation extérieure de l'artiste Catherine Widgery a été réalisée pour l'école en 1993, dans le cadre de la politique d'intégration des arts.
- 📚 **Source:** https://saintejulie.ca/profil-et-histoire/toponymie (Savaria ; Grand-Coteau) ; https://saintejulie.ca/profil-et-histoire/histoire-de-la-ville (21 janv. 1995 ; 4 oct. 1994) ; https://cdn-contenu.quebec.ca/cdn-contenu/adm/min/culture-communications/documents/oeuvres-art/LI-oeuvres-art-public-region-16.pdf (IA-16-184, extérieur)
- 🔎 **À vérifier (checker):** titre et emplacement de l'œuvre de Catherine Widgery inconnus : ne pas la décrire. Adresse : 2029 (Ville, histoire) ou 2020 (brochure de l'école) rue Borduas : ne pas lire l'adresse dans le script. Qui était Maurice Savaria : non trouvé, ne pas le présenter.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {
    "fr": "La salle Maurice-Savaria",
    "en": "Salle Maurice-Savaria"
  },
  "lat": 45.580987,
  "lng": -73.345956,
  "trigger_radius_m": 60,
  "type": "building",
  "categories": [
    "art",
    "vie-locale"
  ],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Programmation de spectacles sur le site de la Ville ; école : accès seulement lors des spectacles"
  }
}
```

---

## Écartés (et pourquoi)
| Lieu | Raison |
|------|--------|
| Sculpture de Michel Goulet à l'aréna (2015, liste du ministère) | Ni titre ni description trouvés ; Goulet a aussi une œuvre de 2015 à l'aréna Éric-Sharp de Saint-Lambert (*Le jardin de givre*) : risque de confusion |
| Installation de François Joly à l'Électrium (1989) | Ni titre ni description trouvés |
| Aménagement de Gilles Mihalcean et peinture d'Anne-Marie Laurin (Centre de formation professionnelle des Patriotes, 2002-2003) | Ni titre ni description ; lieu de formation |
| Œuvres dans les écoles primaires (Du Moulin, Le Rucher, Tourne-Vent) | À l'intérieur d'écoles, non accessibles |
| Murale du parc Arthur-Gauthier (appel de projets 2026, livraison prévue au plus tard le 30 sept. 2026) | Aucune preuve de réalisation trouvée : **à vérifier sur place**, POI possible plus tard |
| Rues de Giverny, du Louvre, de Montparnasse | Thèmes officiels « jardins célèbres de France » et lieux parisiens, pas art québécois |

---
**Total:** 4 POIs trouvés
**Fichier:** content/sainte-julie-quebec-canada/scout-art.md
