// `#show: mainmatter` with the closing sections emitted from a code block
// rather than written as markup children of the document. `split-closing`
// reads direct children, so this is the shape that says whether a caller
// building the closing in a loop — as a template over a list of indorsements
// does — still lands on the right side of the split.

#import "closing_sections.typ": *

#show: addressing
#show: mainmatter
#body-content
#{
  closing()
  for card in indorsements { card }
}
