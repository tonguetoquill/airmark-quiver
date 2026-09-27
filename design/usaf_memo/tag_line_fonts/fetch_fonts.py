"""Fetch the candidate faces from google/fonts into ./fonts.

Each family's upright and italic nearest weight 400 are taken, and a variable
font is instanced at weight 400 with every other axis at its default, so the
candidates are compared at their Regular.

    python3 fetch_fonts.py            # fetch FAMILIES
    python3 fetch_fonts.py --survey   # list every serif family on Google
                                      # Fonts whose upright and italic both
                                      # carry smcp

Needs git and fontTools.
"""

import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

here = Path(__file__).resolve().parent

# google/fonts directories, under ofl/.
FAMILIES = [
    # The first round.
    "ebgaramond", "cormorant", "cormorantgaramond", "cormorantsc",
    # The survey's: upright and italic both carry smcp.
    "alegreya", "ancizarserif", "andadapro", "bitter", "bodonimoda", "bonanova",
    "brygada1918", "castoro", "charissil", "gentiumbookplus", "ibarrarealnova",
    "literata", "merriweather", "neuton", "notoserif", "petrona", "piazzolla",
    "playfairdisplay", "poltawskinowy", "spectral", "stixtwotext", "zillaslab",
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

        picks = {}
        for metadata in sorted(repo.glob("*/*/METADATA.pb")):
            family = metadata.parent
            text = metadata.read_text()
            if survey:
                if "SERIF" not in re.findall(r'category: "(\w+)"', text):
                    continue
            elif family.parent.name != "ofl" or family.name not in FAMILIES:
                continue
            files = styles(text)
            picks[family] = (re.search(r'^name: "([^"]+)"', text, re.M)[1],
                             nearest_400(files, "normal"), nearest_400(files, "italic"))
        if survey:
            picks = {d: p for d, p in picks.items() if p[1] and p[2]}

        wanted = [f"{d.relative_to(repo)}/{f}" for d, (_, *fs) in picks.items() for f in fs if f]
        git(repo, "sparse-checkout", "set", "--no-cone", "--stdin", stdin=sparse_paths(wanted))

        if survey:
            for family, (name, upright, italic) in sorted(picks.items(), key=lambda p: p[1][0]):
                if "smcp" in gsub_features(family / upright) and "smcp" in gsub_features(family / italic):
                    print(f"{name:28} {family.relative_to(repo)}")
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
