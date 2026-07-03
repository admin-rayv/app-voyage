# Test visuel automatisé (build web + Playwright)

Capture des écrans réels de l'app (clair + sombre) dans un Chromium headless,
avec données Supabase mockées, tuiles placeholder et **simulation de marche
GPS** qui déclenche le geofencing de bout en bout (détection → notification →
lecture auto → progression).

## Prérequis
- Chromium Playwright (`npx playwright install chromium`) — adapter
  `executablePath` dans `run.js`
- Node 18+, Python 3 + Pillow

## Utilisation
```bash
# 1. Générer les tuiles placeholder
python3 tool/visual_test/make_tiles.py

# 2. Roboto (fallback moteur) et NotoColorEmoji.ttf sont à placer à côté
#    de run.js (voir les chemins en tête de script)

# 3. Builder le web avec ressources embarquées
flutter build web --release --no-web-resources-cdn

# 4. Servir et capturer
python3 -m http.server 8080 -d build/web &
node tool/visual_test/run.js light
node tool/visual_test/run.js dark
# → captures dans tool/visual_test/shots/
```

Notes:
- Le harnais intercepte `/rest/v1/*` (fixtures.js), les tuiles CARTO et les
  polices — aucun réseau requis.
- La géoloc est mockée: `run.js` simule une marche vers l'Église
  Saint-Lambert pour valider visuellement le trigger GPS.
- Le TTS ne s'entend pas en headless; seul le visuel est validé.
