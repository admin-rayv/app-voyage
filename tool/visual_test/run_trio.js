// Vérif visuelle: recherche POI (vue liste) + section Stockage (réglages)
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');
const { city, points, scriptFor } = require('./fixtures');
const SHOTS = path.join(__dirname, 'shots');
const tile = fs.readFileSync(path.join(__dirname, 'tile_light.png'));
const wait = (ms) => new Promise((r) => setTimeout(r, ms));
(async () => {
  const browser = await chromium.launch({
    executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome',
    headless: true, args: ['--no-sandbox', '--disable-dev-shm-usage'],
  });
  const context = await browser.newContext({
    ignoreHTTPSErrors: true, viewport: { width: 390, height: 844 },
    deviceScaleFactor: 2, isMobile: true, hasTouch: true,
    geolocation: { latitude: 45.4959, longitude: -73.5075, accuracy: 8 },
    permissions: ['geolocation'], locale: 'fr-CA',
  });
  const roboto = fs.readFileSync(path.join(__dirname, 'Roboto-Regular.ttf'));
  const emoji = fs.readFileSync(path.join(__dirname, 'NotoColorEmoji.ttf'));
  const nunito = fs.readFileSync('/home/user/app-voyage/assets/google_fonts/Nunito-Regular.ttf');
  await context.route('**fonts.gstatic.com/**', (route) => {
    const url = route.request().url().toLowerCase();
    const body = url.includes('emoji') ? emoji : url.includes('roboto') ? roboto : nunito;
    return route.fulfill({ contentType: 'font/ttf', body });
  });
  await context.route('**fonts.googleapis.com/**', (r) => r.fulfill({ contentType: 'text/css', body: '' }));
  await context.route('**basemaps.cartocdn.com/**', (r) => r.fulfill({ contentType: 'image/png', body: tile }));
  await context.route('**/rest/v1/**', (route) => {
    const url = route.request().url();
    const accept = route.request().headers()['accept'] || '';
    const single = accept.includes('vnd.pgrst.object');
    const json = (data) => route.fulfill({ contentType: 'application/json',
      body: JSON.stringify(single && Array.isArray(data) ? (data[0] ?? null) : data) });
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
  await context.route('**supabase.co/**', (route) => {
    if (route.request().url().includes('/rest/v1/')) return route.fallback();
    return route.fulfill({ contentType: 'application/json', body: '{}' });
  });
  const page = await context.newPage();
  page.on('pageerror', (e) => console.log('PAGEERROR:', String(e).slice(0, 200)));
  const shot = async (n) => { await page.screenshot({ path: path.join(SHOTS, `trio-${n}.png`) }); console.log('shot', n); };
  const tap = async (x, y, ms = 1600) => { await page.mouse.click(x, y); await wait(ms); };

  await page.goto('http://127.0.0.1:8080/', { waitUntil: 'load' });
  await wait(16000);
  for (let i = 0; i < 4; i++) await tap(195, 785); // onboarding
  await wait(2500);
  await tap(195, 240, 7000);  // carte Saint-Lambert
  await tap(310, 28, 2500);   // toggle liste (appbar)
  await shot('01-liste-recherche');
  await tap(195, 250, 800); await page.keyboard.type('eglise', { delay: 60 });
  await wait(1800);
  await shot('02-recherche-eglise');
  await browser.close();
  console.log('done');
})().catch((e) => { console.error('FATAL', e); process.exit(1); });
