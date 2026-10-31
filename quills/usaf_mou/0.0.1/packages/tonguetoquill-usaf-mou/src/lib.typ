// Public API of the USAF memorandum template, which typesets per AFH 33-337
// "The Tongue and Quill" Chapter 14, "The Official Memorandum". This copy adds
// `agreement-backmatter` and `frontmatter`'s `memo-heading` for memorandums of
// understanding with any number of signers.
//
// The four sections compose in document order: `frontmatter` and `mainmatter`
// as show rules, `backmatter` and `indorsement` as functions, so any number of
// indorsements may follow the memo they endorse.
//
// #import "@preview/tonguetoquill-usaf-mou:0.0.1": (
//   agreement-backmatter, backmatter, frontmatter, indorsement, mainmatter,
// )
//
// #show: frontmatter.with(
//   subject: "Your Subject Here",
//   memo-for: ("OFFICE/SYMBOL",),
//   memo-from: ("YOUR/SYMBOL",),
//   memo-style: "usaf", // "usaf" (default) or "daf"
// )
// #show: mainmatter
//
// Body paragraphs.
//
// #backmatter(signature-block: ("FIRST M. LAST, Maj, USAF", "Duty Title"))
//
// #indorsement(
//   from: "ORG/SYMBOL",
//   to: "RECIPIENT/SYMBOL",
//   signature-block: ("FIRST M. LAST, Maj, USAF", "Duty Title"),
// )[
//   Indorsement content here.
// ]

#import "frontmatter.typ": frontmatter
#import "mainmatter.typ": mainmatter
#import "backmatter.typ": backmatter
#import "agreement.typ": agreement-backmatter
#import "indorsement.typ": indorsement
#import "utils.typ": date-pattern
