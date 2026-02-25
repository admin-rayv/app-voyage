#!/usr/bin/env python3
"""
Fetch existing POIs for a city from Supabase.
Used by poi-scout to avoid duplicates.
"""

import argparse
import sys

try:
    import requests
except ImportError:
    import os
    os.system("pip3 install requests -q")
    import requests

# Supabase config
SUPABASE_URL = "https://lfwnpyttyoefqvhfqajb.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxmd25weXR0eW9lZnF2aGZxYWpiIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTMwNzY1MCwiZXhwIjoyMDg2ODgzNjUwfQ.Hilu9ymXa14JRi7UnvmXVCnEhQDCyv_5yPiVD2DZYjc"

HEADERS = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
}


def get_city_id(city_slug):
    """Look up city by slug (tries multiple formats)"""
    # Try exact match
    r = requests.get(
        f"{SUPABASE_URL}/rest/v1/cities",
        headers=HEADERS,
        params={"slug": f"eq.{city_slug}", "select": "id,name,slug"}
    )
    if r.status_code == 200 and r.json():
        return r.json()[0]
    
    # Try short form (city name only)
    city_name = city_slug.split('-quebec')[0].split('-qc')[0].split('-ontario')[0].split('-canada')[0]
    if city_name != city_slug:
        r = requests.get(
            f"{SUPABASE_URL}/rest/v1/cities",
            headers=HEADERS,
            params={"slug": f"eq.{city_name}", "select": "id,name,slug"}
        )
        if r.status_code == 200 and r.json():
            return r.json()[0]
    
    return None


def get_existing_pois(city_id):
    """Fetch all POIs for a city"""
    r = requests.get(
        f"{SUPABASE_URL}/rest/v1/points",
        headers=HEADERS,
        params={
            "city_id": f"eq.{city_id}",
            "select": "id,name,categories,lat,lng"
        }
    )
    if r.status_code == 200:
        return r.json()
    return []


def main():
    parser = argparse.ArgumentParser(description='List existing POIs for a city')
    parser.add_argument('city_slug', help='City slug (e.g., saint-lambert-quebec-canada or saint-lambert)')
    parser.add_argument('--category', '-c', help='Filter by category')
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    args = parser.parse_args()
    
    # Find city
    city = get_city_id(args.city_slug)
    if not city:
        print(f"❌ Ville non trouvée: {args.city_slug}")
        print("La ville n'existe pas encore dans Supabase. Aucun POI existant.")
        sys.exit(0)
    
    city_name = city['name'].get('fr', city['slug'])
    print(f"🏙️ Ville: {city_name} ({city['id'][:8]}...)")
    
    # Get POIs
    pois = get_existing_pois(city['id'])
    
    # Filter by category if specified
    if args.category:
        pois = [p for p in pois if args.category in p.get('categories', [])]
    
    if not pois:
        print(f"\n✅ Aucun POI existant" + (f" dans la catégorie '{args.category}'" if args.category else ""))
        print("Tu peux proposer n'importe quel POI pour cette ville.")
        sys.exit(0)
    
    print(f"\n📍 {len(pois)} POI(s) existant(s):\n")
    
    if args.json:
        import json
        print(json.dumps(pois, indent=2, ensure_ascii=False))
    else:
        for i, poi in enumerate(pois, 1):
            name_fr = poi['name'].get('fr', 'Sans nom')
            name_en = poi['name'].get('en', '')
            categories = ', '.join(poi.get('categories', []))
            print(f"{i:2}. {name_fr}")
            if name_en and name_en != name_fr:
                print(f"    EN: {name_en}")
            print(f"    📍 {poi['lat']:.4f}, {poi['lng']:.4f}")
            print(f"    🏷️ {categories}")
            print()
    
    print("⚠️ NE PAS proposer ces POIs dans ta recherche (éviter les doublons)!")


if __name__ == "__main__":
    main()
