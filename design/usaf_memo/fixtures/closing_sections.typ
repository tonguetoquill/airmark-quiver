// The memorandum every form in this directory typesets.
//
// Imported by path rather than as `@local/…`, so the check reads the working
// tree and needs no package cache.

#import "../../../quills/usaf_memo/0.3.0/packages/tonguetoquill-usaf-memo/src/lib.typ": (
  backmatter, frontmatter, indorsement, mainmatter,
)

#let addressing = frontmatter.with(
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",
  letterhead-caption: ("123D TEST SQUADRON (AETC)",),
  memo-for: ("ALL PERSONNEL",),
  memo-from: ("123 TS/CC", "1 Test Way", "Test AFB TX 12345-6789"),
  subject: "Closing Sections Outside the Body Rebuild",
  date: "1 September 2026",
)

// Every element the rebuild pass buffers — paragraph, list, table, block quote
// — so the body half of the split is exercised too.
#let body-content = [
  The first paragraph, which takes number one.

  - Alpha, lettered a.
  - Bravo, lettered b.

  #quote(block: true)[An unnumbered line, verbatim.]

  #table(columns: 2, [Left], [Right], [Row], [Two])

  The closing paragraph of the body.
]

// A closing section carrying a page break is rejected outright inside the
// rebuild pass — `pagebreaks are not allowed inside of containers` — so the two
// variants fail differently and both are worth running: with breaks, the split
// is what makes the document compile at all; without them, the document
// compiles either way and only the ink says whether the split happened.
#let page-breaks = sys.inputs.at("page-breaks", default: "true") == "true"

// The 4.5-inch signature anchor, the measured gaps, and the attachment, cc, and
// distribution labels.
#let closing = backmatter.with(
  authority-line: "FOR THE COMMANDER",
  signature-block: ("FIRST M. LAST, Maj, USAF", "Commander"),
  attachments: ("Test Attachment 1", "Test Attachment 2"),
  cc: ("456 TS/CC",),
  distribution: ("123 TS/CC",),
  leading-pagebreak: page-breaks,
)

#let first-indorsement = indorsement.with(
  from: "123 TS/CC",
  to: "456 TS/CC",
  format: if page-breaks { "separate_page" } else { "standard" },
  authority-line: "FOR THE COMMANDER",
  signature-block: ("SECOND N. LAST, Capt, USAF", "Flight Commander"),
  date: "2 September 2026",
)

// Informal rather than standard: two standard indorsements after a backmatter
// that does not break the page make the layout fail to converge.
#let second-indorsement = indorsement.with(
  from: "456 TS/CC",
  to: "123 TS/CC",
  format: "informal",
  signature-block: ("THIRD O. LAST, Maj, USAF", "Director of Operations"),
  date: "3 September 2026",
  action: "approve",
  approval-authority: true,
)

#let indorsements = (
  first-indorsement[The first indorsement, on its own page.],
  second-indorsement[The second indorsement, which approves.],
)
