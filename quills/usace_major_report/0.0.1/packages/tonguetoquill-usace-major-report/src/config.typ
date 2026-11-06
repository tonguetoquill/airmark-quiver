// Geometry and type of a USACE Portland District ENC report on US Letter,
// matching Template-MMR-ENC_MajorMaintenanceReport_20250828,
// Template-MRR-ENC_MajorRehabilitationReport_20250917,
// Template-EDR-ENC_EngineeringDocumentationReport_20250930,
// Template-DDR-ENC_DesignDocumentationReport_20250701,
// Template-Study-EC_FeasibilityStudy_20250923 and
// Template-Phase1a-ENC_Phase1aReport_20251022.

#let MARGIN = 1in
#let BANNER_FROM_EDGE = 0.5in

#let BODY_SIZE = 12pt
#let HEADING_1_SIZE = 14pt
#let TITLE_PROJECT_SIZE = 20pt
#let TITLE_STAGE_SIZE = 16pt
#let PHASE_1A_LOCATION_SIZE = 14pt
#let PHASE_1A_AGENCY_SIZE = 18pt
#let SMALL_SIZE = 10pt
#let TABLE_SIZE = 10pt

#let DEFAULT_BODY_FONTS = ("Liberation Sans",)
#let DEFAULT_MONO_FONTS = ("Liberation Mono",)

// Word's single-spaced Arial line: the 0.905 em win ascent plus a 0.033 em
// line gap above the baseline, the 0.212 em win descent below it.
#let LINE_TOP = 0.938em
#let LINE_BOTTOM = -0.212em
#let LEADING = 0.35em
#let PAR_SPACING = 12pt

#let FIGURE_WIDTH = 6.5in

// Word list numId 1: 1) a) i) (1) (a) (i)
#let ENUM_FORMATS = ("1)", "a)", "i)", "(1)", "(a)", "(i)")
#let LIST_MARKERS = ([•], [o])

#let TABLE_STROKE = 0.5pt + black
#let TABLE_HEADER_FILL = rgb("#d9d9d9")

#let REPORT_ABBREVIATIONS = (
  "Major Maintenance Report": "MMR",
  "Major Rehabilitation Report": "MRR",
  "Engineering Documentation Report": "EDR",
  "Design Documentation Report": "DDR",
  "Feasibility Study": "Feasibility Study",
  "Phase 1A Report": "Phase 1A",
)

