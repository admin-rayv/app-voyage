-- App Voyage Database Schema
-- ============================

-- Cities
CREATE TABLE IF NOT EXISTS cities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  name JSONB NOT NULL,
  country TEXT DEFAULT 'CA',
  region TEXT,
  center_lat FLOAT NOT NULL,
  center_lng FLOAT NOT NULL,
  timezone TEXT DEFAULT 'America/Toronto',
  available_languages TEXT[] DEFAULT ARRAY['fr', 'en'],
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tours
CREATE TABLE IF NOT EXISTS tours (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  city_id UUID REFERENCES cities(id) ON DELETE CASCADE,
  slug TEXT NOT NULL,
  name JSONB NOT NULL,
  description JSONB NOT NULL,
  theme TEXT NOT NULL,
  difficulty TEXT DEFAULT 'easy',
  duration_min INT NOT NULL,
  distance_m INT NOT NULL,
  transport_modes TEXT[] DEFAULT ARRAY['walk'],
  is_free BOOLEAN DEFAULT false,
  price_cad DECIMAL(10,2),
  cover_image_url TEXT,
  status TEXT DEFAULT 'draft',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  published_at TIMESTAMPTZ,
  UNIQUE(city_id, slug)
);

-- Points
CREATE TABLE IF NOT EXISTS points (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tour_id UUID REFERENCES tours(id) ON DELETE CASCADE,
  order_index INT NOT NULL,
  name JSONB NOT NULL,
  lat FLOAT NOT NULL,
  lng FLOAT NOT NULL,
  trigger_radius_m INT DEFAULT 30,
  type TEXT DEFAULT 'building',
  image_url TEXT,
  logistics JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(tour_id, order_index)
);

-- Scripts (stores text content, audio generated on-demand)
CREATE TABLE IF NOT EXISTS scripts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  point_id UUID REFERENCES points(id) ON DELETE CASCADE,
  language TEXT NOT NULL,
  content TEXT NOT NULL,
  voice_id TEXT NOT NULL,
  voice_settings JSONB DEFAULT '{"stability": 0.5, "clarity": 0.75}',
  persona TEXT DEFAULT 'narrator',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(point_id, language)
);

-- Voice Config
CREATE TABLE IF NOT EXISTS voice_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  language TEXT NOT NULL,
  persona TEXT NOT NULL,
  elevenlabs_voice_id TEXT NOT NULL,
  voice_name TEXT NOT NULL,
  default_settings JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  UNIQUE(language, persona)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_tours_city ON tours(city_id);
CREATE INDEX IF NOT EXISTS idx_tours_status ON tours(status);
CREATE INDEX IF NOT EXISTS idx_points_tour ON points(tour_id);
CREATE INDEX IF NOT EXISTS idx_scripts_point_lang ON scripts(point_id, language);

-- Enable Row Level Security
ALTER TABLE cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE tours ENABLE ROW LEVEL SECURITY;
ALTER TABLE points ENABLE ROW LEVEL SECURITY;
ALTER TABLE scripts ENABLE ROW LEVEL SECURITY;
ALTER TABLE voice_config ENABLE ROW LEVEL SECURITY;

-- RLS Policies (public read access)
CREATE POLICY "Cities are viewable by everyone" ON cities FOR SELECT USING (true);
CREATE POLICY "Tours are viewable by everyone" ON tours FOR SELECT USING (status = 'published');
CREATE POLICY "Points are viewable by everyone" ON points FOR SELECT USING (true);
CREATE POLICY "Scripts are viewable by everyone" ON scripts FOR SELECT USING (true);
CREATE POLICY "Voice config is viewable by everyone" ON voice_config FOR SELECT USING (is_active = true);
