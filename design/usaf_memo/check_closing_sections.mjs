// check_closing_sections.mjs — one memorandum, three ways of writing it, and
// the requirement that all three render the same pages.
//
// The invariant: `#show: mainmatter` and `#mainmatter[…]` typeset the same
// document. The show rule receives the closing sections along with the body,
// and `split-closing` is what keeps them out of the body's rebuild pass — the
// rebuild buffers paragraphs, tables, and block quotes and drops everything
// else, so a closing section that enters it loses its 4.5-inch signature
// anchor and its labels, takes body paragraph numbers, and, where it carries a
// page break, does not compile at all.
//
// Usage (from the repo root):
//   node design/usaf_memo/check_closing_sections.mjs
//
// Needs a `typst` binary on PATH; set TYPST to point at one elsewhere.

import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { mkdtempSync, readFileSync, readdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const fixtures = join(here, "fixtures");
const repoRoot = resolve(here, "../..");
// The fixtures reach into `quills/` for the package under test, so the project
// root has to span both.
const fonts = join(
  repoRoot,
  "quills/usaf_memo/0.3.0/packages/tonguetoquill-usaf-memo/fonts",
);
const typst = process.env.TYPST ?? "typst";

const BASELINE = "closing_sections_function.typ";
const FORMS = ["closing_sections_showrule.typ", "closing_sections_nested.typ"];
// With page breaks the split is what makes the document compile; without them
// it compiles either way and only the ink says whether the split happened.
const VARIANTS = ["true", "false"];

// Page images rather than the PDF: two PDFs of the same pages differ in their
// metadata, and it is the ink that has to agree.
//
// A compile that fails is a result, not an accident — it is how the page-break
// variant breaks — so `null` is a verdict and not an error to raise.
const renderPages = (fixture, pageBreaks, outDir) => {
  const stem = `${pageBreaks}-${fixture}`;
  try {
    execFileSync(
      typst,
      [
        "compile",
        "--root", repoRoot,
        "--font-path", fonts,
        "--input", `page-breaks=${pageBreaks}`,
        "--format", "png",
        "--ppi", "100",
        join(fixtures, fixture),
        join(outDir, `${stem}-{p}.png`),
      ],
      { stdio: ["ignore", "ignore", "inherit"] },
    );
  } catch {
    return null;
  }
  return readdirSync(outDir)
    .filter(name => name.startsWith(`${stem}-`))
    .sort((a, b) => Number(a.match(/-(\d+)\.png$/)[1]) - Number(b.match(/-(\d+)\.png$/)[1]))
    .map(name => createHash("sha256").update(readFileSync(join(outDir, name))).digest("hex"));
};

const work = mkdtempSync(join(tmpdir(), "closing-sections-"));
let failures = 0;
try {
  for (const pageBreaks of VARIANTS) {
    const label = `page-breaks=${pageBreaks}`;
    const baseline = renderPages(BASELINE, pageBreaks, work);
    if (baseline === null) {
      throw new Error(`${BASELINE} (${label}) does not compile, so there is nothing to compare against`);
    }
    console.log(`${label}: ${BASELINE} renders ${baseline.length} page(s)`);

    for (const form of FORMS) {
      const pages = renderPages(form, pageBreaks, work);

      if (pages === null) {
        console.error(`FAIL ${label}: ${form} does not compile`);
        failures += 1;
      } else if (pages.length !== baseline.length) {
        console.error(
          `FAIL ${label}: ${form} renders ${pages.length} page(s), baseline has ${baseline.length}`,
        );
        failures += 1;
      } else {
        const differing = pages
          .map((hash, i) => (hash === baseline[i] ? null : i + 1))
          .filter(page => page !== null);
        if (differing.length > 0) {
          console.error(`FAIL ${label}: ${form} differs from the baseline on page(s) ${differing.join(", ")}`);
          failures += 1;
        } else {
          console.log(`pass ${label}: ${form}`);
        }
      }
    }
  }
} finally {
  rmSync(work, { recursive: true, force: true });
}

process.exit(failures === 0 ? 0 : 1);
