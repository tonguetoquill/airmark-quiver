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

## army_memo

Fixtures, a render helper, and a layout check for the `army_memo` quill.

```sh
# render a fixture (run from the repo root; .png writes one image per page,
# anything else a PDF; the trailing date is the one `date: today` prints)
node design/army_memo/render_fixture.mjs design/army_memo/fixtures/basic.md /tmp/basic.pdf 2026-10-13

# with no fixture, renders the blueprint the schema seeds
node design/army_memo/render_fixture.mjs /tmp/seed.pdf 2026-10-13

# measure the rendered PDF against AR 25-50 (`seed` in place of a fixture
# measures a blueprint render)
python3 -I design/army_memo/validate_memo.py design/army_memo/fixtures/basic.md /tmp/basic.pdf
```

`validate_memo.py` needs `pymupdf` and `pyyaml`, and `node` for a render of its
own that it reads for the quill, document and render warnings. It prints PASS,
FAIL or SKIP for each item of the layout checklist, C01 to C59; `-v` lists
every measurement behind them. AR 25-50 places each
element a stated number of lines below the one before it, so the check reads
those offsets in lines, 1.15 times the font size, and everything else in points
on the page. It measures glyph by glyph: the gap after a sentence's period is
read against AR 25-50's rule for where a sentence ends, not against a list of
the fixture's sentences.

The fixtures, by what each reaches that the others do not:

- `basic.md`: the anchors every position is measured from, from the office
  symbol to the signature block, and the single space after `Mr.` and `L.`.
- `two_page_suspense.md`: a suspense date, a wrapped address and subject, an
  authority line typed in lowercase without its colon, and a last paragraph
  that splits two lines and two so the closing never starts a page alone.
- `thru_single.md`, `thru_multiple.md`: one and two THRU offices a blank line
  apart, each with a signature and a comment field spanning its address and the
  blank line below, and a blank date's `Date` field.
- `multiple_address.md`: five addresses under an office-symbol line whose
  contract number does not fit beside the symbol and takes the second line,
  with the DoD seal.
- `max5_overflow.md`: six addresses and six letterhead lines, which warn
  `validation::cardinality` and still render.
- `see_distribution.md`: SEE DISTRIBUTION, an eight-entry distribution list,
  two described enclosures and a CF list, all printed in capitals.
- `distribution_next_page.md`: a body long enough that `DISTRIBUTION:` fits
  under the closing and its first entry does not, so the label reads
  `DISTRIBUTION: (see next page)` and the list starts the next page.
- `mfr.md`: a memorandum for record whose one paragraph is unnumbered and whose
  subparagraphs are lettered.
- `closing.md`: a single reference, a civilian signature block that wraps, a
  mixed enclosure listing (`1–3.  as`), and `CF: (w/o encls)`.
- `encl_one_as.md`, `encl_two_as.md`, `encl_one_described.md`,
  `encl_many_described.md`: the other enclosure forms, `Encl`, `Encls`, `Encl`
  over its description, and `4 Encls` numbered.
- `deep_nesting.md`: four levels of subparagraph, a `10.`, and every case the
  sentence rule decides, each inside a line where its gap can be measured.
- `cui.md`, `secret_banner.md`: black banners, and the CUI block on page 1,
  which the text stops above.
- `cui_keep.md`, `cui_long_poc.md`: a short CUI block over a closing that
  carries two lines of the last paragraph to page 2, and a POC wide enough that
  the block's last line would meet the bottom banner at `usaf_memo`'s height.
- `font11.md`: `basic.md` at 11pt, where the line and the office symbol's
  position scale and the letterhead does not.
- `clp_example2.md`: the second example memorandum's content, a table among it.
  The table sets in the 12pt body face, taller than the example's small link
  text, so the memo takes three pages, the count C48 asks for.
- `sentence_markup.md`: run-in headings ending in `.`, `?` and `:`, sentences
  that end against bold, italic, a link and code, a block quote and a table of
  several sentences, and the label, title and number-lead cases of the
  sentence rule.
- `blocks.md`: a heading followed by bullets, which takes its own number and
  letters the bullets under it, a fenced code block in the monospace face, a
  block quote of two paragraphs, and a sentence ending in `'Closed.'`.
- `sentence_straddle.md`: a paragraph of short sentences that the page break
  divides with two of a sentence's words on each page.
- `final_paragraph_split.md`, `final_table.md`: a last paragraph that spans a
  page on its own, and a last table that runs onto the next page; each keeps
  its last two lines or rows with the closing.
- `authority_wrapped.md`: an authority line that wraps, under a last paragraph
  that splits two lines and two.
- `distribution_one_cf.md`: a one-entry distribution list whose entry fits
  below the label while the `CF:` bound to it does not, so the list starts the
  next page.

