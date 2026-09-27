"""Render the tag-line spike to shots/: the specimen sheet, one full memo page
per candidate and style, and a sheet of their footers cropped side by side.

Run from the repo root after ./fetch_fonts.sh; needs a typst binary (TYPST to
point at one off PATH) and Pillow.
"""

import os
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

here = Path(__file__).resolve().parent
repo = here.parents[2]
shots = here / "shots"
package_fonts = repo / "quills/usaf_memo/0.3.0/packages/tonguetoquill-usaf-memo/fonts"
typst = os.environ.get("TYPST", "typst")
PPI = 200

# Mirrors `candidates` in candidates.typ.
CANDIDATES = [
    ("NimbusRomNo9L", "none", "NimbusRomNo9L — today"),
    ("NimbusRomNo9L", "synth", "NimbusRomNo9L — synthesized SC"),
    ("Cinzel", "native", "Cinzel"),
    ("EB Garamond", "smcp", "EB Garamond"),
    ("Cormorant", "smcp", "Cormorant"),
    ("Cormorant Garamond", "smcp", "Cormorant Garamond"),
    ("Cormorant SC", "native", "Cormorant SC"),
]


def compile_(source, out, *inputs):
    args = [typst, "compile", "--root", str(repo), "--ignore-system-fonts",
            "--font-path", str(here / "fonts"), "--font-path", str(package_fonts),
            "--ppi", str(PPI)]
    for i in inputs:
        args += ["--input", i]
    subprocess.run(args + [str(here / source), str(out)], check=True)


def slug(font, caps, italic):
    return f"{font.lower().replace(' ', '_')}-{caps}{'-italic' if italic else ''}"


shots.mkdir(exist_ok=True)
compile_("specimen.typ", shots / "specimen.png")

# The footer band: 4.25in wide, centered, 1in tall around the tag line.
band = (int(2.125 * PPI), int(9.8 * PPI), int(6.375 * PPI), int(10.8 * PPI))
crops = {}
for font, caps, _ in CANDIDATES:
    for italic in (False, True):
        page = shots / f"memo-{slug(font, caps, italic)}.png"
        compile_("in_context.typ", page, f"font={font}", f"caps={caps}",
                 f"italic={'true' if italic else 'false'}")
        crops[font, caps, italic] = Image.open(page).convert("RGB").crop(band)

label_w, head_h = 520, 90
cw, ch = band[2] - band[0], band[3] - band[1]
sheet = Image.new("RGB", (label_w + 2 * cw, head_h + ch * len(CANDIDATES)), "white")
draw = ImageDraw.Draw(sheet)
label_font = ImageFont.truetype(str(package_fonts / "NimbusRomanNo9L/NimbusRomNo9L-Med.otf"), 30)
for x, head in ((label_w, "Small caps"), (label_w + cw, "Italic small caps")):
    draw.text((x + cw // 2, head_h // 2), head, font=label_font, fill="black", anchor="mm")
for row, (font, caps, label) in enumerate(CANDIDATES):
    y = head_h + row * ch
    sheet.paste(crops[font, caps, False], (label_w, y))
    sheet.paste(crops[font, caps, True], (label_w + cw, y))
    draw.line((0, y, sheet.width, y), fill=(210, 210, 210), width=2)
    draw.text((30, y + ch // 2), label, font=label_font, fill="black", anchor="lm")
sheet.save(shots / "in_context.png")
print(f"wrote {shots}")
