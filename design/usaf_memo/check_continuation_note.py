#!/usr/bin/env python3
"""A backmatter section that leaves a page must say so on the page it leaves.

Usage: python3 check_continuation_note.py

AFH 33-337 wants the departing page to carry a continuation note — "3
Attachments (listed on next page):" for attachments, the neutral "(continued on
next page)" for `cc:` and `DISTRIBUTION:`. The invariant is an equivalence and
both directions are checked: a section starting on a later page than the one
above it carries its note on that earlier page, and one that does not carries no
note at all.

The note is due only across the narrow band of body lengths where the section
above stays behind and the section itself moves. A fixture at one body length
sits on one side of that band and passes either way, so each combination is
swept across it. `quillkit test` cannot do this: it renders each plate once.

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
# Spans the band where the closing section splits, with room on either side.
BODY_LENGTHS = range(18, 36)
COMBINATIONS = [
    (attachments, cc, distribution)
    for attachments in (0, 1, 2, 3, 7)
    for cc, distribution in ((0, 0), (2, 0), (0, 2), (2, 2))
    if attachments or cc or distribution
]

FIXTURE = """#import "/quills/usaf_memo/0.3.0/packages/tonguetoquill-usaf-memo/src/lib.typ": (
  backmatter, frontmatter, mainmatter,
)

#show: frontmatter.with(
  subject: "Continuation Label",
  memo-for: "TEST/CC",
  memo-from: "TEST/DO",
  date: datetime(year: 2026, month: 3, day: 11),
)

#mainmatter[
  #for i in range({body}) [Paragraph #(i + 1) of the body, with enough words to occupy a line or so of text.\\ ]
]

#backmatter(
  signature-block: ("FIRST M. LAST, Maj, USAF", "{signature}"),
{fields})
"""


def fixture_source(body, attachments, cc, distribution):
    fields = ""
    # A one-element Typst array needs the trailing comma; without it the
    # parentheses are grouping and the field arrives as a `str`.
    if attachments:
        fields += "  attachments: (%s,),\n" % ", ".join(
            f'"Attachment {i + 1}"' for i in range(attachments)
        )
    if cc:
        fields += "  cc: (%s,),\n" % ", ".join(f'"Copy Holder {i + 1}"' for i in range(cc))
    if distribution:
        fields += "  distribution: (%s,),\n" % ", ".join(
            f'"Dist Org {i + 1}"' for i in range(distribution)
        )
    return FIXTURE.format(body=body, signature=SIGNATURE_LAST_LINE, fields=fields)


def expected_sections(attachments, cc, distribution):
    """(label, continuation note) per section, in the order they render."""
    sections = []
    if attachments:
        counted = "Attachment" if attachments == 1 else f"{attachments} Attachments"
        sections.append((f"{counted}:", f"{counted} (listed on next page):"))
    if cc:
        sections.append(("cc:", "cc: (continued on next page)"))
    if distribution:
        sections.append(("DISTRIBUTION:", "DISTRIBUTION: (continued on next page)"))
    return sections


def render(source, directory):
    """Pages of the compiled memorandum, as lists of their non-blank lines.

    A layout that does not converge fails outright: the note is decided from a
    query, and a query that moved its own answer would settle wherever the
    layout loop was abandoned rather than on a stable result.
    """
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
    with pymupdf.open(output) as document:
        return [page.get_text().splitlines() for page in document]


def page_of(pages, line):
    """1-based page carrying `line` whole. A label is a prefix of its own note,
    so a substring match would find the note and report the wrong page."""
    for number, lines in enumerate(pages, start=1):
        if line in lines:
            return number
    return None


def main():
    failures = []
    checked = 0
    with tempfile.TemporaryDirectory(dir=REPO_ROOT) as directory:
        directory = Path(directory)
        for attachments, cc, distribution in COMBINATIONS:
            for body in BODY_LENGTHS:
                case = f"attachments={attachments} cc={cc} distribution={distribution} body={body}"
                pages = render(fixture_source(body, attachments, cc, distribution), directory)
                if pages is None:
                    failures.append(f"{case}: layout did not converge")
                    continue
                # The signature block anchors the first section, each section the next.
                anchor = page_of(pages, SIGNATURE_LAST_LINE)
                for label, note in expected_sections(attachments, cc, distribution):
                    section = page_of(pages, label)
                    if section is None:
                        failures.append(f"{case}: section {label!r} did not render")
                        break
                    checked += 1
                    note_page = page_of(pages, note)
                    if section > anchor and note_page != anchor:
                        failures.append(
                            f"{case}: {label!r} left page {anchor} for page {section}, "
                            f"but its note is on page {note_page}"
                        )
                    elif section == anchor and note_page is not None:
                        failures.append(
                            f"{case}: {label!r} stayed on page {section}, "
                            f"but a note printed on page {note_page}"
                        )
                    anchor = section

    if failures:
        print(f"FAIL continuation note: {len(failures)} of {checked} sections")
        for failure in failures[:20]:
            print(f"  {failure}")
        if len(failures) > 20:
            print(f"  … and {len(failures) - 20} more")
        sys.exit(1)
    print(f"pass continuation note: {checked} sections across {len(COMBINATIONS)} combinations")


if __name__ == "__main__":
    main()
