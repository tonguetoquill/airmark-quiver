// A memorandum with no body, so the closing section is the whole of what
// `mainmatter` receives rather than one child among several. The file ends
// without a trailing newline, which is what leaves no sequence around it.

#import "closing_sections.typ": *

#show: addressing
#show: mainmatter
#closing()