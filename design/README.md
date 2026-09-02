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

## usaf_letter

Fixtures and a layout check for the `usaf_letter` quill.

```sh
# render a fixture to PDF (run from the repo root)
node design/usaf_letter/render_fixture.mjs design/usaf_letter/fixtures/maximal.md /tmp/max.pdf

# check the rendered PDF against AFH 33-337's line offsets
python3 design/usaf_letter/validate_letter.py design/usaf_letter/fixtures/maximal.md /tmp/max.pdf
```

`validate_letter.py` needs `pymupdf` and `pyyaml`.

AFH 33-337 places every element of a personal letter a stated number of lines
below the one before it, and `quillkit test` renders the example document
without reading a single one of those offsets. The check reads them off the
rendered baselines, in lines rather than points: the line is the stride of the
sender's address block, a run of consecutive single-spaced lines, so a letter
set at another `font_size` measures the same integers.

`minimal.md` is a one-page letter carrying one attachment and one courtesy
copy, so every offset from the date to the `cc:` element is on one page and
comparable; `maximal.md` carries a CUI banner, a seal subtitle, a tag line, and
two of each listed element, and runs onto a second page, which is where the
page numbering is exercised — the first page of a letter is never numbered.
