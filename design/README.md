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
