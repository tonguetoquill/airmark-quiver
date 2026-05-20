// mainmatter.typ: Body content show rule for personal letter

#import "body.typ": render-body

/// Applies personal letter body formatting to the main content.
///
/// AFH 33-337 Ch. 15: top-level paragraphs are unnumbered with 0.5in
/// first-line indent; sub-paragraphs follow the official memorandum's
/// numbering and indentation rules.
///
/// - it (content): The body content to render
/// -> content
#let mainmatter(it) = {
  render-body(it)
}
