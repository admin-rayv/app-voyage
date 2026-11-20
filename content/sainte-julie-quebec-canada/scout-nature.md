# 🔍 POIs trouvés: Sainte-Julie — nature
> Date: 2026-11-20
> City ID: 9ed9f927-ed8e-4d9c-bcab-55c489de1555
> City: Sainte-Julie / Sainte-Julie
> Coordonnées centre: 45.593062, -73.339594
> Pays: CA | Région: Montérégie
> Status: EN ATTENTE DE VALIDATION

**Méthode :** sources officielles en priorité : page « Toponymie » de la Ville (origine de chaque nom de parc), page « Parcs et lieux d'activités », chronologie « Histoire de la ville », Registre Desjardins de Nature-Action Québec. GPS : Nominatim et OpenStreetMap.

**Doublons :** aucun avec les 16 POIs histoire déjà en BD.

**Note :** sauf l'arboretum, ces lieux sont loin du Vieux-Village. Ils se prêtent surtout au vélo et à la voiture.

---

## POI 1: Parc des Étangs-Antoine-Charlebois
- 📍 **GPS:** 45.643349, -73.334373 (point suggéré : stationnement d'accès le plus proche du parc, selon OpenStreetMap ; le géocodage inverse indique la rue Auger, côté Saint-Amable)
- 🏠 **Adresse:** extrémité nord de Sainte-Julie, J3E 1Y2 (accès par la rue Auger)
- 🏷️ **Catégories:** nature, insolite
- 🏛️ **Type:** park
- 📏 **Rayon déclenchement:** 100m
- 💡 **Hook:** Plus de 80 hectares de milieux humides où vivent la loutre de rivière, la grande aigrette, la gallinule poule-d'eau et même l'orignal. Et ces étangs ne sont pas naturels : c'est une ancienne carrière de sable, creusée pour construire l'autoroute 30.
- 📖 **Anecdote:** La Ville y recense 110 espèces de végétaux, 66 d'oiseaux, 14 de mammifères et 6 d'amphibiens ou de reptiles, dont certaines en situation précaire. Le parc porte le nom d'Antoine Charlebois, propriétaire d'origine des lieux, cultivateur dès 1851 et marguillier, inscrit au tout premier recensement de la paroisse.
- 📚 **Source:** https://registredesjardins.nature-action.qc.ca/sites/parc-des-etangs-antoine-charlebois/ ; https://saintejulie.ca/sport/parcs-et-lieux-d-activites ; https://saintejulie.ca/profil-et-histoire/toponymie
- 🔎 **À vérifier (checker):** superficie : 80 ha (Nature-Action, Ville) contre 64 ha (fiche de toponymie, plus ancienne). Confirmer que le stationnement retenu est bien l'accès officiel (la carte de la Ville montre deux stationnements, P et P2).
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Parc des Étangs-Antoine-Charlebois", "en": "Antoine-Charlebois Ponds Park"},
  "lat": 45.643349,
  "lng": -73.334373,
  "trigger_radius_m": 100,
  "type": "park",
  "categories": ["nature", "insolite"],
  "image_url": null,
  "logistics": {
    "parking": "Stationnements sur le site (P et P2 sur la carte de la Ville)",
    "toilets": null,
    "photo_spot": "Depuis les plateformes d'observation au bord des étangs",
    "tips": "Chiens interdits sur le site. Environ 3 km de sentiers, été comme hiver (raquette). Accès difficile en poussette ou en fauteuil roulant."
  }
}
```

## POI 2: Lac des Outardes (parc Edmour-J.-Harvey)
- 📍 **GPS:** 45.567296, -73.3273575 (point suggéré : lac des Outardes, Nominatim ; à environ 120 m du barrage)
- 🏠 **Adresse:** parc Edmour-J.-Harvey, 1, rue des Brises, Sainte-Julie, QC
- 🏷️ **Catégories:** nature, vie-locale
- 🏛️ **Type:** water
- 📏 **Rayon déclenchement:** 100m
- 💡 **Hook:** Ce lac n'existait pas avant 1963. Pour créer les lacs des Cygnes et des Outardes, on a construit en travers d'un immense ravin un barrage de terre de 25 pieds de haut, avec déversoir et écluse, achevé en 1965.
- 📖 **Anecdote:** Le barrage mesure 150 pieds de large à la base et 33 au sommet. Il fait partie du Domaine des Hauts-Bois, le projet d'Edmour J. Harvey (présenté en 1965) : un quartier bâti sur le flanc boisé du mont Saint-Bruno, sur d'anciennes terres de bois franc, en respectant le relief et la forêt. Après sa mort en 1985, la Ville a rebaptisé le parc Le Plateau en son honneur. L'hiver, le lac est la seule patinoire de la ville réservée aux patineurs (hockey interdit) ; l'été, on y prête gratuitement des pédalos.
- 📚 **Source:** https://saintejulie.ca/profil-et-histoire/toponymie (rue du Barrage, Hauts-Bois, Edmour-J.-Harvey, Bois-Franc) ; https://saintejulie.ca/sport/parcs-et-lieux-d-activites
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Lac des Outardes", "en": "Lac des Outardes"},
  "lat": 45.567296,
  "lng": -73.3273575,
  "trigger_radius_m": 100,
  "type": "water",
  "categories": ["nature", "vie-locale"],
  "image_url": null,
  "logistics": {
    "parking": "Parc Edmour-J.-Harvey, 1, rue des Brises",
    "toilets": "Toilettes accessibles au parc Edmour-J.-Harvey",
    "photo_spot": "Depuis le barrage, rue du Barrage, avec le lac d'un côté et le ravin de l'autre",
    "tips": "Pédalos prêtés gratuitement l'été (gilets fournis) ; patinage l'hiver, surface éclairée le soir, pavillon chauffé"
  }
}
```

