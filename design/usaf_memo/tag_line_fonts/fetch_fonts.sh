#!/usr/bin/env bash
# Fetch the candidate faces from google/fonts into ./fonts, instancing each
# variable font at weight 400 so every candidate is compared at its Regular.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

git clone -q --depth 1 --filter=blob:none --sparse https://github.com/google/fonts.git "$work/gfonts"
git -C "$work/gfonts" sparse-checkout set ofl/ebgaramond ofl/cormorant ofl/cormorantgaramond ofl/cormorantsc

mkdir -p "$here/fonts"
cp "$work/gfonts/ofl/cormorantsc/CormorantSC-Regular.ttf" "$here/fonts/"
python3 - "$work/gfonts/ofl" "$here/fonts" <<'PY'
import glob, os, sys
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer
src, out = sys.argv[1:]
for f in glob.glob(f"{src}/*/*wght*.ttf"):
    base = os.path.basename(f).replace("[wght]", "")
    if "Italic" not in base:
        base = base.replace(".ttf", "-Regular.ttf")
    instancer.instantiateVariableFont(TTFont(f), {"wght": 400}, updateFontNames=True).save(f"{out}/{base}")
PY
ls "$here/fonts"
