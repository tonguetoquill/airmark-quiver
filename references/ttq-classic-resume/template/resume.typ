#import "@preview/ttq-classic-resume:0.2.0": *

// Wrap the entire document in `resume()` to apply page, text, and bullet
// defaults. Override any knob via `resume.with(...)`:
//
//   #show: resume.with(font: "Source Serif Pro", paper: "a4", link-color: blue)
#show: resume

#header(
  name: [Jane Doe],
  contacts: (
    link("mailto:jane@example.com"),
    [+1 (555) 555-5555],
    [San Francisco, CA],
    link("https://janedoe.dev")[janedoe.dev],
  ),
)

#summary[
  Backend engineer with 6+ years building distributed systems for high-traffic
  consumer products. Strong in Go, Python, and infrastructure-as-code; happiest
  reducing latency tail and on-call load.
]

#section[Experience]

#entry(
  heading-left: [Senior Software Engineer],
  heading-right: [Jan 2023 — Present],
  subheading-left: [Acme Corp.],
  subheading-right: [Remote],
  body: [
    - Led migration of a 400 kLoC monolith to event-driven microservices, dropping p99 checkout latency from 1.8 s to 240 ms.
    - Designed a real-time pricing service handling 50 K req/s on a 6-node Kubernetes cluster.
    - Mentored 4 engineers; introduced trunk-based development and codified release practices.
  ],
)

#entry(
  heading-left: [Software Engineer],
  heading-right: [Jun 2019 — Dec 2022],
  subheading-left: [Globex Inc.],
  subheading-right: [New York, NY],
  body: [
    - Built customer analytics dashboard serving 10 K+ daily users (React, FastAPI, ClickHouse).
    - Cut infrastructure spend 25 % via right-sizing, spot-instance migration, and aggressive caching.
  ],
)

#section[Education]

#entry(
  heading-left: [B.S. Computer Science, _summa cum laude_],
  heading-right: [2015 — 2019],
  subheading-left: [State University],
  subheading-right: [Anytown, USA],
)

#section[Projects]

#entry(
  heading-left: [Quillmark],
  heading-right: monolink("https://quillmark.dev"),
  body: [
    - Open-source markdown-to-PDF engine powered by Typst; 1.5 K GitHub stars, used in production by three commercial deployments.
  ],
)

#entry(
  heading-left: [pgwarp],
  heading-right: monolink("https://github.com/jdoe/pgwarp"),
  body: [
    - Logical-replication-based zero-downtime Postgres major-version upgrade tool.
  ],
)

#section[Skills]

#skills(
  (
    (category: [Languages], text: [Go, Python, TypeScript, Rust]),
    (category: [Frameworks], text: [FastAPI, Django, React, Next.js]),
    (category: [Infrastructure], text: [Kubernetes, AWS, Terraform, PostgreSQL, Kafka]),
    (category: [Tools], text: [Git, Docker, Bazel, Datadog]),
  ),
  columns: 2,
)

#section[Awards]

#compact-entry(
  [*Engineering Excellence Award* — Acme Corp.],
  [2024],
)

#compact-entry(
  [*Top 1% Reviewer*, ICML],
  [2022],
)
