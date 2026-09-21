#!/usr/bin/env python3
"""Two officials sign side by side, the junior at the left margin.

Usage: python3 check_dual_signature.py

AFH 33-337 "Signature Block": "If dual signatures are required, type the junior
ranking official's signature block at the left margin; type the senior ranking
official's signature block 4.5 inches from the left edge of the page."

Every assertion is a relation against the same memorandum signed by one
official, so no length the quill single-sources is restated here: the junior
block stands where the body's own left edge is, the two blocks open on one line,
and the senior block lands where the single-signer render puts it — including
where the junior block is long enough to crowd the anchor, which is the case
that must shift nothing and overlap nothing. Each block's signing widget sits
over its own column.

`quillkit test` renders the schema's seed, which carries no junior block, so it
sees none of this.

Needs `pymupdf`. Renders through the engine `quillkit test` uses, so no typst
binary is required; run `npm install` first.
"""

import subprocess
import sys
import tempfile
from pathlib import Path

try:
    import pymupdf
except ImportError as exc:
    raise SystemExit("This check requires the Python package 'pymupdf'.") from exc


HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parents[1]
RENDER = HERE / "render_fixture.mjs"
FIXTURES = HERE / "fixtures"

BODY = "The body of the memorandum"
SENIOR = "SENIOR M. LAST"
JUNIOR_SHORT = "JUNIOR N. LAST"
JUNIOR_LONG = "MAXIMILIAN Q. VANDERBILT-ASHWORTH"

# Rounded to the hundredth of a point: the same ink laid twice is identical, and
# the comparisons below are all of one length against another.
PLACES = 2


def render(fixture, out_dir):
    """The first page of a fixture, as its spans and its widgets."""
    pdf = out_dir / f"{fixture.stem}.pdf"
    result = subprocess.run(
        ["node", str(RENDER), str(fixture), str(pdf)],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise SystemExit(f"{fixture.name} does not render:\n{result.stderr}")
    with pymupdf.open(pdf) as document:
        page = document[0]
        spans = [
            (span["bbox"], span["text"])
            for block in page.get_text("dict")["blocks"]
            for line in block.get("lines", [])
            for span in line["spans"]
            if span["text"].strip()
        ]
        widgets = [(widget.field_name, widget.rect) for widget in page.widgets()]
    return spans, widgets


def find(spans, needle):
    """The bounding box of the span opening the line that carries `needle`."""
    for bbox, text in spans:
        if needle in text:
            return bbox
    raise SystemExit(f"no span carrying {needle!r}")


def widget(widgets, name):
    for field_name, rect in widgets:
        if field_name == name:
            return rect
    raise SystemExit(f"no widget named {name!r}")


def check(label, left, right):
    if round(left, PLACES) != round(right, PLACES):
        print(f"FAIL {label}: {left:.2f} != {right:.2f}")
        return False
    return True


def main():
    with tempfile.TemporaryDirectory() as work:
        out_dir = Path(work)
        single, single_widgets = render(FIXTURES / "signature_single.md", out_dir)
        dual, dual_widgets = render(FIXTURES / "signature_dual.md", out_dir)
        long_dual, long_widgets = render(FIXTURES / "signature_dual_long.md", out_dir)

    anchor = find(single, SENIOR)
    margin = find(single, BODY)[0]
    passed = True

    for label, spans, widgets, junior_name in (
        ("junior block", dual, dual_widgets, JUNIOR_SHORT),
        ("long junior block", long_dual, long_widgets, JUNIOR_LONG),
    ):
        senior = find(spans, SENIOR)
        junior = find(spans, junior_name)
        passed &= check(f"{label}: junior at the left margin", junior[0], margin)
        passed &= check(f"{label}: one anchor line", junior[1], senior[1])
        passed &= check(f"{label}: senior keeps its anchor", senior[0], anchor[0])
        passed &= check(f"{label}: senior keeps its line", senior[1], anchor[1])

        # The junior column is every span left of the senior's anchor. Its
        # widest line is what the senior's anchor may not cross.
        widest = max(bbox[2] for bbox, _ in spans if bbox[0] < senior[0] and bbox[1] >= junior[1])
        if widest >= senior[0]:
            print(f"FAIL {label}: columns overlap, junior reaches {widest:.2f} past {senior[0]:.2f}")
            passed = False

        senior_widget = widget(widgets, "Signature")
        junior_widget = widget(widgets, "Junior_Signature")
        passed &= check(f"{label}: senior widget over its column", senior_widget.x0, senior[0])
        passed &= check(f"{label}: junior widget over its column", junior_widget.x0, junior[0])
        passed &= check(f"{label}: widgets on one line", junior_widget.y0, senior_widget.y0)

    # One signer is untouched by any of it: the schema default renders the
    # memorandum the quill rendered before there was a second block.
    if any(name == "Junior_Signature" for name, _ in single_widgets):
        print("FAIL one signer: a junior widget with no junior block")
        passed = False

    if not passed:
        sys.exit(1)
    print("pass dual signature: junior at the left margin, senior on its anchor")


if __name__ == "__main__":
    main()
