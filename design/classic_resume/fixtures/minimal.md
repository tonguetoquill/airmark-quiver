~~~
$quill: classic_resume@0.0.1
$kind: main
name: Jane Q. Roe
contacts:
  - Portland, OR
  - jane.roe@example.org
link_contacts: false
paper: a4
font_size: 11
margin: 0.75
~~~

~~~
$kind: summary
~~~

Security engineer of eight years, most of it on detection pipelines that other people have to keep running at three in the morning.

- Cleared: TS/SCI, current.
- Reads and writes Go, Python, and enough Rust to be dangerous.

~~~
$kind: experience
extra: '*selected*'
jobs:
- company: Northwind Analytics
  dates: 2021 – Present
  bullets:
  - Rebuilt the alert triage path; median time to first human eyes fell from 40 minutes to 6.
- company: Contoso Security
  role: Detection Engineer
  bullets:
  - Wrote the detection content review process the team still runs.
- company: Far Peak Labs
  location: Remote
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
  bullets:
  - Not public, and the better part of two years.
~~~
