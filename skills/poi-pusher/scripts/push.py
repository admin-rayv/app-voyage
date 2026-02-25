#!/usr/bin/env python3
"""
POI Pusher - Push POIs and scripts from scout files to Supabase
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path

try:
    import requests
except ImportError:
    print("Installing requests...")
    os.system("pip3 install requests -q")
    import requests

# Supabase config
SUPABASE_URL = "https://lfwnpyttyoefqvhfqajb.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxmd25weXR0eW9lZnF2aGZxYWpiIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTMwNzY1MCwiZXhwIjoyMDg2ODgzNjUwfQ.Hilu9ymXa14JRi7UnvmXVCnEhQDCyv_5yPiVD2DZYjc"

HEADERS = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=representation"
}


def supabase_request(method, table, data=None, params=None):
    """Make a request to Supabase REST API"""
    url = f"{SUPABASE_URL}/rest/v1/{table}"
    if params:
        url += "?" + "&".join(f"{k}={v}" for k, v in params.items())
    
    response = requests.request(method, url, headers=HEADERS, json=data)
    
    if response.status_code >= 400:
        print(f"❌ Supabase error: {response.status_code}")
        print(response.text)
        return None
    
    if response.text:
        return response.json()
    return True


def lookup_city(slug):
    """Look up city_id by slug (tries multiple formats)"""
    # Try exact match first
    result = supabase_request("GET", "cities", params={"slug": f"eq.{slug}", "select": "id,name,slug"})
    if result and len(result) > 0:
        city = result[0]
        name = city['name'].get('fr', city['name'].get('en', slug))
        return city['id'], name
    
    # Try just the city name (first part before province)
    # e.g., "saint-lambert-quebec-canada" -> "saint-lambert"
    city_name = slug.split('-quebec')[0].split('-qc')[0].split('-ontario')[0].split('-canada')[0]
    if city_name != slug:
        result = supabase_request("GET", "cities", params={"slug": f"eq.{city_name}", "select": "id,name,slug"})
        if result and len(result) > 0:
            city = result[0]
            name = city['name'].get('fr', city['name'].get('en', city_name))
            return city['id'], name
    
    # Try LIKE match
    result = supabase_request("GET", "cities", params={"slug": f"like.{slug.split('-')[0]}%", "select": "id,name,slug"})
    if result and len(result) > 0:
        city = result[0]
        name = city['name'].get('fr', city['name'].get('en', slug))
        return city['id'], name
    
    return None, None


def create_city(folder_slug, pois):
    """Create a new city from folder slug and POI data"""
    # Parse folder slug: city-province-country (e.g., saint-lambert-quebec-canada)
    parts = folder_slug.split('-')
    
    # Try to identify country (last part)
    country = 'CA'  # Default
    if parts[-1] == 'canada':
        country = 'CA'
        parts = parts[:-1]
    elif parts[-1] == 'france':
        country = 'FR'
        parts = parts[:-1]
    elif parts[-1] == 'usa' or parts[-1] == 'us':
        country = 'US'
        parts = parts[:-1]
    
    # Try to identify province/region
    region = None
    province_map = {
        'quebec': 'QC', 'qc': 'QC',
        'ontario': 'ON', 'on': 'ON',
        'british-columbia': 'BC', 'bc': 'BC',
        'alberta': 'AB', 'ab': 'AB',
    }
    for i, part in enumerate(parts):
        if part in province_map:
            region = province_map[part]
            parts = parts[:i]
            break
    
    # Remaining parts are the city name
    city_slug = '-'.join(parts)
    city_name_raw = ' '.join(parts).title().replace('-', ' ')
    
    # Calculate center from POIs
    lats = []
    lngs = []
    for poi in pois:
        if poi.get('db_data'):
            lat = poi['db_data'].get('lat')
            lng = poi['db_data'].get('lng')
            if lat and lng:
                lats.append(lat)
                lngs.append(lng)
    
    center_lat = sum(lats) / len(lats) if lats else 0
    center_lng = sum(lngs) / len(lngs) if lngs else 0
    
    city_data = {
        "slug": city_slug,
        "name": {"fr": city_name_raw, "en": city_name_raw},
        "country": country,
        "region": region,
        "center_lat": round(center_lat, 6),
        "center_lng": round(center_lng, 6),
        "timezone": "America/Toronto" if country == 'CA' else "UTC",
        "available_languages": ["fr", "en", "es"]
    }
    
    print(f"🏙️ Creating city: {city_name_raw} ({city_slug})")
    print(f"   Country: {country}, Region: {region}")
    print(f"   Center: {center_lat:.4f}, {center_lng:.4f}")
    
    result = supabase_request("POST", "cities", city_data)
    if result and len(result) > 0:
        return result[0]['id'], city_name_raw
    return None, None


def parse_scout_file(filepath):
    """Parse a scout file and extract POIs and scripts"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    pois = []
    
    # Find all POI sections (only main ## POI, not #### POI in reports)
    # Stop at "## Rapport" or "---" section dividers
    poi_pattern = r'^## POI \d+: (.+?)\n(.*?)(?=^## POI \d+:|^## Rapport|^---|\Z)'
    poi_matches = re.findall(poi_pattern, content, re.DOTALL | re.MULTILINE)
    
    for poi_name, poi_content in poi_matches:
        poi_data = {
            'name': poi_name.strip(),
            'db_data': None,
            'scripts': []
        }
        
        # Extract DB data block
        db_pattern = r'### 🗄️ Données BD.*?```json\s*(\{.*?\})\s*```'
        db_match = re.search(db_pattern, poi_content, re.DOTALL)
        if db_match:
            try:
                poi_data['db_data'] = json.loads(db_match.group(1))
            except json.JSONDecodeError as e:
                print(f"⚠️ JSON error in POI '{poi_name}': {e}")
        
        # Extract Scripts BD block
        scripts_pattern = r'### 🗄️ Scripts BD.*?```json\s*(\[.*?\])\s*```'
        scripts_match = re.search(scripts_pattern, poi_content, re.DOTALL)
        if scripts_match:
            try:
                poi_data['scripts'] = json.loads(scripts_match.group(1))
            except json.JSONDecodeError as e:
                print(f"⚠️ Scripts JSON error in POI '{poi_name}': {e}")
        
        # Check verdict
        if "✅ APPROUVÉ" in poi_content or "APPROUVÉ" in poi_content:
            poi_data['approved'] = True
        else:
            poi_data['approved'] = False
        
        pois.append(poi_data)
    
    return pois


