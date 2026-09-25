#!/usr/bin/env python3
"""Check a rendered personal letter PDF against AFH 33-337's line offsets.

Usage: python3 validate_letter.py <fixture.md> <rendered.pdf>

AFH 33-337 places every element of a personal letter a stated number of lines
below the one before it: the sender's address on the second line below the
date, the receiver's on the third line below the sender's, the salutation on
the second line below the receiver's, the complimentary close on the second
line below the last line of text, the signature block on the fifth line below
the close, the attachment element on the third line below the signature block,
and the courtesy copy element on the second line below the attachment element.

Every offset is asserted in **lines**, and the line is measured off the
document itself: the sender's address block is a run of consecutive single-
spaced lines, so its stride is what one line is at whatever size the letter is
set in. A change of `font_size` moves every baseline and leaves every number
here where it was.

`quillkit test` renders each quill's example document and reports that it
rendered. The offsets are what it cannot see.

Needs `pymupdf` and `pyyaml`.
"""

import re
import sys

import pymupdf
import yaml

PT_PER_IN = 72.0
# Baselines land within a quarter point of their nominal position; the offsets
# are integers of a ~14pt line, so this separates none of them.
EPS_PT = 0.5

# A Quillmark document is a sequence of `~~~`-fenced card-yaml blocks, each
# followed by that card's markdown body. A personal letter is one main card.
CARD_FENCE_RE = re.compile(r"^~~~\n(.*?)\n~~~\n?", re.MULTILINE | re.DOTALL)


def load_fixture(fixture_path):
    text = open(fixture_path, encoding="utf-8").read()
    m = CARD_FENCE_RE.search(text)
    if not m:
        raise SystemExit(f"{fixture_path}: no `~~~` card block found")
    fields = yaml.safe_load(m.group(1)) or {}
    if fields.get("$kind") != "main":
        raise SystemExit(f"{fixture_path}: first card must be `$kind: main`")
    data = {k: v for k, v in fields.items() if not k.startswith("$")}
    return data, text[m.end() :].strip()


def extract_lines(pdf_path):
    """Every text line of the document, in flow order, one record per line.

    `page` is 1-based; `base` is the baseline's y, `x0`/`x1` the line's
    horizontal extent. Header and footer ink (page number, classification
    banner, tag line) lands in the same list and is told apart by where it sits
    rather than by any mark of its own, so the offsets below name their lines
    by text.
    """
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
                lines.append(
                    dict(
                        page=pno,
                        base=line["spans"][0]["origin"][1],
                        top=line["bbox"][1],
                        x0=line["bbox"][0],
                        x1=line["bbox"][2],
                        size=line["spans"][0]["size"],
                        text=text,
                    )
                )
    return doc.page_count, tuple(doc[0].rect)[2:], lines


def check(label, condition, failures):
    status = "PASS" if condition else "FAIL"
    print(f"  [{status}] {label}")
    if not condition:
        failures.append(label)


def find(lines, needle, failures, label=None):
    """The one line carrying `needle`, or `None` with a failure recorded.

    Matched by containment rather than by prefix: a numbered attachment reaches
    the page under the number the closing put on it. Ambiguity is a failure
    too — an offset measured off the wrong one of two matching lines would read
    as a layout fault somewhere else.
    """
    hits = [l for l in lines if needle[:60] in l["text"]]
    if len(hits) != 1:
        check(f"{label or needle!r}: exactly one line matches (found {len(hits)})", False, failures)
        return None
    return hits[0]


def offset_lines(a, b, stride):
    """How many lines separate two baselines, as the document measures a line."""
    return (b["base"] - a["base"]) / stride


def check_offset(label, a, b, expected, stride, failures):
    if a is None or b is None:
        check(f"{label}: both lines found", False, failures)
        return
    if a["page"] != b["page"]:
        check(f"{label}: both lines on one page (page {a['page']} then {b['page']})", False, failures)
        return
    actual = offset_lines(a, b, stride)
    ok = abs(actual * stride - expected * stride) <= EPS_PT
    check(f"{label}: {expected} lines below (measured {actual:.2f})", ok, failures)


