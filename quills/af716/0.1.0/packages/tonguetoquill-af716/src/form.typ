// AF Form 716, 20260326, Enlisted Performance Brief, prescribed by DAFI 36-2406.
//
// The grade selects the title and the higher-level review block. E1–E6 prints a
// promotion recommendation, E7–E8 a stratification, and E9 a higher responsibility
// recommendation plus the future-role list. SSgt Select and TSgt Select keep the
// plain title and print none of those blocks: the form's grade script matches
// them before the E1–E6 branch.

#let font = "Liberation Sans"
#let rule = 0.7pt + black

#let e9-grades = ("CMSgt", "CMSgt Select")
#let e78-grades = ("SMSgt", "SMSgt Select", "MSgt", "MSgt Select")
#let select-grades = ("SSgt Select", "TSgt Select")
#let e16-grades = ("TSgt", "SSgt", "SrA", "A1C")

#let blank(v) = v == none or v == false or v == [] or v == ""

#let band(body) = block(width: 100%, stroke: rule, above: 0pt, below: -0.7pt, body)

#let labeled(title, body, min: 12pt) = pad(x: 3pt, y: 2.5pt)[
  #block(spacing: 0pt, text(size: 5.7pt, weight: "bold", tracking: 0.12pt)[#title])
  #v(3pt)
  #set text(size: 8pt)
  #body
  #v(min, weak: true)
]

// The performance boxes on the form are a fixed band. Long comments grow the
// band; short ones still hold the band open so the page reads as the form.
#let at-least(min, body) = layout(size => {
  let h = measure(width: size.width, body).height
  body
  if h < min { v(min - h) }
})

#let row(columns, cells) = band(grid(columns: columns, stroke: (x: rule), ..cells))

#let factor(title, hint, body, min: 52pt) = band(pad(x: 3pt, y: 3pt, at-least(min)[
  #let bare = hint == none or hint == []
  #if bare {
    text(size: 6.6pt, weight: "bold")[#title]
  } else {
    grid(
      columns: (1.9in, 1fr),
      column-gutter: 6pt,
      text(size: 6.6pt, weight: "bold")[#title],
      text(size: 6.3pt)[#hint],
    )
  }
  #v(4pt)
  #set text(size: 8pt)
  #body
]))

#let check(on) = box(
  width: 8pt,
  height: 8pt,
  stroke: 0.7pt,
  baseline: 1pt,
  align(center + horizon, if on { text(size: 6.5pt, weight: "bold")[X] }),
)

#let yes-no(value) = [
  #check(value == "YES") #text(size: 7pt, weight: "bold")[Yes]
  #h(8pt)
  #check(value == "NO") #text(size: 7pt, weight: "bold")[No]
]

#let person(name-label, name, duty-label, duty, org-label, org, type-label, sig-type, sig-label, sig) = {
  row((1.55fr, 1fr), (
    labeled(name-label, name, min: 12pt),
    labeled(duty-label, duty, min: 12pt),
  ))
  row((1.45fr, 0.7fr, 1.15fr), (
    labeled(org-label, org, min: 12pt),
    labeled(type-label, sig-type, min: 12pt),
    labeled(sig-label, sig, min: 12pt),
  ))
}

