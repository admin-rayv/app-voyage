// Test visuel App Voyage (build web) — Playwright + Chromium headless.
// Usage: node run.js <light|dark> [steps]
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');
const { city, points, scriptFor } = require('./fixtures');

const MODE = process.argv[2] || 'light';
const SHOTS = path.join(__dirname, 'shots');
const tile = fs.readFileSync(
  path.join(__dirname, MODE === 'dark' ? 'tile_dark.png' : 'tile_light.png'),
);

const wait = (ms) => new Promise((r) => setTimeout(r, ms));

(async () => {
  const browser = await chromium.launch({
    executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome',
    headless: true,
    args: ['--no-sandbox', '--disable-dev-shm-usage'],
  });

  const context = await browser.newContext({
    ignoreHTTPSErrors: true,
    viewport: { width: 390, height: 844 },
    deviceScaleFactor: 2,
    isMobile: true,
    hasTouch: true,
    colorScheme: MODE === 'dark' ? 'dark' : 'light',
    geolocation: { latitude: 45.4959, longitude: -73.5075, accuracy: 8 },
    permissions: ['geolocation'],
    locale: 'fr-CA',
  });

  // ── Interception réseau ──
  // Polices gstatic → fichiers locaux (le proxy bloque Chromium)
  const roboto = fs.readFileSync(path.join(__dirname, 'Roboto-Regular.ttf'));
  const emoji = fs.readFileSync(path.join(__dirname, 'NotoColorEmoji.ttf'));
  const nunito = fs.readFileSync('/home/user/app-voyage/assets/google_fonts/Nunito-Regular.ttf');
  await context.route('**fonts.gstatic.com/**', (route) => {
    const url = route.request().url().toLowerCase();
    const body = url.includes('emoji') ? emoji : url.includes('roboto') ? roboto : nunito;
    return route.fulfill({ contentType: 'font/ttf', body });
  });
  await context.route('**fonts.googleapis.com/**', (route) =>
    route.fulfill({ contentType: 'text/css', body: '' }),
  );

  // Tuiles CARTO → tuile placeholder locale
  await context.route('**basemaps.cartocdn.com/**', (route) =>
    route.fulfill({ contentType: 'image/png', body: tile }),
  );
  // Supabase REST → fixtures
  await context.route('**/rest/v1/**', (route) => {
    const url = route.request().url();
    const accept = route.request().headers()['accept'] || '';
    const single = accept.includes('vnd.pgrst.object');
    const json = (data) =>
      route.fulfill({
        contentType: 'application/json',
        body: JSON.stringify(single && Array.isArray(data) ? (data[0] ?? null) : data),
      });

    if (url.includes('/rest/v1/cities')) return json([city]);
    if (url.includes('/rest/v1/points')) return json(points);
    if (url.includes('/rest/v1/scripts')) {
      const m = url.match(/point_id=eq\.([0-9a-f-]+)/);
      const lang = (url.match(/language=eq\.(\w+)/) || [])[1] || 'fr';
      if (m) return json([scriptFor(m[1], lang)]);
      return json(points.map((p) => scriptFor(p.id, 'fr')));
    }
    return json([]);
  });
  // Tout autre appel Supabase (auth, realtime) → vide
  await context.route('**supabase.co/**', (route) => {
    const url = route.request().url();
    if (url.includes('/rest/v1/')) return route.fallback();
    return route.fulfill({ contentType: 'application/json', body: '{}' });
  });

  const page = await context.newPage();
  page.on('pageerror', (e) => console.log('PAGEERROR:', String(e).slice(0, 300)));

  const shot = async (name) => {
    await page.screenshot({ path: path.join(SHOTS, `${MODE}-${name}.png`) });
    console.log('shot', `${MODE}-${name}`);
  };
  const tap = async (x, y, ms = 1600) => {
    await page.mouse.click(x, y);
    await wait(ms);
  };

  await page.goto('http://127.0.0.1:8080/', { waitUntil: 'load' });
  await wait(16000); // init Flutter + fonts

  // ── Onboarding (premier lancement) ──
  await shot('01-onboarding-1');
  await tap(195, 785); // Suivant
  await shot('02-onboarding-2');
  await tap(195, 785);
  await shot('03-onboarding-3');
  await tap(195, 785); // C'est parti
  await wait(2500);

  // ── Home ──
  await shot('04-home');

  // ── Carte (tap sur la carte de ville) ──
  await tap(195, 240, 7000); // carte Saint-Lambert
  await shot('05-map');

  // Activer le mode découverte (FAB en bas à droite)
  await tap(310, 785, 3500);
  await shot('06-discovery-on');

  // ── Simulation de marche GPS vers l'Église Saint-Lambert (45.5004,-73.5139)
  const walk = [
    [45.4972, -73.5095], [45.4982, -73.5110], [45.4990, -73.5122],
    [45.4997, -73.5130], [45.5001, -73.5135], [45.50032, -73.51375],
    [45.50037, -73.51385], [45.50040, -73.51388],
  ];
  for (const [latitude, longitude] of walk) {
    await context.setGeolocation({ latitude, longitude, accuracy: 8 });
    await wait(1400);
  }
  await wait(4000); // debounce + notification + délai autoplay
  await shot('07-gps-trigger');

  // ── Preview POI: taper un marqueur histoire isolé ──
  await tap(177, 536, 2200);
  await shot('08-poi-preview');

  // ── Détail POI (bouton "Détail" à droite du preview) ──
  await tap(285, 797, 5000);
  await shot('09-poi-detail');

  // ── Retour puis Paramètres ──
  await tap(28, 56, 2000);  // back → carte
  await tap(28, 56, 2500);  // back → home
  await tap(345, 118, 3000); // engrenage
  await shot('10-settings');

  await browser.close();
  console.log('done', MODE);
})().catch((e) => {
  console.error('FATAL', e);
  process.exit(1);
});
