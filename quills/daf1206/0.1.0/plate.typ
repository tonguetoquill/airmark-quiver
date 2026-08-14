#import "@local/quillmark-helper:0.1.0": data
#import "@local/typst-daf1206:0.1.0": form

#set text(font: "NimbusRomNo9L")

// Map snake_case Quill `data` keys to generated `form.typ` parameter names.
#let vals = (:)

#if data.award != "" { vals.insert("AWARD", data.award) }
#if data.category_if_applicable != "" { vals.insert("CATEGORY_If_Applicable", data.category_if_applicable) }
#if data.award_period != "" { vals.insert("AWARD_PERIOD", data.award_period) }
#if data.rankname_of_nominee != "" {
  vals.insert("RANKNAME_OF_NOMINEE_First_Middle_Initial_Last", data.rankname_of_nominee)
  vals.insert("RANKNAME_OF_NOMINEE_First_Middle_Initial_Last_2", data.rankname_of_nominee)
}
#if data.majcom_fldcom_foa_or_dru != "" { vals.insert("MAJCOM_FLDCOM_FOA_OR_DRU", data.majcom_fldcom_foa_or_dru) }
#if data.dafsc_duty_title != "" { vals.insert("DAFSCDUTY_TITLE", data.dafsc_duty_title) }
#if data.nominees_telephone_dsn_commercial != "" {
  vals.insert("NOMINEES_TELEPHONE__DSN__Commercial", data.nominees_telephone_dsn_commercial)
}
#if data.unit_office_symbol_street_address_base_state_zip != "" {
  vals.insert(
    "UNITOFFICE_SYMBOLSTREET_ADDRESSBASESTATEZIP_CODE",
    data.unit_office_symbol_street_address_base_state_zip,
  )
}
#if data.unit_commander_rank_name_and_telephone != "" {
  vals.insert(
    "RANKNAME_OF_UNIT_COMMANDER_First_Middle_Initial_LastCOMMANDERS_TELEPHONE_DSN__Commercial",
    data.unit_commander_rank_name_and_telephone,
  )
}
#if "$body" in data {
  vals.insert(
    "SPECIFIC_ACCOMPLISHMENTS_Use_Performance_Statements_IAW_DAFMAN_362806",
    data.at("$body"),
  )
}

#let continued-key = "SPECIFIC_ACCOMPLISHMENTS_Use_Performance_Statements_IAW_DAFMAN_362806_Continued"
#for card in data.at("$cards") {
  if card.at("$kind", default: none) == "accomplishments_continued" and continued-key not in vals and "$body" in card {
    vals.insert(continued-key, card.at("$body"))
  }
}

#form(..vals)