def push_poi(city_id, poi_data):
    """Insert a POI into the points table"""
    db_data = poi_data['db_data']
    if not db_data:
        return None
    
    point = {
        "city_id": city_id,
        "name": db_data.get('name'),
        "lat": db_data.get('lat'),
        "lng": db_data.get('lng'),
        "trigger_radius_m": db_data.get('trigger_radius_m', 40),
        "type": db_data.get('type', 'building'),
        "categories": db_data.get('categories', []),
        "image_url": db_data.get('image_url'),
        "logistics": db_data.get('logistics', {}),
        "is_published": False  # Don't publish by default
    }
    
    result = supabase_request("POST", "points", point)
    if result and len(result) > 0:
        return result[0]['id']
    return None


def push_scripts(point_id, scripts):
    """Insert scripts for a POI"""
    inserted = []
    for script in scripts:
        script_data = {
            "point_id": point_id,
            "language": script.get('language'),
            "content": script.get('content'),
            "persona": script.get('persona', 'marco')
        }
        
        result = supabase_request("POST", "scripts", script_data)
        if result:
            inserted.append(script.get('language'))
    
    return inserted


def main():
    parser = argparse.ArgumentParser(description='Push POIs to Supabase')
    parser.add_argument('--file', '-f', help='Path to scout file')
    parser.add_argument('--lookup-city', '-c', help='Look up city by slug')
    parser.add_argument('--dry-run', '-d', action='store_true', help='Parse only, no push')
    args = parser.parse_args()
    
    if args.lookup_city:
        city_id, city_name = lookup_city(args.lookup_city)
        if city_id:
            print(f"✅ Found: {city_name} ({city_id})")
        else:
            print(f"❌ City not found: {args.lookup_city}")
        return
    
    if not args.file:
        print("Usage: push.py --file <path> or --lookup-city <slug>")
        return
    
    filepath = Path(args.file)
    if not filepath.exists():
        # Try relative to app-voyage
        filepath = Path.home() / ".openclaw/workspace/app-voyage" / args.file
    
    if not filepath.exists():
        print(f"❌ File not found: {args.file}")
        return
    
    print(f"🔍 Parsing: {filepath}")
    
    # Extract city slug from path
    # Expected: content/{city-slug}/scout-{category}.md
    parts = filepath.parts
    city_slug = None
    for i, part in enumerate(parts):
        if part == 'content' and i + 1 < len(parts):
            city_slug = parts[i + 1]
            break
    
    if not city_slug:
        print("❌ Could not extract city slug from path")
        return
    
    # Parse the file first (need POIs to calculate city center)
    pois = parse_scout_file(filepath)
    print(f"📄 Found {len(pois)} POIs")
    
    city_id, city_name = lookup_city(city_slug)
    city_created = False
    if not city_id:
        print(f"⚠️ City not found: {city_slug}")
        if args.dry_run:
            print("   (would create city automatically)")
            # Fake city for dry run
            city_id = "dry-run-city-id"
            city_name = city_slug.split('-')[0].title()
        else:
            print("Creating city automatically...")
            city_id, city_name = create_city(city_slug, pois)
            if not city_id:
                print("❌ Failed to create city")
                return
            print(f"✅ City created: {city_name} ({city_id})")
            city_created = True
    else:
        print(f"📍 City: {city_name} ({city_id})")
    
    # Check all approved
    not_approved = [p for p in pois if not p.get('approved')]
    if not_approved:
        print(f"\n⚠️ {len(not_approved)} POIs not approved:")
        for p in not_approved:
            print(f"  - {p['name']}")
        print("\nFix these before pushing.")
        return
    
    if args.dry_run:
        print("\n🔍 Dry run - no changes made")
        for poi in pois:
            print(f"  - {poi['name']}: {len(poi.get('scripts', []))} scripts")
        return
    
    # Push POIs
    print("\nPushing POIs...")
    poi_count = 0
    script_count = 0
    errors = 0
    
    for poi in pois:
        point_id = push_poi(city_id, poi)
        if point_id:
            poi_name = poi['db_data']['name'].get('fr', poi['name'])
            print(f"  ✅ {poi_name} ({point_id[:8]}...)")
            poi_count += 1
            
            # Push scripts
            scripts = poi.get('scripts', [])
            if scripts:
                inserted = push_scripts(point_id, scripts)
                if inserted:
                    print(f"     📝 Scripts: {', '.join(inserted)}")
                    script_count += len(inserted)
        else:
            print(f"  ❌ Failed: {poi['name']}")
            errors += 1
    
    print(f"\n📊 Summary:")
    print(f"  - POIs inserted: {poi_count}")
    print(f"  - Scripts inserted: {script_count}")
    print(f"  - Errors: {errors}")
    
    if errors == 0:
        print("\n✅ Push complete!")
    else:
        print(f"\n⚠️ Completed with {errors} errors")


if __name__ == "__main__":
    main()
