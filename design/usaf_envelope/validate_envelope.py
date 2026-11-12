#!/usr/bin/env python3
"""Measure a rendered envelope against AFH 33-337 chapter 22.

The address is 12pt Courier inside the OCR read area: half an inch from each
side, no higher than 2 3/4 inches from the bottom, and no lower than 5/8 inch.
The lower right 4 3/4 by 5/8 inch stays empty for the barcode. OFFICIAL
BUSINESS, when on, sits two lines under the return address. Lines do not
overlap, and letters print in capitals.

Usage:
  python3 design/usaf_envelope/validate_envelope.py <fixture.md|seed> <file.pdf>
"""

import sys
from pathlib import Path

import pymupdf
import yaml

SIZES = {
    "number-10": (9.5 * 72, 4.125 * 72),
    "monarch": (7.5 * 72, 3.875 * 72),
    "6x9": (9 * 72, 6 * 72),
    "9x12": (12 * 72, 9 * 72),
    "10x13": (13 * 72, 10 * 72),
}

STRIDE = 14.0
OCR_SIDE = 0.5 * 72
OCR_BOTTOM = 0.625 * 72
OCR_TOP = 2.75 * 72
BARCODE_WIDTH = 4.75 * 72
RETURN_INSET = 0.25 * 72
POSTAGE = 1.75 * 72


def load_fields(spec):
    if spec == "seed":
        return {
            "lines": [],
            "official": True,
            "delivery": [],
            "marking": False,
            "size": "number-10",
        }
    text = Path(spec).read_text()
    fence = text.split("~~~", 2)
    data = yaml.safe_load(fence[1]) or {}
    ret = data.get("return") or {}
    delivery = data.get("delivery") or {}
    envelope = data.get("envelope") or {}
    lines = [str(line) for line in (ret.get("lines") or [])]
    # The plate prints at most five delivery lines. A country is the last of
    # them, and the account line is the one that yields when all six are filled.
    ordered = []
    for key in ("non_address", "attention", "recipient", "street", "city"):
        value = delivery.get(key)
        if value:
            ordered.append(str(value))
    country = delivery.get("country")
    if country:
        if len(ordered) > 4:
            ordered = ordered[-4:]
        ordered.append(str(country))
    return {
        "lines": lines,
        "official": ret.get("official_business", True),
        "delivery": ordered,
        "marking": bool((envelope or {}).get("non_machineable", False)),
        "size": (envelope or {}).get("size") or "number-10",
    }


def spans_of(page):
    found = []
    for block in page.get_text("dict")["blocks"]:
        if block.get("type") != 0:
            continue
        for line in block["lines"]:
            for span in line["spans"]:
                found.append(span)
    return found


def joined_lines(spans):
    """Spans that share a baseline, left to right, as one printed line."""
    rows = {}
    for span in spans:
        key = round(span["bbox"][1], 0)
        rows.setdefault(key, []).append(span)
    lines = []
    for key in sorted(rows):
        row = sorted(rows[key], key=lambda span: span["bbox"][0])
        text = "".join(span["text"] for span in row).strip()
        x0 = min(span["bbox"][0] for span in row)
        y0 = min(span["bbox"][1] for span in row)
        x1 = max(span["bbox"][2] for span in row)
        y1 = max(span["bbox"][3] for span in row)
        size = row[0]["size"]
        font = row[0]["font"]
        lines.append({"text": text, "bbox": (x0, y0, x1, y1), "size": size, "font": font})
    return lines


def overlaps(a, b):
    ax0, ay0, ax1, ay1 = a
    bx0, by0, bx1, by1 = b
    return ax0 < bx1 - 0.6 and bx0 < ax1 - 0.6 and ay0 < by1 - 0.6 and by0 < ay1 - 0.6


