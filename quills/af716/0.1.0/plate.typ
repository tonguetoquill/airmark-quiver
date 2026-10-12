#import "@local/quillmark-helper:0.1.0": data, display
#import "@local/tonguetoquill-af716:0.1.0": brief

#let trim(v) = {
  if type(v) != content { return v }
  let kids = v.at("children", default: none)
  if kids == none { return v }
  let padding(c) = c == [ ] or c.func() == parbreak
  while kids.len() > 0 and padding(kids.first()) { kids = kids.slice(1) }
  while kids.len() > 0 and padding(kids.last()) { kids = kids.slice(0, -1) }
  kids.sum(default: [])
}

#let ink(key) = {
  let v = trim(data.at(key))
  if v == none or v == "" or v == [] { [] } else { v }
}

#let choice(key) = {
  let field = data.at(key)
  let value = if type(field) == str { field } else { field.value }
  if value == none { "" } else { value }
}

// Period dates follow the form's `D MMM YYYY`. Signature dates follow `DD MMM YYYY`.
#let period-pattern = "[day padding:none] [month repr:short] [year]"
#let signed-pattern = "[day padding:zero] [month repr:short] [year]"
#let shown-date(key, pattern) = {
  let shown = display(key, pattern)
  if shown == none { [] } else { shown }
}

#brief((
  grade: choice("grade"),
  name: ink("name"),
  dodid: ink("dodid"),
  duty_title: ink("duty_title"),
  dafsc: ink("dafsc"),
  reason: choice("reason"),
  period_from: shown-date("period_from", period-pattern),
  period_thru: shown-date("period_thru", period-pattern),
  days_supervised: ink("days_supervised"),
  days_non_rated: ink("days_non_rated"),
  ratee_acknowledgment: choice("ratee_acknowledgment"),
  ratee_signature_type: choice("ratee_signature_type"),
  ratee_signature: ink("ratee_signature"),
  organization: ink("organization"),
  location: ink("location"),
  duty_description: ink("duty_description"),
  referral: choice("referral_report"),
  executing_mission: ink("executing_mission"),
  leading_people: ink("leading_people"),
  managing_resources: ink("managing_resources"),
  improving_unit: ink("improving_unit"),
  mandatory_comments_required: choice("mandatory_comments_required"),
  mandatory_comments: ink("mandatory_comments"),
  mandatory_fitness_comments: ink("mandatory_fitness_comments"),
  rater_name: ink("rater_name"),
  rater_duty_title: ink("rater_duty_title"),
  rater_organization: ink("rater_organization"),
  rater_signature_type: choice("rater_signature_type"),
  rater_signature: ink("rater_signature"),
  future_role_1: ink("future_role_1"),
  future_role_2: ink("future_role_2"),
  future_role_3: ink("future_role_3"),
  ccm_number: ink("ccm_number"),
  ccm_assigned: ink("ccm_assigned"),
  hlr_assessment: ink("hlr_assessment"),
  stratification: ink("stratification"),
  higher_responsibility: choice("higher_responsibility"),
  promotion_recommendation: choice("promotion_recommendation"),
  concur: choice("concur"),
  hlr_referral: choice("hlr_referral"),
  hlr_name: ink("hlr_name"),
  hlr_duty_title: ink("hlr_duty_title"),
  hlr_organization: ink("hlr_organization"),
  hlr_signature_type: choice("hlr_signature_type"),
  hlr_signature: ink("hlr_signature"),
  functional_examiner: data.functional_examiner,
  fe_comments_kind: choice("fe_comments_kind"),
  fe_comments: ink("fe_comments"),
  fe_name: ink("fe_name"),
  fe_duty_title: ink("fe_duty_title"),
  fe_organization: ink("fe_organization"),
  fe_signature_type: choice("fe_signature_type"),
  fe_signature: ink("fe_signature"),
  air_force_advisor: data.air_force_advisor,
  afa_comments_kind: choice("afa_comments_kind"),
  afa_comments: ink("afa_comments"),
  afa_name: ink("afa_name"),
  afa_duty_title: ink("afa_duty_title"),
  afa_organization: ink("afa_organization"),
  afa_signature_type: choice("afa_signature_type"),
  afa_signature: ink("afa_signature"),
  referral_comments: ink("referral_comments"),
  referring_evaluator_name: ink("referring_evaluator_name"),
  referring_evaluator_duty_title: ink("referring_evaluator_duty_title"),
  referring_evaluator_signature_type: choice("referring_evaluator_signature_type"),
  referring_evaluator_date: shown-date("referring_evaluator_date", signed-pattern),
  referring_evaluator_signature: ink("referring_evaluator_signature"),
  referral_ratee_signature_type: choice("referral_ratee_signature_type"),
  referral_ratee_signature: ink("referral_ratee_signature"),
  referral_ratee_date: shown-date("referral_ratee_date", signed-pattern),
))
