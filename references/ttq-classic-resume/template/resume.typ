// Migrated from the 0.1.x upstream template to the 0.2.0 API.
//   - resume-header   -> header
//   - section-header  -> section
//   - timeline-entry  -> entry
//   - project-entry   -> entry(..., heading-right: monolink(url))
//   - table           -> skills (no longer shadows Typst's built-in)
// `resume()` is now parameterizable; override via `#show: resume.with(...)`.

#import "@preview/ttq-classic-resume:0.2.0": *

#show: resume

#header(
  name: [John Doe],
  contacts: (
    link("mailto:john.doe@example.com"),
    [(555) 123-4567],
    link("https://github.com/johndoe")[github.com/johndoe],
    link("https://linkedin.com/in/johndoe")[linkedin.com/in/johndoe],
    [Pittsburgh, PA],
  ),
)

#section[Active Certifications]

#skills(
  (
    [Offensive Security Certified Professional (OSCP)],
    [GIAC Cyber Threat Intelligence (GCTI)],
    [CompTIA CASP+, CySA+, Sec+, Net+, A+, Proj+],
    [GIAC Machine Learning Engineer (GMLE)],
  ),
  columns: 2,
)

#section[Skills]

#skills(
  (
    (category: [Programming], text: [Python, R, JS, C\#, Rust, PowerShell, CI/CD]),
    (category: [Data Science], text: [ML/statistics, TensorFlow, AI Engineering]),
    (category: [IT & Cybersecurity], text: [AD DS, Splunk, Metasploit, Wireshark, Nessus]),
    (category: [Cloud], text: [AWS EC2/S3, Helm, Docker, Serverless]),
  ),
  columns: 2,
)

#section[Work Experience]

#entry(
  heading-left: [Templar Archives Research Division],
  heading-right: [August 2024 – Present],
  subheading-left: [Psionic Research Analyst],
  subheading-right: [Aiur],
  body: [
    - Analyzed Khala disruption patterns following Amon's corruption, developing countermeasures to protect remaining neural link infrastructure.
    - Building automated threat detection pipelines using Khaydarin crystal arrays to monitor Void energy signatures across the sector.
  ],
)

#entry(
  heading-left: [Terran Dominion Ghost Academy],
  heading-right: [May 2025 – July 2025],
  subheading-left: [Covert Ops Trainee],
  subheading-right: [Tarsonis (Remote)],
  body: [
    - Developed tactical HUD displays for Ghost operatives integrating real-time Zerg hive cluster intelligence.
    - Created automated target acquisition systems for nuclear launch protocols; involved cloaking field calibration and EMP targeting.
    - Discovered (and reported) a critical vulnerability in Adjutant defense networks exploitable by Zerg Infestors.
  ],
)

#entry(
  heading-left: [Abathur's Evolution Pit],
  heading-right: [June 2023 – July 2023],
  subheading-left: [Biomass Research Intern],
  subheading-right: [Char],
  body: [
    - Developed tracking algorithms for Overlord surveillance networks; supported pattern-of-life analysis for Terran outpost elimination.
    - Prototyped a creep tumor optimization tool featuring swarm pathfinding, resource node mapping, and hatchery placement recommendations.
  ],
)

#entry(
  heading-left: [Raynor's Raiders],
  heading-right: [January 2018 – June 2020],
  subheading-left: [Combat Engineer],
  subheading-right: [Mar Sara],
  body: [
    - Administered Hyperion shipboard systems, SCV maintenance protocols, and bunker defense automation for 30,000+ colonists.
    - Developed siege tank targeting scripts, delivered Zerg threat briefs, and integrated supply depot optimization procedures.
    - Achieved Distinguished Graduate honors at the Mar Sara Militia Academy.
    - Awarded the Raynor's Star and Mar Sara Defense Medal for meritorious service against the Swarm.
  ],
)

#section[Education]

#entry(
  heading-left: [Carnegie Mellon University],
  heading-right: [December 2025],
  subheading-left: [Master of Information Technology Strategy],
  subheading-right: [Pittsburgh, PA],
)

