#!/usr/bin/env python3
"""Check a rendered bullet background paper against AFH 33-337, pp. 226–227.

Usage: python3 validate_bbp.py <fixture.md> <rendered.pdf>

The sample page sets the measurements this checks: a centered title one inch
from the top, single spacing inside an item and double spacing between items,
one-inch margins, the identification line on page 1 only, and — from page 2 —
the page number half an inch from the top at the right margin.

`quillkit test` renders the example and reports that it rendered. The
measurements are what it cannot see.

Needs `pymupdf` and `pyyaml`.
"""

import re
import sys

import pymupdf
import yaml

PT = 72.0
# A baseline that should sit on a stated line, and a centered line's midpoint.
EPS = 1.0
# A wrapped centered subject can sit a point and a half off true center.
CENTER_EPS = 2.0
# Typst will leave a word a few points past the margin rather than hyphenate it.
MARGIN_SLOP = 4.0

CARD_FENCE_RE = re.compile(r"^~~~\n(.*?)\n~~~\n?", re.MULTILINE | re.DOTALL)


def load_fixture(path):
    text = open(path, encoding="utf-8").read()
    m = CARD_FENCE_RE.search(text)
    if not m:
        raise SystemExit(f"{path}: no `~~~` card block found")
    fields = yaml.safe_load(m.group(1)) or {}
    data = {k: v for k, v in fields.items() if not k.startswith("$")}
    return data, text[m.end():]


def extract(pdf_path):
    doc = pymupdf.open(pdf_path)
    lines = []
    for pno, page in enumerate(doc, 1):
        for block in page.get_text("dict")["blocks"]:
            if block["type"] != 0:
                continue
            for line in block["lines"]:
                text = "".join(span["text"] for span in line["spans"]).strip()
                if not text:
                    continue
                span = line["spans"][0]
                lines.append(dict(
                    page=pno,
                    base=span["origin"][1],
                    top=line["bbox"][1],
                    bottom=line["bbox"][3],
                    x0=line["bbox"][0],
                    x1=line["bbox"][2],
                    text=text,
                    rect=pymupdf.Rect(line["bbox"]),
                ))
    widgets = []
    for pno, page in enumerate(doc, 1):
        for widget in page.widgets() or []:
            widgets.append((pno, widget.field_name, pymupdf.Rect(widget.rect)))
    return doc.page_count, tuple(doc[0].rect)[2:], lines, widgets


def check(label, condition, failures):
    print(f"  [{'PASS' if condition else 'FAIL'}] {label}")
    if not condition:
        failures.append(label)


def find(lines, needle, page=None, exact=False):
    hits = []
    for line in lines:
        if page is not None and line["page"] != page:
            continue
        matched = line["text"] == needle if exact else needle in line["text"]
        if matched:
            hits.append(line)
    return hits


def one(lines, needle, failures, page=None, exact=False):
    hits = find(lines, needle, page, exact=exact)
    check(f"{needle!r} appears once (found {len(hits)})", len(hits) == 1, failures)
    return hits[0] if len(hits) == 1 else None


def midpoint(line):
    return (line["x0"] + line["x1"]) / 2


