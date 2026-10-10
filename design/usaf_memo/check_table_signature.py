#!/usr/bin/env python3
"""A table under a subparagraph hangs under its text, and a table that ends the
body keeps the signature block company.

Usage: python3 check_table_signature.py

Two relations, read off the rendered page:

- The table's left rule stands where the text of the subparagraph it sits in
  starts. The subparagraph is lettered h., whose label is wider than i.'s, so a
  table measured against the next letter's label lands left of the text.
- AFH 33-337: "Do not place the signature element on a continuation page by
  itself." The page carrying the signature block carries body text too.

The second holds or fails only across the band of body lengths where the table
meets the page bottom, so each table is swept across a page of body lengths.
Its rows carry line breaks, and both row counts stay inside the relocation
budget that keeps a last element with the signature; a table past it can end a
page with the signature alone on the next (#228). `quillkit test` renders each
plate once and sees neither relation.

Needs `pymupdf` and a `typst` binary on PATH; set TYPST to point at one
elsewhere.
"""

import os
import subprocess
import sys
import tempfile
from pathlib import Path

try:
    import pymupdf
except ImportError as exc:
    raise SystemExit("This check requires the Python package 'pymupdf'.") from exc


REPO_ROOT = Path(__file__).resolve().parents[2]
PACKAGE = REPO_ROOT / "quills/usaf_memo/0.3.0/packages/tonguetoquill-usaf-memo"
FONTS = PACKAGE / "fonts"
TYPST = os.environ.get("TYPST", "typst")

SIGNATURE_LAST_LINE = "Commander"
SUBPARAGRAPH = "The subparagraph the table sits under."
# A page of body lengths, so the table ends at a page bottom somewhere among them.
BODY_LENGTHS = range(0, 50)
ROW_COUNTS = (2, 4)
TOLERANCE = 0.01

FIXTURE = """#import "/quills/usaf_memo/0.3.0/packages/tonguetoquill-usaf-memo/src/lib.typ": (
  backmatter, frontmatter, mainmatter,
)

#show: frontmatter.with(
  subject: "Table Before Signature",
  memo-for: "TEST/CC",
  memo-from: "TEST/DO",
  date: datetime(year: 2026, month: 3, day: 11),
  memo-style: "{style}",
)

#mainmatter[
  #for i in range({body}) [Line #(i + 1) of the body, with enough words to occupy a line or so of text.\\ ]

  #for letter in "abcdefg" [- Subparagraph #letter.
  ]
  - {subparagraph}

    #table(
      columns: 2,
      table.header[Name][Notes],
      ..range({rows}).map(i => ([Row #(i + 1)], [line one \\ line two])).flatten(),
    )
]

#backmatter(
  signature-block: ("FIRST M. LAST, Maj, USAF", "{signature}"),
)
"""


def render(source, directory):
    """The compiled memorandum's pages, or None where layout did not converge."""
    # The fixture imports by absolute package path, so the project root Typst is
    # given has to span both it and `quills/`.
    fixture = directory / "fixture.typ"
    fixture.write_text(source)
    output = directory / "fixture.pdf"
    result = subprocess.run(
        [TYPST, "compile", "--root", str(REPO_ROOT), "--font-path", str(FONTS),
         str(fixture), str(output)],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        raise SystemExit(f"fixture does not compile:\n{result.stderr}")
    if "did not converge" in result.stderr:
        return None
    return pymupdf.open(output)


def lines(page):
    """(text, x where the text after its label starts) per line of the page."""
    for block in page.get_text("rawdict")["blocks"]:
        for line in block.get("lines", []):
            chars = [c for span in line["spans"] for c in span["chars"]]
            text = "".join(c["c"] for c in chars)
            i = text.find(" ")
            while 0 <= i < len(text) and text[i] == " ":
                i += 1
            start = chars[i if 0 < i < len(text) else 0]["origin"][0]
            yield text, start


def table_left_rule(page):
    """x of the leftmost vertical rule on the page, the table's left edge."""
    xs = [
        item[1].x
        for drawing in page.get_drawings()
        for item in drawing["items"]
        if item[0] == "l" and abs(item[1].x - item[2].x) < TOLERANCE
        and abs(item[1].y - item[2].y) > 1
    ]
    return min(xs) if xs else None


def check(document):
    """The failures this render shows."""
    failures = []
    text_start = None
    rule = None
    signature_page = None
    for number, page in enumerate(document, start=1):
        page_lines = list(lines(page))
        texts = [text for text, _ in page_lines]
        for text, start in page_lines:
            if text.endswith(SUBPARAGRAPH):
                text_start = start
        if rule is None and any(text.startswith("Name") for text in texts):
            rule = table_left_rule(page)
        if SIGNATURE_LAST_LINE in texts:
            signature_page = number
            body = [
                text for text in texts
                if text.startswith(("Line ", "Row ", "Name", "line "))
                or "Subparagraph" in text or text.endswith(SUBPARAGRAPH)
            ]
            if not body:
                failures.append(f"the signature block is alone on page {number}")
    if signature_page is None:
        failures.append("the signature block did not render")
    if text_start is None or rule is None:
        failures.append("the subparagraph or its table did not render")
    elif abs(rule - text_start) > TOLERANCE:
        failures.append(
            f"the table's left rule is at {rule:.2f}pt, its subparagraph's text at {text_start:.2f}pt"
        )
    return failures


def main():
    failures = []
    checked = 0
    with tempfile.TemporaryDirectory(dir=REPO_ROOT) as directory:
        directory = Path(directory)
        for style in ("usaf", "daf"):
            for rows in ROW_COUNTS:
                for body in BODY_LENGTHS:
                    case = f"style={style} rows={rows} body={body}"
                    source = FIXTURE.format(
                        style=style, body=body, rows=rows,
                        subparagraph=SUBPARAGRAPH, signature=SIGNATURE_LAST_LINE,
                    )
                    document = render(source, directory)
                    if document is None:
                        failures.append(f"{case}: layout did not converge")
                        continue
                    with document:
                        failures.extend(f"{case}: {failure}" for failure in check(document))
                    checked += 1

    if failures:
        print(f"FAIL table signature: {len(failures)} failures across {checked} memoranda")
        for failure in failures[:20]:
            print(f"  {failure}")
        if len(failures) > 20:
            print(f"  … and {len(failures) - 20} more")
        sys.exit(1)
    print(f"pass table signature: {checked} memoranda")


if __name__ == "__main__":
    main()
