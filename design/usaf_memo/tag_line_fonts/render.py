"""Render the tag-line spike to shots/: the specimen and survey sheets, one full
memo page per candidate and style, and sheets of their footers cropped side by
side.

Run from the repo root after fetch_fonts.py; needs a typst binary (TYPST to
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

# The survey's finalists, against EB Garamond.
FINALISTS = [
    ("EB Garamond", "smcp", "EB Garamond"),
    ("STIX Two Text", "smcp", "STIX Two Text"),
    ("Spectral", "smcp", "Spectral"),
    ("Castoro", "smcp", "Castoro"),
    ("Brygada 1918", "smcp", "Brygada 1918"),
    ("Ibarra Real Nova", "smcp", "Ibarra Real Nova"),
    ("Alegreya", "smcp", "Alegreya"),
]

# Small caps natively, with an italic. Mirrors `native` in native.typ.
NATIVE = [
    ("Spectral SC", "native", "Spectral SC"),
    ("Bona Nova SC", "native", "Bona Nova SC"),
    ("Alegreya SC", "native", "Alegreya SC"),
    ("Playfair Display SC", "native", "Playfair Display SC"),
    ("Bodoni Moda SC 11pt", "native", "Bodoni Moda SC"),
    ("Alegreya Sans SC", "native", "Alegreya Sans SC"),
    ("Arsenal SC", "native", "Arsenal SC"),
    ("Alumni Sans SC", "native", "Alumni Sans SC"),
]

# One or two from each of shortlist.typ's tiers.
SHORTLIST = [
    ("Spectral SC", "native", "Spectral SC", True),
    ("Playfair Display SC", "native", "Playfair Display SC", True),
    ("Cinzel", "native", "Cinzel", False),
    ("Vollkorn SC", "native", "Vollkorn SC", False),
    ("Marcellus SC", "native", "Marcellus SC", False),
    ("EB Garamond", "smcp", "EB Garamond", True),
    ("STIX Two Text", "smcp", "STIX Two Text", True),
    ("Source Serif 4", "smcp", "Source Serif 4", False),
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


# The footer band: 3in wide, centered, 0.6in tall around the tag line.
BAND = (int(2.75 * PPI), int(10.05 * PPI), int(5.75 * PPI), int(10.65 * PPI))
LABEL_FONT = ImageFont.truetype(str(package_fonts / "NimbusRomanNo9L/NimbusRomNo9L-Med.otf"), 30)
NOTE_FONT = ImageFont.truetype(str(package_fonts / "NimbusRomanNo9L/NimbusRomNo9L-RegIta.otf"), 26)


def footer_sheet(candidates, out):
    """Each candidate is (font, caps, label) or (font, caps, label, has italic
    small caps); a face without them leaves its italic cell to say so."""
    crops = {}
    for font, caps, _, *italics in candidates:
        for italic in (False, True)[: 1 if italics == [False] else 2]:
            page = shots / f"memo-{slug(font, caps, italic)}.png"
            compile_("in_context.typ", page, f"font={font}", f"caps={caps}",
                     f"italic={'true' if italic else 'false'}")
            crops[font, caps, italic] = Image.open(page).convert("RGB").crop(BAND)

    label_w, head_h = 520, 90
    cw, ch = BAND[2] - BAND[0], BAND[3] - BAND[1]
    sheet = Image.new("RGB", (label_w + 2 * cw, head_h + ch * len(candidates)), "white")
    draw = ImageDraw.Draw(sheet)
    for x, head in ((label_w, "Small caps"), (label_w + cw, "Italic small caps")):
        draw.text((x + cw // 2, head_h // 2), head, font=LABEL_FONT, fill="black", anchor="mm")
    for row, (font, caps, label, *_) in enumerate(candidates):
        y = head_h + row * ch
        sheet.paste(crops[font, caps, False], (label_w, y))
        if (font, caps, True) in crops:
            sheet.paste(crops[font, caps, True], (label_w + cw, y))
        else:
            draw.text((label_w + cw + cw // 2, y + ch // 2), "no italic small caps",
                      font=NOTE_FONT, fill=(140, 140, 140), anchor="mm")
        draw.line((0, y, sheet.width, y), fill=(210, 210, 210), width=2)
        draw.text((30, y + ch // 2), label, font=LABEL_FONT, fill="black", anchor="lm")
    sheet.save(shots / out)


shots.mkdir(exist_ok=True)
compile_("specimen.typ", shots / "specimen.png")
compile_("survey.typ", shots / "survey.png")
compile_("native.typ", shots / "native.png")
compile_("shortlist.typ", shots / "shortlist-{p}.png")
footer_sheet(CANDIDATES, "in_context.png")
footer_sheet(FINALISTS, "in_context_finalists.png")
footer_sheet(NATIVE, "in_context_native.png")
footer_sheet(SHORTLIST, "in_context_shortlist.png")
print(f"wrote {shots}")
