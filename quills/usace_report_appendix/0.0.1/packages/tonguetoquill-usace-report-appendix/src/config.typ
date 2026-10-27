// Geometry and type of a USACE report appendix on US Letter, matching
// Template-Appendix-ENC_StandardizedReportAppendix_20230206.

#let MARGIN = 1in
#let COVER_MARGIN = (x: 0.85in, top: 0.5in, bottom: 0.4in)
#let SF901_PURPLE = rgb(80, 46, 133)
#let HEADER_FROM_EDGE = 0.5in
#let FOOTER_FROM_EDGE = 0.5in

#let BODY_SIZE = 12pt
#let HEADING_1_SIZE = 14pt
#let SMALL_SIZE = 10pt
#let TABLE_SIZE = 10pt

#let DEFAULT_BODY_FONTS = ("Liberation Sans",)
#let DEFAULT_MONO_FONTS = ("Liberation Mono",)

// Word's single-spaced Arial line: the 0.905 em win ascent plus a 0.033 em
// line gap above the baseline, the 0.212 em win descent below it.
#let LINE_TOP = 0.938em
#let LINE_BOTTOM = -0.212em
#let LEADING = 0pt
#let PAR_SPACING = 12pt

// Heading 2 to 4 tab stops: the title starts this far from the margin.
#let HEADING_TABS = (0.5in, 0.625in, 0.75in)
// TOC 2 and 3: number indent and the tab the title starts at.
#let TOC_INDENT = 0.25in
#let TOC_TABS = (0.6875in, 0.875in)

// Word list numId 1: 1) a) i) (1) (a) (i)
#let ENUM_FORMATS = ("1)", "a)", "i)", "(1)", "(a)", "(i)")
#let LIST_MARKERS = ([•], [o])
// Word's list tab: each marker or number sits in a box this wide.
#let LIST_TAB = 0.25in
#let BULLET_INDENT = 0.125in

#let TABLE_STROKE = 0.5pt + black
#let TABLE_HEADER_FILL = rgb("#d9d9d9")

#let SF901_ATTENTION = [
  All individuals handling this information are required to protect it from unauthorized disclosure.

  Handling, storage, reproduction, and disposition of the attached document(s) must be in accordance with 32 CFR Part 2002 and applicable agency policy.

  Access to and dissemination of Controlled Unclassified Information shall be allowed as necessary and permissible to any individual(s), organization(s), or grouping(s) of users, provided such access or dissemination is consistent with or in furtherance of a Lawful Government Purpose and in a manner consistent with applicable law, regulations, and Government-wide policies.
]

#let SF901_FOOTER = [
  Standard Form 901 (11-18)\
  Prescribed by GSA/ISOO | 32 CFR 2002
]
