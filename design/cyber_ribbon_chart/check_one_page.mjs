// check_one_page.mjs — a ribbon chart is a one-page leave-behind, and the one
// lever that can cost it that page is the timeline window: more years buy their
// columns out of the width, and the milestone chips wrap taller as they narrow.
// `quillkit test` renders the blueprint's near-empty seed and never sees it, so
// this sweeps both fixtures across every window the schema recommends.
//
// Usage: node design/cyber_ribbon_chart/check_one_page.mjs

import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

import { Engine, init } from "@quillmark/wasm";
import { fromDir } from "@quillmark/quiver/node";

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(__dirname, "../..");

const { Document } = await init();
const quiver = await fromDir(repoRoot);
const engine = new Engine();
const quill = await quiver.getQuill("cyber_ribbon_chart@0.0.1");

// 6 is the shortest window a young officer would set; 18 is the one the
// `timeline_years` description points at, because it is where the last SDE look
// comes into view. Every year between them has to hold the page too.
const windows = [6, 8, 10, 12, 14, 16, 18];
const failures = [];

for (const fixture of ["maximal.md", "minimal.md"]) {
  const source = readFileSync(resolve(__dirname, "fixtures", fixture), "utf8");
  const windowLine = /^timeline_years: \d+$/m;
  if (!windowLine.test(source)) {
    console.error(`${fixture} has no bare \`timeline_years: N\` line to sweep`);
    process.exit(1);
  }
  console.log(fixture);
  for (const years of windows) {
    const md = source.replace(windowLine, `timeline_years: ${years}`);
    const doc = Document.fromMarkdown(md);
    let result;
    try {
      // PNG, not PDF: a PDF is one artifact however many pages it holds, so
      // counting artifacts off a PDF render is a check that cannot fail.
      result = await engine.render(quill, doc, { format: "png" });
    } finally {
      doc.free();
    }
    const pages = result.artifacts.length;
    console.log(`  timeline_years: ${String(years).padStart(2)} → ${pages} page${pages === 1 ? "" : "s"}`);
    if (pages !== 1) failures.push(`${fixture} at a ${years}-year window renders ${pages} pages`);
  }
}

if (failures.length > 0) {
  console.error("the chart left its page:");
  for (const f of failures) console.error(`  - ${f}`);
  process.exit(1);
}
console.log(`both fixtures hold one page at every window from ${windows[0]} to ${windows.at(-1)} years`);
