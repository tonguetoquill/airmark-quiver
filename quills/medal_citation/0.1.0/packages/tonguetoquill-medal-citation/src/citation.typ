#import "config.typ": *
#import "primitives.typ": *

// One certificate. A medal supplies its image, its title, the lines between the
// title and the medal's name, the line that names the recipient, and the date
// line; everything else is shared.
//
// - f (dictionary): oak_leaf_cluster, rank, service, period_from, period_to,
//   accomplishments, commander_title.
// - given (array): the date line, one entry per printed line.
// - signer (array): the lines under the rule; a blank entry prints no line.
// - signing-field (function): (width, height) => the widget over the signing space.
#let citation(
  f,
  image-file: none,
  title: none,
  preamble: (),
  medal-name: none,
  awarded: none,
  given: (),
  signer: (),
  signing-field: none,
) = {
  set page(paper: "us-letter", margin: 0pt)
  set text(font: font, size: size.line, fill: black, hyphenate: false)
  set par(leading: 0.35em, spacing: 0pt)

  let signer = signer.filter(l => not blank(l))
  closing-block(given, signer, signing-field: signing-field)

  v(medal-image.top)
  align(center, image(image-file, height: medal-image.height))
  v(20pt)
  heading-line(title, size: size.title, bold: true)
  v(24pt)
  for l in preamble {
    l
    v(7pt)
  }
  heading-line(medal-name, size: size.medal, bold: true)
  block(width: 100%, height: 32pt, align(horizon, cluster-line(f.oak_leaf_cluster)))
  heading-line(awarded, bold: true)
  v(10pt)
  heading-line(upper(f.rank), size: size.small)
  v(9pt)
  heading-line(bold: true)[FOR]
  v(10pt)
  heading-line(upper(f.service))
  v(9pt)
  heading-line(size: size.small)[#f.period_from #h(8pt) TO #h(8pt) #f.period_to]
  v(20pt)
  heading-line(bold: true)[ACCOMPLISHMENTS]
  v(18pt)

  accomplishments-block(f.accomplishments, given-top(signer.len(), given.len()) - 8pt)
}
