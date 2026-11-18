// check_signer_rows.mjs — AFH 33-337: "Do not place the signature element on a
// continuation page by itself." With three or four signers the block is two
// rows, and both rows share one page with the body's last lines. Sweeps body
// length across the first page break so the break falls between the rows.
//
// Usage (from the repo root): node design/usaf_memo/check_signer_rows.mjs
//
// Needs `pdftotext` (poppler-utils) on PATH.

import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { execFileSync } from "node:child_process";
import { Engine, init } from "@quillmark/wasm";
import { fromDir } from "@quillmark/quiver/node";

const ref = "usaf_memo@0.4.1";
const { Document } = await init();
const quill = await (await fromDir(process.cwd())).getQuill(ref);
const engine = new Engine();
const out = mkdtempSync(join(tmpdir(), "signer-rows-"));
const lead = k => Array(k).fill("Lead filler words fill the page.").join(" ");
const names = ["MARY E. BROWN", "JOHN Q. PUBLIC", "JANE A. DOE", "RICHARD C. ROE"];
const block = name => `"${name}, Col, USAF\\\\\\nCommander"`;
let bad = [], warn = [], n = 0;
for (const count of [3, 4]) {
  const extra = names.slice(1, count).map(name => `    - signature_block: ${block(name)}`).join("\n");
  for (let k = 0; k <= 120; k++) {
    const md = `~~~\n$quill: ${ref}\n$kind: main\naddressing:\n  memo_for: 123 OG/CC\n  memo_from: 123 CS/SCX\n  subject: Sweep\n  date: 2026-11-12\n  signature_block: ${block(names[0])}\nadditional:\n  additional_signers:\n${extra}\n~~~\n\n${lead(k)}\n\nNotional closing text ends the body.\n`;
    const r = await engine.render(quill, Document.parse(md), { format: "pdf" }, "2026-11-13");
    const id = `${count}-signers-${k}`;
    if ((r.warnings ?? []).some(w => /converge|stabilize/.test(w.message))) warn.push(id);
    const f = `${out}/${id}.pdf`;
    writeFileSync(f, Buffer.from(r.artifacts[0].bytes)); n++;
    const pages = execFileSync("pdftotext", ["-layout", f, "-"]).toString().split("\f");
    const at = names.slice(0, count).map(name => pages.findIndex(p => p.includes(name)));
    if (new Set(at).size > 1) bad.push(`${id}: signers on pages ${at.map(i => i + 1).join(", ")}`);
  }
}
console.log(`${n} renders: ${bad.length} split, ${warn.length} not converged`);
for (const b of bad) console.log(`split: ${b}`);
for (const w of warn) console.log(`not converged: ${w}`);
if (bad.length || warn.length) process.exit(1);
