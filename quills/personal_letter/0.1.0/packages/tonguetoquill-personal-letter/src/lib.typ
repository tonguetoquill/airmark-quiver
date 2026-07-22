// lib.typ — public API for the tonguetoquill-personal-letter package
//
// Implements AFH 33-337 "The Tongue and Quill" Chapter 15 — The Personal Letter.
//
// Basic usage:
//
//   #import "@local/tonguetoquill-personal-letter:0.1.0": frontmatter, mainmatter, backmatter
//
//   #show: frontmatter.with(
//     return_address:   ("Rank Name", "Title", "Org", "Street", "City ST ZIP"),
//     receiver_address: ("Rank Name", "Title", "Org", "Street", "City ST ZIP"),
//     salutation:       "Dear Colonel Smith",
//     addressee_type:   "military",  // or "civilian"
//   )
//
//   #show: mainmatter
//
//   Paragraph one — first line indented 0.5 in; sub-paragraphs use a., (1) …
//
//   #backmatter(
//     signature_block: ("FULL NAME, Rank, USAF", "Duty Title"),
//   )

#import "frontmatter.typ": frontmatter
#import "mainmatter.typ": mainmatter
#import "backmatter.typ": backmatter
