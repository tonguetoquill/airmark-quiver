// mainmatter.typ — body show rule for the personal letter

#import "body.typ": render-body

/// Applies Ch. 15 body formatting:
/// unnumbered top-level paragraphs (0.5 in first-line indent) and memo-style
/// sub-paragraph numbering (a., (1), (a) …) indented from 0.5 in.
#let mainmatter(it) = {
  render-body(it)
}