## POI 3: Parc de l'Érablière
- 📍 **GPS:** 45.5715785, -73.3154134 (Nominatim, parc)
- 🏠 **Adresse:** Domaine des Hauts-Bois, Sainte-Julie, QC (près de la rue de La Rochelle)
- 🏷️ **Catégories:** nature, histoire
- 🏛️ **Type:** park
- 📏 **Rayon déclenchement:** 60m
- 💡 **Hook:** Un parc aménagé sur une ancienne érablière, celle de Louis-Armand-Savaria, avec ses arbres centenaires et un pont rustique qui enjambe un ravin.
- 📖 **Anecdote:** C'est le promoteur du Domaine des Hauts-Bois qui l'a aménagé, avant de le céder à la Ville avec ses bancs octogonaux en madriers de grange et ses allées de gravier. Le nom Savaria, omniprésent à Sainte-Julie (hôtel de ville, salle de spectacle, rue), est aussi celui de cette érablière.
- 📚 **Source:** https://saintejulie.ca/profil-et-histoire/toponymie (Érablière, de l')
- 🔎 **À vérifier (checker):** confirmer l'emplacement du parc (Nominatim seul) et que le pont et les bancs existent toujours.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Parc de l'Érablière", "en": "Maple Grove Park"},
  "lat": 45.5715785,
  "lng": -73.3154134,
  "trigger_radius_m": 60,
  "type": "park",
  "categories": ["nature", "histoire"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": "Depuis le pont rustique, au-dessus du ravin",
    "tips": "Parc de quartier dans un secteur résidentiel boisé"
  }
}
```

## POI 4: Arboretum Pierre-Steben (parc Armand-Frappier)
- 📍 **GPS:** 45.5825819, -73.3300531 (point suggéré : parc Armand-Frappier, Nominatim ; l'arboretum lui-même n'est pas cartographié)
- 🏠 **Adresse:** parc Armand-Frappier, boulevard Armand-Frappier, Sainte-Julie, QC
- 🏷️ **Catégories:** nature
- 🏛️ **Type:** park
- 📏 **Rayon déclenchement:** 60m
- 💡 **Hook:** Près de 200 variétés d'arbres, d'arbustes, de vivaces et de plantes aquatiques, toutes adaptées au climat local, plantées autour d'un réservoir qui capte les eaux de pluie. L'idée : venir s'en inspirer pour son propre terrain.
- 📖 **Anecdote:** L'arboretum a été créé en 1995 grâce à une contribution d'Hydro-Québec (Programme de mise en valeur de l'environnement). Depuis 2007, il porte le nom de Pierre Steben (1951-2004), jardinier aux travaux publics de la Ville depuis 1981, mort dans un accident de travail. Une plaque commémorative a été dévoilée un 21 juin.
- 📚 **Source:** https://saintejulie.ca/profil-et-histoire/toponymie (Pierre-Steben, arboretum ; Armand-Frappier) ; https://saintejulie.ca/profil-et-histoire/histoire-de-la-ville
- 🔎 **À vérifier (checker):** position exacte de l'arboretum dans le parc.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Arboretum Pierre-Steben", "en": "Pierre-Steben Arboretum"},
  "lat": 45.5825819,
  "lng": -73.3300531,
  "trigger_radius_m": 60,
  "type": "park",
  "categories": ["nature"],
  "image_url": null,
  "logistics": {
    "parking": null,
    "toilets": null,
    "photo_spot": null,
    "tips": "Le parc Armand-Frappier est relié à la piste cyclable ; bon arrêt à vélo"
  }
}
```

