// check_vocabulary.mjs — the qualification vocabulary is written twice: as the
// `enum` a document picks from in Quill.yaml, and as the grouped list the plate
// prints in full and marks against. Neither can read the other, so this holds
// them to each other: same members, same order.
//
// Usage: node design/cyber_ribbon_chart/check_vocabulary.mjs

import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const quill = resolve(__dirname, "../../quills/cyber_ribbon_chart/0.0.1");

// The `values:` block under `qualifications.items.properties.qualification`.
const yaml = readFileSync(resolve(quill, "Quill.yaml"), "utf8");
const enumBlock = yaml.match(/qualification:\n\s*type: enum\n\s*values:\n((?:\s*- .*\n)+)/);
if (!enumBlock) throw new Error("no qualification enum found in Quill.yaml");
const schema = enumBlock[1]
  .split("\n")
  .filter((l) => l.trim().startsWith("- "))
  .map((l) => l.trim().slice(2).trim());

// The string literals inside the plate's `#let vocabulary = (...)` binding.
const plateSrc = readFileSync(resolve(quill, "plate.typ"), "utf8");
const vocabStart = plateSrc.indexOf("#let vocabulary = (");
if (vocabStart < 0) throw new Error("no vocabulary binding found in plate.typ");
const vocabEnd = plateSrc.indexOf("\n)", vocabStart);
const vocabSrc = plateSrc.slice(vocabStart, vocabEnd);
// Group headings open a pair — ("Heading", ( — so they are the only quoted
// string immediately followed by a comma and a parenthesis.
const plate = [...vocabSrc.matchAll(/"([^"]+)"/g)]
  .map((m) => m[1])
  .filter((s, i, all) => {
    const idx = vocabSrc.indexOf(`"${s}"`);
    return !/^\s*,\s*\(/.test(vocabSrc.slice(idx + s.length + 2));
  });

const problems = [];
if (schema.length !== plate.length) {
  problems.push(`count: Quill.yaml declares ${schema.length}, plate.typ prints ${plate.length}`);
}
for (const s of schema) if (!plate.includes(s)) problems.push(`plate.typ never prints "${s}"`);
for (const p of plate) if (!schema.includes(p)) problems.push(`Quill.yaml cannot pick "${p}"`);
const shared = schema.filter((s) => plate.includes(s));
const order = plate.filter((p) => schema.includes(p));
for (let i = 0; i < shared.length; i++) {
  if (shared[i] !== order[i]) {
    problems.push(`order diverges at ${i}: Quill.yaml "${shared[i]}", plate.typ "${order[i]}"`);
    break;
  }
}

if (problems.length > 0) {
  console.error("vocabulary mismatch:");
  for (const p of problems) console.error(`  - ${p}`);
  process.exit(1);
}
console.log(`vocabulary agrees — ${schema.length} qualifications, same order in both`);
