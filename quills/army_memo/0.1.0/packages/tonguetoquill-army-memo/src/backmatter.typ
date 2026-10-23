// The memorandum's closing: AR 25-50 2-4c.

#import "primitives.typ": *

#let backmatter(
  signature-block: (),
  // "FOR THE COMMANDER", or "FOR THE" another head, where the signer acts for
  // them. Blank is no line.
  authority-line: none,
  signature-blank-lines: 4,
  signing-field: none,
  enclosures: (),
  distribution: (),
  cf: (),
  cf-without-enclosures: false,
) = [#{
  let distribution = listing-entries(distribution)
  let cf = listing-entries(cf)
  let lists = render-distribution-and-copies(
    distribution: distribution,
    cf: cf,
    cf-without-enclosures: cf-without-enclosures,
    has-enclosures: ensure-array(enclosures).any(e => not blank(e)),
  )
  render-closing(
    signature-block,
    authority-line: authority-line,
    signature-blank-lines: signature-blank-lines,
    signing-field: signing-field,
    enclosures: enclosures,
    tail: lists.head,
  )
  // The page the body's last lines are kept on needs the closing's extent
  // below the last body line.
  context {
    let line = LINE.to-absolute()
    let width = page.width - 2 * MARGIN
    let rows = calc.max(
      line-count(render-signature-lines(signature-block), width - SIGNATURE_INDENT),
      line-count(render-enclosures(enclosures), ENCLOSURE_WIDTH),
      1,
    )
    let authority = format-authority-line(authority-line)
    let lead = if authority == none { 0 } else { 1 + line-count(par(authority), width) }
    let head = listing-head-lines(distribution, cf, width)
    [#metadata((lead + signature-blank-lines + rows + head) * line)<army-memo-closing-need>]
  }
  lists.rest
}<army-memo-closing>]
