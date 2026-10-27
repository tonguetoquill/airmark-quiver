#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/tonguetoquill-usace-report-appendix:0.0.1": appendix

#let dist = qm.data.cui_distribution
#let dist-display = if dist.value == "Other" { dist.detail } else { dist.value }

#appendix(
  letter: qm.data.appendix_letter,
  title: qm.data.appendix_title,
  project-name: qm.data.project_name,
  cui-enabled: qm.data.cui_enabled,
  cui-controlled-by-component: qm.data.cui_controlled_by_component,
  cui-controlled-by-office: qm.data.cui_controlled_by_office,
  cui-categories: qm.data.cui_categories,
  cui-distribution: dist-display,
  cui-poc: qm.data.cui_poc,
  body: {
    let b = qm.data.at("$body")
    if type(b) == str { [] } else { b }
  },
)
