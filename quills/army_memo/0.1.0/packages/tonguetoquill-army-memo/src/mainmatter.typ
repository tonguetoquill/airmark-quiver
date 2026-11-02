// The memorandum body: AR 25-50 2-4b.

#import "body.typ": *

/// Splits content at the first closing section: the part `render-body` numbers,
/// and the part that reaches the page untouched.
///
/// `render-body` rebuilds what it is given from a buffer of paragraphs, tables
/// and block quotes, so a closing section passed through it would lose its
/// placement and take paragraph numbers. Applied as a show rule, `mainmatter`
/// is handed the closing along with the body; `backmatter` labels its output
/// to mark the boundary.
///
/// A marker is found on `it` itself, on a direct child, or inside the `styled`
/// element that a `set` or `show` rule after `#show: mainmatter` wraps the
/// remainder in; both halves come back under those styles. A marker nested in
/// a caller's own container is not found.
///
/// - it (content): Content handed to `mainmatter`
/// -> array: the body content and the closing content
#let split-closing(it) = {
  if it.at("label", default: none) == <army-memo-closing> { return ([], it) }
  // `styled` is not a name in scope; its two fields identify it.
  if it.has("child") and it.has("styles") {
    let (body, closing) = split-closing(it.child)
    let restyle = part => (it.func())(part, it.styles)
    return (restyle(body), restyle(closing))
  }
  if not it.has("children") { return (it, []) }
  let children = it.children
  let boundary = children.position(child => child.at("label", default: none) == <army-memo-closing>)
  if boundary == none { return (it, []) }
  (children.slice(0, boundary).sum(default: []), children.slice(boundary).sum(default: []))
}

/// The memorandum body, numbered per AR 25-50 2-4b, with the references as its
/// first paragraph.
///
/// - references (array): Citations, in the order the body cites them
/// - it (content): Body content
/// -> content
#let mainmatter(references: (), it) = {
  let (body, closing) = split-closing(it)
  render-body(body, references: references)
  closing
}
