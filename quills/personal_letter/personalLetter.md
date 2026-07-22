---
# U.S. Air Force Personal Letter (AFH 33-337, Chapter 15 — The Tongue and Quill)
QUILL: personal_letter@0.1.0  # sentinel; required, verbatim
# Sender's rank, full name, duty title, organization, and complete mailing address (single-spaced). Placed flush left on the second line below the date. Use periods after Mr., Ms., Mrs., Dr. No punctuation on the last line except the ZIP+4 dash.
# e.g. [Chief Master Sergeant David L. Jones, Duty Title, Organization, Street Address, City ST 12345-6789]
# Official department title in the letterhead (change only for joint commands or DoD agencies).
letterhead_title: DEPARTMENT OF THE AIR FORCE  # string; optional
# Unit name printed below the department title. Leave blank to omit letterhead entirely.
letterhead_caption:  # array<string>; optional
  - HEADQUARTERS 99TH AIR BASE WING
# Seal shown in the letterhead. 'dow' for the Department of War seal (Air Force); 'dod' for DoD seal.
letterhead_seal: dow  # enum<dow | dod>; optional
return_address:  # array<string>; required
  - Colonel Jane M. Smith, USAF
  - Commander, 99th Air Base Wing
  - Nellis Air Force Base
  - 4475 England Avenue
  - Nellis AFB NV 89191-7074
# Recipient's title or rank, full name, and complete mailing address (single-spaced). Placed on the third line below the return address. Spell out all military ranks in full.
# e.g. [Lieutenant Colonel Getty A. Letter, Duty Title, Organization, Street Address, City ST 12345-6789]
receiver_address:  # array<string>; required
  - Major General Robert A. Johnson
  - Commander, Air Force Materiel Command
  - 2275 D Street
  - Wright-Patterson AFB OH 45433-7050
# Begins with 'Dear' followed by the title (or rank) and last name of the receiver. No punctuation after the salutation (open punctuation style).
# e.g. Dear Colonel Letter
salutation: "Dear General Johnson"  # string; required
# Controls the date format. Military/government addressees: 'Day Month Year' (15 October 2014). Civilian addressees: 'Month Day, Year' (October 15, 2014).
addressee_type: military  # enum<military | civilian>; optional
# Full signature block of the sender. Line 1: Name in UPPERCASE as signed, grade, and service. Line 2: Duty title.
# e.g. ["DAVID L. JONES, CMSgt, USAF", Duty Title]
signature_block:  # array<string>; required
  - JANE M. SMITH, Colonel, USAF
  - Commander, 99th Air Base Wing
# 'Attachment:' for a single attachment; '# Attachments:' for two or more. Placed flush left on the third line below the signature element.
# e.g. [Attachment description]
attachments: []  # array<string>; optional
# Courtesy copy recipients. Placed on the second line below the attachment element, or the third line below the signature if no attachment is used.
# e.g. ["Rank and Name, ORG/SYMBOL"]
cc: []  # array<string>; optional
# Font size for the letter text (pt). Decimal values (e.g. 11.5) are supported.
# e.g. 12
font_size: 12  # number; optional
# YYYY-MM-DD. Leave blank to use today's date.
date: "2026-05-21"  # date<YYYY-MM-DD>; optional
# Classification marking in the header/footer banner. Follows DoD/CAPCO color guidance. Leave blank to omit.
classification: ""  # enum< | UNCLASSIFIED | CUI | CONFIDENTIAL | SECRET | TOP SECRET>; optional
# Marking appended after double slash (e.g. NF with CUI renders as CUI//NF). Leave blank for classification only.
dissemination: ""  # string; optional
---

It is my honor to congratulate you on your selection for promotion to Lieutenant General. Your distinguished service and exceptional leadership throughout your career reflect great credit upon yourself and the United States Air Force.

Your commitment to mission excellence and dedication to your Airmen are testaments to the kind of officer our Air Force needs at every level. I look forward to seeing the continued contributions you will make in your next assignment.

Please convey my congratulations to your family as well. Their support has been central to your success and to the strength of our Air Force.
