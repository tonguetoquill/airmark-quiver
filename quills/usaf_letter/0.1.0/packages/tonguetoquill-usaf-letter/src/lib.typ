// Public API of the USAF personal letter template, which typesets per AFH
// 33-337 "The Tongue and Quill", "The Personal Letter".
//
// The three sections compose in document order: `frontmatter` and `mainmatter`
// as show rules, `backmatter` as a function.
//
// #import "@preview/tonguetoquill-usaf-letter:0.1.0": (
//   backmatter, frontmatter, mainmatter,
// )
//
// #show: frontmatter.with(
//   letter-from: ("Colonel Jane A. Doe", "Commander", "123d Example Squadron",
//                 "1 Example Way", "Placeholder AFB ST 12345-6789"),
//   letter-for: ("Major John B. Smith", "Chief, Plans and Programs",
//                "456th Example Group", "2 Sample Blvd", "Sample AFB ST 98765-4321"),
//   salutation: "Dear Major Smith",
// )
// #show: mainmatter
//
// Body paragraphs.
//
// #backmatter(
//   complimentary-close: "Sincerely",
//   signature-block: ("FIRST M. LAST, Rank, USAF",),
// )

#import "frontmatter.typ": frontmatter
#import "mainmatter.typ": mainmatter
#import "backmatter.typ": backmatter
#import "utils.typ": date-pattern