def check(spec, pdf_path):
    fields = load_fields(spec)
    doc = pymupdf.open(pdf_path)
    failures = []

    def fail(message):
        failures.append(message)

    if doc.page_count != 1:
        fail(f"page count {doc.page_count}, expected 1")
    page = doc[0]
    width, height = page.rect.width, page.rect.height
    expect_w, expect_h = SIZES[fields["size"]]
    if abs(width - expect_w) > 1 or abs(height - expect_h) > 1:
        fail(f"page {width:.1f}x{height:.1f}, expected {expect_w:.1f}x{expect_h:.1f}")

    # role is where a too-long line is cut off: the postage corner, or the
    # delivery address's half-inch right margin. None is a line that is never cut.
    expected = [(line.upper(), "return") for line in fields["lines"]]
    if fields["official"]:
        expected.append(("OFFICIAL BUSINESS", None))
    if fields["marking"]:
        expected.append(("NON-MACHINEABLE", None))
    expected.extend((line.upper(), "delivery") for line in fields["delivery"])

    spans = spans_of(page)
    lines = joined_lines(spans)
    if len(lines) != len(expected):
        fail(
            "printed "
            + repr([line["text"] for line in lines])
            + ", expected "
            + repr([text for text, _role in expected])
        )
    limit_of = {"return": width - POSTAGE, "delivery": width - OCR_SIDE}

    for line in lines:
        letters = [ch for ch in line["text"] if ch.isalpha()]
        if any(ch != ch.upper() for ch in letters):
            fail(f"not capitals: {line['text']!r}")
        if abs(line["size"] - 12) > 0.6:
            fail(f"size {line['size']} on {line['text']!r}")
        if "LiberationMono" not in line["font"] and "Courier" not in line["font"]:
            fail(f"font {line['font']!r} on {line['text']!r}")

    for i, left in enumerate(lines):
        for right in lines[i + 1 :]:
            if overlaps(left["bbox"], right["bbox"]):
                fail(f"overlapping lines {left['text']!r} and {right['text']!r}")

    barcode = pymupdf.Rect(width - BARCODE_WIDTH, height - OCR_BOTTOM, width, height)
    for line in lines:
        if pymupdf.Rect(line["bbox"]).intersects(barcode):
            fail(f"barcode clear area holds {line['text']!r}")

    paired = list(zip(lines, expected))
    for got, (want, role) in paired:
        if got["text"] == want:
            continue
        limit = limit_of.get(role)
        cut_at_margin = limit is not None and abs(got["bbox"][2] - limit) <= 3
        if cut_at_margin and want.startswith(got["text"]) and got["text"]:
            continue
        fail(f"printed {got['text']!r}, expected {want!r}")

    return_lines = [got for got, (_want, role) in paired if role == "return"]
    for line in return_lines:
        if abs(line["bbox"][0] - RETURN_INSET) > 3:
            fail(f"return line {line['text']!r} starts at {line['bbox'][0]:.1f}, not {RETURN_INSET:.1f}")
        if line["bbox"][2] > width - POSTAGE + 3:
            fail(f"return line {line['text']!r} runs into the postage corner")
    for above, below in zip(return_lines, return_lines[1:]):
        gap = below["bbox"][1] - above["bbox"][1]
        if abs(gap - STRIDE) > 1.5:
            fail(f"return stride {gap:.1f} between {above['text']!r} and {below['text']!r}")

    official = next((got for got, (want, _role) in paired if want == "OFFICIAL BUSINESS"), None)
    if official is not None:
        if abs(official["bbox"][0] - RETURN_INSET) > 3:
            fail("OFFICIAL BUSINESS is not at the return address's left edge")
        if return_lines:
            gap = official["bbox"][1] - return_lines[-1]["bbox"][1]
            if abs(gap - 2 * STRIDE) > 1.5:
                fail(f"OFFICIAL BUSINESS is {gap:.1f}pt below the return address, expected {2 * STRIDE:.0f}")
        elif official["bbox"][1] > RETURN_INSET + 4:
            fail("OFFICIAL BUSINESS is not in the upper left")

    delivery = [got for got, (_want, role) in paired if role == "delivery"]
    if delivery:
        left = delivery[0]["bbox"][0]
        for line in delivery:
            if abs(line["bbox"][0] - left) > 1:
                fail(f"{line['text']!r} is not blocked left with the address")
            if line["bbox"][0] < OCR_SIDE - 1:
                fail(f"{line['text']!r} crosses the left half-inch margin")
            if line["bbox"][2] > width - OCR_SIDE + 2:
                fail(f"{line['text']!r} crosses the right half-inch margin")
        top_from_bottom = height - delivery[0]["bbox"][1]
        if top_from_bottom > OCR_TOP + 3:
            fail(f"first address line is {top_from_bottom / 72:.2f}in from the bottom, above 2.75in")
        bottom_from_bottom = height - delivery[-1]["bbox"][3]
        if bottom_from_bottom < OCR_BOTTOM - 1:
            fail(f"last address line is {bottom_from_bottom / 72:.2f}in from the bottom, below 5/8in")
        for above, below in zip(delivery, delivery[1:]):
            gap = below["bbox"][1] - above["bbox"][1]
            if abs(gap - STRIDE) > 1.5:
                fail(f"address stride {gap:.1f} between {above['text']!r} and {below['text']!r}")
        # Blocked left near the middle, unless a long line had to move left
        # to keep the half-inch right margin.
        widest = max(line["bbox"][2] - line["bbox"][0] for line in delivery)
        if widest <= width / 2 - OCR_SIDE and abs(left - width / 2) > 2:
            fail(f"address starts at {left:.1f}, not the middle {width / 2:.1f}")

    mark = next((got for got, (want, _role) in paired if want == "NON-MACHINEABLE"), None)
    if mark is not None and delivery:
        if mark["bbox"][3] >= delivery[0]["bbox"][1]:
            fail("NON-MACHINEABLE is not above the address")
        if abs(mark["bbox"][0] - delivery[0]["bbox"][0]) > 1:
            fail("NON-MACHINEABLE is not aligned with the address")

    doc.close()
    return failures


def main():
    if len(sys.argv) != 3:
        print(__doc__.strip(), file=sys.stderr)
        sys.exit(2)
    failures = check(sys.argv[1], sys.argv[2])
    label = Path(sys.argv[1]).name
    if failures:
        print(f"FAIL {label}")
        for message in failures:
            print(f"  {message}")
        sys.exit(1)
    print(f"PASS {label}")


if __name__ == "__main__":
    main()
