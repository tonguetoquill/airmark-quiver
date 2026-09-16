~~~
$quill: classic_resume@0.1.0
$kind: main
name: John Doe
contacts:
  - john.doe@example.com
  - (555) 123-4567
  - github.com/johndoe
  - linkedin.com/in/johndoe
  - Pittsburgh, PA
link_contacts: true
paper: us-letter
font_size: 12
margin: 0.5
~~~

~~~
$kind: section
topic:
  value: certifications
  columns: 2
  items:
    - Offensive Security Certified Professional (OSCP)
    - GIAC Cyber Threat Intelligence (GCTI)
    - "CompTIA CASP+, CySA+, Sec+, Net+, A+, Proj+"
    - GIAC Machine Learning Engineer (GMLE)
title: Active Certifications
~~~

~~~
$kind: section
topic:
  value: skills
  columns: 2
  labeled_items:
    - label: Programming
      text: "Python, R, JS, C#, Rust, PowerShell, CI/CD"
    - label: Data Science
      text: "ML/statistics, TensorFlow, AI Engineering"
    - label: IT & Cybersecurity
      text: "AD DS, Splunk, Metasploit, Wireshark, Nessus"
    - label: Cloud
      text: "AWS EC2/S3, Helm, Docker, Serverless"
~~~

~~~
$kind: section
topic:
  value: experience
~~~

~~~
$kind: entry
heading: Templar Archives Research Division
form:
  value: dated
  dates: August 2024 – Present
  subtitle: Psionic Research Analyst
  location: Aiur
~~~

- Analyzed Khala disruption patterns following Amon's corruption, developing countermeasures to protect remaining neural link infrastructure.
- Building automated threat detection pipelines using Khaydarin crystal arrays to monitor Void energy signatures across the sector.

~~~
$kind: entry
heading: Terran Dominion Ghost Academy
form:
  value: dated
  dates: May 2025 – July 2025
  subtitle: Covert Ops Trainee
  location: Tarsonis (Remote)
~~~

- Developed tactical HUD displays for Ghost operatives integrating real-time Zerg hive cluster intelligence.
- Created automated target acquisition systems for nuclear launch protocols; involved cloaking field calibration and EMP targeting.
- Discovered (and reported) a critical vulnerability in Adjutant defense networks exploitable by Zerg Infestors.

~~~
$kind: entry
heading: Abathur's Evolution Pit
form:
  value: dated
  dates: June 2023 – July 2023
  subtitle: Biomass Research Intern
  location: Char
~~~

- Developed tracking algorithms for Overlord surveillance networks; supported pattern-of-life analysis for Terran outpost elimination.
- Prototyped a creep tumor optimization tool featuring swarm pathfinding, resource node mapping, and hatchery placement recommendations.

~~~
$kind: entry
heading: Raynor's Raiders
form:
  value: dated
  dates: January 2018 – June 2020
  subtitle: Combat Engineer
  location: Mar Sara
~~~

- Administered Hyperion shipboard systems, SCV maintenance protocols, and bunker defense automation for 30,000+ colonists.
- Developed siege tank targeting scripts, delivered Zerg threat briefs, and integrated supply depot optimization procedures.
- Achieved Distinguished Graduate honors at the Mar Sara Militia Academy.
- Awarded the Raynor's Star and Mar Sara Defense Medal for meritorious service against the Swarm.

~~~
$kind: section
topic:
  value: education
~~~

~~~
$kind: entry
heading: Carnegie Mellon University
form:
  value: dated
  dates: December 2025
  subtitle: Master of Information Technology Strategy
  location: Pittsburgh, PA
~~~

~~~
$kind: entry
heading: United States Air Force Academy
form:
  value: dated
  dates: May 2024
  subtitle: BS, Data Science
  location: Colorado Springs, CO
~~~

- Distinguished Graduate (top 10%); Chinese language minor (L2+/R1 on DLPT).
- Delogrand deputy captain, cyber combat lead, and web exploit SME.
- Professor Bradley A. Warner Data Science Catalyst and Top Cadet in Computer Networks.

~~~
$kind: entry
heading: Western Governors University
form:
  value: dated
  dates: April 2022
  subtitle: BS, Cybersecurity and Information Assurance
  location: Remote
~~~

~~~
$kind: entry
heading: Community College of the Air Force
form:
  value: dated
  dates: February 2019
  subtitle: AS, Information Systems Technology
  location: Remote
~~~

~~~
$kind: section
topic:
  value: other
title: Cyber Competition
~~~

~~~
$kind: entry
heading: 1st in SANS Academy Cup 2024
form:
  value: dated
~~~

- Competed as the Delogrand Web Exploit SME, solving SQLi, API, and HTTP packet crafting problems.
- Also placed first in SANS Core Netwars competition.

~~~
$kind: entry
heading: 1st in NCX 2023
form:
  value: dated
~~~

- Developed strategies, defensive scripts, and exploits for the Cyber Combat event.
- Analyzed logs with Bash and Python for the Data Analysis event.

~~~
$kind: entry
heading: 1st in SANS Academy Cup 2023
form:
  value: dated
~~~

- Competed as the Delogrand Web Exploit SME, solving XSS, XXE, SQLi, and HTTP crafting problems.
- Took first place against rival Army, Navy, and Coast Guard service academy teams.

~~~
$kind: section
topic:
  value: projects
~~~

~~~
$kind: entry
heading: TongueToQuill
form:
  value: linked
  url: https://www.tonguetoquill.com
~~~

- Rich markdown editor for perfectly formatted USAF and USSF documents with Claude MCP integration.

~~~
$kind: entry
heading: Quillmark
form:
  value: linked
  url: https://github.com/nibsbin/quillmark
~~~

- Parameterization engine for generating arbitrarily typesetted documents from markdown content.

~~~
$kind: entry
heading: Scraipe
form:
  value: linked
  url: https://pypi.org/project/scraipe/
~~~

- An asynchronous scraping and enrichment library to automate cybersecurity research.

~~~
$kind: entry
heading: ADSBLookup
form:
  value: linked
  url: <closed source>
~~~

- Reversed the internal API of a popular ADSB web service to pull comprehensive live ADSB datasets; ported and exposed attributes in a user-friendly, Pandas-compatible Python library for data scientists.
