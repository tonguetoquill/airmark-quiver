~~~card-yaml
$quill: usaf_memo@0.3
$kind: main
letterhead_title:
  - DEPARTMENT OF THE AIR FORCE
  - YOUR SQUADRON HERE
memo_for:
  - ORG/SYMBOL
memo_from:
  - YOUR ORG/CC
subject: Appointment of Primary and Alternate Program Managers
references:
  - "DAFI XX-XXXX, DD Month YYYY, *Title of the Governing Publication*"
signature_block:
  - FIRST M. LAST, Lt Col, USAF
  - Commander
cc:
  - YOUR ORG/CSS
$ext:
  editor:
    tips:
      - Address the letter to the program office (the FAC, Wing IP, LRS, etc.); it files the letter.
      - Each appointee is a table row. Press Enter in the last row to add one.
      - Point just left of a row and click the grip that appears. Backspace deletes the row; Alt+Up or Alt+Down moves it. Columns work the same from the grip above them.
      - Names, duty phones, and e-mail are PII. If you list DEROS, clearances, or non-duty contact details, set Classification to CUI and fill the CUI block.
~~~

<!--------------
In the data above, edit:
  - Memorandum For (the program office that files the letter)
  - Memorandum From (your unit commander's office symbol)
  - Subject (name the program and the roles)
  - References (the publication that requires the appointment)
  - Signature block (program publications normally require the unit commander)
---------------->

In accordance with reference (a), the following individuals are appointed as the [UNIT NAME] Primary and Alternate [PROGRAM] Managers:

| Role | Rank | Name | Office Symbol | Duty Phone | Email |
|---|---|---|---|---|---|
| Primary | TSgt | First M. Last | ORG/SYMBOL | 555-1234 | first.last@us.af.mil |
| Alternate | SSgt | First M. Last | ORG/SYMBOL | 555-5678 | first.last@us.af.mil |

<!--------------
Below the table, state the duties, training, and replacement rules the
governing publication sets. Common lines: training within N days of this
letter; notify the program office 60 days before PCS, PCA, or separation;
the alternate performs the duties in the primary's absence.
---------------->

Appointees will complete [PROGRAM] training within 30 days of this letter and will notify [PROGRAM OFFICE] 60 days prior to PCS, PCA, or separation. Appointees will:

- Maintain the unit program continuity folder.
- Brief unit leadership on program status at the monthly staff meeting.

Point of contact for this action is [Rank First M. Last], [ORG/SYMBOL], [DSN 555-1234] or [first.last@us.af.mil].

This letter supersedes all previous letters, same subject.
