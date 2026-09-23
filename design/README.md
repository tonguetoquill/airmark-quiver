# design/

Development scaffolding for quills — fixtures, render helpers, and validators.

This directory lives **outside `quills/`** on purpose: `package.json` publishes
`quills` and `Quiver.yaml` only, so nothing here ships to npm consumers.

## afmc_moa

Fixtures and a structural validator for the `afmc_moa` quill.

```sh
# render a fixture to PDF (run from the repo root)
node design/afmc_moa/render_fixture.mjs design/afmc_moa/fixtures/maximal.md /tmp/max.pdf

# check the rendered PDF against DoDI 4000.19 structural requirements
python3 design/afmc_moa/validate_moa.py design/afmc_moa/fixtures/maximal.md /tmp/max.pdf
```

`validate_moa.py` needs `pymupdf` and `pyyaml`.

`minimal.md` is a non-reimbursable MOA (no Attachment A); `maximal.md` is a
reimbursable one with two card-driven attachments, so it exercises the
Attachment A/B/C lettering.

## cyber_ribbon_chart

Fixtures, a render helper, and a check for the `cyber_ribbon_chart` quill.

```sh
# render a fixture (run from the repo root; .png renders an image, anything else a PDF)
node design/cyber_ribbon_chart/render_fixture.mjs design/cyber_ribbon_chart/fixtures/maximal.md /tmp/max.pdf

# with no fixture, renders the blueprint the schema seeds
node design/cyber_ribbon_chart/render_fixture.mjs /tmp/seed.pdf
```

`maximal.md` is a Captain with three vectors, a tour clipped by the window and
one placed past it, and every kind of record filled. `minimal.md` is the other
end: a 2d Lt at a six-year window with one unlabelled vector, a half-year tour,
no stratifications and no remarks — the fills where a section collapses rather than
printing an empty heading, and where the record column disappears entirely.

A ribbon chart is a one-page leave-behind, and `timeline_years` is the lever
that can cost it that page — more years narrow the columns and the milestone
chips wrap taller as they do. `quillkit test` renders the near-empty seed and
never sees it, so a filled document sweeps the windows the schema recommends:

```sh
node design/cyber_ribbon_chart/check_one_page.mjs
```

## classic_resume

Fixtures and a render helper for the `classic_resume` quill.

```sh
# render a fixture to PDF (run from the repo root)
node design/classic_resume/render_fixture.mjs design/classic_resume/fixtures/maximal.md /tmp/max.pdf

# with no fixture, renders the blueprint the schema seeds
node design/classic_resume/render_fixture.mjs /tmp/seed.pdf
```

`maximal.md` is the package's own example resume, so its render is comparable
against `thumbnail.png` upstream. `minimal.md` is the one the gate cannot reach:
a4 at 11pt, unlinked contacts, a Summary whose body is prose and a list, a
Certifications list at three columns, a linked entry with nothing to link, and
a dated entry at each of the four fills of its second line — both halves, each
half alone, and neither, which is the fill that prints no second line at all.

## usaf_memo

A check that `#show: mainmatter` and `#mainmatter[…]` typeset the same
memorandum. The show rule is handed the closing sections along with the body,
and `split-closing` is what keeps them out of the body's rebuild pass; the
plates call the function form, so `quillkit test` never exercises the show rule.

```sh
# run from the repo root; needs a typst binary
node design/usaf_memo/check_closing_sections.mjs
TYPST=/path/to/typst node design/usaf_memo/check_closing_sections.mjs
```

The fixtures compile the package straight out of `quills/`, so there is no
package cache to populate. `closing_sections.typ` holds the memorandum; each
`_*.typ` beside it writes that same memorandum in one of the shapes a closing
section reaches the show rule in, against a `_function.typ` baseline.

A second check: a backmatter section that leaves a page must say so on the page
it leaves, per AFH 33-337. The note is due only across the narrow band of body
lengths where the section above stays behind and the section itself moves, so
the check sweeps each combination of attachments, `cc:` and `DISTRIBUTION:`
across that band rather than asserting on one fixture — one body length sits on
a side of the band and passes either way. `quillkit test` renders each plate
once and cannot see it.

```sh
# run from the repo root; needs a typst binary and pymupdf
python3 design/usaf_memo/check_continuation_note.py
TYPST=/path/to/typst python3 design/usaf_memo/check_continuation_note.py
```
