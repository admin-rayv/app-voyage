# 🔍 POIs trouvés: Sainte-Julie — architecture
> Date: 2026-11-20
> City ID: 9ed9f927-ed8e-4d9c-bcab-55c489de1555
> City: Sainte-Julie / Sainte-Julie
> Coordonnées centre: 45.593062, -73.339594
> Pays: CA | Région: Montérégie
> Status: EN ATTENTE DE VALIDATION

**Méthode :** recherche large d'emblée. Sources : dépliant du circuit patrimonial du Comité d'histoire (descriptions architecturales maison par maison), évaluations architecturales de l'inventaire MRC 2014 (RPCQ), toponymie de la Ville, La Relève (citation du presbytère, nov. 2026).

**Déjà en BD avec l'étiquette architecture :** Église de Sainte-Julie, Ancienne école du village, Maison Savaria, Maison de la Belle-Rivière, Église Saint-François-d'Assise. Les détails architecturaux du dépliant pour ces bâtiments (rosace et tourelles de l'église, briques en éventail de l'école, chambranles du magasin Malo) pourront enrichir leurs scripts plus tard.

**Densité :** le Vieux-Village est très serré (maisons à 20-40 m les unes des autres). Rayons réduits à 20-25 m pour les nouveaux POIs de la rue Principale ; la file d'attente de l'app gère les chevauchements.

---

## POI 1: Le presbytère de 1893
- 📍 **GPS:** 45.5928, -73.3385 (⚠️ point suggéré : entre l'église et le 550, boul. Saint-Joseph ; la Ville situe le marché « dans le passage entre l'église et le presbytère, à proximité du 550 ». À confirmer sur le terrain)
- 🏠 **Adresse:** à côté de l'église, 1686, rue Principale / boulevard Saint-Joseph, Sainte-Julie, QC
- 🏷️ **Catégories:** architecture, histoire
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 40m
- 💡 **Hook:** Un presbytère « monumental d'esprit mansard américain », coiffé d'un toit en croupe à pente aiguë et d'un campanile décoratif, avec un porche et un fronton qui lui donnent une touche victorienne. La Ville vient de le citer immeuble patrimonial (novembre 2026).
- 📖 **Anecdote:** Construit sur les plans de l'architecte montréalais Alfred Préfontaine et inauguré le 11 juillet 1893 par Mgr Édouard-Charles Fabre, il remplace le premier presbytère de 1850, vendu aux enchères et déplacé rue Principale. La Relève le décrit comme représentatif de l'éclectisme victorien, avec son importante ornementation de la toiture, des lucarnes et du balcon. Il a abrité le siège social de la Caisse populaire en 1937-1938. La Fabrique, administrée par des bénévoles, entretient l'église et le presbytère.
- 📚 **Source:** https://saintejulie.ca/uploads/html_content/stejulie_docs/Circuit-patrimonial.pdf (dépliant « À la découverte du Vieux-Village », Comité d'histoire de Sainte-Julie, conception Odette Lemerise) ; http://lareleve.qc.ca/2026/11/03/presbytere-cite-immeuble-patrimonial-eglise-sainte-julie-classee-a/ ; https://saintejulie.ca/la-ville/decouvrir-la-ville/portail-de-la-ville/religion
- 🔎 **À vérifier (checker):** position exacte inconnue (aucune fiche RPCQ, absent d'OSM). Usage actuel non confirmé : la page Religion de la Ville dit « aujourd'hui devenu une résidence privée » dans un paragraphe ambigu ; La Relève dit que la Fabrique en prend soin. Ne pas préciser l'usage actuel dans le script.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {
    "fr": "Le presbytère",
    "en": "The Rectory"
  },
  "lat": 45.5928,
  "lng": -73.3385,
  "trigger_radius_m": 40,
  "type": "building",
  "categories": [
    "architecture",
    "histoire"
  ],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": "Depuis le passage entre l'église et le presbytère, pour voir le porche et le campanile",
    "tips": null
  }
}
```

## POI 2: La maison du notaire Lapierre
- 📍 **GPS:** 45.5940615, -73.338691 (Nominatim, 1667 rue Principale)
- 🏠 **Adresse:** 1667, rue Principale, Sainte-Julie, QC
- 🏷️ **Catégories:** architecture, histoire
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 25m
- 💡 **Hook:** Une maison de style Second Empire construite vers 1885, résidence de 1886 à 1926 du notaire Napoléon-Paul Lapierre, présenté par la Ville comme « le personnage le plus influent à Sainte-Julie » à son époque.
- 📖 **Anecdote:** Notaire de 1884 à 1926 et secrétaire-trésorier de la municipalité dès 1885, il cumule les fonctions : secrétaire-trésorier des commissions scolaires et des syndics de construction de l'église actuelle, greffier de la Cour des commissaires, propriétaire de la compagnie électrique et du réservoir d'aqueduc, premier gérant de la Banque Nationale à Sainte-Julie. En 1907, il obtient un privilège exclusif de 20 ans pour l'éclairage et le chauffage au gaz. Le boulevard, le parc et la place N.-P.-Lapierre portent son nom.
- 📚 **Source:** https://saintejulie.ca/uploads/html_content/stejulie_docs/Circuit-patrimonial.pdf (dépliant « À la découverte du Vieux-Village », Comité d'histoire de Sainte-Julie, conception Odette Lemerise) ; https://saintejulie.ca/profil-et-histoire/toponymie (N.-P.-Lapierre) ; https://saintejulie.ca/la-ville/decouvrir-la-ville/portail-de-la-ville/patrimoine-immobilier (privilège de 1907)
- 🔎 **À vérifier (checker):** décrire le Second Empire de façon générale (toit mansardé à deux pentes) sans inventer de détail propre à la maison.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {
    "fr": "La maison du notaire",
    "en": "The Notary's House"
  },
  "lat": 45.5940615,
  "lng": -73.338691,
  "trigger_radius_m": 25,
  "type": "building",
  "categories": [
    "architecture",
    "histoire"
  ],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Résidence privée : à admirer depuis le trottoir"
  }
}
```

