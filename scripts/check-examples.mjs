// Every quill version ships a root `example.md`, and it renders against its quill
// with no warning. `quillkit test` renders the example but passes one that warns.

import { Engine, init } from "@quillmark/wasm";
import { fromDir } from "@quillmark/quiver/node";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

await init();
const quiver = await fromDir(resolve(dirname(fileURLToPath(import.meta.url)), ".."));
const engine = new Engine();

const failures = [];
let count = 0;
for (const name of quiver.quillNames()) {
  for (const version of quiver.versionsOf(name)) {
    const ref = `${name}@${version}`;
    const quill = await quiver.getQuill(ref);
    let doc;
    try {
      doc = quill.exampleDocument();
      if (!doc) {
        failures.push(`${ref}: ships no example.md`);
        continue;
      }
      count++;
      const result = await engine.render(quill, doc, { format: "pdf" });
      const warnings = [...(doc.warnings ?? []), ...(result.warnings ?? [])];
      for (const w of warnings) {
        failures.push(`${ref}: ${w.code}${w.path ? ` at ${w.path}` : ""}: ${w.message}`);
      }
      if (!warnings.length) console.log(`✓ ${ref} example`);
    } catch (error) {
      failures.push(`${ref}: ${error?.message ?? String(error)}`);
    } finally {
      doc?.free();
    }
  }
}

if (failures.length) {
  for (const f of failures) console.error(`✗ ${f}`);
  process.exit(1);
}
console.log(`${count} examples render against this quiver`);
