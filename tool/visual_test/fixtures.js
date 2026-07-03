// Fixtures Supabase pour le test visuel — vrais POIs de Saint-Lambert.
const CITY_ID = 'f1fba711-49fe-4b49-87e3-b49442c39e9c';

const city = {
  id: CITY_ID,
  slug: 'saint-lambert-quebec-canada',
  name: { fr: 'Saint-Lambert', en: 'Saint Lambert' },
  country: 'CA',
  region: 'QC',
  center_lat: 45.5004,
  center_lng: -73.5136,
  timezone: 'America/Toronto',
  available_languages: ['fr', 'en', 'es'],
  image_url: null,
  image_credit: null,
  created_at: '2026-02-25T00:00:00Z',
};

const mk = (id, fr, en, lat, lng, cats, type = 'building') => ({
  id: `00000000-0000-4000-8000-0000000000${id}`,
  city_id: CITY_ID,
  name: { fr, en },
  lat,
  lng,
  trigger_radius_m: 40,
  type,
  categories: cats,
  image_url: null,
  logistics: {},
  is_published: true,
});

const points = [
  mk('01', 'Église Saint-Lambert', 'Saint-Lambert Church', 45.5004, -73.5139, ['histoire', 'architecture'], 'church'),
  mk('02', 'Maison Marsil', 'Marsil House', 45.4998, -73.5157, ['histoire', 'insolite']),
  mk('03', 'Parc du Village', 'Village Park', 45.4989, -73.5121, ['histoire', 'nature'], 'park'),
  mk('04', 'Vue sur le Pont Victoria', 'Victoria Bridge View', 45.5062, -73.5222, ['architecture', 'histoire'], 'viewpoint'),
  mk('05', 'Écluse de Saint-Lambert', 'Saint-Lambert Lock', 45.5083, -73.5150, ['architecture', 'insolite']),
  mk('06', 'Avenue Victoria', 'Victoria Avenue', 45.5012, -73.5128, ['histoire', 'vie-locale']),
  mk('07', 'Église anglicane St-Barnabas', 'St. Barnabas Church', 45.5021, -73.5147, ['histoire'], 'church'),
  mk('08', 'King Cottages', 'King Cottages', 45.5030, -73.5165, ['architecture']),
  mk('09', 'Boulangerie du coin', 'Corner Bakery', 45.5008, -73.5115, ['food']),
  mk('10', 'Murale de la gare', 'Station Mural', 45.5044, -73.5170, ['art']),
  mk('11', 'Marché du jeudi', 'Thursday Market', 45.4995, -73.5108, ['vie-locale', 'food']),
  mk('12', 'Piste cyclable du fleuve', 'Riverside Bike Path', 45.5070, -73.5195, ['nature'], 'park'),
  mk('13', 'Maison Sharpe', 'Sharpe House', 45.4983, -73.5142, ['histoire']),
  mk('14', 'Parc de la Voie Maritime', 'Seaway Park', 45.5095, -73.5175, ['nature', 'insolite'], 'park'),
  mk('15', 'Café Passion', 'Café Passion', 45.5016, -73.5119, ['food', 'vie-locale']),
  mk('16', 'Galerie d’art municipale', 'Municipal Art Gallery', 45.4991, -73.5133, ['art', 'vie-locale']),
];

const scriptFor = (pointId, language) => ({
  id: `11111111-0000-4000-8000-0000000000${pointId.slice(-2)}`,
  point_id: pointId,
  language,
  content:
    language === 'fr'
      ? 'Tu vois cette église devant toi? Prends deux secondes pour regarder ' +
        'la rosace au-dessus du portail. En 1936, un incendie a tout ravagé ' +
        '— sauf le clocher. Les paroissiens ont reconstruit autour, dans le ' +
        'style Dom Bellot, avec ces briques brunes typiques. Petit tip: le ' +
        'meilleur angle photo, c’est du coin de la rue Green, en fin ' +
        'd’après-midi quand le soleil frappe la façade.'
      : 'See this church in front of you? Take a moment to look at the rose ' +
        'window above the portal. In 1936 a fire destroyed everything — ' +
        'except the bell tower. The parishioners rebuilt around it in the ' +
        'Dom Bellot style with those typical brown bricks.',
  persona: 'marco',
  word_count: 78,
  estimated_duration_sec: 31,
});

module.exports = { city, points, scriptFor };
