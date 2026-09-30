// check_click_targets.mjs — every field a classic_resume document prints can be
// clicked in the preview to reach the field it came from: the render's regions
// name each one. Renders the example, the seed and every fixture.
//
// Usage: node design/classic_resume/check_click_targets.mjs
//
// Run it from the repo root so that `@quillmark/*` resolve from node_modules.

import { readFileSync, readdirSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join, resolve } from "node:path";

import { Engine, init } from "@quillmark/wasm";
import { fromDir } from "@quillmark/quiver/node";

const here = dirname(fileURLToPath(import.meta.url));
await init();
const quiver = await fromDir(resolve(here, "../.."));
const quill = await quiver.getQuill("classic_resume@0.0.1");
const engine = new Engine();
const schema = quill.schema;

const PRINTED_TYPES = new Set(["string", "plaintext", "richtext"]);
const textOf = (value) => (typeof value === "string" ? value : value?.text ?? "");

// The address of every non-blank leaf under `addr` that the page prints, spelled
// as regions spell it: `main.contacts[1]`, `cards.projects[6].projects[0].link`.
function printed(addr, field, value, out) {
  if (field.type === "array") {
    (value ?? []).forEach((item, i) => printed(`${addr}[${i}]`, field.items, item, out));
  } else if (field.type === "object") {
    for (const [key, property] of Object.entries(field.properties)) {
      printed(`${addr}.${key}`, property, value?.[key], out);
    }
  } else if (PRINTED_TYPES.has(field.type) && textOf(value).trim() !== "") {
    out.push(addr);
  }
}

function expected(doc) {
  const view = quill.reader(doc).resolve();
  const out = [];
  for (const { name, value } of view.main.fields) {
    printed(`main.${name}`, schema.main.fields[name], value, out);
  }
  for (const card of view.cards) {
    const fields = schema.card_kinds[card.kind].fields;
    const prefix = `cards.${card.kind}[${card.index}]`;
    for (const { name, value } of card.fields) printed(`${prefix}.${name}`, fields[name], value, out);
    if (textOf(card.body?.value).trim() !== "") out.push(`${prefix}.body`);
  }
  return out;
}

const fixtures = join(here, "fixtures");
const documents = [
  ["example.md", () => quill.exampleDocument()],
  ["seed", () => quill.seedDocument()],
  ...readdirSync(fixtures)
    .filter((file) => file.endsWith(".md"))
    .map((file) => [`fixtures/${file}`, () => quill.parse(readFileSync(join(fixtures, file), "utf8"))]),
];

const failures = [];
for (const [label, open] of documents) {
  const doc = open();
  try {
    const { regions } = await engine.render(quill, doc, { format: "pdf", regions: true });
    const clickable = new Set(regions.map((region) => region.field));
    const missing = expected(doc).filter((addr) => !clickable.has(addr));
    for (const addr of missing) failures.push(`${label}: ${addr} prints but has no region`);
    if (!missing.length) console.log(`✓ ${label}`);
  } finally {
    doc.free();
  }
}

if (failures.length) {
  for (const failure of failures) console.error(`✗ ${failure}`);
  process.exit(1);
}
