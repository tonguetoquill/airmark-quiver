#import "@local/quillmark-helper:0.2.0" as qm
#import "@local/typst-daf1206:0.1.0": form

#set text(font: "TeX Gyre Termes")

// Map snake_case Quill `data` keys to generated `form.typ` parameter names. The
// form's cells take a `str`, so each text field is read through `qm.str`.
#let vals = (:)

#if qm.data.award != "" { vals.insert("AWARD", qm.str(qm.data.award)) }
#if qm.data.category_if_applicable != "" { vals.insert("CATEGORY_If_Applicable", qm.str(qm.data.category_if_applicable)) }
#if qm.data.award_period != "" { vals.insert("AWARD_PERIOD", qm.str(qm.data.award_period)) }
#if qm.data.rankname_of_nominee != "" {
  vals.insert("RANKNAME_OF_NOMINEE_First_Middle_Initial_Last", qm.str(qm.data.rankname_of_nominee))
  vals.insert("RANKNAME_OF_NOMINEE_First_Middle_Initial_Last_2", qm.str(qm.data.rankname_of_nominee))
}
#if qm.data.majcom_fldcom_foa_or_dru != "" { vals.insert("MAJCOM_FLDCOM_FOA_OR_DRU", qm.str(qm.data.majcom_fldcom_foa_or_dru)) }
#if qm.data.dafsc_duty_title != "" { vals.insert("DAFSCDUTY_TITLE", qm.str(qm.data.dafsc_duty_title)) }
#if qm.data.nominees_telephone_dsn_commercial != "" {
  vals.insert("NOMINEES_TELEPHONE__DSN__Commercial", qm.str(qm.data.nominees_telephone_dsn_commercial))
}
#if qm.data.unit_office_symbol_street_address_base_state_zip != "" {
  vals.insert(
    "UNITOFFICE_SYMBOLSTREET_ADDRESSBASESTATEZIP_CODE",
    qm.str(qm.data.unit_office_symbol_street_address_base_state_zip),
  )
}
#if qm.data.unit_commander_rank_name_and_telephone != "" {
  vals.insert(
    "RANKNAME_OF_UNIT_COMMANDER_First_Middle_Initial_LastCOMMANDERS_TELEPHONE_DSN__Commercial",
    qm.str(qm.data.unit_commander_rank_name_and_telephone),
  )
}
#if "$body" in qm.data {
  vals.insert(
    "SPECIFIC_ACCOMPLISHMENTS_Use_Performance_Statements_IAW_DAFMAN_362806",
    qm.data.at("$body"),
  )
}

#let continued-key = "SPECIFIC_ACCOMPLISHMENTS_Use_Performance_Statements_IAW_DAFMAN_362806_Continued"
#for card in qm.data.at("$cards") {
  if card.at("$kind", default: none) == "accomplishments_continued" and continued-key not in vals and "$body" in card {
    vals.insert(continued-key, card.at("$body"))
  }
}

#form(..vals)