#let brief(f) = {
  let grade = f.grade
  let e9 = grade in e9-grades
  let e78 = grade in e78-grades
  let e16 = grade in e16-grades
  let title = if e9 {
    [Enlisted Performance Brief (E9)]
  } else if e78 {
    [Enlisted Performance Brief (E7–E8)]
  } else if e16 {
    [Enlisted Performance Brief (E1–E6)]
  } else {
    [ENLISTED PERFORMANCE BRIEF]
  }

  set page(
    paper: "us-letter",
    margin: (top: 0.46in, bottom: 0.72in, x: 0.32in),
    header: align(center, text(font: font, size: 8pt, weight: "bold")[CUI (when filled in)]),
    header-ascent: 35%,
    footer: context {
      set text(font: font, size: 6pt)
      grid(
        columns: (1.85in, 1fr, 2.3in),
        align: (left + top, center + horizon, right + top),
        [
          AF FORM 716, 20260326 \
          Prescribed By: DAFI36-2406
        ],
        text(size: 8pt, weight: "bold")[CUI (when filled in)],
        align(right, block(width: 2.2in)[
          PRIVACY ACT INFORMATION: The information in this form is CONTROLLED UNCLASSIFIED INFORMATION. Protect IAW the Privacy Act of 1974.
        ]),
      )
    },
    footer-descent: 25%,
  )
  set text(font: font, size: 8pt, hyphenate: false)
  set par(leading: 0.45em, spacing: 0.35em, justify: false)
  set block(spacing: 0pt)
  set list(indent: 0.5em, body-indent: 0.35em, spacing: 0.15em, marker: [–])

  align(center, text(size: 11pt, weight: "bold", title))
  v(3pt)
  align(center, text(size: 7pt, weight: "bold")[
    PLEASE READ THE PRIVACY ACT STATEMENT ON THE BACK BEFORE COMPLETING THE FORM.
  ])
  v(4pt)

  row((1.15in, 1fr, 1.35in), (
    labeled("GRADE", grade),
    labeled("NAME", f.name),
    labeled("DoDID#", f.dodid),
  ))
  row((1.35fr, 0.55fr, 0.85fr, 1.15fr, 0.55fr, 0.58fr), (
    labeled("DUTY TITLE", f.duty_title),
    labeled("DAFSC", f.dafsc),
    labeled("REASON", f.reason),
    labeled("PERIOD", [#f.period_from #h(4pt) THRU #h(4pt) #f.period_thru]),
    labeled("DAYS SUPERVISED", f.days_supervised),
    labeled("DAYS NON-RATED", f.days_non_rated),
  ))
  row((1.5fr, 0.7fr, 1.2fr), (
    labeled("RATEE ACKNOWLEDGMENT", f.ratee_acknowledgment),
    labeled("TYPE OF SIGNATURE", f.ratee_signature_type),
    labeled("RATEE SIGNATURE", f.ratee_signature),
  ))
  row((1.6fr, 1fr), (
    labeled("ORGANIZATION AND COMMAND", f.organization),
    labeled("LOCATION", f.location),
  ))
  factor("DUTY DESCRIPTION", [], f.duty_description, min: 36pt)
  band(pad(x: 3pt, y: 3pt)[
    #text(size: 6.6pt, weight: "bold")[REFERRAL REPORT]
    #h(10pt)
    #yes-no(f.referral)
  ])
  factor(
    "EXECUTING THE MISSION",
    [Effectively uses knowledge, initiative, and adaptability to produce timely, high quality/quantity results to positively impact the mission.],
    f.executing_mission,
  )
  factor(
    "LEADING PEOPLE",
    [Fosters cohesive teams, effectively communicates, and uses emotional intelligence to take care of people and accomplish the mission.],
    f.leading_people,
  )
  factor(
    "MANAGING RESOURCES",
    [Manages assigned resources effectively and takes responsibility for actions/behaviors to maximize organizational performance.],
    f.managing_resources,
  )
  factor(
    "IMPROVING THE UNIT",
    [Demonstrates critical thinking and fosters innovation to find creative solutions and improve mission execution.],
    f.improving_unit,
  )
  band(pad(x: 3pt, y: 3pt)[
    #grid(
      columns: (1fr, auto),
      align: horizon,
      text(size: 6.6pt, weight: "bold")[MANDATORY COMMENTS (FITNESS/HOUSING/VOTING)],
      yes-no(f.mandatory_comments_required),
    )
    #if f.mandatory_comments_required == "YES" {
      v(3pt)
      f.mandatory_comments
      v(16pt, weak: true)
    }
  ])
  factor(
    "MANDATORY FITNESS COMMENTS",
    [Enter appropriate fitness score, category, and exemptions IAW AFI 36-2406. Note: References to conduct as a fitness representative will NOT be included in this section.],
    f.mandatory_fitness_comments,
  )

  person(
    "RATER NAME, GRADE, BRANCH OF SERVICE",
    f.rater_name,
    "RATER DUTY TITLE",
    f.rater_duty_title,
    "RATER ORGANIZATION AND COMMAND",
    f.rater_organization,
    "TYPE OF SIGNATURE",
    f.rater_signature_type,
    "RATER SIGNATURE",
    f.rater_signature,
  )
  row((1fr, 1fr, 1fr), (
    labeled("FUTURE ROLES", f.future_role_1),
    labeled("FUTURE ROLES", f.future_role_2),
    labeled("FUTURE ROLES", f.future_role_3),
  ))
  if not blank(f.ccm_number) or not blank(f.ccm_assigned) {
    band(pad(x: 3pt, y: 2pt, text(size: 8pt)[#f.ccm_number of #f.ccm_assigned Assigned CMSgts]))
  }

  factor("HIGHER LEVEL REVIEWER ASSESSMENT", [], f.hlr_assessment, min: 40pt)
  {
    let mark = if e78 {
      labeled("STRATIFICATION", f.stratification)
    } else if e9 {
      labeled("HIGHER RESPONSIBILITY", f.higher_responsibility)
    } else if e16 {
      labeled("PROMOTION RECOMMENDATION", f.promotion_recommendation)
    } else {
      none
    }
    let concur = labeled("CONCUR", f.concur)
    let referral = labeled("REFERRAL REPORT", yes-no(f.hlr_referral))
    if mark == none {
      row((1fr, 1fr), (concur, referral))
    } else {
      row((1.5fr, 0.8fr, 1.1fr), (mark, concur, referral))
    }
  }
  person(
    "HIGHER LEVEL REVIEWER NAME, GRADE, BRANCH OF SERVICE",
    f.hlr_name,
    "HIGHER LEVEL REVIEWER DUTY TITLE",
    f.hlr_duty_title,
    "HIGHER LEVEL REVIEWER ORGANIZATION AND COMMAND",
    f.hlr_organization,
    "TYPE OF SIGNATURE",
    f.hlr_signature_type,
    "HIGHER LEVEL REVIEWER SIGNATURE",
    f.hlr_signature,
  )

  pagebreak()

  align(center, text(size: 11pt, weight: "bold", title))
  v(4pt)
  row((1.15in, 1fr, 1.35in), (
    labeled("GRADE", grade),
    labeled("NAME", f.name),
    labeled("DoDID#", f.dodid),
  ))
  v(6pt)

  if f.functional_examiner {
    text(size: 8pt, weight: "bold")[FUNCTIONAL EXAMINER]
    h(8pt)
    text(size: 8pt)[#f.fe_comments_kind]
    v(3pt)
    if f.fe_comments_kind == "Comments" {
      factor("COMMENTS", [], f.fe_comments)
    }
    person(
      "NAME, GRADE, BRANCH OF SERVICE",
      f.fe_name,
      "FUNCTIONAL EXAMINER DUTY TITLE",
      f.fe_duty_title,
      "FUNCTIONAL EXAMINER ORGANIZATION AND COMMAND",
      f.fe_organization,
      "TYPE OF SIGNATURE",
      f.fe_signature_type,
      "SIGNATURE",
      f.fe_signature,
    )
    v(8pt)
  }

  if f.air_force_advisor {
    text(size: 8pt, weight: "bold")[AIR FORCE ADVISOR]
    h(8pt)
    text(size: 8pt)[#f.afa_comments_kind]
    v(3pt)
    if f.afa_comments_kind == "Comments" {
      factor("COMMENTS", [], f.afa_comments)
    }
    person(
      "NAME, GRADE, BRANCH OF SERVICE",
      f.afa_name,
      "AIR FORCE ADVISOR DUTY TITLE",
      f.afa_duty_title,
      "AIR FORCE ADVISOR ORGANIZATION AND COMMAND",
      f.afa_organization,
      "TYPE OF SIGNATURE",
      f.afa_signature_type,
      "SIGNATURE",
      f.afa_signature,
    )
    v(8pt)
  }

  if f.referral == "YES" or f.hlr_referral == "YES" {
    band(pad(x: 4pt, y: 4pt)[
      #text(size: 7pt, weight: "bold")[
        I AM REFERRING THIS EVALUATION TO YOU ACCORDING TO AFI 36-2406, PARA 1.11.
        IT CONTAINS COMMENT(S) THAT MAKE(S) THE REPORT A REFERRAL AS DEFINED IN
        AFI 36-2406, PARA1.11.
      ]
      #v(4pt)
      #f.referral_comments
      #v(20pt, weak: true)
    ])
    person(
      "REFERRING EVALUATOR NAME, GRADE, BRANCH OF SERVICE",
      f.referring_evaluator_name,
      "REFERRING EVALUATOR DUTY TITLE",
      f.referring_evaluator_duty_title,
      "TYPE OF SIGNATURE",
      f.referring_evaluator_signature_type,
      "DATE",
      f.referring_evaluator_date,
      "REFERRING EVALUATOR SIGNATURE",
      f.referring_evaluator_signature,
    )
    row((0.7fr, 1.3fr, 0.8fr), (
      labeled("TYPE OF SIGNATURE", f.referral_ratee_signature_type),
      labeled("SIGNATURE OF RATEE", f.referral_ratee_signature),
      labeled("DATE", f.referral_ratee_date),
    ))
    v(8pt)
  }

  band(pad(x: 4pt, y: 4pt)[
    #align(center, text(size: 8pt, weight: "bold")[PRIVACY ACT STATEMENT])
    #v(3pt)
    #set par(leading: 0.55em, spacing: 0.4em)
    #text(size: 8pt)[
      *AUTHORITY:* Title 10 United States Code (U.S.C.) 9013, Secretary of the Air Force: AFI 36-2406, Officer and Enlisted Evaluations Systems.

      *PURPOSE:* Used to document effectiveness/duty performance history; promotion, school and assignment selection; reduction-in-force; control roster; reenlistment; separation; research and statistical analysis.

      *ROUTINE USES:* DoD Blanket Routine Uses Apply.

      *DISCLOSURE:* Voluntary. Not providing DoDID number may cause form to not be processed or to positively identify the person being evaluated.

      *SORN:* F036 AF PC A, Effectiveness/Performance Reporting Records
    ]
  ])
}
