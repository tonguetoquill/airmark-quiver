// The show-rule form with `set` and `show` rules written after `#show:
// mainmatter`. Those wrap the rest of the document in a `styled` element, which
// carries its content in `child` rather than `children` — the shape the split
// has to look through rather than past.

#import "closing_sections.typ": *

#show: addressing
#show: mainmatter
#set par(justify: false)
#show strong: it => it
#body-content
#closing()
#indorsements.join()
