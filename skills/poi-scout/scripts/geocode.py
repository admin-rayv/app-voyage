#!/usr/bin/env python3
"""Geocode an address using OpenStreetMap Nominatim (free, no API key)."""

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

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: geocode.py <address>")
        print('Example: geocode.py "349 Riverside, Saint-Lambert, QC"')
        sys.exit(1)
    
    address = " ".join(sys.argv[1:])
    result = geocode(address)
    if result:
        print(f"{result[0]}, {result[1]}")
    else:
        print("NOT_FOUND")
        sys.exit(1)