`make_black_seal.py` writes the quill's black-ink seals from `usaf_memo`'s
color ones (AR 25-50 1-16b(3)); run it from the repo root to regenerate them.

## cyber_career_plan

Fixtures, a render helper, and a check for the `cyber_career_plan` quill.

```sh
# render a fixture (run from the repo root; .png renders an image, anything else a PDF)
node design/cyber_career_plan/render_fixture.mjs design/cyber_career_plan/fixtures/maximal.md /tmp/max.pdf

# with no fixture, renders the blueprint the schema seeds
node design/cyber_career_plan/render_fixture.mjs /tmp/seed.pdf
```

`maximal.md` is a Captain with an adjusted year group, three constraints (one
too short for its label), three vectors branching from a Winter move, a tour
clipped by the window and one placed past it, milestones already done,
stratifications out of order, and every kind of record filled. `minimal.md` is
the other end: a 2d Lt at a six-year window with one untracked vector, no
constraints, no stratifications and no remarks. Those are the fills where a
row of the record goes rather than printing empty, and where no IDE or SDE
window is in view, so the timeline has one eligibility lane. `current.md` is
the current assignment at its
narrowest: one vector, a move on the first Summer of the window, so the block
is one half-year wide and sheds its text. It also carries courses passed
unticked, a constraint label longer than its bar, a constraint past the window,
tour lengths outside 0.5 to 4, and the `adjusted_yg: 0` older documents hold.
`long_notes.md` is a full chart under six typed paragraphs of notes, a degree
marked "(in progress)", and a stratification with no HLR: the notes area holds
what was typed and the line it is signed on, on the one page.

A career plan is a one-page leave-behind, and two levers can cost it that page:
`timeline_years` — more years narrow the columns, and a mark that wrapped to
fit one would make the timeline taller — and the typed notes. `quillkit test`
renders the near-empty seed and never sees either, so the check sweeps every
fixture across the windows the schema recommends:

```sh
node design/cyber_career_plan/check_one_page.mjs
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
against `thumbnail.png` upstream. At 12pt it runs onto a second page, which is
where the running head is exercised. `minimal.md` is the one the gate cannot
reach: a4 at 11pt, a contact with nothing to link, a Summary with an empty
title whose body is prose and a list, a retitled section, a Certifications list
at three columns, a project with nothing to link, a job whose details are a
sentence rather than a list, and a job at each of the four fills of its second
line — both halves, each half alone, and neither, which is the fill that prints
no second line at all.

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

A third: a table under a subparagraph hangs under that subparagraph's text, and
a table that ends the body keeps the signature block off a page of its own. The
check reads the table's left rule against the text it hangs under, beside a
label wider than the next letter's, and sweeps a table of multi-line rows
across a page of body lengths in USAF and DAF style.

```sh
# run from the repo root; needs a typst binary and pymupdf
python3 design/usaf_memo/check_table_signature.py
TYPST=/path/to/typst python3 design/usaf_memo/check_table_signature.py
```

## usaf_letter

Fixtures and a layout check for the `usaf_letter` quill.

```sh
# render a fixture to PDF (run from the repo root)
node design/usaf_letter/render_fixture.mjs design/usaf_letter/fixtures/maximal.md /tmp/max.pdf

# with no fixture, renders the blueprint the schema seeds
node design/usaf_letter/render_fixture.mjs /tmp/seed.pdf

# check the rendered PDF against AFH 33-337's line offsets
python3 design/usaf_letter/validate_letter.py design/usaf_letter/fixtures/maximal.md /tmp/max.pdf
```

`validate_letter.py` needs `pymupdf` and `pyyaml`.

AFH 33-337 places every element of a personal letter a stated number of lines
below the one before it, and `quillkit test` renders the seed without reading a
single one of those offsets. The check reads them off the rendered baselines, in
lines rather than points: the line is the stride of the sender's address block,
a run of consecutive single-spaced lines, so a letter set at another
`font_size` measures the same integers.

`minimal.md` is a one-page letter carrying one attachment and one courtesy
copy, so every offset from the date to the `cc:` element is on one page and
comparable; `maximal.md` carries a CUI banner, a seal subtitle, a tag line, and
two of each listed element, and runs onto a second page, which is where the
page numbering is exercised — the first page of a letter is never numbered.

The letter package's `config.typ`, `utils.typ` and `primitives.typ` are
`usaf_memo@0.3.0`'s, byte for byte: the letterhead, the signature block, and
the attachment and `cc:` elements with their continuation note are one
implementation across the two documents. Syncing them is a copy, and a
divergence shows here:

```sh
for f in config utils primitives; do
  cmp quills/usaf_memo/0.3.0/packages/tonguetoquill-usaf-memo/src/$f.typ \
      quills/usaf_letter/0.1.0/packages/tonguetoquill-usaf-letter/src/$f.typ
done
```
