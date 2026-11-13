// check_signature_company.mjs — AFH 33-337: "Do not place the signature
// element on a continuation page by itself." Every signature block, the memo's
// and an indorsement's, shares its page with body text, and every layout
// converges.
//
// A stranded signature block shows only where the body's last element meets
// the foot of a page, so each ending (long and short paragraphs, tables under
// and over the relocation budget, bullets, a block quote) is swept across two
// pages of body lengths, with one and four signers and with an indorsement.
// `quillkit test` renders each example once and sees neither.
//
// Usage (from the repo root): node design/usaf_memo/check_signature_company.mjs
//
// Needs `pdftotext` (poppler-utils) on PATH.

import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { execFileSync } from "node:child_process";
import { Engine, init } from "@quillmark/wasm";
import { fromDir } from "@quillmark/quiver/node";
const { Document } = await init();
const quill = await (await fromDir(process.cwd())).getQuill("usaf_memo@0.4.0");
const engine = new Engine();
const out = mkdtempSync(join(tmpdir(), "signature-company-"));
const lead = k => Array(k).fill("Lead filler words fill the page.").join(" ");
const tails = {
  para20: Array(30).fill("Notional closing text ends the body.").join(" "),
  para8: Array(12).fill("Notional closing text ends the body.").join(" "),
  table8: "| Item | Detail |\n|---|---|\n" + Array.from({length: 8}, (_, i) => `| Row ${i} | Notional cell text\\\nsecond line |`).join("\n"),
  table14: "| Item | Detail |\n|---|---|\n" + Array.from({length: 14}, (_, i) => `| Row ${i} | Notional cell text\\\nsecond line |`).join("\n"),
  bullets: "Notional intro.\n\n" + Array.from({length: 6}, () => "- " + Array(5).fill("Notional bullet text runs on.").join(" ")).join("\n\n"),
  quote: "> " + Array.from({length: 22}, (_, i) => `NOTIONAL NAME ${i}, Capt, USAF`).join("\\\n> "),
};
const signers = {
  one: "",
  four: `additional:
  additional_signers:
    - signature_block: "JOHN Q. PUBLIC, Lt Col, USAF\\\\\\nCommander"
    - signature_block: "JANE A. DOE, Col, USAF\\\\\\nCommander"
    - signature_block: "RICHARD C. ROE, Col, USAF\\\\\\nCommander"`,
};
let bad = [], warn = [], n = 0;
for (const [tn, tail] of Object.entries(tails)) for (const [sn, sg] of Object.entries(signers)) for (const ind of [false, true]) {
  if (ind && sn === "four") continue;
  for (let k = 0; k <= 150; k += 2) {
    let md = `~~~\n$quill: usaf_memo@0.4.0\n$kind: main\naddressing:\n  memo_for: 123 OG/CC\n  memo_from: 123 CS/SCX\n  subject: Sweep\n  date: 2026-11-12\n  signature_block: "MARY E. BROWN, Maj, USAF\\\\\\nCommander"\n${sg}\n~~~\n\n${lead(k)}\n\n${tail}\n`;
    if (ind) md += `\n~~~\n$kind: indorsement\naddressing:\n  from: 123 OG/CC\n  for: 123 CS/SCX\n  signature_block: "INDO R. SER, Col, USAF\\\\\\nCommander"\n~~~\n\n${lead(k)}\n\n${tail}\n`;
    const doc = Document.parse(md);
    const r = await engine.render(quill, doc, { format: "pdf" }, "2026-11-13");
    if ((r.warnings??[]).some(w => /converge|stabilize/.test(w.message))) warn.push(`${tn}-${sn}-${ind?"ind":"memo"}-${k}`);
    const f = `${out}/${tn}-${sn}-${ind?"ind":"memo"}-${k}.pdf`;
    writeFileSync(f, Buffer.from(r.artifacts[0].bytes)); n++;
    const pages = execFileSync("pdftotext", ["-layout", f, "-"]).toString().split("\f");
    for (const name of ["MARY E. BROWN", "INDO R. SER"]) {
      const i = pages.findIndex(p => p.includes(name));
      if (i < 0) continue;
      const before = pages[i].split(name)[0];
      if (!/(Notional|NOTIONAL|Row \d|second line|Lead filler)/.test(before)) bad.push(`${f.split("/").pop()} ${name}`);
    }
  }
}
console.log(`${n} renders: ${bad.length} stranded, ${warn.length} not converged`);
for (const b of bad) console.log(`stranded: ${b}`);
for (const w of warn) console.log(`not converged: ${w}`);
if (bad.length || warn.length) process.exit(1);
