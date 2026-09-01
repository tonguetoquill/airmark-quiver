// `#show: mainmatter`: the rest of the document reaches the show rule, closing
// sections included, and `split-closing` is what keeps them out of the rebuild
// pass. The form `lib.typ` documents.

#import "closing_sections.typ": *

#show: addressing
#show: mainmatter
#body-content
#closing()
#indorsements.join()
