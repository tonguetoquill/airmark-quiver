// The personal letter's body: AFH 33-337 "For the body of the personal letter,
// the paragraphs are indented 0.5 inches from the left margin but they are not
// numbered."

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": render-letter-table

/// Splits content at the closing section: the part this styles as body
/// paragraphs, and the part that reaches the page untouched.
///
/// Applied as a show rule, `mainmatter` is handed the closing section along
/// with the body, and the body's first-line indent would then displace the
/// complimentary close and the signature lines. `backmatter` labels its output
/// to mark the boundary.
///
/// Everything from the marker on stays together, prose a caller wrote after the
/// closing included.
///
/// A marker is found on `it` itself, on a direct child, or inside the `styled`
/// element that a `set` or `show` rule after `#show: mainmatter` wraps the
/// remainder in; both halves come back under those styles. A marker a caller
/// nested in a container of their own — a `block`, a `grid` cell — is not
/// found. A closing section built in a code block or a loop is not nested:
/// joining content extends the sequence on the left in place, so its marker
/// stays a direct child.
///
/// - it (content): Content handed to `mainmatter`
/// -> array: the body content and the closing content
#let split-closing(it) = {
  if it.at("label", default: none) == <usaf-letter-closing> { return ([], it) }
  // `styled` is not a name in scope; its two fields identify it.
  if it.has("child") and it.has("styles") {
    let (body, closing) = split-closing(it.child)
    let restyle = part => (it.func())(part, it.styles)
    return (restyle(body), restyle(closing))
  }
  if not it.has("children") { return (it, []) }
  let children = it.children
  let boundary = children.position(child => child.at("label", default: none) == <usaf-letter-closing>)
  if boundary == none { return (it, []) }
  // `sum` over `join`: an empty half is `none` from a join and `[]` from this.
  (children.slice(0, boundary).sum(default: []), children.slice(boundary).sum(default: []))
}

/// Show rule for the personal letter's body.
///
/// - it (content): Body content
/// -> content
#let mainmatter(it) = {
  let (body, closing) = split-closing(it)
  context {
    // `par.leading` and `par.spacing` are both half an em, so a paragraph break
    // would otherwise land on the page as an ordinary line break. A blank line
    // is what separates one letter paragraph from the next.
    set par(
      first-line-indent: (amount: letter-paragraph.first-line-indent, all: true),
      spacing: spacing.line + line-stride(),
    )
    // The indent belongs to the letter's own paragraphs. Inside a list, a
    // quote, or a table cell, a line already sits where its container put it.
    show list: set par(first-line-indent: 0pt)
    show enum: set par(first-line-indent: 0pt)
    show table: it => {
      set par(first-line-indent: 0pt)
      render-letter-table(it)
    }
    // A block quote is the body's unindented block: the author's lines as
    // written, flush with the margin, which is what lets a letter carry a
    // roster of names or an address without the paragraph indent claiming its
    // first line.
    show quote.where(block: true): it => {
      set par(first-line-indent: 0pt)
      it.body
    }
    body
  }
  closing
}