def validate(fixture_path, pdf_path):
    print(f"=== {fixture_path} -> {pdf_path} ===")
    data, body = load_fixture(fixture_path)
    page_count, (page_width, _page_height), lines = extract_lines(pdf_path)
    failures = []

    margin = PT_PER_IN  # AFH 33-337: 1-inch left, right and bottom margins

    # ---- The line, measured off the sender's address block --------------
    sender = [find(lines, s, failures, f"sender line {i}") for i, s in enumerate(data["letter_from"])]
    if any(l is None for l in sender) or len(sender) < 2:
        print("  sender's address block not located; nothing else can be measured\n")
        return failures + ["sender block"]
    strides = [sender[i + 1]["base"] - sender[i]["base"] for i in range(len(sender) - 1)]
    stride = sum(strides) / len(strides)
    check(
        f"sender's address block is single-spaced (stride {stride:.2f}pt)",
        max(strides) - min(strides) <= EPS_PT,
        failures,
    )

    # ---- The heading elements -------------------------------------------
    date = min((l for l in lines if l["page"] == 1 and l["x1"] > page_width / 2 and l["base"] > 100), key=lambda l: l["base"])
    check(
        f"date flush with the right margin (right edge {date['x1']:.2f}pt)",
        abs(date["x1"] - (page_width - margin)) <= EPS_PT,
        failures,
    )
    check(
        f"date 1.75in from the top of page 1 (top {date['top']:.2f}pt)",
        abs(date["top"] - 1.75 * PT_PER_IN) <= EPS_PT,
        failures,
    )

    recipient = [find(lines, s, failures, f"recipient line {i}") for i, s in enumerate(data["letter_for"])]
    salutation = find(lines, data["salutation"], failures, "salutation")

    check_offset("sender's address", date, sender[0], 2, stride, failures)
    check_offset("receiver's address", sender[-1], recipient[0], 3, stride, failures)
    check_offset("salutation", recipient[-1], salutation, 2, stride, failures)

    # ---- The body --------------------------------------------------------
    paragraphs = [p.strip() for p in body.split("\n\n") if p.strip() and not p.startswith(">")]
    first_par = find(lines, paragraphs[0], failures, "first body paragraph")
    check_offset("body", salutation, first_par, 2, stride, failures)
    check(
        f"body paragraphs indented 0.5in (first line at {first_par['x0'] - margin:.2f}pt)"
        if first_par
        else "body paragraphs indented 0.5in",
        first_par is not None and abs(first_par["x0"] - (margin + 0.5 * PT_PER_IN)) <= EPS_PT,
        failures,
    )

    # ---- The closing -----------------------------------------------------
    close = find(lines, data["complimentary_close"], failures, "complimentary close")
    signature = [find(lines, s, failures, f"signature line {i}") for i, s in enumerate(data["signature_block"])]
    # The last line of text is the line above the close, whichever element of
    # the body it belongs to.
    if close is not None:
        above = sorted(
            (l for l in lines if (l["page"], l["base"]) < (close["page"], close["base"]) and l["x0"] < margin + PT_PER_IN),
            key=lambda l: (l["page"], l["base"]),
        )
        check_offset("complimentary close", above[-1], close, 2, stride, failures)
    check_offset("signature block", close, signature[0], 5, stride, failures)
    for anchored, name in ((close, "complimentary close"), (signature[0], "signature block")):
        check(
            f"{name} anchored 4.5in from the left edge (at {anchored['x0']:.2f}pt)" if anchored else f"{name} anchored 4.5in from the left edge",
            anchored is not None and abs(anchored["x0"] - 4.5 * PT_PER_IN) <= EPS_PT,
            failures,
        )

    # ---- The attachment and courtesy copy elements ------------------------
    attachments = data.get("attachments") or []
    cc = data.get("cc") or []
    attachment_label = None
    if attachments:
        label = "Attachment:" if len(attachments) == 1 else f"{len(attachments)} Attachments:"
        attachment_label = find(lines, label, failures, "attachment element")
        check_offset("attachment element", signature[-1], attachment_label, 3, stride, failures)
        last_attachment = find(lines, attachments[-1], failures, "last attachment")
    if cc:
        cc_label = find(lines, "cc:", failures, "courtesy copy element")
        if attachments:
            check_offset("courtesy copy element", last_attachment, cc_label, 2, stride, failures)
        else:
            check_offset("courtesy copy element", signature[-1], cc_label, 3, stride, failures)

    # ---- Page numbering ---------------------------------------------------
    # AFH 33-337: the first page is never numbered; succeeding pages carry the
    # number flush with the right margin, above the text.
    first_page_top = min(l["base"] for l in lines if l["page"] == 1)
    check(
        "page 1 unnumbered",
        not any(l["page"] == 1 and l["text"] == "1" and l["base"] < first_page_top for l in lines),
        failures,
    )
    for pno in range(2, page_count + 1):
        number = [l for l in lines if l["page"] == pno and l["text"] == str(pno)]
        check(f"page {pno} numbered", len(number) == 1, failures)
        if number:
            check(
                f"page {pno} number flush with the right margin (right edge {number[0]['x1']:.2f}pt)",
                abs(number[0]["x1"] - (page_width - margin)) <= EPS_PT,
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
