# Changelog

## v0.32.2 - 2026-08-27

- fix(usaf_memo): keep the signing widget in the blank lines above the signature block
- Take quillkit 0.5.4 and quiver 0.27.0
- Take @quillmark/wasm 0.110.0 (#130)
- Move date above signature block


## v0.32.1 - 2026-08-24

- feat(usaf_memo): file the date under Addressing, and give the automatic one a region (#128)
- feat(usaf_memo): typeset the block quote as the body's unlabeled block (#127)
- Take quillkit 0.5.3 and quiver 0.26.0, on wasm 0.109.0 (#126)
- fix(usaf_memo): decline the block quote rather than mis-number it (#125)
- feat(usaf_memo): take subject and attachments as richtext (#122)
- Take quillkit 0.5.2 and quiver 0.25.0, on wasm 0.108.3 (#121)


## v0.32.0 - 2026-08-20

- Take quillkit 0.5.1, on wasm 0.108.1 (#119)
- Take quillkit 0.5.0 for the studio
- feat(usaf_memo): make classification a variant container, on quillmark 0.108
- feat(usaf_memo): derive indorsement action wording, underline the choice


## Unreleased

- **`usaf_memo@0.3.0`'s vendored `src/` is a verbatim copy of upstream.** Every
  `.typ` file matches `tonguetoquill/typst-usaf-memo` byte for byte, so a sync
  is a copy rather than a translation, and an upstream fix can no longer be
  mistranslated on the way in.

  The two adaptations that stood in the way are gone. Public parameters take
  upstream's `kebab-case` spelling: `plate.typ` already maps `Quill.yaml` fields
  to package parameters, and the two are separate namespaces that merely shared
  a spelling, so only the parameter half moved — 20 names in the plate and 8 in
  the design fixtures. `Quill.yaml` is untouched, its fields stay `snake_case`,
  and so do the plate's own locals and the schema paths a fill-in widget is
  addressed by (`field: "signature_block"`). The quillmark-specific comments go
  with upstream's own: what a quill hands the package is described in
  `Quill.yaml` and `plate.typ`, which is where a reader of either looks.

  This leaves `usaf_memo`'s package spelled unlike the quiver's other four,
  which is the trade. Those four are authored here and have no upstream to
  match, so their spelling costs nothing; this one is a vendored fork, and its
  spelling cost a hand translation of every upstream change.

  No ink moves. The closing-section fixture renders the same pages, hash for
  hash, across both page-break variants.

  `usaf_memo@0.2.0` vendors its own older package and is untouched.

- **`usaf_memo@0.3.0` says which `action` value a coordinating official
  writes** (#145). The description taught that an earlier indorsement "reads
  Concur/Nonconcur" and left the author to write `concur`, which `values:`
  refuses. It now says to write `approve` or `disapprove` at every place in the
  chain, and that the printed pair follows the place: `approve` is Concur on a
  coordinating indorsement and Approve on the last. Nothing renders differently.

- **`usaf_memo@0.3.0`: a backmatter list running onto the next page says so on
  the page it leaves.** AFH 33-337 wants the note there — "3 Attachments (listed
  on next page):", or the neutral "(continued on next page)" for `cc:` and
  `DISTRIBUTION:`. It is decided by reading the page the section landed on
  instead of predicting it from inside the section, which reported the top of
  the page it had already moved to and so never fired. Each closing block
  reserves the following section's lead-in and note line as breaking height and
  reclaims it immediately, so the note is guaranteed room on the departing page;
  where that reservation does not fit, the signature block travels with its
  sections rather than stranding them. Ported from upstream
  [typst-usaf-memo#53](https://github.com/tonguetoquill/typst-usaf-memo/pull/53),
  leaving the three touched functions code-identical to upstream.

  A memorandum whose signature block ends within about three lines of the bottom
  margin, with backmatter below it, now moves that block to the next page with
  its sections. Nothing else moves: where no section splits, layout is unchanged.

  The vendored manifest requires Typst 0.15.1, matching the compiler the quiver's
  wasm runtime already provides.

- **`usaf_memo@0.3.0` vendors `tonguetoquill-usaf-memo` 5.0.0, upstream's own.**
  The vendored copy had drifted from `tonguetoquill/typst-usaf-memo`, and
  upstream is where the package is authored, so upstream wins each difference:
  `authority-line` is renamed `format-authority-line`; `date-placeholder-slot`
  takes its widget by name and rules the slot's baseline when given none, for a
  date written by hand; the two inlined line-stride measurements call the
  `line-stride()` helper they duplicated; a local in `frontmatter` is inlined;
  and `render-backmatter-section` drops its explicit `pagebreak()` for
  `block(breakable: false, ..)`.

  **That last one moves every memorandum with an attachment, cc, or
  distribution list.** A bare emission skipped `block.above`, so the gap below
  the signature block measured 35.83pt where every other blank-line gap in a
  memorandum is a whole number of line strides; it is 41.83pt now, three
  strides, and the gap after an enumerated attachment list is 27.89pt where it
  was 21.89pt. Both are the spec-correct values. `Cinzel[wght].ttf` gives way to
  upstream's static `Cinzel-Regular.ttf`, which renders the same glyphs at the
  same positions and does not draw typst 0.14's warning that variable fonts may
  render incorrectly.

  It also carries upstream's defect in that function. AFH 33-337 wants a list
  running onto the next page to say so on the page it leaves; the note is
  computed from a fit test that cannot be reached once the section has moved,
  since the section carries `here()` with it and then measures against a full
  empty page. The note is due only where the signature block and the list fall
  on different pages — a body long enough to push the list over, short enough
  to keep the signature back. Across a sweep of that band the note printed for
  the first half of it before this sync and nowhere in it after. Fixed by the
  first entry above, which ships in the same release.

  Every `.typ` file is code-identical to upstream. Two adaptations survived this
  sync — `snake_case` public parameters, and comments naming what a quill hands
  the package — and the entry above drops both.

  The manifest declares 5.0.0 rather than 4.0.0, which the plate's import
  follows; its `[template]` section is dropped, having named a `template/`
  directory and thumbnail the vendored copy does not ship.

- **`usaf_memo@0.3.0` keeps the closing sections out of the body rebuild.**
  `mainmatter` renders through a buffer: `render-body` lays the content out
  hidden, collects each paragraph, table, and block quote, and emits that
  buffer in document order with AFH 33-337 numbering assigned. Everything the
  buffer does not hold — the `place`, the measured gaps, the 4.5-inch pad a
  signature block is made of — is dropped on the way through. That is the right
  treatment for a body and the wrong one for anything else, and applied as a
  show rule, `#show: mainmatter`, the rest of the document is what it gets:
  `backmatter` and every `indorsement` went through it too. The signature
  blocks landed at the left margin without their anchors, the attachment and
  cc labels and the indorsement headers vanished, and the lines that survived
  took body paragraph numbers — in a memo with one indorsement, the memo's own
  signature block disappeared and the indorsement's became paragraphs 3 and 4.
  A closing section carrying a page break did not render wrong so much as not
  render: the rebuild lays its content out inside a `place`, where Typst rejects
  a `pagebreak` outright, so `backmatter(leading_pagebreak: true)` and any
  `separate_page` indorsement failed the compile.

  The two halves have to part before the rebuild rather than be filtered
  during it, since by then the geometry is already gone. `backmatter` and
  `indorsement` label what they return, and `mainmatter` splits its content at
  the first marker: what precedes it goes to `render-body`, what follows
  reaches the page untouched. Everything from the marker on stays together,
  prose written between two closing sections included — past the signature
  block a memorandum's body is over. Three shapes carry a marker and all three
  are read: a direct child, the whole of what the show rule was handed where a
  closing section is all there is, and the `child` of the `styled` element a
  `set` or `show` rule written after `#show: mainmatter` wraps the remainder
  in — that last one being the shape an ordinary `#set par(..)` produces, and
  the one whose absence left the bug fully reachable.

  The plate calls `#mainmatter[…]`, which has no marker to split at and renders
  exactly as before, so nothing this quiver produces moves. The fix is for the
  package's own callers — the form `lib.typ` documents — and the same one
  landed upstream in `tonguetoquill/typst-usaf-memo`.
  `design/usaf_memo/check_closing_sections.mjs` renders one memorandum in each
  of those shapes and requires the pages to agree, which `quillkit test` cannot
  do: every plate in `quills/` uses the function form.

- **The `usaf_memo` packages are Apache-2.0.** Both vendored copies of
  `tonguetoquill-usaf-memo` carried MIT while every other quill's package,
  `package.json`, and the README said Apache-2.0. Upstream relicensed the
  package, so each copy now takes that LICENSE and the `Apache-2.0` SPDX
  identifier in `typst.toml` — `usaf_memo/0.2.0` included, since a published
  version's distributed copies keep the terms they were received under and
  leaving the file MIT would only misdeclare the license from here on. No
  `.typ` source under `0.2.0` is touched and nothing it renders moves. The
  bundled fonts keep their own upstream terms, as do the seals under
  `quills/usaf_memo/*/assets/`.

- **`usaf_memo@0.3.0` takes an authority line.** AFH 33-337's closing section
  opens with an element the quill had no field for: the authority line, which
  tells the reader the signer acted for the commander, the command section, or
  the headquarters. `authority_line` now carries it — on the memo, and on each
  indorsement, which closes with a signature of its own. The handbook places it
  "in uppercase on the second line below the last line of the text and 4.5
  inches from the left edge", and then measures the signature from it rather
  than from the body: "if the authority line is used, type the signature element
  five lines below the authority line." So `render-signature-block` renders it,
  as the one place that knows where the block's anchor landed — it shares that
  anchor, joins the widest-line test that shifts a long block left, and rides
  inside the same unbreakable block, since an authority line stranded above a
  page break from the signature it authorizes is the split the block exists to
  prevent. The field is uppercased for the author, and blank is no line at all:
  that is the ordinary memo, the one the commander signs, where the handbook
  forbids the line outright.

  What that primitive takes is the slot rather than the element. AFH 33-337
  seats a personal letter's complimentary close in exactly the same place under
  exactly the same rule — "'Sincerely' on the second line below the text and 4.5
  inches from the left edge", the signature "on the fifth line below and aligned
  with the complimentary close" — while barring the authority line from letters
  outright: "The authority line is not used for Personal Letters." One geometry,
  two occupants that never co-occur. So the parameter is `closing-line`, either
  may fill it, and casing stays with the element that has an opinion about it:
  `authority-line()` uppercases the memo's, and "Sincerely" would not be. The
  schema field stays `authority_line` — this quill renders memoranda, whose slot
  admits one occupant, and a letter would be its own quill with its own field
  over the same primitive.

- **`usaf_memo@0.3.0` keeps the signing widget in the blank lines above the
  signature block.** Since #113 moved the four blank lines inside the
  unbreakable block, `render-signature-block` has emitted `v(gap)` and then
  `place`d the widget: `place` anchors at the current flow position, so the
  widget anchored at the first name line and painted down over the printed
  signature block. It is now placed before the gap is emitted and offset to
  the bottom of the gap, so it ends where the printed name begins, and the
  same code path carries every indorsement's widget. The plate sizes the
  widget to two and a half lines (the helper's default is 50pt, the whole
  gap) so the line and a half above it stays clear of the body text; the
  block itself stays on AFH 33-337's fifth line below the text. Nothing else
  moves: the printed memo is pixel-identical, only the widget rectangle
  changes.

- **Take `@quillmark/wasm` 0.110.0.** `Quill::validate` refuses only what the
  render floor refuses, and the difference lands here: `usaf_memo@0.2.0` declares
  `letterhead_caption` an `array`, and the bare scalar a starter template spells
  it with — a valid one-element list everywhere the document renders — audited as
  fatally `validation::type_mismatch` on every document seeded from that template.
  It audits clean, and a fatal `validation::*` now means the document does not
  render. Two codes move with the rule: a value the render floor adopts raises
  nothing where it raised `type_mismatch`, and a bare scalar stringified into an
  `enum` field is domain-checked on that string, so a spelling outside `values:`
  is `validation::enum_violation` where it was silent. The release's other half is
  a writer's obligation on the content seam and reaches no plate: a quill reads a
  container path and writes none.

- **Take `quillkit` 0.5.4 and `@quillmark/quiver` 0.27.0.** The gate already
  rendered on wasm 0.110.0, resolving whatever this collection's tree holds; the
  studio client renders through the copies it was built with, and those were the
  0.109.0 stack. Both now stand on one version, so what the studio draws and what
  `quillkit test` renders agree. Nothing in a quill moves for either.

- **`usaf_memo@0.3.0` drops the `box` around its date claim.**
  [borb-sh/quillmark#1375](https://github.com/borb-sh/quillmark/pull/1375)
  makes a `field-region` claim around inline content layout-neutral: each of the
  helper's two markers had trailed a space into the inline flow, 5.43pt across
  the pair at 12pt. `usaf_memo@0.3.0`'s date claim needed a `box` to absorb that,
  and the box is now redundant, so it goes: the claim renders pixel-identical
  without it, and drops the one-line constraint a box imposes.

- **`usaf_memo@0.3.0` gives the automatic date a preview region.** A blank
  `date` means today's, and until now the plate let `frontmatter` fill it from
  its own `datetime.today()`. Package-born ink carries no schema address, so the
  one date a memo never types was the one date a preview could not click: an
  editor could route to every other field and not to that one. The plate stamps
  today itself and wraps the stamp in the helper's `field-region("date", ..)`,
  which claims the ink for the field on both placements — the heading and the
  indorsement header that re-inks it through `original_date`. The render is
  unchanged: against an authored same-day date, page 1 is pixel-identical and
  page 2 differs by four pixels of one gray level.
  - The stamp is markup rather than the `str` `.display()` returns, because a
    `str` off a function call carries no source position and unpositioned ink
    is unclaimable.

- **`usaf_memo@0.3.0` files the date under Addressing.** The memo's `date` and
  the `indorsement` card's `date` both move from the `additional` group to the
  end of `addressing`, where they sit below the signature block. A date is part
  of who-to-whom-and-when, not a formatting knob, and both editors now read in
  the order AFH 33-337 lays the page out: recipients, sender, subject, signer,
  date. Field order is declaration order, so the move is the declaration's
  position; nothing about either field's type, default, or render changes.

- **`usaf_memo@0.3.0` typesets the block quote as the body's unlabeled block**
  (#123). AFH 33-337 numbers every paragraph and letters every subparagraph, and
  a memorandum sometimes has to hold lines that are neither — a roster of names,
  an address, a quoted passage. A `>` block is where an author says so:
  `render-body` captures it and emits its content verbatim in the second pass,
  so nothing inside it takes a number, a letter, or a bullet, and the paragraphs
  around it keep the numbering they had. `main.body` and the `indorsement` card
  body no longer declare `unsupported: [quote]`, so a body holding one stops
  drawing `plate::unsupported_construct`. A body with no block quote renders
  byte-identically.
  - This supersedes the decline that stood in this section: a quote used to be
    dropped, and before that it was silently swallowed into a numbered
    paragraph. What was blocking is fixed upstream — under `@quillmark/wasm`
    0.109.0 a container inside a list item no longer terminates the list, so a
    quote nests inside `item(body: ..)`, its siblings keep their nesting, and
    the level the capture records is trustworthy. A quote inside a subparagraph
    therefore hangs under that subparagraph's text; one at top level sits flush
    at the left margin.
  - Two things are imposed on the quote, both so it reads as authored: it is
    block-indented to that offset rather than first-line-indented like a
    continuation, since its line structure is the point; and its own paragraphs
    are spaced by a blank line, because `par.leading` and `par.spacing` are both
    half an em here and a paragraph break would otherwise land as an ordinary
    line break. Typst's own block-quote framing (padding, attribution) is
    dropped with the element.
  - Line breaks inside a quote are the Markdown ones: a soft break joins, a hard
    break (a trailing backslash, or two trailing spaces) breaks. That is settled
    in `from_markdown` before any plate is reached — `> A\n> B` parses as the
    single line `A B` — so a roster ends each of its lines with a backslash. The
    seeded body example shows it.
  - This is the unlabeled-block escape hatch #124 went looking for, and now the
    only one that reaches the page. A fenced block was the standing answer, but
    it does not render at all: a block `raw` is neither a paragraph nor a table,
    so no rule in `render-body`'s capture pass buffers it and the hidden first
    pass swallows it whole — the same silent drop the quote used to take. That
    is untouched here and still open.
- **`usaf_memo@0.3.0` takes `subject` and `attachments` as `richtext`.** Both
  fields carry citations, and AFH 33-337 italicizes publication titles wherever
  they appear. `references` has accepted emphasis since 0.2.0, so until now an
  author could italicize a title in the references block and not in the
  attachment entry naming the same publication — nor in the subject line, which
  is where a lone reference prints, in parentheses and in italics, immediately
  beside a subject that could not match it. Both fields now take standard
  Markdown emphasis, and their descriptions say so in the wording `references`
  uses. A Markdown link lowers to a real PDF link annotation, drawn unstyled, so
  a linked attachment is clickable in the PDF and unchanged on paper.
  - Rendering of text that carries no marks is byte-identical: the seeded
    example and a filled memo both pixel-match their `plaintext` renders, and
    `main.subject` and `main.attachments[i]` keep their regions, so the
    cross-navigation 0.3.0 was minted for is unaffected.
  - One shape changes. A content field rests at its codec's canonical form, so
    `attachments` now serializes as a content object (`text:` beside a `marks:`
    list) in the seeded blueprint and in any document re-serialized after
    `quill.parse` — the shape `references` has always rested at. `subject` stays
    a scalar in the blueprint, since its `!must_fill` marker skips the codec,
    and rests as an object once filled and written back. Documents need no
    migration: an authored `subject:` or `attachments:` string still parses.

- **`usaf_memo@0.3.0`'s CUI block is a variant of `classification`, not four
  fields beside it.** `classification` declares a `CUI` variant, so it rests as
  a container: the marking is `classification.value`, and the four cells that
  exist only in the CUI world sit under it with their `cui_` prefix dropped.
  A document selecting CUI moves its four keys in:

  ```yaml
  # Before
  classification: CUI
  cui_controlled_by: SAF/AA
  cui_poc: Capt J. Smith, DSN 555-1234
  cui_category: PRVCY
  cui_limited_dissemination: FEDONLY

  # After
  classification:
    value: CUI
    controlled_by: SAF/AA
    poc: Capt J. Smith, DSN 555-1234
    category: PRVCY
    limited_dissemination: FEDONLY
  ```

  A stale key reaches nothing and draws no diagnostic — the plate reads the
  container — so sweep with `quill.validate(doc)` rather than a render diff:
  `controlled_by` and `poc` carry no `default:` and are therefore obliged in
  the CUI world, which is what DoDM 5200.48 requires and what the flat spelling
  could state only in prose. Every other world is unchanged, and the bare
  `classification: CUI` spelling stays valid for a memo carrying no CUI answers.
  `dissemination` keeps its place beside the container: it is the banner's
  suffix on a classified memo as much as on a CUI one.

- **Migrate to `@quillmark/wasm` 0.108, `@quillmark/quiver` 0.24 and `quillkit`
  0.4.** A `date` field now reaches a plate as a native Typst `datetime`, so
  the `(value:, display:)` wrapper every quill dispatched on is gone. Where a
  package inks the date, the plate hands it `display("<field>", pattern)` — the
  field's content projection, whose glyphs keep their schema address however
  deep the package formats it — so the memo date, each indorsement's signing
  date, and the MOA's mid-point review date stay click-to-edit. Both memo
  packages export the pattern they print (`date-pattern`) rather than have the
  plate restate it.

- **An indorsement's action line now words itself, and marks the choice with an
  underline.** `$cards.indorsement.<n>.action` no longer asks which pair of
  options to print — it carries only the decision (`approve`, `disapprove`, or
  `undecided`), and `usaf_memo@0.3.0` derives the wording from the
  indorsement's place in the chain: the last indorsement is the approval
  authority and reads Approve / Disapprove, every one before it is a
  coordinating official and reads Concur / Nonconcur. The `concur`,
  `nonconcur`, and `undecided_concur` values are gone; a card carrying one now
  fails validation and should be re-pointed at the matching decision
  (`concur` → `approve`, `nonconcur` → `disapprove`, `undecided_concur` →
  `undecided`). Blank still hides the line entirely. The selected option is
  also underlined rather than enclosed in a rounded box, which in a rendered
  PDF read as a fillable form widget sitting among the real ones; the rejected
  option is still struck out.


## v0.31.0 - 2026-08-14

- chore: migrate to @quillmark/wasm 0.105 and quiver 0.23
- chore(afmc_moa): version the quill 0.0.1
- refactor(afmc_moa): use plaintext/richtext for text fields instead of string
- fix(afmc_moa): correct attachment lettering, date formatting, and naming
- fix(MOAs): tighten nested indent taper further
- fix(MOAs): stop over-indenting nested body paragraphs
- feat(MOAs): make Financial Details its own card, in document order
- feat(MOAs): model every example on DoDI 4000.19 Figure 1
- fix(usaf_memo): stop indorsement signatures orphaning onto their own page (#113)
- usaf_memo: make an undated indorsement's date a fillable PDF field (#111)
- feat(MOAs): split remaining standard sections into their own cards
- feat(MOAs): move background into its own card
- fix(MOAs): correct Quill.yaml schema and plate.typ data keys
- fix(MOAs): move mouDesign.md into version dir
- feat(MOAs): add MOA quill 0.1.0


## Unreleased

- Migrate to `@quillmark/wasm` 0.105 and `@quillmark/quiver` 0.23. Enum blanks
  are engine-supplied (`""` is no longer a `values:` member), so
  `classification` and `action` drop the empty member and keep `default: ""`;
  plates branch over `values ∪ blank` instead of treating an unanswered enum as
  the first variant.


## v0.30.0 - 2026-08-13

- feat(usaf_memo): merge letterhead_caption into letterhead_title (#109)


## v0.29.0 - 2026-08-13

- usaf_memo: mint 0.3.0, moving every prose field onto plaintext for region cross-navigation (#105)
- Update enum field syntax in Quill schemas (#106)
- usaf_memo: port #91, #92, #93 onto @quillmark/wasm 0.103 (#103)
- Ignore build output and refresh lockfile


## Unreleased

- **An undated indorsement now renders a fillable PDF field, not a rule.** The
  blank date slot in an indorsement header (`$cards.indorsement.<n>.date` left
  empty, the usual case since the endorser dates the memo when signing) is an
  empty AcroForm text box the endorser types into, replacing the 1in rule they
  had to write on by hand. It occupies exactly the rule's box — 1in wide, one
  line tall, sitting on the date's baseline — so surrounding layout is
  unchanged, and it is emitted only where a header prints a date slot: an
  indorsement carrying a date still prints that date, and an `informal`
  indorsement still has no header to date. The widget also carries the region
  the blank slot never had, so a click on it in a preview routes to the card's
  `date` field. Non-PDF output (SVG/PNG) renders the slot as blank space,
  where it previously drew the rule.
- **`usaf_memo@0.3.0` no longer strands an indorsement signature on a page of
  its own.** AFH 33-337 is explicit — "do not place the signature element on a
  continuation page by itself" — but the only thing holding a signature block to
  its text was a rule in the body renderer that made the closing element sticky
  when it measured under four lines. A body ending in anything longer, or in a
  table, had no anchor at all: when its last line fell within about five lines of
  the page foot, the four blank lines were consumed at the bottom of that page
  and the signature block opened the next one alone. Reproduced across a sweep of
  127 generated documents, which found it in fourteen: standard, `separate_page`
  and action-line indorsements, indorsement chains, and bodies closing on a
  table. The rule now keys on how much space relocating the element would cost
  rather than on a line count, so the closing element is sticky up to a third of
  the text block — long enough to cover the paragraphs and tables a memorandum
  actually ends on, short enough that a half-page block is still divided by the
  break as before (which leaves its own tail on the continuation page for the
  signature to sit under). Same sweep after the change: fourteen fixed, none
  regressed, and the seeded example plus the CUI, DAF and backmatter documents
  render pixel-identically.
- **The signing field no longer lands off the page with it.** The field is drawn
  over the blank lines above the printed name, and was positioned by reaching
  upward out of the signature block — into space belonging to the previous page
  whenever the block started at a top margin. It was painted over the page number
  and the classification banner in all eighteen documents where that happened.
  The four blank lines now sit inside the block, which is what the field is
  measured against, so it travels with the block onto whatever page that lands
  on. The gap above the signature is unchanged, and so is every one of the 771
  signature regions across the sweep.
- **Two cases stay the author's to structure around**, deliberately: each needs a
  Typst primitive that does not exist, and engineering around either costs more
  than it buys. Typst has no way to emit an author-facing warning (`warn` is not
  a binding), so the guidance lives in the schema and here rather than in a
  diagnostic.
  - A closing paragraph or table longer than a third of the text block — about
    fifteen lines at 12pt — is left to be divided by the page break, so if it
    happens to end within a few lines of the page foot its signature can still
    open a page alone. Keeping it sticky instead would relocate forty-odd lines
    and gut the page it left. The remedy is the one AFH 33-337 itself implies:
    split the closing paragraph. The budget is a fixed length, so smaller body
    type buys proportionally more lines.
  - An `informal` indorsement with no body and no action renders nothing but a
    signature block. A section with no text of its own cannot be tied to the text
    above it — Typst has no keep-with-previous, and the only mechanism that
    reaches backward risks stranding the *main* memorandum's signature, trading a
    degenerate case for a common one. Give such an indorsement a body or an
    action, or use `standard`, which prints a header that anchors it. The
    `format` field says so at the point the choice is made. Its signing field is
    now on the page with it either way.
- **`usaf_memo@0.3.0` takes the letterhead as one array.** `letterhead_caption`
  is folded into `letterhead_title`, which is now an ordered list of lines: the
  first is the department title, set larger, and the rest are the unit's
  organization lines beneath it. A one-line list renders the title alone; an
  empty list renders no letterhead text and raises nothing. This replaces a
  split whose two halves were always authored together and whose names gave no
  hint which line landed where. Breaking for documents pinned to `@0.3`, which
  0.3.0 shipped too recently to have many of; `@0.2` is untouched.
- **New quill version: `usaf_memo@0.3.0`.** Every prose field is now a content
  field (`plaintext`, or `richtext` where AFH 33-337 calls for emphasis), so its
  rendered glyphs carry schema-addressed regions and a preview can cross-navigate
  to the editor field a click landed on. A `string` field lowers into the data
  literal and places glyphs no region is keyed to; a content field lowers to a
  markup block whose spans the backend reads geometry from. Converted:
  `memo_for`, `memo_from`, `subject`, `signature_block`, `letterhead_title`,
  `letterhead_seal_subtitle`, `dissemination`,
  `cui_controlled_by`, `cui_category`, `cui_limited_dissemination`, `cui_poc`,
  `cc`, `distribution`, `attachments`, and the indorsement card's `from`, `for`,
  and `signature_block`. On the seeded example this takes the rendered document
  from 5 addressable fields to 24; on a document that fills the optional fields,
  from 10 to 35.
- The fields that stay non-content are the ones with nothing to navigate *to*:
  the controlled vocabularies (`classification`, `letterhead_seal`,
  `memo_style`, `format`, `action`), `font_size`, and the `date` fields, which
  already lower to click-to-edit value objects. `tag_line` and `references` were
  already `richtext` and are unchanged.
- `usaf_memo@0.2.0` is retained unchanged, so documents pinned to `@0.2` keep
  resolving and rendering exactly as before.
- Rendering is unchanged: across the seeded example and hand-built documents
  covering CUI markings, a Memorandum for Record, blank optionals, DAF style,
  inline and block references, and all three indorsement formats, output is
  pixel-identical apart from ±1 antialiasing where a value now sits in its own
  shaped run.


## v0.28.0 - 2026-08-11

- Upgrade to @quillmark/wasm 0.103, quiver 0.21, and quillkit 0.2 (#101)
- Bump quillkit to 0.1.1 (#98)
- Retire what the quillkit migration left behind (#97)
- Migrate to @quillmark/wasm 0.102 and quiver 0.19, and move the author's loop onto quillkit (#96)


## v0.27.0 - 2026-06-22

- usaf_memo: a standard indorsement that gets pushed onto a new page now automatically renders the separate-page identifying header (`Nth Ind to ORIG, DATE, SUBJECT`), and the header is kept together with its body/signature so it is never stranded or orphaned across a page break.
- Change indorsement date default from today to blank (#87)
- Standardize fonts across quills to NimbusRomNo9L (#86)
- Remove freedom250

## v0.26.0 - 2026-06-16

- Refactor CUI indicator block layout and styling (#82)


## v0.25.1 - 2026-06-10

- make fields in Additional section of Indorsement compact


## v0.25.0 - 2026-06-10

- Remove attachments and cc from usaf_memo indorsements (#79)
- Bump to @quillmark/wasm@0.90.0 and @quillmark/quiver@0.15.0


## v0.24.8 - 2026-06-08

- Remove attachments and cc from indorsements (usaf_memo) — AFH 33-337 does not define backmatter elements for indorsements


## v0.24.7 - 2026-06-07

- Remove body example for indorsements (usaf_memo)
- Replace Arimo font with Nimbus Roman No9 L (#77)


## v0.24.6 - 2026-06-05

- usaf_memo: order the Classification field group above Additional in the editor UI


## v0.24.5 - 2026-06-05

- Add adjustable letterhead emblem height for placement parity (#74)
- Swap Freedom250 emblem with Freedom250 + USAF 


## v0.24.4 - 2026-06-05

- chore: upgrade @quillmark/wasm to 0.88.0 and @quillmark/quiver to 0.13.0 (#72)


## v0.24.3 - 2026-06-03

- Fix CUI markings to comply with DoD CUI Registry (DoDM 5200.48) (#57)
- Add Liberation Mono font and configure monospace text rendering (#69)
- usaf_memo: make tag_line a Markdown field (#68)
- **Tag line is now a Markdown field** — `usaf_memo/0.2.0` `tag_line` changed
  from `string` to `markdown`. The organizational motto accepts standard
  Markdown emphasis (e.g. `*italics*`, `**bold**`). Existing plain-string tag
  lines continue to work unchanged.

## v0.24.2 - 2026-06-01

- usaf_memo: clarify that unclassified documents typically omit classification banner (#66)


## v0.24.1 - 2026-06-01

- fix(usaf-memo): wrap inline-reference in box() to prevent closing paren falling on new line (#64)

## v0.24.0 - 2026-06-01

- **References are now a Markdown field** — `usaf_memo/0.2.0` `references`
  items changed from `string` to `markdown`. Entries accept standard Markdown
  (e.g. `*Title*` for italic publication titles) and render as an
  auto-lettered `(a) (b) (c)` list per AFH 33-337. Existing plain-string
  references continue to work unchanged. (#55)
- **Single-reference rule** — when exactly one reference is supplied it is now
  rendered inline in parentheses after the SUBJECT line; the standalone
  References block only renders for two or more references, per AFH 33-337
  (`frontmatter.typ`, `primitives.typ`). (#54)
- Compatibility: `@quillmark/wasm` 0.87.0, `@quillmark/quiver` ^0.12.0.
  (#58, #59)
- CI: adopt the two-stage release workflow mirrored from quillmark. (#61)

## v0.23.0 - 2026-05-28

- Compatibility: `@quillmark/wasm` 0.85.0, which drops the `required` field
  axis in favor of the Endorsed / Must Fill model (a field is Must Fill iff it
  has no `default`). No quill schemas changed — all `required:` properties were
  already removed in the 0.84.0 migration. (#56)

## v0.22.1 - 2026-05-22

- Compatibility: `@quillmark/wasm` 0.84.0.

## v0.22.0 - 2026-05-22

- Compatibility: `@quillmark/wasm` 0.83.0. (#52)

## v0.21.0 - 2026-05-22

- Compatibility: migrate to `@quillmark/wasm` 0.82.0. (#51)

## v0.20.4 - 2026-05-19

- Pin the WASM peer dependency in `package-lock.json` and adjust spacing in
  `usaf_memo/0.2.0` `primitives.typ`. No rendering changes.

## v0.20.3 - 2026-05-19

- **Breaking default:** the Freedom 250 letterhead emblem is now opt-in. The
  runtime default for `freedom250` in `usaf_memo/0.2.0` (`plate.typ`) changed
  from `true` to `false`; set `freedom250: true` to keep the emblem.

## v0.20.2 - 2026-05-19

- Remove the `freedom250` schema default in `usaf_memo/0.2.0` (`Quill.yaml`) so
  the field is off unless explicitly enabled.
