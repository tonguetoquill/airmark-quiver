# <img src="https://www.tonguetoquill.com/favicon.svg" alt="Tongue to Quill (TTQ) Logo" style="width:24px;"/> TTQ Classic Resume

[![github-repository](https://img.shields.io/badge/GitHub-Repository-blue?logo=github)](https://github.com/nibsbin/ttq-classic-resume)
[![typst-universe](https://img.shields.io/badge/Typst-Universe-aqua)](https://typst.app/universe/package/ttq-classic-resume)
[![nibs](https://img.shields.io/badge/author-Nibs-white?logo=github)](https://github.com/nibsbin)

A clean, professional resume template for Typst with a refined, dense layout optimized for single-page resumes.

Maintained by [TongueToQuill](https://www.tonguetoquill.com)

## Preview

See [`template/resume.typ`](template/resume.typ) for a complete working resume.

> **Note:** A rendered `thumbnail.png` is required by Typst Universe and must be regenerated before publishing 0.2.0.

## Quick Start

**Using Typst CLI:**

```bash
typst init @preview/ttq-classic-resume:0.2.0
typst compile resume.typ
```

**Using [typst.app](https://typst.app):**

Click "Start from template" and search for `ttq-classic-resume`.

## API

```typst
#import "@preview/ttq-classic-resume:0.2.0": *

#show: resume.with(
  font: ("EB Garamond",),     // any font stack
  font-size: 12pt,
  paper: "us-letter",         // or "a4", etc.
  margin: 0.5in,
  leading: 0.5em,
  link-color: black,
  bullet-marker: auto,        // or any content (e.g. `[•]`, `sym.dash.em`)
)
```

| Function | Purpose |
|---|---|
| `resume(...)` | Document show rule. All knobs above are optional. |
| `header(name, contacts, separator)` | Name + contact line. `contacts` is `array<content>`. |
| `section(title, extra: none, rule: true)` | Bold uppercase section header with optional underline. |
| `entry(heading-left, heading-right, subheading-left, subheading-right, body)` | Two-row entry block. Subsumes the old `timeline-entry` and `project-entry`. |
| `compact-entry(left, right: none)` | One-line entry for awards / certifications / publications. |
| `summary(body)` | Lede paragraph wrapper. |
| `skills(items, columns: 2)` | Categorized (`{category, text}`) or flat content grid. Mixed shapes raise an error. |
| `monolink(url, label: none)` | Monospaced italic link styled to sit on the right of an entry heading. |

### Migrating from 0.1.x

| 0.1.x | 0.2.0 |
|---|---|
| `resume(content)` | `#show: resume.with(...)` (now parameterized) |
| `resume-header(name, contacts)` | `header(name: ..., contacts: ...)` |
| `section-header(title, extra)` | `section(title, extra: ...)` |
| `timeline-entry(...)` | `entry(...)` |
| `project-entry(name, url, body)` | `entry(heading-left: name, heading-right: monolink(url), body: body)` |
| `table(items, columns)` | `skills(items, columns)` (no longer shadows built-in `table`) |
| `config` (frozen dict) | parameters of `resume(...)` |
| `vgap` | use Typst's `v(...)` directly |

## Documentation

See [`template/resume.typ`](template/resume.typ) for a complete worked example.

## License

MIT
