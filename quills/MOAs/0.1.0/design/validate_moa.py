#!/usr/bin/env python3
"""Validate a rendered MOA PDF against DoDI 4000.19 structural requirements.

Usage: python3 validate_moa.py <fixture.md> <rendered.pdf>

The MOA quill's main body is freeform (paragraphs 1-N are written directly
by the author, auto-numbered by the plate), so this validator checks
*structure* rather than specific wording: DoDI 4000.19 Figure 1's chained
decimal outline numbering (1., 4.1., 6.1.1.1.) must be contiguous at every
level, the title block / signatures / Attachment A gating must reflect the
frontmatter fields that still drive them, and the fixture's own freeform
body text must have made it into the rendered output.

Cross-checked against DoDI 4000.19 Table 1 (22 minimum-content items). Two
items are legal/runtime constraints pymupdf cannot verify from rendered text
and are only documented here, not asserted:
  - Item 12: no agreement may remain active > 10 years from its effective
    date absent separate legal authority.
  - Item 12: the agreement start date must be the same as or later than the
    latest signature date.
"""

import re
import sys
from collections import defaultdict

import fitz
import yaml

CARD_FENCE_RE = re.compile(r"^```card (\S+)\n(.*?)\n```\n?", re.MULTILINE | re.DOTALL)


def load_fixture(fixture_path):
    text = open(fixture_path, encoding="utf-8").read()
    _, frontmatter, rest = text.split("---", 2)
    data = yaml.safe_load(frontmatter)

    cards = []
    body_end = len(rest)
    for m in CARD_FENCE_RE.finditer(rest):
        if body_end == len(rest):
            body_end = m.start()
        card_fields = yaml.safe_load(m.group(2)) or {}
        card_body_start = m.end()
        next_m = CARD_FENCE_RE.search(rest, card_body_start)
        card_body = rest[card_body_start : next_m.start() if next_m else len(rest)]
        cards.append((m.group(1), card_fields, card_body.strip()))

    body = rest[:body_end].strip()
    return data, body, cards


def extract_text(pdf_path):
    doc = fitz.open(pdf_path)
    pages = [page.get_text() for page in doc]
    return doc.page_count, pages, "\n".join(pages)


def check(label, condition, failures):
    status = "PASS" if condition else "FAIL"
    print(f"  [{status}] {label}")
    if not condition:
        failures.append(label)


def check_chain_numbering(text, label, failures):
    """DoDI 4000.19 uses chained decimal numbering (1., 4.1., 6.1.1.1.); at
    every nesting level, siblings under the same parent must be numbered
    contiguously starting from 1, with no gaps or duplicates."""
    tokens = re.findall(r"^\s*((?:\d+\.)+)\s", text, re.MULTILINE)
    children = defaultdict(list)
    for tok in tokens:
        parts = tok.rstrip(".").split(".")
        parent = ".".join(parts[:-1])
        children[parent].append(int(parts[-1]))

    ok = True
    for parent, nums in children.items():
        if sorted(nums) != list(range(1, len(nums) + 1)):
            ok = False
    check(f"{label}: chained decimal numbering contiguous at every level (parents: {dict(children)})", ok, failures)


def first_snippet(text, length=40):
    for line in text.splitlines():
        line = line.strip().lstrip("-").strip()
        if line:
            return line[:length]
    return ""


def validate(fixture_path, pdf_path):
    print(f"=== {fixture_path} -> {pdf_path} ===")
    data, body, cards = load_fixture(fixture_path)
    page_count, pages, full_text = extract_text(pdf_path)
    failures = []

    def present(s):
        return s in full_text

    def absent(s):
        return s not in full_text

    # ---- Title block ---------------------------------------------------
    check("title block present", present("MEMORANDUM OF AGREEMENT"), failures)
    check("agreement number present", present(data["agreement_number"]), failures)
    check("both party names present", present(data["first_party_name"]) and present(data["second_party_name"]), failures)

    # ---- Main body: freeform content survived, numbering well-formed ---
    # Each attachment restarts its own numbering scope (DoDI 4000.19 Figure
    # 1 attachments are separate continuation pages), so split the document
    # on "ATTACHMENT <letter>" markers before checking chain contiguity —
    # otherwise attachments' restarted "1." would look like a numbering gap
    # in the main body's sequence.
    snippet = first_snippet(body)
    check(f"main body content present (fixture's first line: {snippet!r})", present(snippet), failures)
    parts = re.split(r"\nATTACHMENT ([A-Z])\n", full_text)
    check_chain_numbering(parts[0], "main body", failures)
    for letter, scope in zip(parts[1::2], parts[2::2]):
        check_chain_numbering(scope, f"Attachment {letter}", failures)

    # ---- Financial details / Attachment A gated by 'reimbursable' ------
    reimbursable = bool(data.get("reimbursable"))
    check(
        f"ATTACHMENT A {'present' if reimbursable else 'absent'} as expected",
        (present("ATTACHMENT A") if reimbursable else absent("ATTACHMENT A")),
        failures,
    )

    # ---- Card-driven attachments (B, C, ...) ----------------------------
    letter = ord("B")
    for tag, fields, card_body in cards:
        if tag != "attachment":
            continue
        label = chr(letter)
        check(f"ATTACHMENT {label} present", present(f"ATTACHMENT {label}"), failures)
        if "title" in fields:
            check(f"ATTACHMENT {label} title present", present(fields["title"]), failures)
        snippet = first_snippet(card_body)
        if snippet:
            check(f"ATTACHMENT {label} body content present", present(snippet), failures)
        letter += 1

    # ---- Table 1 minimum-content spot checks ----------------------------
    check("both signatories present", present(data["first_party_signatory"]) and present(data["second_party_signatory"]), failures)
    check("AGREED: block present", present("AGREED:"), failures)
    check("Mid-Point Review block present", present("Mid-Point Review"), failures)

    # ---- Signature page not orphaned (must share a page with other content,
    # or be preceded by a page that isn't itself signature-only) -----------
    last_page_text = pages[-1]
    check(
        "signature page carries more than just AGREED: block (not orphaned)",
        len(last_page_text.strip()) > len("AGREED:") + 200,
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
