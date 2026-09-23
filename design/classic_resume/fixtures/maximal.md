~~~
$quill: classic_resume@0.0.1
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
$kind: certifications
title: Active Certifications
columns: 2
items:
- Offensive Security Certified Professional (OSCP)
- GIAC Cyber Threat Intelligence (GCTI)
- CompTIA CASP+, CySA+, Sec+, Net+, A+, Proj+
- GIAC Machine Learning Engineer (GMLE)
~~~

~~~
$kind: skills
columns: 2
skills:
- label: Programming
  text: Python, R, JS, C#, Rust, PowerShell, CI/CD
- label: Data Science
  text: ML/statistics, TensorFlow, AI Engineering
- label: IT & Cybersecurity
  text: AD DS, Splunk, Metasploit, Wireshark, Nessus
- label: Cloud
  text: AWS EC2/S3, Helm, Docker, Serverless
~~~

~~~
$kind: experience
jobs:
- company: Templar Archives Research Division
  dates: August 2024 – Present
  role: Psionic Research Analyst
  location: Aiur
  details: |
    - Analyzed Khala disruption patterns following Amon's corruption, developing countermeasures to protect remaining neural link infrastructure.
    - Building automated threat detection pipelines using Khaydarin crystal arrays to monitor Void energy signatures across the sector.
- company: Terran Dominion Ghost Academy
  dates: May 2025 – July 2025
  role: Covert Ops Trainee
  location: Tarsonis (Remote)
  details: |
    - Developed tactical HUD displays for Ghost operatives integrating real-time Zerg hive cluster intelligence.
    - Created automated target acquisition systems for nuclear launch protocols; involved cloaking field calibration and EMP targeting.
    - Discovered (and reported) a critical vulnerability in Adjutant defense networks exploitable by Zerg Infestors.
- company: Abathur's Evolution Pit
  dates: June 2023 – July 2023
  role: Biomass Research Intern
  location: Char
  details: |
    - Developed tracking algorithms for Overlord surveillance networks; supported pattern-of-life analysis for Terran outpost elimination.
    - Prototyped a creep tumor optimization tool featuring swarm pathfinding, resource node mapping, and hatchery placement recommendations.
- company: Raynor's Raiders
  dates: January 2018 – June 2020
  role: Combat Engineer
  location: Mar Sara
  details: |
    - Administered Hyperion shipboard systems, SCV maintenance protocols, and bunker defense automation for 30,000+ colonists.
    - Developed siege tank targeting scripts, delivered Zerg threat briefs, and integrated supply depot optimization procedures.
    - Achieved Distinguished Graduate honors at the Mar Sara Militia Academy.
    - Awarded the Raynor's Star and Mar Sara Defense Medal for meritorious service against the Swarm.
~~~

~~~
$kind: education
schools:
- school: Carnegie Mellon University
  dates: December 2025
  degree: Master of Information Technology Strategy
  location: Pittsburgh, PA
- school: United States Air Force Academy
  dates: May 2024
  degree: BS, Data Science
  location: Colorado Springs, CO
  details: |
    - Distinguished Graduate (top 10%); Chinese language minor (L2+/R1 on DLPT).
    - Delogrand deputy captain, cyber combat lead, and web exploit SME.
    - Professor Bradley A. Warner Data Science Catalyst and Top Cadet in Computer Networks.
- school: Western Governors University
  dates: April 2022
  degree: BS, Cybersecurity and Information Assurance
  location: Remote
- school: Community College of the Air Force
  dates: February 2019
  degree: AS, Information Systems Technology
  location: Remote
~~~

~~~
$kind: other
title: Cyber Competition
entries:
- heading: 1st in SANS Academy Cup 2024
  details: |
    - Competed as the Delogrand Web Exploit SME, solving SQLi, API, and HTTP packet crafting problems.
    - Also placed first in SANS Core Netwars competition.
- heading: 1st in NCX 2023
  details: |
    - Developed strategies, defensive scripts, and exploits for the Cyber Combat event.
    - Analyzed logs with Bash and Python for the Data Analysis event.
- heading: 1st in SANS Academy Cup 2023
  details: |
    - Competed as the Delogrand Web Exploit SME, solving XSS, XXE, SQLi, and HTTP crafting problems.
    - Took first place against rival Army, Navy, and Coast Guard service academy teams.
~~~

~~~
$kind: projects
projects:
- name: TongueToQuill
  url: https://www.tonguetoquill.com
  details: |
    - Rich markdown editor for perfectly formatted USAF and USSF documents with Claude MCP integration.
- name: Quillmark
  url: https://github.com/nibsbin/quillmark
  details: |
    - Parameterization engine for generating arbitrarily typesetted documents from markdown content.
- name: Scraipe
  url: https://pypi.org/project/scraipe/
  details: |
    - An asynchronous scraping and enrichment library to automate cybersecurity research.
- name: ADSBLookup
  url: <closed source>
  details: |
    - Reversed the internal API of a popular ADSB web service to pull comprehensive live ADSB datasets; ported and exposed attributes in a user-friendly, Pandas-compatible Python library for data scientists.
~~~
