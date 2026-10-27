---
name: quill-design
description: Design a new quill or review an existing one for intuitive organization and a form that prints a correct document. Use when creating, revising or reviewing a Quill.yaml, its seeds, defaults, groups, card kinds or descriptions.
---

# Quill design

A quill is judged on the page it prints and in the editor a writer fills, not in its YAML. Four principles cover what has gone right and wrong in this quiver so far. They are ranked: when two pull against each other, the earlier one wins. They are principles, not rules; the editor and the format are still moving, so weigh them against what you see rather than applying them blind.

## The principles

1. **The path of least effort prints a correct document.** No field is required, every absent value renders its `default:` or its blank, and a new document starts with one card of every kind carrying its `seed:`. So the blank starter is a real document a writer may print, and the quill author alone decides what it looks like. Judge every field, group, default and seed by one question: if the writer does what the form invites, including doing nothing, what prints? A `default:` is an answer and should be the right one for most writers. A `seed:` is a prompt and should be impossible to mistake for an answer. A wrong print is the only failure a writer cannot recover from, which is why this ranks first.

2. **The form is organized around the writer's task, not the data or the plate.** Groups, their order, their names and what starts open match how the writer thinks about the document they are producing. What every writer fills goes first and open; what few writers touch goes later and collapsed, unless a skipped value would print wrong. Name groups for a step in the task, never for a leftover ("Additional"). When the writer's model is a paper form, the task is filling its boxes in order, so the form follows the paper.

3. **Say it in the schema; spend words only on what the schema cannot say.** Structure is seen every time; help text is read once, if at all. A cap as `max:` becomes a counter; a cap in prose is forgotten. A set of fields that applies only under one choice is that enum's `variants:`, which cannot be half-filled; a boolean beside a separate group can. An optional number is `integer?`. What the schema cannot carry, the description carries, in the order the writer needs it: the one fact that prevents a wrong print, what the field is, one example, when to leave it blank, and what prints.

4. **Model each thing as what it is, and the same way everywhere.** A section of a document is a card kind whose `title` defaults to the heading it prints. A row of a table is a row in an array, laid out as a table when the writer enters many. A card per row earns its cost only when a row has its own prose or its own place in the document. Values that belong together as data are an `object`; values that only sit together on screen are a presentation group. Before modeling a concept, look at how a sibling quill models it and reuse that. This ranks last because it is the one most likely to move as the format evolves.

## Designing a new quill

Start from the model quill for the document's shape, then write the blank starter before the example.

| Shape | Model |
| --- | --- |
| A flat form with a prose body and optional routing cards | `usaf_memo` (latest) |
| A document built from reorderable sections | `classic_resume` |
| Structured data the plate computes from | `cyber_career_plan` |
| A fixed one-page certificate or form | `medal_citation` |

Then, in this order:

1. List what prints, and which of it most writers fill. That list is the open group; everything else is collapsed or absent.
2. Give every field a type that lets the editor enforce it (`max:`, enums, `variants:`, `integer?`) and a `default:` that is the right answer for most writers, under any cap.
3. Seed only cards most writers keep, with placeholders no one could mistake for content (`ORG/SYMBOL`, `FIRST M. LAST, Rank, USAF`). A kind most writers never add gets no seed.
4. Write each description with the wrong-print fact first. Give a `title:` to any field or group whose key does not read as a label (`pas`, `rdp`, `afsc`).
5. Turn the body off (`body: { enabled: false }`) on any card or main that never uses it.
6. Add `example.md`, then run the check below.

## Reviewing a quill

Read the quill in the order a writer meets it, not the order of the file.

- Open the blank starter in the editor (`npm run dev`, examples off) and print it. Anything on the page the writer did not type is a finding under principle 1: a seed, a default, a card nobody asked for.
- Fill it as a first-time writer with the help text closed. A field you could not find, or found in the wrong group, is a finding under principle 2.
- Open the help text last. Any fact you needed to avoid a wrong print that lived only there is a finding under principle 3. Any limit stated in prose that the schema could enforce is one too.
- Compare each concept (conditional fields, repeated rows, grouping, shared blocks such as classification) with how its sibling quills model it. Each divergence is a finding under principle 4 unless the quill says why.
- Report findings by principle, highest first, with what prints or what the writer sees as the evidence. A style preference with no such evidence is not a finding.

## The one firm check

Open the blank document, fill it the way a writer would, and look at what prints. `npm test` proves the quill renders; only this check proves it renders what the writer meant. Do it before calling a design done and before closing a review.

## Where the principles pull against each other

- Seeds teach the shape and seeds pollute the page. Prefer unmistakable placeholders on cards most writers keep, and no seed elsewhere.
- Collapsing hides clutter and hides fields that print. Keep open any field whose skipped value prints wrong.
- The writer's order and the paper's order are both the writer's task. A quill serving both kinds of writer has to pick, and should say which.
- A reached `max:` greys out Add with no message, so enforce hard limits the page or record has and leave soft ones to prose.
- Enum values are stored ids and the editor shows them raw. Readable ids (`us-letter`) serve both the data and the writer.
