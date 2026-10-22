// Renders an army_memo fixture through the real Engine (@quillmark/wasm) and
// @quillmark/quiver, the pipeline `quillkit test` uses. With no fixture,
// renders the blueprint the schema seeds. A `.png` output writes one image per
// page, `<name>-<n>.png`; anything else writes a PDF. A trailing YYYY-MM-DD
// pins the render date, so `date: today` prints the same day every run.
//
// Usage: node design/army_memo/render_fixture.mjs [fixture.md] <out.pdf|out.png> [YYYY-MM-DD]
//
// Run it from the repo root so that `@quillmark/*` resolve from node_modules.
// PPI=<n> sets a PNG's resolution (default 144).

import { readFileSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, extname, resolve } from "node:path";

import { Engine, init } from "@quillmark/wasm";
import { fromDir } from "@quillmark/quiver/node";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "../..");

const args = process.argv.slice(2);
const today = /^\d{4}-\d{2}-\d{2}$/.test(args.at(-1) ?? "") ? args.pop() : undefined;
if (args.length === 0 || args.length > 2) {
  console.error("Usage: node design/army_memo/render_fixture.mjs [fixture.md] <out.pdf|out.png> [YYYY-MM-DD]");
  process.exit(1);
}
const [fixturePath, outputPath] = args.length === 1 ? [null, args[0]] : args;

const { Document } = await init();
const quill = await (await fromDir(repoRoot)).getQuill("army_memo@0.1.0");
for (const w of quill.warnings ?? []) console.warn(`quill warning: ${w.code}: ${w.message}`);

const doc = Document.fromMarkdown(fixturePath ? readFileSync(resolve(fixturePath), "utf8") : quill.blueprint);
const png = extname(outputPath) === ".png";
let result;
try {
  for (const w of doc.warnings ?? []) console.warn(`document warning: ${w.code}${w.path ? ` at ${w.path}` : ""}: ${w.message}`);
  result = await new Engine().render(
    quill,
    doc,
    png ? { format: "png", ppi: Number(process.env.PPI ?? 144) } : { format: "pdf" },
    today,
  );
} catch (error) {
  for (const d of error?.diagnostics ?? []) {
    const at = d.location ? ` (${d.location.file}:${d.location.line}:${d.location.column})` : "";
    console.error(`${d.severity}: ${d.code}: ${d.message}${at}`);
  }
  if (!error?.diagnostics?.length) console.error(error);
  process.exit(1);
} finally {
  doc.free();
}

for (const w of result.warnings ?? []) console.warn(`warning: ${w.code}${w.path ? ` at ${w.path}` : ""}: ${w.message}`);

result.artifacts.forEach((artifact, i) => {
  const out = png ? outputPath.replace(/\.png$/, `-${i + 1}.png`) : outputPath;
  writeFileSync(resolve(out), Buffer.from(artifact.bytes));
  console.log(`wrote ${out}`);
});