## POI 3: La place des notaires
- 📍 **GPS:** 45.5941525, -73.3381786 (Nominatim, 1644 rue Principale)
- 🏠 **Adresse:** 1644, rue Principale, Sainte-Julie, QC
- 🏷️ **Catégories:** architecture, vie-locale
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 25m
- 💡 **Hook:** Un édifice de 1896 où cinq notaires ont tenu leur étude, et qui servait aussi de salle publique et de bureau municipal. De 1926 à 1978, la Banque Provinciale du Canada y a eu une succursale.
- 📖 **Anecdote:** Dans un village sans hôtel de ville, c'était un véritable centre civique : actes notariés, assemblées, bureau municipal et banque sous le même toit. La Ville situe aussi la Banque Provinciale et la salle du conseil louée en 1901 sur le lot de l'actuelle pizzeria voisine.
- 📚 **Source:** https://saintejulie.ca/uploads/html_content/stejulie_docs/Circuit-patrimonial.pdf (dépliant « À la découverte du Vieux-Village », Comité d'histoire de Sainte-Julie, conception Odette Lemerise) ; https://saintejulie.ca/la-ville/decouvrir-la-ville/portail-de-la-ville/patrimoine-immobilier (Banque Provinciale, salle du conseil)
- 🔎 **À vérifier (checker):** adresse : la place des notaires est le no 5 du dépliant ; le 1644 vient du titre de photo du circuit sur le site de la Ville. Ne pas affirmer que la salle de 1901 était dans ce bâtiment précis.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {
    "fr": "La place des notaires",
    "en": "The Notaries' Building"
  },
  "lat": 45.5941525,
  "lng": -73.3381786,
  "trigger_radius_m": 25,
  "type": "building",
  "categories": [
    "architecture",
    "vie-locale"
  ],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Immeuble privé : à regarder depuis le trottoir"
  }
}
```

## POI 4: La vieille maison du 1622
- 📍 **GPS:** 45.5945517, -73.3377758 (Nominatim, 1622 rue Principale)
- 🏠 **Adresse:** 1622, rue Principale, Sainte-Julie, QC
- 🏷️ **Catégories:** architecture, histoire
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 20m
- 💡 **Hook:** Peut-être la plus vieille maison du village : le Comité d'histoire croit que sa construction remonte « bien avant 1850 », et qu'elle a été déménagée ici vers 1870. Une maison de style vernaculaire, plus ancienne que la paroisse elle-même.
- 📖 **Anecdote:** Le larmier, ce bord de toit qui avance pour éloigner l'eau des murs, aurait été ajouté lors d'une rénovation de la toiture. Encore une maison déménagée, à Sainte-Julie.
- 📚 **Source:** https://saintejulie.ca/uploads/html_content/stejulie_docs/Circuit-patrimonial.pdf (dépliant « À la découverte du Vieux-Village », Comité d'histoire de Sainte-Julie, conception Odette Lemerise)
- 🔎 **À vérifier (checker):** « Nous croyons » : garder le conditionnel. Ne pas dire « la plus vieille maison » de façon affirmative.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {
    "fr": "La vieille maison du 1622",
    "en": "The Old House at 1622"
  },
  "lat": 45.5945517,
  "lng": -73.3377758,
  "trigger_radius_m": 20,
  "type": "building",
  "categories": [
    "architecture",
    "histoire"
  ],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Résidence privée : à admirer depuis le trottoir"
  }
}
```

