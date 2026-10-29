---
name: quill-design
description: Design a new quill or review an existing one for intuitive organization and a form that prints a correct document. Use when creating, revising or reviewing a Quill.yaml, its seeds, defaults, groups, card kinds or descriptions.
---

# Quill design

A quill is judged on the page it prints and in the editor a writer fills, not in its YAML. Four principles, ranked, cover what has gone right and wrong in this quiver. They are tendencies with evidence behind them, not rules: the editor and the format are still moving, so weigh them against what you see.

## The principles

1. **Nothing prints that the writer did not choose.** No field is required, every absent value renders its `default:` or its blank, and a new document starts with one card of every kind, seed or not. So the untouched document is a real page a writer may print, and the quill author alone decides what is on it. A wrong print is the only failure a writer cannot recover from, which is why this ranks first. A `default:` prints silently when it is wrong for a writer, so give one only where a value is right for nearly everyone or a wrong one is obvious on the page; a blank is at least visible. A `seed:` is a prompt: make it impossible to mistake for content (`ORG/SYMBOL`, `FIRST M. LAST, Rank, USAF`) and seed only cards most writers keep. A kind most writers never add still appears on every new document, so its blanks must print as nothing.

2. **The form follows the writer's task, not the data or the plate.** Groups, their order and their names match how the writer thinks about the document. What every writer fills goes first; what few writers touch goes later, unless a skipped value would print wrong. Name a group for a step in the task, never for a leftover ("Additional"). When the writer's model is a paper form, the task is filling its boxes in order, so the form follows the paper. The editor opens the first group and collapses the rest; the author controls the order, not the open state.

3. **Say it in the schema; spend words only on what the schema cannot say.** Structure is seen every time, help text once if at all. A hard limit the page or record has is a `max:` the writer sees as a counter; a soft one stays in prose, since a reached cap greys out Add with no message. Fields that apply only under one choice are that enum's `variants:`, which cannot be half-filled the way a boolean beside a separate group can. An optional number is `integer?`. What the schema cannot carry, the description does, in the order the writer needs it: the fact that prevents a wrong print, what the field is, one example, when to leave it blank, what prints.

4. **Model each thing as what it is, the way its siblings do.** A section of a document is a card kind. A row is an element of an array, laid out as a table when writers enter many; a card per row earns its cost only when a row has its own prose or its own place on the page. Values that belong together are a top-level `object`, which is both the group the editor draws and the address the document stores (`ui.group` is the legacy spelling, deprecated upstream, and this repo fails on warnings). Enum values are stored ids the editor shows raw, so make them readable (`us-letter`). Before modeling a concept, look at how a sibling quill models it and reuse that unless the sibling is the thing to fix.

## Designing a new quill

Start from the model for the document's shape: `usaf_memo` (latest) for a flat form with a prose body and routing cards, `classic_resume` for reorderable sections, `cyber_career_plan` for structured data the plate computes from, `medal_citation` for a fixed one-page form. Each has known weak spots in its seeds and labels; copy the structure, not the file.

1. List what prints and which of it most writers fill. That is the first group; the rest follows or is left out.
2. Type every field so the editor can enforce it, and give a `title:` to any field or group whose key does not read as a label (`pas`, `afsc`).
3. Write defaults, seeds and descriptions under principle 1, then turn the body off (`body: { enabled: false }`) wherever it means nothing.
4. Give each field an `example:` and each body a `body.example`, run `npm test`, then run the check below.

## Reviewing a quill

Read it in the order a writer meets it, not the order of the file, and report findings by principle with what prints or what the writer sees as the evidence. A preference with no such evidence is not a finding.

- Render the untouched document (the check below). Anything on the page the writer did not type is a principle 1 finding.
- Fill it as a first-time writer with the help text closed, in the editor (`npm run dev`) or by reading the schema top to bottom. A field you could not find, or found in the wrong group, is a principle 2 finding.
- Open the help text last. A fact you needed to avoid a wrong print that lived only there, or a hard limit stated only in prose, is a principle 3 finding.
- Compare each concept with its sibling quills. A divergence the quill does not explain is a principle 4 finding.

## The one firm check

`npm test` proves a quill renders; only looking at the untouched page proves it prints what the writer meant. Run `node .claude/skills/quill-design/render-seed.mjs <name>@<major.minor>` from the repo root and open the `seed-<n>.png` it writes, or open the quill in studio with examples off. Do it before calling a design done and before closing a review.
