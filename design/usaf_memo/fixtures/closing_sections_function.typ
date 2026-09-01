// `#mainmatter[…]`: the body reaches the rebuild pass, the closing sections
// never enter it. What the plates in `quills/` compile.

#import "closing_sections.typ": *

#show: addressing
#mainmatter(body-content)
#closing()
#indorsements.join()
