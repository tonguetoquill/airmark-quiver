// One memorandum page with the tag line in the footer, through the package's
// own `frontmatter`, so the candidate sits at its real size and position.
//
//   --input font=<family>  --input caps=<mode>  --input italic=true|false
//   --input slant=true|false

#import "../../../quills/usaf_memo/0.3.0/packages/tonguetoquill-usaf-memo/src/lib.typ": (
  backmatter, frontmatter, mainmatter,
)
#import "candidates.typ": tag-line

#let font = sys.inputs.at("font", default: "NimbusRomNo9L")
#let caps = sys.inputs.at("caps", default: "none")
#let italic = sys.inputs.at("italic", default: "false") == "true"
#let slant = sys.inputs.at("slant", default: "false") == "true"

#show: frontmatter.with(
  letterhead-title: "DEPARTMENT OF THE AIR FORCE",
  letterhead-caption: ("123D TEST SQUADRON (AETC)",),
  letterhead-seal: image("../../../quills/usaf_memo/0.3.0/assets/dow_seal.png"),
  memo-for: ("ALL PERSONNEL",),
  memo-from: ("123 TS/CC",),
  subject: "Tag Line Typeface",
  date: "1 September 2026",
  footer-tag-line: tag-line(font, "Aim High", italic: italic, caps: caps, slant: slant),
)

#mainmatter[
  The first paragraph of the memorandum, set in the body face so the tag line
  can be read against it.
]

#backmatter(signature-block: ("FIRST M. LAST, Rank, USAF", "Duty Title"))
