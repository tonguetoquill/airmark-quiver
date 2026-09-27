"""Fetch the candidate faces from google/fonts into ./fonts.

Each family's upright and italic nearest weight 400 are taken, and a variable
font is instanced at weight 400 with every other axis at its default, so the
candidates are compared at their Regular.

    python3 fetch_fonts.py            # fetch FAMILIES
    python3 fetch_fonts.py --survey   # list the Google Fonts families with
                                      # small caps, native (any category) or
                                      # by smcp (serif), grouped by what
                                      # their italic does

Needs git and fontTools.
"""

import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from fontTools.pens.boundsPen import BoundsPen
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

here = Path(__file__).resolve().parent

# google/fonts directories, under ofl/.
FAMILIES = [
    # The first round.
    "ebgaramond", "cormorant", "cormorantgaramond", "cormorantsc",
    # Upright and italic both carry smcp.
    "alegreya", "ancizarserif", "andadapro", "bitter", "bodonimoda", "bonanova",
    "brygada1918", "castoro", "charissil", "gentiumbookplus", "ibarrarealnova",
    "literata", "merriweather", "neuton", "notoserif", "petrona", "piazzolla",
    "playfairdisplay", "poltawskinowy", "spectral", "stixtwotext", "zillaslab",
    # Small caps natively, with an italic.
    "alegreyasc", "bodonimodasc", "bonanovasc", "playfairdisplaysc", "spectralsc",
    "alegreyasanssc", "arsenalsc", "alumnisanssc",
    # Small caps natively, no italic.
    "vollkornsc", "imfellenglishsc", "marcellussc", "baskervvillesc", "matesc", "sedansc",
    # Upright carries smcp, italic does not.
    "sourceserif4", "vollkorn", "cardo", "baskervville", "sortsmillgoudy", "gfsdidot",
]


def git(repo, *args, stdin=None):
    subprocess.run(["git", "-C", str(repo), *args], input=stdin, text=True, check=True)


def styles(metadata):
    """(style, filename, weight) for each file a METADATA.pb lists."""
    return [
        (re.search(r'style: "(\w+)"', f)[1], re.search(r'filename: "([^"]+)"', f)[1],
         int(re.search(r"weight: (\d+)", f)[1]))
        for f in re.findall(r"fonts \{(.*?)\n\}", metadata, re.S)
    ]


def nearest_400(files, style):
    matches = [f for f in files if f[0] == style]
    return min(matches, key=lambda f: abs(f[2] - 400))[1] if matches else None


def sparse_paths(paths):
    # Sparse-checkout patterns are globs, and variable fonts are named `[wght]`.
    return "".join("/" + p.replace("[", r"\[").replace("]", r"\]") + "\n" for p in paths)


def gsub_features(path):
    font = TTFont(path, lazy=True)
    if "GSUB" not in font:
        return set()
    return {r.FeatureTag for r in font["GSUB"].table.FeatureList.FeatureRecord}


def is_native(name, upright):
    """Whether a family's own lowercase are small caps. Google names such a
    family `… SC`, except the Noto CJK `SC`, Simplified Chinese. One under
    another name, such as Cinzel, draws its lowercase without ascenders."""
    if name.endswith(" SC"):
        return not name.startswith("Noto")
    font = TTFont(upright)
    glyphs, cmap = font.getGlyphSet(), font.getBestCmap()

    def top(char):
        pen = BoundsPen(glyphs)
        glyphs[cmap[ord(char)]].draw(pen)
        return pen.bounds[3]

    try:
        x, cap = top("x"), top("H")
        return max(top("h"), top("d"), top("l")) <= x * 1.04 and x < cap * 0.95
    except (KeyError, TypeError):
        return False


def at_regular(path):
    font = TTFont(path)
    if "fvar" not in font:
        return font
    axes = {a.axisTag: a.defaultValue for a in font["fvar"].axes}
    if "wght" in axes:
        axes["wght"] = 400
    return instancer.instantiateVariableFont(font, axes, updateFontNames=True)


def main():
    survey = "--survey" in sys.argv
    work = Path(tempfile.mkdtemp())
    try:
        repo = work / "gfonts"
        subprocess.run(["git", "clone", "-q", "--depth", "1", "--filter=blob:none",
                        "--sparse", "https://github.com/google/fonts.git", str(repo)], check=True)
        git(repo, "sparse-checkout", "set", "--no-cone", "/*/*/METADATA.pb")

        picks, categories = {}, {}
        for metadata in sorted(repo.glob("*/*/METADATA.pb")):
            family = metadata.parent
            text = metadata.read_text()
            if not survey and (family.parent.name != "ofl" or family.name not in FAMILIES):
                continue
            files = styles(text)
            picks[family] = (re.search(r'^name: "([^"]+)"', text, re.M)[1],
                             nearest_400(files, "normal"), nearest_400(files, "italic"))
            categories[family] = re.findall(r'category: "(\w+)"', text)
        if survey:
            picks = {
                d: p for d, p in picks.items()
                if p[1] and ("SERIF" in categories[d] or p[0].endswith(" SC"))
            }

        wanted = [f"{d.relative_to(repo)}/{f}" for d, (_, *fs) in picks.items() for f in fs if f]
        git(repo, "sparse-checkout", "set", "--no-cone", "--stdin", stdin=sparse_paths(wanted))

        if survey:
            groups = {}
            for family, (name, upright, italic) in sorted(picks.items(), key=lambda p: p[1][0]):
                if is_native(name, family / upright):
                    group = "Small caps natively, " + ("with an italic" if italic else "no italic")
                elif "smcp" not in gsub_features(family / upright):
                    continue
                elif not italic:
                    group = "smcp, no italic"
                elif "smcp" in gsub_features(family / italic):
                    group = "smcp, upright and italic"
                else:
                    group = "smcp, upright only"
                groups.setdefault(group, []).append(f"{name:30} {family.relative_to(repo)}")
            for group, rows in groups.items():
                print(f"{group} ({len(rows)}):", *rows, sep="\n  ")
            return

        out = here / "fonts"
        out.mkdir(exist_ok=True)
        for family, (_, *files) in picks.items():
            for f in filter(None, files):
                at_regular(family / f).save(out / f.replace("[", "").replace("]", "").replace(",", "-"))
        print(f"{len(picks)} families into {out}")
    finally:
        shutil.rmtree(work)


main()
