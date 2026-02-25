-- ============================================
-- App Voyage — Schéma initial (POI-first)
-- Migration: 001_initial_schema.sql
-- Date: 2026-02-25
-- ============================================

-- ============================================
-- 1. TABLES PRINCIPALES
-- ============================================

-- Cities (Villes)
CREATE TABLE cities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  name JSONB NOT NULL,
  country TEXT NOT NULL DEFAULT 'CA',
  region TEXT,
  center_lat FLOAT NOT NULL,
  center_lng FLOAT NOT NULL,
  timezone TEXT DEFAULT 'America/Toronto',
  available_languages TEXT[] DEFAULT ARRAY['fr', 'en'],
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Points (POIs standalone, liés à une ville)
CREATE TABLE points (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  city_id UUID REFERENCES cities(id) ON DELETE CASCADE NOT NULL,
  name JSONB NOT NULL,
  lat FLOAT NOT NULL,
  lng FLOAT NOT NULL,
  trigger_radius_m INT DEFAULT 40,
  type TEXT DEFAULT 'building',
  categories TEXT[] DEFAULT '{}',
  image_url TEXT,
  logistics JSONB DEFAULT '{}',
  is_published BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Scripts (Contenu audio texte, par POI et par langue)
CREATE TABLE scripts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  point_id UUID REFERENCES points(id) ON DELETE CASCADE NOT NULL,
  language TEXT NOT NULL,
  content TEXT NOT NULL,
  voice_id TEXT,
  voice_settings JSONB DEFAULT '{"stability": 0.5, "clarity": 0.75}',
  persona TEXT DEFAULT 'narrator',
  word_count INT GENERATED ALWAYS AS (
    array_length(regexp_split_to_array(content, '\s+'), 1)
  ) STORED,
  estimated_duration_sec INT GENERATED ALWAYS AS (
    CAST(array_length(regexp_split_to_array(content, '\s+'), 1) * 0.4 AS INT)
  ) STORED,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(point_id, language)
);

-- Voice Config (Configuration des voix ElevenLabs)
CREATE TABLE voice_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  language TEXT NOT NULL,
  persona TEXT NOT NULL,
  elevenlabs_voice_id TEXT NOT NULL,
  voice_name TEXT NOT NULL,
  default_settings JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  UNIQUE(language, persona)
);

-- ============================================
-- 2. TABLES V2 (Tours curatés)
-- ============================================

-- Tours (Collections curatées de POIs — V2)
CREATE TABLE tours (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  city_id UUID REFERENCES cities(id) ON DELETE CASCADE NOT NULL,
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

-- Tour-Points (Table de jointure many-to-many — V2)
CREATE TABLE tour_points (
  tour_id UUID REFERENCES tours(id) ON DELETE CASCADE,
  point_id UUID REFERENCES points(id) ON DELETE CASCADE,
  order_index INT NOT NULL,
  PRIMARY KEY (tour_id, point_id)
);

-- ============================================
-- 3. INDEX
-- ============================================

CREATE INDEX idx_points_city ON points(city_id);
CREATE INDEX idx_points_published ON points(city_id, is_published);
CREATE INDEX idx_points_categories ON points USING GIN(categories);
CREATE INDEX idx_scripts_point_lang ON scripts(point_id, language);
CREATE INDEX idx_tours_city ON tours(city_id);
CREATE INDEX idx_tours_status ON tours(status);
CREATE INDEX idx_tour_points_tour ON tour_points(tour_id);
CREATE INDEX idx_tour_points_point ON tour_points(point_id);

-- ============================================
-- 4. ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE points ENABLE ROW LEVEL SECURITY;
ALTER TABLE scripts ENABLE ROW LEVEL SECURITY;
ALTER TABLE voice_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE tours ENABLE ROW LEVEL SECURITY;
ALTER TABLE tour_points ENABLE ROW LEVEL SECURITY;

-- Public read access for published content (anon users can browse)
CREATE POLICY "cities_read" ON cities FOR SELECT USING (true);
CREATE POLICY "points_read" ON points FOR SELECT USING (is_published = true);
CREATE POLICY "scripts_read" ON scripts FOR SELECT 
  USING (EXISTS (SELECT 1 FROM points WHERE points.id = scripts.point_id AND points.is_published = true));
CREATE POLICY "voice_config_read" ON voice_config FOR SELECT USING (is_active = true);
CREATE POLICY "tours_read" ON tours FOR SELECT USING (status = 'published');
CREATE POLICY "tour_points_read" ON tour_points FOR SELECT
  USING (EXISTS (SELECT 1 FROM tours WHERE tours.id = tour_points.tour_id AND tours.status = 'published'));

-- Service role has full access (for admin/content management)
-- (Supabase service_role bypasses RLS by default)

-- ============================================
-- 5. UPDATED_AT TRIGGER
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cities_updated_at BEFORE UPDATE ON cities
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER points_updated_at BEFORE UPDATE ON points
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER scripts_updated_at BEFORE UPDATE ON scripts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER tours_updated_at BEFORE UPDATE ON tours
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
