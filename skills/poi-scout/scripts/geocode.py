#!/usr/bin/env python3
"""Geocode an address using OpenStreetMap Nominatim (free, no API key).

Usage:
  geocode.py <address>                    # Address → GPS
  geocode.py --reverse <lat>,<lng>        # GPS → Address
"""

import json
import sys
import urllib.request
import urllib.parse

def geocode(address):
    """Return (lat, lng) for an address, or None."""
    query = urllib.parse.urlencode({
        "q": address,
        "format": "json",
        "limit": 1
    })
    url = f"https://nominatim.openstreetmap.org/search?{query}"
    req = urllib.request.Request(url, headers={"User-Agent": "AppVoyage/1.0"})
    try:
        resp = urllib.request.urlopen(req, timeout=10)
        data = json.loads(resp.read())
        if data:
            return float(data[0]["lat"]), float(data[0]["lon"])
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
    return None

def reverse_geocode(lat, lng):
    """Return address for GPS coordinates, or None."""
    query = urllib.parse.urlencode({
        "lat": lat,
        "lon": lng,
        "format": "json",
        "addressdetails": 1
    })
    url = f"https://nominatim.openstreetmap.org/reverse?{query}"
    req = urllib.request.Request(url, headers={"User-Agent": "AppVoyage/1.0"})
    try:
        resp = urllib.request.urlopen(req, timeout=10)
        data = json.loads(resp.read())
        if data and "display_name" in data:
            return {
                "display_name": data["display_name"],
                "address": data.get("address", {}),
                "type": data.get("type", "unknown"),
                "name": data.get("name", "")
            }
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
    return None

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage:")
        print('  geocode.py <address>              # Address → GPS')
        print('  geocode.py --reverse <lat>,<lng>  # GPS → Address')
        print()
        print('Examples:')
        print('  geocode.py "349 Riverside, Saint-Lambert, QC"')
        print('  geocode.py --reverse 45.5044,-73.5174')
        sys.exit(1)
    
    if sys.argv[1] == "--reverse":
        if len(sys.argv) < 3:
            print("Error: --reverse requires coordinates (lat,lng)")
            sys.exit(1)
        coords = sys.argv[2].replace(" ", "").split(",")
        if len(coords) != 2:
            print("Error: coordinates must be lat,lng format")
            sys.exit(1)
        lat, lng = float(coords[0]), float(coords[1])
        result = reverse_geocode(lat, lng)
        if result:
            print(f"Address: {result['display_name']}")
            if result['name']:
                print(f"Name: {result['name']}")
            print(f"Type: {result['type']}")
            addr = result['address']
            if addr:
                parts = []
                if 'house_number' in addr:
                    parts.append(addr['house_number'])
                if 'road' in addr:
                    parts.append(addr['road'])
                if 'city' in addr or 'town' in addr or 'municipality' in addr:
                    parts.append(addr.get('city') or addr.get('town') or addr.get('municipality'))
                if 'state' in addr:
                    parts.append(addr['state'])
                if 'country' in addr:
                    parts.append(addr['country'])
                print(f"Parsed: {', '.join(parts)}")
        else:
            print("NOT_FOUND")
            sys.exit(1)
    else:
        address = " ".join(sys.argv[1:])
        result = geocode(address)
        if result:
            print(f"{result[0]}, {result[1]}")
        else:
            print("NOT_FOUND")
            sys.exit(1)
