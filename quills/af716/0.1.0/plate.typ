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

// AF Form 716 maxChars on the narrative boxes. A space counts.
#let counted(c) = {
  c == [ ] or c.func() == linebreak or c.func() == parbreak or c.func() == smartquote
}

#let char-count(c) = {
  if type(c) == str { return c.clusters().len() }
  if type(c) != content { return 0 }
  if counted(c) { return 1 }
  if c.has("text") and type(c.at("text")) == str { return c.text.clusters().len() }
  if c.has("children") { return c.children.map(char-count).sum(default: 0) }
  if c.has("body") { return char-count(c.body) }
  if c.has("child") { return char-count(c.child) }
  0
}

// Returns (kept content or none, characters still available).
#let take-chars(c, left) = {
  if left <= 0 { return (none, 0) }
  if type(c) == str {
    let clusters = c.clusters()
    if clusters.len() <= left { return (c, left - clusters.len()) }
    return (clusters.slice(0, left).join(), 0)
  }
  if type(c) != content { return (c, left) }
  if counted(c) { return (c, left - 1) }
  if c.has("text") and type(c.at("text")) == str {
    let clusters = c.text.clusters()
    if clusters.len() <= left { return (c, left - clusters.len()) }
    let kept = clusters.slice(0, left).join()
    let fields = c.fields()
    fields.remove("text")
    let out = if fields.len() == 0 { text(kept) } else { text(..fields, kept) }
    return (out, 0)
  }
  if c.has("children") {
    let kept = ()
    let rest = left
    for k in c.children {
      if rest <= 0 { break }
      let (piece, next) = take-chars(k, rest)
      rest = next
      if piece != none { kept.push(piece) }
    }
    if kept.len() == 0 { return (none, rest) }
    let out = if c.fields().keys() == ("children",) {
      kept.sum(default: [])
    } else {
      let fields = c.fields()
      fields.remove("children")
      c.func()(..fields, children: kept)
    }
    return (out, rest)
  }
  if c.has("body") {
    let (piece, rest) = take-chars(c.body, left)
    if piece == none { return (none, rest) }
    let fields = c.fields()
    fields.remove("body")
    let out = if fields.len() == 0 { c.func()(piece) } else { c.func()(..fields, piece) }
    return (out, rest)
  }
  if c.has("child") {
    let (piece, rest) = take-chars(c.child, left)
    if piece == none { return (none, rest) }
    let fields = c.fields()
    fields.remove("child")
    let out = if fields.len() == 0 { c.func()(piece) } else { c.func()(..fields, piece) }
    return (out, rest)
  }
  (c, left)
}

#let capped(body, limit) = {
  if type(body) != content { return body }
  if char-count(body) <= limit { return body }
  let (out, _) = take-chars(body, limit)
  if out == none { [] } else { out }
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
  duty_description: capped(ink("duty_description"), 450),
  referral: choice("referral_report"),
  executing_mission: capped(ink("executing_mission"), 350),
  leading_people: capped(ink("leading_people"), 350),
  managing_resources: capped(ink("managing_resources"), 350),
  improving_unit: capped(ink("improving_unit"), 350),
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
  hlr_assessment: capped(ink("hlr_assessment"), 250),
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
