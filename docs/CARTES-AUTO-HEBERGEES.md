# Cartes auto-hébergées (voyage.bjpr.ca/cartes)

Mises en place le 2026-11-23 (v0.7.7), quand CARTO a commencé à exiger une clé
(ses tuiles affichaient « API KEY REQUIRED »).

## Chaîne
```
App (flutter_map, tuiles raster PNG)
  → https://voyage.bjpr.ca/cartes/styles/{light|dark}/{z}/{x}/{y}{@2x}.png
  → Caddy (cee-staging, handle_path /cartes/*)
  → voyage-cartes-cache  (nginx, 127.0.0.1:8102, cache disque 5 Go max, 365 j)
  → voyage-cartes        (tileserver-gl v5.7.0, 127.0.0.1:8101, dessine les PNG)
  → /srv/cartes/data/rive-sud.pmtiles (extrait Protomaps, OpenStreetMap)
```

## Fichiers sur le VPS (`/srv/cartes`)
- `data/rive-sud.pmtiles` — extrait bbox `-74.3,45.0,-72.6,46.1` (Rive-Sud + île de Montréal),
  build Protomaps du 2026-11-22 (~120 Mo), schéma v4.
- `styles/light.json`, `styles/dark.json` — générés avec `@protomaps/basemaps@5.7.2`
  (`layers('protomaps', namedFlavor(...), {lang: 'fr'})`), source `pmtiles://{rive-sud}`.
- `styles/sprites/`, `fonts/` — depuis `protomaps/basemaps-assets` (sprites v4, Noto Sans).
- `config.json` (tileserver-gl), `nginx.conf` (cache), `cache/` (tuiles déjà dessinées).
- `prechauffer.py sud ouest nord est` — dessine d'avance z10–17, clair + sombre @2x.

## Ajouter une région (nouvelle ville hors zone)
```bash
ssh cee-staging
pmtiles extract https://build.protomaps.com/AAAAMMJJ.pmtiles /srv/cartes/data/NOUVEAU.pmtiles \
  --bbox=OUEST,SUD,EST,NORD --dry-run   # taille d'abord
```
Le plus simple : refaire un seul extrait couvrant l'ancienne + la nouvelle zone,
remplacer `rive-sud.pmtiles`, `sudo docker restart voyage-cartes`, vider
`/srv/cartes/cache/*`, relancer `prechauffer.py` pour chaque ville.

## Mettre à jour les données OSM (1–2 fois par an)
Même commande d'extraction avec un build récent, puis redémarrer et vider le cache.

## Conteneurs
```bash
sudo docker run -d --name voyage-cartes --restart unless-stopped --memory 1g \
  --network voyage-cartes-net -v /srv/cartes:/data -p 127.0.0.1:8101:8080 \
  maptiler/tileserver-gl:v5.7.0 --config /data/config.json --public_url https://voyage.bjpr.ca/cartes/
sudo docker run -d --name voyage-cartes-cache --restart unless-stopped --memory 128m \
  --network voyage-cartes-net -v /srv/cartes/nginx.conf:/etc/nginx/conf.d/default.conf:ro \
  -v /srv/cartes/cache:/var/cache/cartes -p 127.0.0.1:8102:8080 nginx:1.27-alpine
```

## App
- `lib/widgets/map_tiles.dart` : URLs des tuiles + attribution (© OpenStreetMap, Protomaps).
- `lib/services/map_tile_cache.dart` : `_tileSource` — le changer vide le cache des
  téléphones une fois (utile si l'adresse ou le style des tuiles change).
- Hors de la zone extraite, la carte est vide (seulement les POIs).
