#!/usr/bin/env python3
"""Structural validator for a rendered usaf_appointment fixture.

Usage: python3 design/usaf_appointment/validate_appointment.py <fixture.md> <rendered.pdf>

Checks the rendered PDF against the shape an appointment letter is expected to
take (AFH 33-337 official memorandum with an appointee table): the appointing
sentence opens the numbered body, every appointee appears, table columns are
present exactly when the column rule says so, the numbering chain is
contiguous, the supersession sentence closes the body when enabled, and the signature block is
not stranded on a page of its own.

Requires pymupdf and pyyaml.
"""

import re
import sys

import pymupdf
import yaml

CARD_FENCE_RE = re.compile(r"^~~~\n(.*?)\n~~~\n?", re.MULTILINE | re.DOTALL)

# (card field, printed header) in table order. `role` through `deros` render
# only when some appointee fills them; `extra` only when the letter names it.
COLUMNS = [
    ("role", "Role"),
    ("rank", "Rank"),
    ("name", "Name"),
    ("office_symbol", "Office Symbol"),
    ("duty_phone", "Duty Phone"),
    ("email", "Email"),
    ("deros", "DEROS"),
]
DEFAULT_SUPERSESSION = "This letter supersedes all previous letters, same subject."


def load_fixture(path):
    """Split a Quillmark document into (root data, root body, member cards)."""
    text = open(path, encoding="utf-8").read()
    blocks = list(CARD_FENCE_RE.finditer(text))
    assert blocks, "no card-yaml blocks found"
    root = yaml.safe_load(blocks[0].group(1))
    assert root.get("$kind") == "main", "first block must be the main card"
    data = {k: v for k, v in root.items() if not k.startswith("$")}
    body_end = blocks[1].start() if len(blocks) > 1 else len(text)
    body = text[blocks[0].end():body_end].strip()
    members = []
    for m in blocks[1:]:
        card = yaml.safe_load(m.group(1))
        if card.get("$kind") == "member":
            members.append({k: v for k, v in card.items() if not k.startswith("$")})
    return data, body, members


def extract_text(path):
    doc = pymupdf.open(path)
    pages = [page.get_text() for page in doc]
    return len(pages), pages, "\n".join(pages)


def normalize(s):
    return re.sub(r"\s+", " ", s).strip()


def check(label, condition, failures):
    print(f"[{'PASS' if condition else 'FAIL'}] {label}")
    if not condition:
        failures.append(label)


def numbered_paragraphs(text):
    """Top-level paragraph numbers in order of appearance ("1.", "2.", ...)."""
    return [int(n) for n in re.findall(r"^(\d+)\.\s", text, re.MULTILINE)]


def main(fixture_path, pdf_path):
    data, body, members = load_fixture(fixture_path)
    page_count, pages, text = extract_text(pdf_path)
    flat = normalize(text)
    failures = []

    subject = normalize(re.sub(r"\*", "", str(data["subject"])))
    check("subject present", subject in flat, failures)

    statement = normalize(re.sub(r"\*", "", str(data["appointment_statement"])))
    snippet = statement[:60]
    check("appointing sentence present exactly once (no hidden-pass leakage)",
          flat.count(snippet) == 1, failures)

    numbers = numbered_paragraphs(text)
    check("paragraph numbering contiguous from 1",
          numbers == list(range(1, len(numbers) + 1)), failures)
    if len(numbers) >= 2:
        first = re.search(r"^1\.\s+(.{20})", text, re.MULTILINE)
        check("appointing sentence is paragraph 1",
              first is not None and normalize(first.group(1)) in statement, failures)
    else:
        print("[SKIP] single paragraph is unnumbered per AFH 33-337")

    for m in members:
        check(f"appointee present: {m['name']}", normalize(m["name"]) in flat, failures)

    for key, header in COLUMNS:
        expected = any(str(m.get(key, "")).strip() for m in members)
        present = re.search(rf"\b{re.escape(header)}\b", text) is not None
        check(f"column '{header}' {'present' if expected else 'absent'}",
              present == expected, failures)
    extra = str(data.get("members_extra_column", "")).strip()
    if extra:
        check(f"extra column '{extra}' present", extra in flat, failures)

    supersedes = data.get("supersedes_previous", True)
    wording = normalize(data.get("supersession_text") or DEFAULT_SUPERSESSION)
    if supersedes:
        check("supersession sentence present", wording in flat, failures)
        if numbers:
            last = re.findall(rf"^{numbers[-1]}\.\s+(.+)", text, re.MULTILINE)
            check("supersession sentence is the last numbered paragraph",
                  bool(last) and normalize(last[-1])[:30] in wording, failures)
    else:
        check("no supersession sentence", DEFAULT_SUPERSESSION not in flat, failures)

    sig_line = normalize(data["signature_block"][0])
    sig_page = next((i for i, p in enumerate(pages) if sig_line in normalize(p)), None)
    check("signature block rendered", sig_page is not None, failures)
    if sig_page is not None:
        # The signing widget must sit in the blank lines ABOVE the printed
        # signature block, never over it (usaf_memo@0.3.0 regression).
        page = pymupdf.open(pdf_path)[sig_page]
        widgets = [w for w in page.widgets() if w.field_name == "Signature"]
        hits = page.search_for(data["signature_block"][0])
        check("signature widget present on the signature page", bool(widgets) and bool(hits), failures)
        if widgets and hits:
            check("signature widget ends above the printed name line",
                  widgets[0].rect.y1 <= hits[-1].y0 + 0.5, failures)
    if sig_page is not None:
        page_text = normalize(re.sub(r"\bCUI\b|^\s*\d+\s*$", "", pages[sig_page], flags=re.MULTILINE))
        check("signature block shares its page with body or trailer text",
              len(page_text) > len(sig_line) + 60, failures)

    print(f"\n{page_count} page(s); {len(failures)} failure(s)")
    return 1 if failures else 0


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(2)
    sys.exit(main(sys.argv[1], sys.argv[2]))
