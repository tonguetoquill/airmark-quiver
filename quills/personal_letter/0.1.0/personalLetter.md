---
# U.S. Air Force Personal Letter (AFH 33-337, Chapter 15)
QUILL: personal_letter@0.1.0  # sentinel; required, verbatim
# Sender's rank, full name, duty title, organization, and complete mailing address. Placed flush left on the second line below the date. Use USPS abbreviations; no punctuation in the last line except the ZIP+4 dash.
# e.g. [Chief Master Sergeant David L. Jones, Duty Title, Organization, Street Address, City ST 12345-6789]
return_address: []  # array<string>; required
# Recipient's title or rank, full name, and complete mailing address. Placed on the third line below the return address. Spell out all military ranks; no punctuation in the last line except the ZIP+4 dash.
# e.g. [Lieutenant Colonel Getty A. Letter, Duty Title, Organization, Street Address, City ST 12345-6789]
receiver_address: []  # array<string>; required
# Begins with 'Dear' followed by the title (or rank) and last name of the receiver. Do not use punctuation after the salutation.
# e.g. Dear Colonel Letter
salutation: ""  # string; required
# Full signature block. Line 1: Name in UPPERCASE as signed, grade, and service. Line 2: Duty title. Spell out 'Colonel' and general officer ranks.
# e.g. ["DAVID L. JONES, CMSgt, USAF", Duty Title]
signature_block: []  # array<string>; required
# Controls date format. Military addressees use 'Day Month Year' (15 October 2014); civilian addressees use 'Month Day, Year' (October 15, 2014).
addressee_type: military  # enum<military | civilian>; optional
# Standard title. Only change for Joint Commands or DoW Agencies.
letterhead_title: DEPARTMENT OF THE AIR FORCE  # string; optional
# The full organization name of your unit.
letterhead_caption:  # array<string>; optional
  - HEADQUARTERS [UNIT NAME]
# Department of War (DoW) or Department of Defense (DoD) seal shown in the letterhead.
letterhead_seal: dow  # enum<dow | dod>; optional
# Optional line below the DoW seal (bold caps). Leave blank to omit.
letterhead_seal_subtitle: ""  # string; optional
# Organizational motto at the bottom of the page.
tag_line: ""  # string; optional
# Show the America 250 / Freedom 250 commemorative emblem in the letterhead, mirrored opposite the seal.
freedom250: false  # boolean; optional
# List attachments in the order they are mentioned in the letter. 'Attachment:' for one; '# Attachments:' for two or more. Placed flush left on the third line below the signature element.
# e.g. [Attachment description]
attachments: []  # array<string>; optional
# Courtesy copy recipients. Placed on the second line below the attachment element, or the third line below the signature if no attachment is used.
# e.g. ["Rank and Name, ORG/SYMBOL"]
cc: []  # array<string>; optional
# Font size for the letter text (pt). Decimal values (e.g. 11.5) are supported.
# e.g. 12
font_size: 12  # number; optional
# YYYY-MM-DD. Leave blank to use today's date.
date: ""  # date<YYYY-MM-DD>; optional
# Classification marking displayed in the header/footer banner. Banner colors follow DoD/CAPCO guidance. Leave blank to omit.
classification: ""  # enum< | UNCLASSIFIED | CUI | CONFIDENTIAL | SECRET | TOP SECRET>; optional
# Optional marking appended after double slash (e.g. NF with classification CUI renders as CUI//NF). Leave blank to show only the classification with no //.
dissemination: ""  # string; optional
---

The text of the letter. The first line of each major paragraph is indented 0.5 inches; subsequent lines are flush with the left margin. Keep the letter brief, preferably no longer than one page, and avoid acronyms.

A second paragraph, if needed.

- A sub-paragraph, automatically lettered (a., b., etc.).

