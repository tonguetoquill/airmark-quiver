~~~
$quill: classic_resume@0.1.0
$kind: main
name: Jane Q. Roe
contacts:
  - Portland, OR
  - jane.roe@example.org
paper: a4
font_size: 11
margin: 0.75
~~~

~~~
$kind: summary
title: ""
~~~

An engineer. Likes climbing rocks and making useful things.

- Cleared: TS/SCI, current.
- Reads and writes Go, Python, and enough Rust to be dangerous.

~~~
$kind: experience
title: Selected Experience
jobs:
- company: Northwind Analytics
  dates: 2021 – Present
  details: |
    - Rebuilt the alert triage path; median time to first human eyes fell from 40 minutes to 6.
- company: Contoso Security
  role: Detection Engineer
  details: |
    - Wrote the detection content review process the team still runs.
- company: Far Peak Labs
  location: Remote
  details: |
    A six-month contract building the log pipeline the detection team now runs on, handed over with its runbook.
- company: Winner, Regional CCDC
~~~

~~~
$kind: certifications
columns: 3
items:
- GCIA
- GCFA
- CISSP, *lapsed*
~~~

~~~
$kind: projects
projects:
- name: Internal detection corpus
  details: |
    - Not public, and the better part of two years.
~~~
