# Changelog

## v0.32.0 - 2026-08-20

- Take quillkit 0.5.1, on wasm 0.108.1 (#119)
- Take quillkit 0.5.0 for the studio
- feat(usaf_memo): make classification a variant container, on quillmark 0.108
- feat(usaf_memo): derive indorsement action wording, underline the choice


## Unreleased

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
  - Two shapes are load-bearing and neither is obvious. The stamp is markup
    rather than the `str` `.display()` returns, because a `str` off a function
    call carries no source position and unpositioned ink is unclaimable. And it
    is boxed, because each of the helper's two markers trails a space into the
    inline flow (5.43pt across the pair at 12pt) and a box trims its content's
    leading and trailing whitespace; unboxed, the indorsement header line moved.

- **`usaf_memo@0.3.0` files the date under Addressing.** The memo's `date` and
  the `indorsement` card's `date` both move from the `additional` group to the
  end of `addressing`, where they sit below the signature block. A date is part
  of who-to-whom-and-when, not a formatting knob, and both editors now read in
  the order AFH 33-337 lays the page out: recipients, sender, subject, signer,
  date. Field order is declaration order, so the move is the declaration's
  position; nothing about either field's type, default, or render changes.

- **`usaf_memo@0.3.0` declines the block quote instead of mis-numbering it**
  (#123). `main.body` and the `indorsement` card body both declare
  `unsupported: [quote]`, and `render-body` drops `quote.where(block: true)`
  in its capture pass, so the declaration is true rather than nominal. A body
  holding a `>` now draws the non-fatal `plate::unsupported_construct` before
  the render — `this quill does not typeset a block quote` — where it used to
  render as an ordinary numbered paragraph with the quote marking silently
  dropped. Documents that hold no block quote render byte-identically.
  - The root cause is upstream and structural, and this is a containment, not
    a fix. Against `@quillmark/wasm` 0.108.3 the Markdown lowering does not
    nest a quote inside a list item: it closes the `item(..)` at the quote,
    emits the `quote(..)` as a sibling, and leaves every later block of that
    item at top level, so the next item restarts its lettering. A heading, a
    fenced block, and a nested list in the same position all stay inside
    `item(body: ..)`, which acquits `render-body`'s capture shape — the
    nesting is gone before this package sees the tree, and no show rule here
    can recover it. That damage to the *surrounding* blocks remains; what
    changes is that the construct responsible is now named out loud, and
    removing the `>` restores a correct render.
  - So a block quote is not the unlabeled-block escape hatch. A fenced block
    is (#124): it nests correctly inside a list item today, and it preserves
    line structure, which a quote cannot — the lowering collapses a quote's
    soft breaks to spaces before any plate is reached.

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