## POI 5: La maison du chiffonnier
- 📍 **GPS:** 45.5928101, -73.3404916 (Nominatim, 1733 rue Principale)
- 🏠 **Adresse:** 1733, rue Principale, Sainte-Julie, QC
- 🏷️ **Catégories:** architecture, histoire
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 20m
- 💡 **Hook:** Une petite maison de ferme dont le carré n'a pas changé depuis son origine, bien avant 1855. Un rare témoin intact du Sainte-Julie rural.
- 📖 **Anecdote:** À côté, un hangar servait d'entrepôt, notamment à un marchand de chiffons : d'où son surnom de « maison du chiffonnier » dans le circuit de la Ville.
- 📚 **Source:** https://saintejulie.ca/uploads/html_content/stejulie_docs/Circuit-patrimonial.pdf (dépliant « À la découverte du Vieux-Village », Comité d'histoire de Sainte-Julie, conception Odette Lemerise) ; https://baladodiscovery.com/poi/624/7212/la-maison-du-chiffonier (titre de l'arrêt du circuit de la Ville)
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {
    "fr": "La maison du chiffonnier",
    "en": "The Rag Merchant's House"
  },
  "lat": 45.5928101,
  "lng": -73.3404916,
  "trigger_radius_m": 20,
  "type": "building",
  "categories": [
    "architecture",
    "histoire"
  ],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Résidence privée : à admirer depuis le trottoir"
  }
}
```

## POI 6: Les maisons Boomtown de la montée
- 📍 **GPS:** 45.594667, -73.341194 (exacte, fiche RPCQ du 670)
- 🏠 **Adresse:** 670, montée Sainte-Julie (et sa voisine, le 654), Sainte-Julie, QC
- 🏷️ **Catégories:** architecture
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 30m
- 💡 **Hook:** Deux maisons de style Boomtown, un style apparu au Québec vers 1880 : toit plat ou à faible pente vers l'arrière, plan rectangulaire, et toute l'ornementation concentrée en haut de la façade, dans une corniche. Comme une façade de western.
- 📖 **Anecdote:** Le 670 a été construit vers 1917 pour Télesphore Carrière ; il a gardé ses fenêtres à guillotine, ses chambranles, ses poteaux ouvragés de galerie, ses aisseliers et sa corniche à consoles. Sa voisine, le 654, date de 1907 et a été construite pour Joseph-Antoine Morin (la maison des deux maires et du comptoir postal).
- 📚 **Source:** https://www.patrimoine-culturel.gouv.qc.ca/rpcq/detail.do?methode=consulter&id=201256&type=bien ; https://www.patrimoine-culturel.gouv.qc.ca/rpcq/detail.do?methode=consulter&id=201255&type=bien
- 🔎 **À vérifier (checker):** la comparaison avec un « décor de western » est une image de Marco, pas une affirmation de la source.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {
    "fr": "Les maisons Boomtown",
    "en": "The Boomtown Houses"
  },
  "lat": 45.594667,
  "lng": -73.341194,
  "trigger_radius_m": 30,
  "type": "building",
  "categories": [
    "architecture"
  ],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": "Lever les yeux vers la corniche à consoles",
    "tips": "Résidences privées : à admirer depuis le trottoir"
  }
}
```