def validate(fixture_path, pdf_path):
    print(f"=== {fixture_path} -> {pdf_path} ===")
    data, _body = load_fixture(fixture_path)
    page_count, (page_width, page_height), lines, widgets = extract(pdf_path)
    failures = []
    center = page_width / 2
    right = page_width - PT

    check("US Letter", abs(page_width - 8.5 * PT) < 1 and abs(page_height - 11 * PT) < 1, failures)

    title = one(lines, "BULLET BACKGROUND PAPER", failures, page=1, exact=True)
    on = one(lines, "ON", failures, page=1, exact=True)
    if title and on:
        check(
            f"title one inch from the top (top {title['top']:.2f}pt)",
            abs(title["top"] - PT) <= CENTER_EPS,
            failures,
        )
        check(
            f"title centered (mid {midpoint(title):.2f}pt)",
            abs(midpoint(title) - center) <= EPS,
            failures,
        )
        check(
            f"ON centered (mid {midpoint(on):.2f}pt)",
            abs(midpoint(on) - center) <= EPS,
            failures,
        )

    subject = (data.get("subject") or "").upper()
    # The subject is every centered line between ON and the first line that
    # starts at the left margin. A line of body text that happens to fill the
    # measure has its midpoint at the center too, and is told apart by that.
    subject_lines = []
    if on and subject:
        for line in lines:
            if line["page"] != 1 or line["base"] <= on["base"]:
                continue
            if line["x0"] <= PT + 4 or abs(midpoint(line) - center) > CENTER_EPS:
                break
            subject_lines.append(line)
        printed = " ".join(line["text"] for line in subject_lines)
        check(f"subject prints in capitals ({printed!r})", printed == subject, failures)

    # Single spacing, measured off the first wrapped body line that is not a
    # bullet: the second line of that paragraph.
    body = [
        line for line in lines
        if line["page"] == 1
        and line["x0"] <= PT + EPS
        and not line["text"].startswith("-")
        and line["text"] not in ("BULLET BACKGROUND PAPER", "ON")
        and line not in subject_lines
        and not line["text"].startswith("MSgt")
        and not line["text"].startswith("Capt")
        and "Controlled By" not in line["text"]
        and not line["text"].startswith("CUI")
        and not line["text"].startswith("LDC")
        and not line["text"].startswith("POC")
    ]
    # The opening paragraph is the run of flush lines before the first heading
    # or bullet, after the subject.
    stride = None
    if len(body) >= 2:
        stride = body[1]["base"] - body[0]["base"]
        check(
            f"single spacing is the sample's line (stride {stride:.2f}pt)",
            13.0 <= stride <= 15.5,
            failures,
        )
    if stride and title and on:
        gap = on["base"] - title["base"]
        check(
            f"title to ON is a double space ({gap:.2f}pt, stride {stride:.2f}pt)",
            abs(gap - 2 * stride) <= EPS,
            failures,
        )
    if stride and on and subject_lines:
        gap = subject_lines[0]["base"] - on["base"]
        check(
            f"ON to subject is a double space ({gap:.2f}pt)",
            abs(gap - 2 * stride) <= EPS,
            failures,
        )
        if len(subject_lines) >= 2:
            wrap = subject_lines[1]["base"] - subject_lines[0]["base"]
            check(
                f"a wrapped subject is single-spaced ({wrap:.2f}pt)",
                abs(wrap - stride) <= EPS,
                failures,
            )
        if body:
            gap = body[0]["base"] - subject_lines[-1]["base"]
            check(
                f"subject to text is a double space ({gap:.2f}pt)",
                abs(gap - 2 * stride) <= EPS,
                failures,
            )

    bullets = [line for line in lines if line["page"] == 1 and re.match(r"-+ ", line["text"])]
    if stride and len(bullets) >= 2:
        # Consecutive main bullets, skipping a wrap (a wrap is indented and
        # does not start with the marker).
        mains = [line for line in bullets if line["text"].startswith("- ") and not line["text"].startswith("--")]
        if len(mains) >= 2:
            gap = mains[1]["base"] - mains[0]["base"]
            # A wrapped main bullet puts its continuation between the two
            # markers, so the gap is then three strides. Accept a whole
            # number of strides, at least two.
            strides = gap / stride
            check(
                f"space between main bullets is a whole number of lines ({strides:.2f})",
                abs(strides - round(strides)) <= 0.08 and round(strides) >= 2,
                failures,
            )
        levels = {}
        for line in bullets:
            marks = len(line["text"].split(" ", 1)[0])
            levels.setdefault(marks, line)
        if 1 in levels:
            check(
                f"main bullet at the left margin (x {levels[1]['x0']:.2f}pt)",
                abs(levels[1]["x0"] - PT) <= EPS,
                failures,
            )
        if 1 in levels and 2 in levels:
            check(
                "a second-level dash starts to the right of the first",
                levels[2]["x0"] > levels[1]["x0"] + 2,
                failures,
            )
        if 2 in levels and 3 in levels:
            check(
                "a third-level dash starts to the right of the second",
                levels[3]["x0"] > levels[2]["x0"] + 2,
                failures,
            )
        # A hanging indent: the line after a bullet that does not itself
        # start with a dash sits to the right of that bullet's marker.
        for prev, line in zip(lines, lines[1:]):
            if prev["page"] != 1 or line["page"] != 1:
                continue
            if re.match(r"-+ ", prev["text"]) and not line["text"].startswith("-"):
                if line["base"] - prev["base"] < (stride or 20) * 1.4:
                    check(
                        f"wrap hangs under the text ({line['text'][:30]!r})",
                        line["x0"] > prev["x0"] + 2,
                        failures,
                    )
                    break

    outside = []
    for line in lines:
        # The designation block is right-aligned in the text area, and the
        # banner is centered. Both are clear of the side margins; the lines
        # that have to start at the left margin are the body and the title's
        # neighbors, checked individually above.
        if line["x1"] > right + MARGIN_SLOP:
            outside.append(f"{line['text'][:40]!r} ends at {line['x1']:.1f}pt")
        if line["x0"] < PT - EPS and line["text"][:1].isdigit() is False:
            outside.append(f"{line['text'][:40]!r} starts at {line['x0']:.1f}pt")
    check(
        "text stays inside the side margins" if not outside else "text stays inside the side margins: " + "; ".join(outside),
        not outside,
        failures,
    )

    marked = bool(data.get("classification"))
    originator = data.get("originator") or ""
    id_lines = find(lines, originator) if originator else []
    if originator:
        check("identification line is on page 1 only", id_lines and all(line["page"] == 1 for line in id_lines) and len(id_lines) == 1, failures)
        if id_lines:
            id_line = id_lines[0]
            from_bottom = page_height - id_line["base"]
            expected = PT if marked else 0.5 * PT
            check(
                f"identification line {expected / PT:.2f}in from the bottom (baseline {from_bottom:.2f}pt up)",
                abs(from_bottom - expected) <= EPS,
                failures,
            )
            check(
                f"identification line at the left margin (x {id_line['x0']:.2f}pt)",
                abs(id_line["x0"] - PT) <= EPS,
                failures,
            )
            if data.get("date") == "2014-06-20":
                check("date prints as 20 Jun 14", "20 Jun 14" in id_line["text"], failures)
            if data.get("date") in ("", None) and data.get("originator"):
                check("a blank date leaves the slash for the fill-in", id_line["text"].endswith("/"), failures)

    if not data.get("date") and originator:
        check("a blank date is a fillable field", any(name == "Date" for _p, name, _r in widgets), failures)

    # Page 1 is unnumbered. Later pages carry the number at the right margin,
    # half an inch from the top.
    check(
        "page 1 unnumbered",
        not any(line["page"] == 1 and line["text"] == "1" and line["top"] < PT for line in lines),
        failures,
    )
    for pno in range(2, page_count + 1):
        number = [line for line in lines if line["page"] == pno and line["text"] == str(pno)]
        check(f"page {pno} numbered", len(number) == 1, failures)
        if number:
            check(
                f"page {pno} number at the right margin (right edge {number[0]['x1']:.2f}pt)",
                abs(number[0]["x1"] - right) <= EPS,
                failures,
            )
            check(
                f"page {pno} number half an inch from the top (top {number[0]['top']:.2f}pt)",
                abs(number[0]["top"] - 0.5 * PT) <= CENTER_EPS,
                failures,
            )

    if marked:
        banners = find(lines, "CUI//NF")
        check("banner on the first page, top and bottom", sum(1 for line in banners if line["page"] == 1) == 2, failures)
        for label in ("Controlled By:", "CUI Category:", "LDC:", "POC:"):
            one(lines, label, failures, page=1)
        # Nothing collides: the identification line, the designation block, and
        # the banners occupy different boxes.
        interesting = [
            line for line in lines
            if line["page"] == 1 and (
                (originator and originator in line["text"])
                or line["text"].startswith(("Controlled By", "CUI Category", "LDC:", "POC:", "CUI//"))
            )
        ]
        collided = False
        for i, a in enumerate(interesting):
            for b in interesting[i + 1:]:
                if (a["rect"] & b["rect"]).get_area() > 0.5:
                    collided = True
                    check(f"no overlap between {a['text'][:24]!r} and {b['text'][:24]!r}", False, failures)
        if not collided:
            check("identification line, designation block, and banners do not overlap", True, failures)
        body_bottom = max(
            (line["bottom"] for line in lines if line["page"] == 1 and line["x0"] <= PT + 20 and line["text"].startswith("-")),
            default=0,
        )
        block_top = min(
            (line["top"] for line in lines if line["page"] == 1 and line["text"].startswith("Controlled By")),
            default=page_height,
        )
        check(
            f"body stays above the designation block ({body_bottom:.1f}pt then {block_top:.1f}pt)",
            body_bottom < block_top - 6,
            failures,
        )

    print(f"  page count: {page_count}")
    print(f"  {len(failures)} failure(s)\n")
    return failures


def main():
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)
    failures = validate(sys.argv[1], sys.argv[2])
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
