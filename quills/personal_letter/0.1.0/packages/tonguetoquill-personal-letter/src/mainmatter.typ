// mainmatter.typ: Mainmatter show rule for the USAF personal letter
//
// This module implements the text section of a USAF personal letter per
// AFH 33-337 "The Text of the Personal Letter".

#import "body.typ": *

/// Mainmatter show rule for personal letter body content.
///
/// AFH 33-337 "The Text of the Personal Letter" requirements:
/// - Begin text on the second line below the salutation
/// - Single-space the text; one blank line between paragraphs
/// - DO NOT number paragraphs
/// - Indent major paragraphs 0.5 inch; subparagraphs an additional 0.5 inch
///
/// - it (content): The body content to render
/// -> content
#let mainmatter(it) = {
  render-body(it)
}
