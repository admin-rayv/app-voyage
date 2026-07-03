#!/usr/bin/env python3
"""Génère les tuiles placeholder (le proxy/offline bloque les vraies tuiles CARTO)."""
from PIL import Image, ImageDraw
import random, os

HERE = os.path.dirname(__file__)

def make_tile(bg, road, block, path):
    img = Image.new('RGB', (256, 256), bg)
    d = ImageDraw.Draw(img)
    rnd = random.Random(42)
    for x in range(0, 256, 64):
        for y in range(0, 256, 64):
            if rnd.random() < 0.5:
                d.rectangle((x+8, y+8, x+56, y+56), fill=block)
    for i in range(0, 257, 64):
        d.line((i, 0, i, 256), fill=road, width=6)
        d.line((0, i, 256, i), fill=road, width=6)
    d.line((0, 100, 256, 180), fill=road, width=9)
    img.save(path)

make_tile((237, 234, 227), (255, 255, 255), (229, 225, 216), f'{HERE}/tile_light.png')
make_tile((22, 26, 29), (43, 48, 52), (28, 33, 36), f'{HERE}/tile_dark.png')
print('tiles ok')
