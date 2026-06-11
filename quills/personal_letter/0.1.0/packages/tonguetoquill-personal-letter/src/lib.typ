// lib.typ: Public API for the USAF personal letter template
//
// This module provides a composable API for creating United States Air Force
// personal letters that comply with AFH 33-337 "The Tongue and Quill",
// "The Personal Letter" chapter (cross-referenced to AFMAN 33-326 §4.1,
// "Personalized Letter", for inch/line-space anchors).
//
// AFH 33-337 specifies:
// - Use when warmth or sincerity is essential (appreciation, condolence,
//   welcome, congratulations); keep it brief, preferably one page
// - Margins: 1 inch left, right, and bottom; 12pt Times New Roman
// - Date: right side, 1.75 inches (10 line spaces) from the top of the page
// - Sender's address element flush left below the date (optional when the
//   letterhead identifies the sender); receiver's address element below it
// - Salutation "Dear Xxxxx" with no punctuation, one blank line under the
//   receiver's address
// - Text starts one blank line below the salutation; paragraphs unnumbered,
//   first line indented 0.5 inch, subparagraphs an additional 0.5 inch
// - Complimentary close "Sincerely" (no punctuation) one blank line below the
//   text, 4.5 inches from the left page edge
// - Signature element on the fifth line below the close, aligned with it:
//   name in uppercase, grade spelled out, service; no duty title and no
//   authority line
// - Attachments flush left below the signature element; "cc:" below that
//
// Basic usage:
//
// #import "@local/tonguetoquill-personal-letter:0.1.0": frontmatter, mainmatter, backmatter
//
// #show: frontmatter.with(
//   recipient: ("Colonel William J. Nash", "Program Director", "75 South Butler Avenue", "Patrick AFB FL 32925-6357"),
//   salutation: "Dear Colonel Nash",
// )
//
// #show: mainmatter
//
// Your letter body content here.
//
// #backmatter(
//   signature_block: ("JACOB R. BRADLEY, Colonel, USAF",),
// )

#import "frontmatter.typ": frontmatter
#import "mainmatter.typ": mainmatter
#import "backmatter.typ": backmatter
