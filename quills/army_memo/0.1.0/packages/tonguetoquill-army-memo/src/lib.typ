// A U.S. Army memorandum per AR 25-50, "Preparing and Managing
// Correspondence".
//
// #import "@local/tonguetoquill-army-memo:0.1.0": backmatter, frontmatter, mainmatter
//
// #show: frontmatter.with(
//   office-symbol: "AFZC-SC",
//   memo-for: ("Commander, 1st Armored Division",),
//   subject: "Your Subject Here",
// )
// #mainmatter[Body paragraphs.]
// #backmatter(signature-block: ("JOHN A. SMITH", "LTC, SC", "Commanding"))

#import "frontmatter.typ": frontmatter
#import "mainmatter.typ": mainmatter
#import "backmatter.typ": backmatter
#import "utils.typ": date-pattern
