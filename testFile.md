---
# AF Form 4141 — Individual's Record of Duties and Experience, Ground Environment Personnel
QUILL: af4141@0.1.0  # sentinel; required, verbatim
# Full name in Last, First, Middle Initial format.
name: ""  # string; required
# Unit or organization of assignment.
unit: ""  # string; required
# Current grade or CCC level.
grade: ""  # string; optional
# Commander's authentication entry on page 1.
commanders_auth: ""  # string; optional
---

```card experience
# composable (0..N)
# Each card represents one row in the Record of Experience table. Rows fill page 1 (up to 16 rows) then page 2 (up to 21 rows), for a maximum of 37 rows.
# Date of the action (column A).
date: ""  # date<YYYY-MM-DD>; optional
# One type of action per line (column B).
action: ""  # string; optional
# Written grade, if applicable (column C).
written_grade: ""  # string; optional
# Date of written grade (column D). Omit or leave blank when there is no written grade.
written_grade_date: ""  # date<YYYY-MM-DD>; optional
# Positional grade, if applicable (column E).
positional_grade: ""  # string; optional
# Date of positional grade (column F). Omit or leave blank when there is no positional grade.
positional_grade_date: ""  # date<YYYY-MM-DD>; optional
# Authentication or remarks entry (column G).
auth_or_remarks: "wasssuppppp"  # string; optional 
```