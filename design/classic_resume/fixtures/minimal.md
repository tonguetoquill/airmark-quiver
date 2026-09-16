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
$kind: section
topic:
  value: summary
~~~

Security engineer of eight years, most of it on detection pipelines that other people have to keep running at three in the morning.

- Cleared: TS/SCI, current.
- Reads and writes Go, Python, and enough Rust to be dangerous.

~~~
$kind: section
topic:
  value: experience
extra: "*selected*"
~~~

~~~
$kind: entry
heading: Northwind Analytics
form:
  value: dated
  dates: 2021 – Present
~~~

- Rebuilt the alert triage path; median time to first human eyes fell from 40 minutes to 6.

~~~
$kind: entry
heading: Contoso Security
form:
  value: dated
  subtitle: Detection Engineer
~~~

- Wrote the detection content review process the team still runs.

~~~
$kind: entry
heading: Far Peak Labs
form:
  value: dated
  location: Remote
~~~

~~~
$kind: entry
heading: Winner, Regional CCDC
form:
  value: dated
~~~

~~~
$kind: section
topic:
  value: certifications
  columns: 3
  items:
    - GCIA
    - GCFA
    - "CISSP, *lapsed*"
~~~

~~~
$kind: section
topic:
  value: projects
~~~

~~~
$kind: entry
heading: Internal detection corpus
form:
  value: linked
~~~

- Not public, and the better part of two years.