## POI 5: Piste cyclopédestre du Grand-Coteau
- 📍 **GPS:** 45.6033421, -73.3553792 (point suggéré : parc Desrochers, extrémité ouest de la piste)
- 🏠 **Adresse:** parc Desrochers, 1111, rue Desrochers, Sainte-Julie, QC
- 🏷️ **Catégories:** nature
- 🏛️ **Type:** viewpoint
- 📏 **Rayon déclenchement:** 60m
- 💡 **Hook:** Une piste qui offre une vue exceptionnelle sur le mont Royal, le centre-ville de Montréal et les terres agricoles de la Montérégie. Elle traverse le secteur que les habitants appelaient « le Grand Coteau » dès 1750, bien avant que Sainte-Julie existe.
- 📖 **Anecdote:** Aménagé en 2014, ce tronçon fait partie du sentier Oka–Mont-Saint-Hilaire et relie le parc Desrochers au parc Armand-Frappier. Le Grand Coteau, c'était une étendue de terre plane, entaillée de vallées, sur le versant nord du mont Saint-Bruno. Le nom a survécu dans celui de la piste et de l'école secondaire.
- 📚 **Source:** https://saintejulie.ca/profil-et-histoire/toponymie (Grand-Coteau, piste cyclopédestre) ; https://saintejulie.ca/profil-et-histoire/histoire-de-la-ville (1750)
- 🔎 **À vérifier (checker):** le parc Desrochers est-il bien le meilleur point de vue ? La source ne précise pas où la vue est la plus belle.
- ✅ **Verdict:** EN ATTENTE

### 🗄️ Données BD (prêtes pour insertion)
```json
{
  "name": {"fr": "Piste du Grand-Coteau", "en": "Grand-Coteau Trail"},
  "lat": 45.6033421,
  "lng": -73.3553792,
  "trigger_radius_m": 60,
  "type": "viewpoint",
  "categories": ["nature"],
  "image_url": null,
  "logistics": {
    "parking": "Parc Desrochers, 1111, rue Desrochers",
    "toilets": null,
    "photo_spot": "Vers l'ouest, pour cadrer le mont Royal et les tours du centre-ville",
    "tips": "Piste cyclopédestre : idéale à vélo. Le parc Desrochers a aussi une piste de vélo de montagne (8 h à 20 h)."
  }
}
```

---

## Écartés (et pourquoi)
| Lieu | Raison |
|------|--------|
| Parc national du Mont-Saint-Bruno | Contigu à Sainte-Julie, mais le parc et ses lacs sont surtout sur le territoire de Saint-Bruno-de-Montarville. Il est évoqué dans les POIs 2, 3 et 5. |
| Protection de 12 ha du « bois du mont Saint-Bruno » (2011, Nature-Action) | Lieu exact introuvable |
| Parc Le Rocher | À Saint-Amable (voisin des étangs) |
| Parc de la Coulée (cours d'eau Hébert) | Pas d'histoire à raconter au-delà du nom |
| Piste de vélo de montagne (parc Edmour-J.-Harvey, 2024 ; parc Desrochers) | Plus pertinent en **vie-locale** |
| Jardin communautaire Vincent-Provencher, parc canin | Plus pertinents en **vie-locale** |
| Électrium (Hydro-Québec) | Centre d'interprétation : à voir en **vie-locale** ou **insolite** |

---
**Total:** 5 POIs trouvés
**Fichier:** content/sainte-julie-quebec-canada/scout-nature.md
