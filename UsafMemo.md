---
# U.S. Air Force and Space Force Official Memorandum
QUILL: usaf_memo@0.2.0  # sentinel; required, verbatim
# Organization/office symbol in UPPERCASE. To address a specific person, add their rank and name in parentheses (e.g., 'ORG/SYMBOL (LT COL JANE DOE)'). For numerous recipients, use 'DISTRIBUTION'.
# e.g. [ORG1/SYMBOL, ORG2/SYMBOL]
memo_for: []  # array<string>; required
# If recipients are on the same installation, use only the office symbol. For recipients on other installations, include the full mailing address to enable return correspondence. Omit entirely to produce a Memorandum for Record (no MEMO FROM line).
# e.g. [ORG/SYMBOL, Organization Name, 123 Street Ave, City ST 12345-6789]
memo_from: []  # array<string>; optional
# Be brief and clear. Capitalize the first letter of each word except articles, prepositions, and conjunctions. Include suspense dates in parentheses if applicable.
# e.g. Subject of the Memorandum
subject: ""  # string; required
# Line 1: Name in UPPERCASE as signed, grade, and service. Line 2: Duty title. Spell out 'Colonel' and general officer ranks.
# e.g. ["FIRST M. LAST, Rank, USSF", Duty Title]
signature_block: []  # array<string>; required
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
# Cite by organization, type, date, and title.
# e.g. ["AFM 33-326, 31 July 2019, Preparing Official Communications"]
references: []  # array<string>; optional
# List office symbols of recipients to receive copies.
# e.g. ["Rank and Name, ORG/SYMBOL"]
cc: []  # array<string>; optional
# Complete list of recipients if 'SEE DISTRIBUTION' is used in the 'Memo For' field.
# e.g. [ORG1/SYMBOL, ORG2/SYMBOL]
distribution: []  # array<string>; optional
# List attachments in the order they are mentioned in the memo. Briefly describe each; do not use 'as stated' or abbreviations.
# e.g. ["Attachment description, YYYY MMM DD"]
attachments: []  # array<string>; optional
# USAF memorandum (default) or DAF headquarters memorandum. DAF changes date formatting and body paragraph layout per AFH 33-337.
memo_style: usaf  # enum<usaf | daf>; optional
# Font size for the memo text (pt). Decimal values (e.g. 11.5) are supported.
# e.g. 12
font_size: 12  # number; optional
# YYYY-MM-DD. Leave blank to use today's date.
date: ""  # date<YYYY-MM-DD>; optional
# Select the classification marking displayed in the header/footer banner. Banner colors follow DoD/CAPCO marking guidance (UNCLASSIFIED green, CUI/CONFIDENTIAL black, SECRET red, TOP SECRET orange). Follow AFI 31-401 and applicable DoD guidance. Leave blank to omit the banner.
classification: ""  # enum< | UNCLASSIFIED | CUI | CONFIDENTIAL | SECRET | TOP SECRET>; optional
# Optional marking appended after double slash (e.g. NF with classification CUI renders as CUI//NF). Leave blank to show only the classification with no //.
dissemination: ""  # string; optional
---

The first paragraph. Top-level paragraphs are auto-numbered; do not add manual numbering.

- Nested bullets are automatically lettered.


```card indorsement
# composable (0..N)
# Chain of routing endorsements. Each endorsement block adds an official response or forwarding action to the original memo.
# Office symbol or Rank Name of the endorsing official (e.g., 'ORG/SYMBOL').
from: ORG/SYMBOL  # string; optional
# Office symbol or organization receiving the endorsed memo.
for: ORG/SYMBOL  # string; optional
# Line 1: Name in UPPERCASE as signed, grade, and service. Line 2: Duty title.
# e.g. ["FIRST M. LAST, Rank, USAF", Duty Title]
signature_block:  # array<string>; required
  - FIRST M. LAST, Rank, USAF
  - Duty Title
# Action taken by the endorser. Leave blank to hide the Approve/Disapprove line entirely, 'undecided' to display the line with neither option circled, 'approve' or 'disapprove' to circle the selected option.
action: ""  # enum< | undecided | approve | disapprove>; optional
# Format style: 'standard' (formal on same page), 'informal' (less formal routing), or 'separate_page' (starts on new page).
format: standard  # enum<standard | informal | separate_page>; optional
# List of attachments specific to this endorsement.
attachments: []  # array<string>; optional
# List of office symbols to receive copies of this endorsement.
cc: []  # array<string>; optional
# YYYY-MM-DD. Date the endorser signs/forwards the memo (per AFH 33-337 Ch. 14, this is distinct from the originating memo's date). Leave blank to use today's date.
date: ""  # date<YYYY-MM-DD>; optional
```