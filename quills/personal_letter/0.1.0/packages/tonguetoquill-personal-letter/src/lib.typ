// lib.typ: Public API for personal letter template (AFH 33-337 Ch. 15)
//
// Provides a composable API for creating Air Force personal letters compliant
// with Chapter 15 of The Tongue and Quill (AFH 33-337).
//
// Basic usage:
//
// #import "@local/tonguetoquill-personal-letter:0.1.0": frontmatter, mainmatter, backmatter
//
// #show: frontmatter.with(
//   return_address: ("Rank Name", "Duty Title", "Organization", "Address"),
//   receiver_address: ("Rank Name", "Duty Title", "Organization", "Address"),
//   salutation: "Dear Colonel Smith",
//   addressee_type: "military",  // or "civilian"
// )
//
// #show: mainmatter
//
// Letter body text here.
//
// #backmatter(
//   signature_block: ("FULL NAME, Rank, USAF", "Duty Title"),
//   attachments: (...),
//   cc: (...),
// )

#import "frontmatter.typ": frontmatter
#import "mainmatter.typ": mainmatter
#import "backmatter.typ": backmatter
