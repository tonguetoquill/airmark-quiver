// The personal letter's body: AFH 33-337 "For the body of the personal letter,
// the paragraphs are indented 0.5 inches from the left margin but they are not
// numbered."

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": render-memo-table

// AFH 33-337: a personal letter's paragraphs are indented half an inch from the
// left margin and carry no number or letter.
#let paragraph-indent = 0.5in

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

// The body's blocks in order — its own paragraphs, and each list, table and
// block quote whole — so the last can be found; and how deep in one of those
// containers the current paragraph sits.
#let BLOCKS = counter("usaf-letter-blocks")
#let NESTED = state("usaf-letter-nested", 0)

/// Whether a body's last block holds the signature to its page: a sticky block
/// relocates whole rather than splitting, so one taller than a third of the
/// text height is left to the break, which leaves its own tail above the
/// signature.
///
/// - it (content): The last block
/// -> bool
#let keeps-signature(it) = {
  let budget = (page.height - spacing.margin * 2) / 3
  measure(it, width: page.width - spacing.margin * 2).height <= budget
}

/// Counts a container as one block of the body and the paragraphs inside it
/// as none, and sets it a blank line off the paragraphs around it.
///
/// - it (content): The container
/// -> content
#let container(it) = context {
  if NESTED.get() > 0 { return it }
  BLOCKS.step()
  NESTED.update(n => n + 1)
  context {
    let last = BLOCKS.get() == BLOCKS.final()
    block(above: par.spacing, sticky: last and keeps-signature(it), it)
  }
  NESTED.update(n => n - 1)
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
      first-line-indent: (amount: paragraph-indent, all: true),
      spacing: spacing.line + line-stride(),
    )
    // The indent belongs to the letter's own paragraphs. Inside a list, a
    // quote, or a table cell, a line already sits where its container put it.
    show list: it => {
      set par(first-line-indent: 0pt)
      container(it)
    }
    show enum: it => {
      set par(first-line-indent: 0pt)
      container(it)
    }
    show table: it => {
      set par(first-line-indent: 0pt)
      container(render-memo-table(it))
    }
    // A block quote is the body's unindented block: the author's lines as
    // written, flush with the margin, which is what lets a letter carry a
    // roster of names or an address without the paragraph indent claiming its
    // first line.
    show quote.where(block: true): it => {
      set par(first-line-indent: 0pt)
      container(it.body)
    }
    show raw.where(block: true): container
    // AFH 33-337: "Do not place the signature element on a continuation page
    // by itself." The signature block has no keep-with-previous of its own —
    // Typst has no such property — so the anchor comes from this side: the
    // body's last block, a paragraph or a container, is set sticky, carried
    // onto the next page along with the signature instead of breaking away
    // from it.
    show par: p => context {
      if NESTED.get() > 0 { return p }
      BLOCKS.step()
      context {
        if BLOCKS.get() != BLOCKS.final() { return p }
        // `above` stands in for the paragraph spacing a bare paragraph would
        // have taken from the one before it.
        block(sticky: keeps-signature(p), above: par.spacing, p)
      }
    }
    body
  }
  closing
}
