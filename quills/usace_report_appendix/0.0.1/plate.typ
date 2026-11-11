#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/tonguetoquill-usace-report-appendix:0.0.1": appendix, statement-date-pattern

#let dist = qm.data.cui.distribution
#let dist-display = if dist.value == "Other" { dist.detail } else { dist.value }

#appendix(
  appendix-type: qm.data.appendix.appendix_type,
  letter: qm.data.appendix.appendix_letter,
  title: qm.data.appendix.appendix_title,
  project-name: qm.data.appendix.project_name,
  marking: qm.data.cui.marking,
  cui-controlled-by-component: qm.data.cui.controlled_by_component,
  cui-controlled-by-office: qm.data.cui.controlled_by_office,
  cui-categories: qm.data.cui.categories,
  cui-distribution: dist-display,
  cui-distribution-reason: qm.data.cui.distribution_reason,
  cui-distribution-date: qm.ink(qm.data.cui, "distribution_date", statement-date-pattern),
  cui-distribution-office: qm.data.cui.distribution_office,
  cui-poc: qm.data.cui.poc,
  executive-summary: qm.data.appendix.executive_summary,
  body: {
    let b = qm.data.at("$body")
    if type(b) == str { [] } else { b }
  },
)