#entry(
  heading-left: [United States Air Force Academy],
  heading-right: [May 2024],
  subheading-left: [BS, Data Science],
  subheading-right: [Colorado Springs, CO],
  body: [
    - Distinguished Graduate (top 10%); Chinese language minor (L2+/R1 on DLPT).
    - Delogrand deputy captain, cyber combat lead, and web exploit SME.
    - Professor Bradley A. Warner Data Science Catalyst and Top Cadet in Computer Networks.
  ],
)

#entry(
  heading-left: [Western Governors University],
  heading-right: [April 2022],
  subheading-left: [BS, Cybersecurity and Information Assurance],
  subheading-right: [Remote],
)

#entry(
  heading-left: [Community College of the Air Force],
  heading-right: [February 2019],
  subheading-left: [AS, Information Systems Technology],
  subheading-right: [Remote],
)

#section[Cyber Competition]

#entry(
  heading-left: [1st in SANS Academy Cup 2024],
  body: [
    - Competed as the Delogrand Web Exploit SME, solving SQLi, API, and HTTP packet crafting problems.
    - Also placed first in SANS Core Netwars competition.
  ],
)

#entry(
  heading-left: [1st in NCX 2023],
  body: [
    - Developed strategies, defensive scripts, and exploits for the Cyber Combat event.
    - Analyzed logs with Bash and Python for the Data Analysis event.
  ],
)

#entry(
  heading-left: [1st in SANS Academy Cup 2023],
  body: [
    - Competed as the Delogrand Web Exploit SME, solving XSS, XXE, SQLi, and HTTP crafting problems.
    - Took first place against rival Army, Navy, and Coast Guard service academy teams.
  ],
)

#entry(
  heading-left: [1st in RMCS 2023],
  body: [
    - Competed as the Delogrand Web Exploit SME, solving obfuscated JS, Wasm, XSS, and SQLi problems.
  ],
)

#entry(
  heading-left: [1st in NCX 2022],
  body: [
    - Trained and strategized teams for the Cyber Combat event.
  ],
)

#section[Projects]

#entry(
  heading-left: [TongueToQuill],
  heading-right: monolink("https://www.tonguetoquill.com"),
  body: [
    - Rich markdown editor for perfectly formatted USAF and USSF documents with Claude MCP integration.
  ],
)

#entry(
  heading-left: [Quillmark],
  heading-right: monolink("https://github.com/nibsbin/quillmark"),
  body: [
    - Parameterization engine for generating arbitrarily typesetted documents from markdown content.
  ],
)

#entry(
  heading-left: [RoboRA],
  heading-right: monolink("https://github.com/nibsbin/RoboRA"),
  body: [
    - AI research automation framework for Dr. Nadiya Kostyuk's research on global cyber policy.
  ],
)

#entry(
  heading-left: [Scraipe],
  heading-right: monolink("https://pypi.org/project/scraipe/"),
  body: [
    - An asynchronous scraping and enrichment library to automate cybersecurity research.
  ],
)

#entry(
  heading-left: [Quandry],
  heading-right: monolink("https://quandry.streamlit.app/"),
  body: [
    - LLM Expectation Engine to automate security and behavior evaluation of LLM models.
    - Awarded 1st place out of 11 teams in CMU's Fall 2024 Information Security, Privacy, and Policy poster fair.
  ],
)

#entry(
  heading-left: [Streamlit Scroll Navigation],
  heading-right: monolink("https://pypi.org/project/streamlit-scroll-navigation/"),
  body: [
    - Published a Streamlit-featured PyPI package to help data scientists create fluid single-page applications.
  ],
)

#entry(
  heading-left: [ADSBLookup],
  heading-right: monolink("<closed source>"),
  body: [
    - Reversed the internal API of a popular ADSB web service to pull comprehensive live ADSB datasets; ported and exposed attributes in a user-friendly, Pandas-compatible Python library for data scientists.
  ],
)

#entry(
  heading-left: [OSCP LaTeX Report Template],
  heading-right: monolink("https://github.com/SnpM/oscp-latex-report-template"),
  body: [
    - Published a report template that features custom commands for streamlined penetration test documentation.
  ],
)

#entry(
  heading-left: [Lockstep Framework],
  heading-right: monolink("https://github.com/SnpM/LockstepFramework"),
  body: [
    - As a budding programmer, I created a popular RTS engine with custom-built deterministic physics.
  ],
)
