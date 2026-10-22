"""Writes army_memo's black-ink seals from usaf_memo's color ones.

AR 25-50 1-16b(3) prints computer-generated letterhead in black ink. Each pixel
keeps its alpha; its gray level is its darkness against the seal's ink,
#355E93, so the ink prints black and the paper stays white.

Usage: python3 -I design/army_memo/make_black_seal.py   (from the repo root)
"""

import sys
from pathlib import Path

from PIL import Image

SOURCE = Path("quills/usaf_memo/0.3.0/assets")
TARGET = Path("quills/army_memo/0.0.1/assets")
INK_LUMA = 0.2126 * 0x35 + 0.7152 * 0x5E + 0.0722 * 0x93


def blacken(image):
    black = image.convert("RGBA")
    pixels = black.load()
    for y in range(black.height):
        for x in range(black.width):
            r, g, b, a = pixels[x, y]
            luma = 0.2126 * r + 0.7152 * g + 0.0722 * b
            t = min(max((255 - luma) / (255 - INK_LUMA), 0.0), 1.0)
            gray = round(255 * (1 - t))
            pixels[x, y] = (gray, gray, gray, a)
    return black


def main():
    for name in ("dow_seal.png", "dod_seal.png"):
        source = Image.open(SOURCE / name)
        blacken(source).save(TARGET / name, optimize=True)
        print(f"wrote {TARGET / name} {source.size[0]}x{source.size[1]}")


if __name__ == "__main__":
    sys.exit(main())
