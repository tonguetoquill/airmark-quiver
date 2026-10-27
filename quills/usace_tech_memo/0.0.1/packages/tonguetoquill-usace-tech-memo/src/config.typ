// Geometry and type of a USACE ENC technical memorandum on US Letter,
// matching Template-Memo-ENC_TechnicalMemorandum_20230206.

#let MARGIN = 1in
#let COVER_MARGIN = (x: 0.85in, top: 0.5in, bottom: 0.4in)
#let SF901_PURPLE = rgb(80, 46, 133)
#let BANNER_FROM_EDGE = 0.5in
#let PAGE_NUMBER_FROM_EDGE = 0.72in

#let BODY_SIZE = 12pt
#let HEADING_1_SIZE = 14pt
#let TITLE_STUDY_SIZE = 20pt
#let TITLE_KIND_SIZE = 18pt
#let TITLE_SUBJECT_SIZE = 16pt
#let TITLE_LINE_SIZE = 14pt
#let SMALL_SIZE = 10pt
#let TABLE_SIZE = 10pt

#let DEFAULT_BODY_FONTS = ("Liberation Sans",)
#let DEFAULT_MONO_FONTS = ("Liberation Mono",)

#let LEADING = 0.35em
#let PAR_SPACING = 12pt

#let FIGURE_WIDTH = 6.5in

// Word list numId 1: 1) a) i) (1) (a) (i)
#let ENUM_FORMATS = ("1)", "a)", "i)", "(1)", "(a)", "(i)")
#let LIST_MARKERS = ([•], [o])

#let TABLE_STROKE = 0.5pt + black

#let DISTRIBUTION_STATEMENTS = (
  "Distribution Statement A": "DISTRIBUTION STATEMENT A. Approved for public release; distribution is unlimited.",
  "Distribution Statement B": "DISTRIBUTION STATEMENT B. Distribution authorized to U.S. Government agencies only.",
  "Distribution Statement C": "DISTRIBUTION STATEMENT C. Distribution authorized to U.S. Government agencies and their contractors.",
  "Distribution Statement D": "DISTRIBUTION STATEMENT D. Distribution authorized to the Department of Defense and U.S. DoD contractors only.",
  "Distribution Statement E": "DISTRIBUTION STATEMENT E. Distribution authorized to DoD Components only.",
  "Distribution Statement F": "DISTRIBUTION STATEMENT F. Further dissemination only as directed by the controlling office or higher DoD authority.",
)

#let SF901_ATTENTION = [
  All individuals handling this information are required to protect it from unauthorized disclosure.

  Handling, storage, reproduction, and disposition of the attached document(s) must be in accordance with 32 CFR Part 2002 and applicable agency policy.

  Access to and dissemination of Controlled Unclassified Information shall be allowed as necessary and permissible to any individual(s), organization(s), or grouping(s) of users, provided such access or dissemination is consistent with or in furtherance of a Lawful Government Purpose and in a manner consistent with applicable law, regulations, and Government-wide policies.
]

#let SF901_FOOTER = [
  Standard Form 901 (11-18)\
  Prescribed by GSA/ISOO | 32 CFR 2002
]