## POI 7: Deux styles sur le rang de la Vallée
- 📍 **GPS:** 45.586986, -73.31232 (point suggéré : entre le 1315 et le 1360, fiches RPCQ)
- 🏠 **Adresse:** 1315 et 1360, rang de la Vallée, Sainte-Julie, QC
- 🏷️ **Catégories:** architecture
- 🏛️ **Type:** building
- 📏 **Rayon déclenchement:** 120m
- 💡 **Hook:** À deux pas l'une de l'autre, deux maisons de ferme qui résument l'évolution de l'architecture rurale au Québec : une maison à mansarde en brique de 1916, et un « vernaculaire américain » en bois de 1910.
- 📖 **Anecdote:** La maison à mansarde (1315) était très en vogue à la campagne entre 1875 et 1930 ; celle-ci a gardé sa brique, son toit en tôle traditionnelle, ses linteaux en ciment, ses cheminées en tôle ouvragée, et elle est entourée de bâtiments secondaires anciens. Le vernaculaire américain (1360) remplace peu à peu la maison traditionnelle québécoise à partir de la fin du 19e siècle ; il a gardé ses planches horizontales, sa porte à imposte, ses chambranles et les poteaux ouvragés de sa galerie.
- 📚 **Source:** https://www.patrimoine-culturel.gouv.qc.ca/rpcq/detail.do?methode=consulter&id=201259&type=bien ; https://www.patrimoine-culturel.gouv.qc.ca/rpcq/detail.do?methode=consulter&id=201260&type=bien
- 🔎 **À vérifier (checker):** les deux maisons sont à environ 220 m : rayon large, POI pensé pour la voiture ou le vélo.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {
    "fr": "Deux styles sur le rang de la Vallée",
    "en": "Two Styles on Rang de la Vallée"
  },
  "lat": 45.586986,
  "lng": -73.31232,
  "trigger_radius_m": 120,
  "type": "building",
  "categories": [
    "architecture"
  ],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Résidences privées en zone rurale : POI pensé pour la voiture ou le vélo"
  }
}
```

## POI 8: Le Domaine des Hauts-Bois
- 📍 **GPS:** 45.571698, -73.325268 (Nominatim, boulevard des Hauts-Bois)
- 🏠 **Adresse:** boulevard des Hauts-Bois, Sainte-Julie, QC
- 🏷️ **Catégories:** architecture, nature
- 🏛️ **Type:** street
- 📏 **Rayon déclenchement:** 100m
- 💡 **Hook:** Un quartier pensé pour la forêt. En 1965, le promoteur Edmour J. Harvey propose de construire sur le flanc nord du mont Saint-Bruno en respectant « le caractère boisé et accidenté du terrain » : 24 millions de pieds carrés de bois franc, de ravins et de plateau.
- 📖 **Anecdote:** Le projet est accepté par le conseil en 1966 ; le premier terrain est vendu en 1967 à Jacquelin Beaulieu. En 1971, la Ville annexe même une partie du territoire de Saint-Bruno pour le Domaine. Les noms de rues et de parcs racontent le lieu : le Bois-Franc (érables, frênes, tilleuls), l'Érablière, le Barrage. Harvey, originaire de Roberval, développe le Domaine jusqu'à sa mort en 1985.
- 📚 **Source:** https://saintejulie.ca/profil-et-histoire/toponymie (Hauts-Bois ; Edmour-J.-Harvey ; Jacquelin-Beaulieu ; Bois-Franc ; Barrage)
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {
    "fr": "Le Domaine des Hauts-Bois",
    "en": "Domaine des Hauts-Bois"
  },
  "lat": 45.571698,
  "lng": -73.325268,
  "trigger_radius_m": 100,
  "type": "street",
  "categories": [
    "architecture",
    "nature"
  ],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Quartier résidentiel : mieux en voiture ou à vélo"
  }
}
```

---

## Écartés (et pourquoi)
| Lieu | Raison |
|------|--------|
| 621, montée Sainte-Julie (esprit mansard américain, 1884, maison de trois meuniers) | Pratiquement au même point que la maison du forgeron et le magasin Morin (déjà en BD) : trop de déclenchements au même coin |
| 1625, rue Principale (vers 1870 ; bureau de poste dans la salle à manger de 1960 à 1973) | Peu d'intérêt architectural ; anecdote à reprendre en **insolite** |
| Hôtel de ville (édifice industriel converti) | Déjà en BD (vie-locale) |
| 1361, chemin de la Belle-Rivière | Évaluation sans détail architectural notable |

---
**Total:** 8 POIs trouvés
**Fichier:** content/sainte-julie-quebec-canada/scout-architecture.md
