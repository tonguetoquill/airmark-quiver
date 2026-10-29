#!/usr/bin/env python3
"""Measures a rendered army_memo PDF against AR 25-50's layout, item by item
(C01-C59), and prints PASS, FAIL or SKIP per item, with the measurements
behind each FAIL. Exits 1 when any item fails.

    python3 -I design/army_memo/validate_memo.py [-v] <fixture.md | seed> <rendered.pdf> [YYYY-MM-DD]

`-v` lists every measurement. The fixture's YAML says which elements exist and what they read; `seed` reads
the document the schema seeds instead. The date is the one the PDF was rendered with
(default 2026-10-13), which `date: today` prints. The script renders the
fixture once more through render_fixture.mjs, beside the PDF, to read the
quill, document and render warnings (C57, C58, C59).
"""

import datetime as dt
import os
import re
import statistics
import subprocess
import sys
import tempfile
from pathlib import Path

import pymupdf
import yaml

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
RENDERER = HERE / "render_fixture.mjs"

POS, RECT, GAP, LU_TOL = 0.25, 0.5, 0.10, 0.01
WORD_GAP = 1.2
SEGMENT_GAP = 12.0
LIGATURES = {"ﬀ": "ff", "ﬁ": "fi", "ﬂ": "fl", "ﬃ": "ffi", "ﬄ": "ffl"}
TITLES = set("mr mrs ms messrs mmes dr prof rev fr hon pres sen rep gov supt st mt gen adm brig col lt capt cmdr maj sgt ft vs".split())
NUMBER_LEADS = set("approx jan feb mar apr jun jul aug sep sept oct nov dec".split())
DESIGNATOR_LEADS = set("no nos vol fig figs para paras encl app art sec ch pt pp ref pg bldg rm ste apt ext tel".split())
DESIGNATOR = re.compile(r"^(\d|[IVXLCDM]+(?![^\W\d_])|[A-Z](-?\d|(?![^\W\d_])))")
DESCENDER = 0.218
LETTER_LABELS = set("""tab annex appendix attachment enclosure exhibit figure table chart map schedule phase stage step
    plan option section part paragraph subparagraph item line column row box level grade class category type model
    version series group company battery troop team unit gate area zone sector range site lot block building room
    objective""".split())
RULE = re.compile(r"\s*([-*_])(?:\s*\1){2,}\s*")
ITEM = re.compile(r"^( *)(?:[-*+]|\d+[.)])\s+(?:\[[ xX]\]\s+)?", re.M)
ZIP = re.compile(r"^\d{5}(-\d{4})?[.,;:)]*$")
STATE_NAMES = """alabama alaska arizona arkansas california colorado connecticut delaware florida georgia hawaii idaho
    illinois indiana iowa kansas kentucky louisiana maine maryland massachusetts michigan minnesota mississippi
    missouri montana nebraska nevada hampshire jersey mexico york carolina dakota ohio oklahoma oregon pennsylvania
    island tennessee texas utah vermont virginia washington wisconsin wyoming columbia rico guam samoa islands""".split()
STATE = re.compile(r"^([A-Z]{2}|(?i:" + "|".join(STATE_NAMES) + r"))$")
LETTERHEAD_BASELINES = [46.25, 56.16, 65.40, 74.40, 83.76]
CUI_LAST_BASELINE = 792 - 27 - 13.8
INITIALS = re.compile(r"^(?:[^\W\d_]\.)*[^\W\d_]$")
DESIGNATORS = [
    (1, re.compile(r"^\d+\.$")),
    (2, re.compile(r"^[a-z]\.$")),
    (3, re.compile(r"^\(\d+\)$")),
    (4, re.compile(r"^\([a-z]\)$")),
]
WIDGET_NAME = re.compile(r"^[A-Za-z0-9_]+$")

CHECKS = [
    ("C01", "Page size"),
    ("C02", "Measured LU"),
    ("C03", "Advance ends within 540"),
    ("C04", "Body and closing ink above 720"),
    ("C05", "Span colors black"),
    ("C06", "Fonts"),
    ("C07", "Seal image rect"),
    ("C08", "Seal ink bbox"),
    ("C09", "Seal black ink"),
    ("C10", "Letterhead line 1"),
    ("C11", "Letterhead lines 2-5"),
    ("C12", "Plain continuation pages"),
    ("C13", "Office symbol line"),
    ("C14", "Blank record number"),
    ("C15", "Date"),
    ("C16", "Date widget"),
    ("C17", "Suspense"),
    ("C18", "Address first line"),
    ("C19", "Single address"),
    ("C20", "Memorandum for record"),
    ("C21", "Multiple address"),
    ("C22", "SEE DISTRIBUTION"),
    ("C23", "THRU single"),
    ("C24", "THRU multiple"),
    ("C25", "THRU widgets"),
    ("C26", "SUBJECT"),
    ("C27", "Body start"),
    ("C28", "Paragraph gaps"),
    ("C29", "Designator x0"),
    ("C30", "Designator gap"),
    ("C31", "Turnover lines"),
    ("C32", "One-paragraph memo"),
    ("C33", "Sentence gaps"),
    ("C34", "References"),
    ("C35", "Single reference"),
    ("C36", "Table"),
    ("C37", "Authority line"),
    ("C38", "Signature name"),
    ("C39", "Signature lines"),
    ("C40", "Signature widget"),
    ("C41", "Enclosure header"),
    ("C42", "Enclosure items"),
    ("C43", "DISTRIBUTION"),
    ("C44", "CF"),
    ("C45", "Continuation header"),
    ("C46", "Continuation text"),
    ("C47", "Page number"),
    ("C48", "Page count"),
    ("C49", "Widow and orphan"),
    ("C50", "Closing keep"),
    ("C51", "No hyphenation"),
    ("C52", "Banners"),
    ("C53", "Banner clears letterhead"),
    ("C54", "CUI block"),
    ("C55", "Widgets"),
    ("C56", "Scaling"),
    ("C57", "Cardinality"),
    ("C58", "Load warnings"),
    ("C59", "Render warnings"),
]


class Report:
    def __init__(self):
        self.results = {cid: [] for cid, _ in CHECKS}

    def expect(self, cid, ok, detail):
        self.results[cid].append((bool(ok), detail))
        return ok

    def near(self, cid, what, got, want, tol=POS):
        ok = got is not None and abs(got - want) <= tol
        return self.expect(cid, ok, f"{what} {fmt(got)} (want {fmt(want)})")

    def steps(self, cid, what, a, b, n, lu):
        if a is None or b is None:
            return self.expect(cid, False, f"{what}: missing")
        got = (b - a) / lu
        return self.expect(cid, abs(got - n) <= LU_TOL, f"{what} {got:.3f} LU (want {n})")

    def print(self, verbose=False):
        failed = False
        for cid, title in CHECKS:
            rows = self.results[cid]
            if not rows:
                print(f"SKIP {cid} {title}")
                continue
            bad = [d for ok, d in rows if not ok]
            failed |= bool(bad)
            print(f"{'FAIL' if bad else 'PASS'} {cid} {title}" + (": " + "; ".join(bad[:6]) if bad else ""))
            if verbose:
                for ok, d in rows:
                    print(f"     {'ok ' if ok else 'BAD'} {d}")
        return failed


def fmt(v):
    if v is None:
        return "none"
    if isinstance(v, float):
        return f"{v:.2f}"
    if isinstance(v, (list, tuple)):
        return "[" + ", ".join(fmt(x) for x in v) + "]"
    return repr(v)


def norm(s):
    return re.sub(r"\s+", " ", str(s).replace(" ", " ")).strip()


# --- the fixture ------------------------------------------------------------------------------


def node(args):
    return subprocess.run(["node", *args], cwd=REPO, capture_output=True, text=True)


def seed():
    script = (
        'import { init } from "@quillmark/wasm"; import { fromDir } from "@quillmark/quiver/node";'
        "await init(); const q = await (await fromDir(process.cwd())).getQuill('army_memo@0.1.0');"
        "process.stdout.write(q.seedDocument().toMarkdown());"
    )
    out = node(["--input-type=module", "-e", script])
    if out.returncode:
        sys.exit(out.stderr)
    return out.stdout


def load_fixture(arg):
    text = seed() if arg == "seed" else Path(arg).read_text(encoding="utf8")
    m = re.match(r"~~~\n(.*?)\n~~~\n?(.*)", text, re.S)
    data = yaml.safe_load(m.group(1)) or {}
    return data, m.group(2), text


class Memo:
    """The fixture's fields, with the plate's defaults."""

    def __init__(self, data, body, source, today):
        def group(name):
            return data.get(name) or {}

        def value(g, key, default=None):
            v = group(g).get(key)
            return default if v is None else v

        def items(g, key):
            return [str(x) for x in (value(g, key, []) or []) if norm(x)]

        self.size = float(value("additional", "font_size", 12))
        self.lu = 1.15 * self.size
        self.cap = 0.662 * self.size
        self.space = 0.25 * self.size
        self.os = 100.95 + 26.37 * self.size / 12
        self.memo_for = items("addressing", "memo_for")
        self.memo_thru = items("addressing", "memo_thru")
        self.office_symbol = norm(value("addressing", "office_symbol", ""))
        self.record_number = re.sub(r"^\((.*)\)$", r"\1", norm(value("addressing", "record_number", ""))).strip()
        self.office_symbol_info = norm(value("addressing", "office_symbol_info", ""))
        self.subject = norm(value("addressing", "subject", ""))
        self.date = self.print_date(value("addressing", "date"), today)
        self.suspense = self.print_date(value("addressing", "suspense"), today)
        self.authority = norm(value("addressing", "authority_line", ""))
        self.signature = items("addressing", "signature_block")
        self.letterhead = items("letterhead", "letterhead_title") or ["DEPARTMENT OF THE ARMY"]
        self.seal = value("letterhead", "letterhead_seal", "dow")
        self.references = items("additional", "references")
        self.enclosures = items("additional", "enclosures")
        self.distribution = items("additional", "distribution")
        self.cf = items("additional", "cf")
        self.cf_without = bool(value("additional", "cf_without_enclosures", False))
        marking = data.get("classification") or {}
        classification = marking.get("level")
        if isinstance(classification, dict):
            self.cui = {k: norm(v) for k, v in classification.items() if k != "value" and v is not None}
            classification = classification.get("value")
        else:
            self.cui = {}
        self.classification = norm(classification or "")
        self.dissemination = norm(marking.get("dissemination") or "") if self.classification not in ("", "UNCLASSIFIED") else ""
        self.body = body
        self.source = norm(source)
        self.has_table = bool(re.search(r"^\|.*\|\s*$", body, re.M))
        blocks = [b for b in re.split(r"\n\s*\n", body.strip()) if b.strip()]
        plain = lambda b: not re.match(r"^(\s|[-*+]\s|[>|#<]|\d+\.\s|~~~|```|\$\$)", b) and not RULE.fullmatch(b)
        # A heading runs into the paragraph after it, or stands as a paragraph.
        self.top_paragraphs = [
            b for i, b in enumerate(blocks)
            if plain(b) or (b.startswith("#") and not (i + 1 < len(blocks) and plain(blocks[i + 1])))
        ]
        # A body typed as a list numbers its outermost items, and their
        # further paragraphs, as its paragraphs.
        marks = [m for b in blocks for m in ITEM.finditer(b)]
        if marks and all(re.match(r"^(\s|[-*+]\s|\d+[.)]\s)", b) for b in blocks):
            base = min(len(m.group(1)) for m in marks)
            content = min(len(m.group(0)) for m in marks if len(m.group(1)) == base)
            indent = lambda b: len(b) - len(b.lstrip(" "))
            self.top_paragraphs = [m.group(0) for m in marks if len(m.group(1)) == base] + [
                b for b in blocks if not ITEM.match(b) and indent(b) <= content
            ]
        # Each paragraph of a block quote, and each line of a code block, by
        # its first line's text: an unnumbered line of its own.
        quoted = "\n".join(l for l in body.split("\n") if l.startswith(">"))
        self.quotes = [
            norm(re.sub(r"^>\s?", "", q.strip().split("\n")[0], flags=re.M))
            for q in re.split(r"^>\s*$", quoted, flags=re.M) if q.strip()
        ]
        self.quotes += [norm(l) for c in re.findall(r"^```[^\n]*\n(.*?)^```", body, re.S | re.M) for l in c.split("\n") if l.strip()]

    @staticmethod
    def print_date(v, today):
        if v is None or str(v).strip() == "":
            return None
        d = today if str(v).strip() == "today" else v
        if isinstance(d, str):
            d = dt.date.fromisoformat(d)
        return f"{d.day} {d.strftime('%B')} {d.year}"

    @property
    def banner(self):
        if not self.classification:
            return None
        return self.classification + ("//" + self.dissemination.upper() if self.dissemination else "")

    @property
    def authority_text(self):
        if not self.authority:
            return None
        return re.sub(r"[\s.,;:]+$", "", self.authority.upper()) + ":"

    def enclosure_listing(self):
        """(header, [(label or None, text)]) per AR 25-50 2-4c(3) and 4-2c."""
        entries = self.enclosures
        as_ = [norm(e).lower().rstrip(". ") in ("as", "as stated") for e in entries]
        n = len(entries)
        if n == 0:
            return None, []
        if all(as_):
            return ("Encl" if n == 1 else "Encls"), []
        if n == 1:
            return "Encl", [(None, capitalize(norm(entries[0])))]
        items, i = [], 0
        while i < n:
            if as_[i]:
                j = i
                while j + 1 < n and as_[j + 1]:
                    j += 1
                items.append((f"{i + 1}." if i == j else f"{i + 1}–{j + 1}.", "as"))
                i = j + 1
            else:
                items.append((f"{i + 1}.", capitalize(norm(entries[i]))))
                i += 1
        return f"{n} Encls", items


# --- the PDF ----------------------------------------------------------------------------------


class Glyph:
    __slots__ = ("c", "x", "y", "end", "font", "size", "color")

    def __init__(self, c, x, y, end, font, size, color):
        self.c, self.x, self.y, self.end = c, x, y, end
        self.font, self.size, self.color = font, size, color


class Seg:
    """A run of glyphs on one baseline, split into words at the gaps between them."""

    def __init__(self, glyphs):
        self.glyphs = glyphs
        self.words, word = [], [glyphs[0]]
        for prev, g in zip(glyphs, glyphs[1:]):
            if g.x - prev.end > WORD_GAP:
                self.words.append(word)
                word = []
            word.append(g)
        self.words.append(word)

    @property
    def x0(self):
        return self.glyphs[0].x

    @property
    def end(self):
        return self.glyphs[-1].end

    @property
    def base(self):
        return self.glyphs[0].y

    @property
    def tokens(self):
        return ["".join(g.c for g in w) for w in self.words]

    @property
    def gaps(self):
        return [b[0].x - a[-1].end for a, b in zip(self.words, self.words[1:])]

    @property
    def text(self):
        return " ".join(self.tokens)

    @property
    def bold(self):
        return all("Bold" in g.font for g in self.glyphs)

    @property
    def sizes(self):
        return {round(g.size, 2) for g in self.glyphs}

    def after(self, k):
        """The x where word k starts."""
        return self.words[k][0].x


class Row:
    def __init__(self, page, segs):
        self.page, self.segs = page, segs

    @property
    def base(self):
        return self.segs[0].base

    @property
    def x0(self):
        return self.segs[0].x0

    @property
    def text(self):
        return " ".join(s.text for s in self.segs)

    def left(self, limit=300):
        return [s for s in self.segs if s.x0 < limit]

    def right(self, limit=300):
        return [s for s in self.segs if s.x0 >= limit]

    def __repr__(self):
        return f"p{self.page + 1}@{self.base:.2f}x{self.x0:.2f}:{self.text[:40]!r}"


def page_glyphs(page):
    out = []
    for block in page.get_text("rawdict")["blocks"]:
        if block["type"] != 0:
            continue
        for line in block["lines"]:
            for span in line["spans"]:
                font = span["font"].split("+", 1)[-1]
                for ch in span["chars"]:
                    if ch["c"].isspace():
                        continue
                    x, y = ch["origin"]
                    out.append(Glyph(LIGATURES.get(ch["c"], ch["c"]), x, y, ch["bbox"][2], font, span["size"], span["color"]))
    return out


def rows_of(glyphs, page_index):
    rows, current = [], []
    # A ligature's later letters stand where its first ends; rounding keeps
    # them in content order.
    for g in sorted(glyphs, key=lambda g: (round(g.y, 1), round(g.x, 2))):
        if current and abs(g.y - current[0].y) > 0.05:
            rows.append(current)
            current = []
        current.append(g)
    if current:
        rows.append(current)
    out = []
    for glyphs_in_row in rows:
        glyphs_in_row.sort(key=lambda g: round(g.x, 2))
        segs, seg = [], [glyphs_in_row[0]]
        for prev, g in zip(glyphs_in_row, glyphs_in_row[1:]):
            if g.x - prev.end > SEGMENT_GAP:
                segs.append(Seg(seg))
                seg = []
            seg.append(g)
        segs.append(Seg(seg))
        merged = []
        for s in segs:
            # A `(1)` designator stands 18pt from its text.
            if merged and re.match(r"^\(\w{1,3}\)$", merged[-1].text) and s.x0 - merged[-1].end < 19:
                merged[-1] = Seg(merged[-1].glyphs + s.glyphs)
            else:
                merged.append(s)
        out.append(Row(page_index, merged))
    return out


def table_boxes(page):
    """Each table's frame, [x0, y0, x1, y1, drawings], from its rules' centre
    lines: a vertical rule's ends overhang the frame by half its stroke. A
    group of drawings with fewer than two vertical rules is an underline or a
    strike, not a table."""
    groups = []
    for d in page.get_drawings():
        r = d["rect"]
        extent = [r.x0, r.y0, r.x1, r.y1]
        groups.append([extent, [d]])
    merged = True
    while merged:
        merged = False
        for i in range(len(groups)):
            for j in range(i + 1, len(groups)):
                a, b = groups[i][0], groups[j][0]
                if a[0] <= b[2] + 1 and b[0] <= a[2] + 1 and a[1] <= b[3] + 1 and b[1] <= a[3] + 1:
                    groups[i] = [[min(a[0], b[0]), min(a[1], b[1]), max(a[2], b[2]), max(a[3], b[3])], groups[i][1] + groups[j][1]]
                    del groups[j]
                    merged = True
                    break
            if merged:
                break
    boxes = []
    for extent, drawings in groups:
        verticals = sum(1 for d in drawings for it in d["items"] if it[0] == "l" and abs(it[1].x - it[2].x) < 0.01)
        if verticals < 2:
            continue
        xs, ys = [], []
        for d in drawings:
            for item in d["items"]:
                if item[0] == "l":
                    p, q = item[1], item[2]
                    if abs(p.x - q.x) < 0.01:
                        xs.append(p.x)
                    if abs(p.y - q.y) < 0.01:
                        ys.append(p.y)
                elif item[0] == "re":
                    xs += [item[1].x0, item[1].x1]
                    ys += [item[1].y0, item[1].y1]
        boxes.append([min(xs, default=extent[0]), min(ys, default=extent[1]),
                      max(xs, default=extent[2]), max(ys, default=extent[3]), drawings])
    return boxes


# --- reading the memo off the pages -----------------------------------------------------------


class Page:
    def __init__(self, index, page, memo):
        self.index = index
        self.tables = table_boxes(page)
        glyphs = page_glyphs(page)
        self.glyphs = glyphs
        # A thematic break: a full-width rule centred in a line of its own,
        # framed as that line's cap top and baseline.
        self.rules = [
            [72.0, it[1].y - memo.cap / 2, 540.0, it[1].y + memo.cap / 2, [d]]
            for d in page.get_drawings() for it in d["items"]
            if it[0] == "l" and abs(it[1].y - it[2].y) < 0.01
            and abs(min(it[1].x, it[2].x) - 72) < 0.5 and abs(max(it[1].x, it[2].x) - 540) < 0.5
            and not any(t[1] - 1 <= it[1].y <= t[3] + 1 for t in self.tables)
            and not any(abs(g.y - it[1].y) < memo.lu - memo.cap / 2 for g in glyphs)
        ]
        in_table = lambda g: any(t[0] - 1 <= g.x <= t[2] + 1 and t[1] - 1 <= g.y <= t[3] + 1 for t in self.tables)
        self.table_glyphs = [g for g in glyphs if in_table(g)]
        rows = rows_of([g for g in glyphs if not in_table(g)], index)
        self.banners, self.cui, self.letterhead, self.number = [], [], [], []
        self.suspense = None
        rest = []
        for r in rows:
            if memo.banner and (abs(r.base - 35.11) < 1 or abs(r.base - 765) < 1) and abs(r.segs[0].x0 + r.segs[-1].end - 612) < 2:
                self.banners.append(r)
            elif index == 0 and r.base > 600 and all(s.sizes == {10.0} for s in r.segs):
                self.cui.append(r)
            elif index == 0 and r.base < memo.os - 2 * memo.lu - 2:
                self.letterhead.append(r)
            elif index == 0 and abs(r.base - (memo.os - 2 * memo.lu)) < 1 and r.text.startswith("S:"):
                self.suspense = r
            elif abs(r.base - 732.70) < 1 and re.fullmatch(r"\d+", r.text):
                self.number.append(r)
            else:
                rest.append(r)
        self.header = []
        if index > 0:
            top = 72 + memo.cap
            while rest and rest[0].base < top + (len(self.header) + 0.5) * memo.lu:
                self.header.append(rest.pop(0))
        self.flow = rest


def find_subject(rows):
    for i, r in enumerate(rows):
        if r.text.startswith("SUBJECT:"):
            return i
    return None


def run_of(rows, start, lu):
    """Rows from `start` while each is one LU below the last."""
    out = [rows[start]]
    for r in rows[start + 1 :]:
        if abs((r.base - out[-1].base) / lu - 1) <= LU_TOL:
            out.append(r)
        else:
            break
    return out


def designator(seg):
    tok = seg.tokens[0]
    for level, pat in DESIGNATORS:
        if pat.match(tok) and len(seg.tokens) > 1:
            return level
    return None


def ends_sentence(token, nxt, before=""):
    if not nxt or not (nxt[0].isupper() or nxt[0].isdigit() or nxt[0] in "\"'“‘("):
        return False
    core = token.rstrip("\"'”’)")
    if core.endswith("?"):
        return True
    if not core.endswith("."):
        return False
    word = re.sub(r"^[^\w]+", "", core[:-1]).lower()
    if INITIALS.match(word):
        return len(word) == 1 and before.lower() in LETTER_LABELS
    if word in TITLES:
        return False
    if word in NUMBER_LEADS:
        return not nxt[0].isdigit()
    if word in DESIGNATOR_LEADS:
        return not DESIGNATOR.match(nxt)
    if word == "al" and before.lower() == "et":
        return not (nxt[0] == "(" or nxt[0].isdigit())
    return True


def word_gap(prev, nxt, space):
    """One space between words; two before a ZIP code (AR 25-50 5-10b)."""
    return 2 * space if ZIP.match(nxt) and STATE.match(prev) else space


def join(text, line):
    """Two lines' text as one: a line that breaks after a slash or hyphen
    breaks inside a word."""
    if not text:
        return line
    return text + ("" if text.endswith(("/", "-", "\u2010")) else " ") + line


def match_lines(rows, entries, first_x, turn_x, upper_first=False, transform=None):
    """Splits `rows` among `entries` by text. Returns ([(entry, rows)], problems)."""
    out, problems, i = [], [], 0
    for k, entry in enumerate(entries):
        want = norm(entry)
        if transform:
            want = transform(k, want)
        got, taken = "", []
        while i < len(rows) and len(norm(got)) < len(want):
            taken.append(rows[i])
            got = join(got, rows[i].text)
            i += 1
        if norm(got) != want:
            problems.append(f"entry {k + 1} reads {norm(got)!r}, want {want!r}")
        for j, r in enumerate(taken):
            want_x = first_x if j == 0 else turn_x
            if abs(r.x0 - want_x) > POS:
                problems.append(f"entry {k + 1} line {j + 1} x0 {r.x0:.2f} (want {want_x:.2f})")
        out.append((entry, taken))
    if i < len(rows):
        problems.append(f"{len(rows) - i} extra line(s) from {rows[i]!r}")
    return out, problems


# --- the checks -------------------------------------------------------------------------------


def validate(fixture_arg, pdf_path, today):
    data, body, source = load_fixture(fixture_arg)
    memo = Memo(data, body, source, today)
    rep = Report()
    lu, size = memo.lu, memo.size

    doc = pymupdf.open(pdf_path)
    widgets = []
    for i, page in enumerate(doc):
        for w in page.widgets():
            widgets.append((i, w.field_name, w.field_type_string, pymupdf.Rect(w.rect), w.xref))
    clean = pymupdf.open(pdf_path)
    for page in clean:
        for w in list(page.widgets()):
            page.delete_widget(w)
    pages = [Page(i, p, memo) for i, p in enumerate(clean)]
    p1 = pages[0]

    # C01, C05, C06, C03
    for i, page in enumerate(doc):
        rep.expect("C01", abs(page.rect.width - 612) < 0.01 and abs(page.rect.height - 792) < 0.01,
                   f"page {i + 1} {page.rect.width:.2f} x {page.rect.height:.2f}")
    for pg in pages:
        bad_color = {f"#{g.color:06x}" for g in pg.glyphs if g.color != 0}
        bad_color |= {f"rule {d.get('color')}" for d in clean[pg.index].get_drawings()
                      if tuple(d.get("color") or (0, 0, 0)) != (0, 0, 0) or d.get("fill") is not None}
        rep.expect("C05", not bad_color, f"page {pg.index + 1} colors {sorted(bad_color)}")
        bad_font = {g.font for g in pg.glyphs if not g.font.startswith(("TeXGyreTermes", "LiberationMono"))}
        rep.expect("C06", not bad_font, f"page {pg.index + 1} fonts {sorted(bad_font)}")
        excluded = {id(g) for r in pg.banners + pg.cui for s in r.segs for g in s.glyphs}
        ends = [g.end for g in pg.glyphs if id(g) not in excluded]
        if ends:
            rep.expect("C03", max(ends) <= 540 + 0.01, f"page {pg.index + 1} max advance end {max(ends):.2f}")

    for pg in pages:
        bases = [r.base for r in pg.header + pg.flow] + [g.y for g in pg.table_glyphs]
        if bases:
            limit = 720 - DESCENDER * size
            rep.expect("C04", max(bases) <= limit + 0.01, f"page {pg.index + 1} lowest baseline {max(bases):.2f} (descenders reach {max(bases) + DESCENDER * size:.2f})")

    # Page 1 heading.
    flow1 = p1.flow
    os_rows = [r for r in flow1 if abs(r.base - memo.os) <= 1]
    symbol_rows = run_of(flow1, flow1.index(os_rows[0]), lu) if os_rows else []
    symbol_rows = [r for r in symbol_rows if r.left(420)]
    last_os = symbol_rows[-1].base if symbol_rows else memo.os
    subj_i = find_subject(flow1)

    # C07-C09 seal.
    imgs = clean[0].get_image_info()
    want_rect = [35.76, 28.71, 109.68, 102.63] if memo.seal == "dow" else [36.00, 28.95, 108.00, 100.95]
    rep.expect("C07", len(imgs) == 1, f"page 1 images {len(imgs)}")
    if imgs:
        got = list(imgs[0]["bbox"])
        rep.expect("C07", all(abs(a - b) <= RECT for a, b in zip(got, want_rect)), f"seal rect {fmt(got)} (want {fmt(want_rect)})")
    for pg in range(1, len(clean)):
        rep.expect("C07", not clean[pg].get_image_info(), f"page {pg + 1} has an image")
    if imgs:
        clip = pymupdf.Rect(20, 15, 125, 115)
        pix = clean[0].get_pixmap(dpi=600, clip=clip, alpha=False, annots=False)
        s = pix.samples
        n, w, h = pix.n, pix.width, pix.height
        xs, ys = [], []
        for y in range(h):
            row = s[y * pix.stride : y * pix.stride + w * n]
            for x in range(w):
                if min(row[x * n : x * n + 3]) < 128:
                    xs.append(x)
                    ys.append(y)
        k = 72 / 600
        ink = [clip.x0 + min(xs) * k, clip.y0 + min(ys) * k, clip.x0 + (max(xs) + 1) * k, clip.y0 + (max(ys) + 1) * k]
        rep.expect("C08", all(abs(a - b) <= 0.5 for a, b in zip(ink, [36.00, 28.95, 108.00, 100.95])),
                   f"ink {fmt(ink)} (want [36.00, 28.95, 108.00, 100.95])")
        pix = clean[0].get_pixmap(dpi=300, clip=pymupdf.Rect(want_rect), alpha=False, annots=False)
        s, n = pix.samples, pix.n
        spread = max(max(abs(s[i] - s[i + 1]), abs(s[i + 1] - s[i + 2]), abs(s[i] - s[i + 2])) for i in range(0, len(s), n))
        darkest = min(s)
        rep.expect("C09", spread <= 2 and darkest <= 20, f"channel spread {spread}, darkest {darkest}")

    # C10, C11 letterhead.
    lh = sorted(p1.letterhead, key=lambda r: r.base)
    for k, want_text in enumerate(memo.letterhead):
        cid = "C10" if k == 0 else "C11"
        want_base = LETTERHEAD_BASELINES[k] if k < 5 else LETTERHEAD_BASELINES[-1] + 9.20 * (k - 4)
        row = next((r for r in lh if abs(r.base - want_base) <= 1), None)
        if not rep.expect(cid, row is not None, f"line {k + 1} missing at {want_base:.2f}"):
            continue
        seg = row.segs[0]
        rep.expect(cid, len(row.segs) == 1 and seg.text == norm(want_text).upper(), f"line {k + 1} text {row.text!r}")
        rep.expect(cid, seg.bold and seg.sizes == {11.0 if k == 0 else 8.0}, f"line {k + 1} bold {seg.bold} sizes {seg.sizes}")
        rep.near(cid, f"line {k + 1} baseline", seg.base, want_base)
        rep.near(cid, f"line {k + 1} center", (seg.x0 + seg.end) / 2, 306.0)
        rep.expect(cid, seg.end - seg.x0 <= 360 + 0.01, f"line {k + 1} width {seg.end - seg.x0:.2f}")
        if seg.end - seg.x0 < 359:
            space = 0.25 * (11.0 if k == 0 else 8.0)
            for t, (before, after) in enumerate(zip(seg.tokens, seg.tokens[1:])):
                zip_gap = re.fullmatch(r"[A-Z]{2}", before) and re.fullmatch(r"\d{5}(-\d{4})?", after)
                rep.near(cid, f"line {k + 1} gap before {after!r}", seg.gaps[t], 2 * space if zip_gap else space, GAP)

    # C12 continuation pages are plain.
    for pg in pages[1:]:
        rep.expect("C12", not clean[pg.index].get_image_info(), f"page {pg.index + 1} has an image")
        rep.expect("C12", not pg.letterhead and pg.suspense is None, f"page {pg.index + 1} has letterhead or suspense")
        tops = [r for r in pg.header + pg.flow if r.base < 79.94 - 8]
        rep.expect("C12", not tops, f"page {pg.index + 1} text above 71.94: {tops[:2]}")
        dated = [r for r in pg.header if memo.date and memo.date in r.text]
        rep.expect("C12", not dated, f"page {pg.index + 1} header has the date")

    # C13, C14 office symbol.
    if memo.office_symbol:
        if rep.expect("C13", symbol_rows, "no office symbol line at OS"):
            seg = symbol_rows[0].left(420)[0]
            rep.near("C13", "baseline", seg.base, memo.os)
            rep.near("C13", "x0", seg.x0, 72.0)
            text = " ".join(r.left(420)[0].text for r in symbol_rows)
            head = memo.office_symbol + (f" ({memo.record_number})" if memo.record_number else "")
            want = head + (f" {memo.office_symbol_info}" if memo.office_symbol_info else "")
            rep.expect("C13", text == want, f"text {text!r} (want {want!r})")
            first = symbol_rows[0].left(420)[0].text
            rep.expect("C13", first in (head, want), f"first line {first!r} (want {head!r}, or the whole line)")
            for r in symbol_rows[1:]:
                rep.near("C13", "turnover x0", r.x0, 72.0)
            for r in symbol_rows:
                for g in r.left(420)[0].gaps:
                    rep.near("C13", "word gap", g, memo.space, GAP)
            if not memo.record_number:
                rep.expect("C14", "(" not in text, f"office symbol reads {text!r}")
    elif symbol_rows:
        rep.expect("C13", False, f"office symbol line present: {symbol_rows[0]!r}")

    # C15, C16 date.
    date_widgets = [w for w in widgets if w[1] == "Date"]
    os_right = [s for r in os_rows for s in r.right(420)]
    if memo.date:
        if rep.expect("C15", len(os_right) == 1, f"date segments on the OS line: {[s.text for s in os_right]}"):
            seg = os_right[0]
            rep.expect("C15", seg.text == memo.date, f"date {seg.text!r} (want {memo.date!r})")
            rep.near("C15", "advance end", seg.end, 540.0)
            rep.near("C15", "baseline", seg.base, memo.os)
        rep.expect("C16", not date_widgets, "Date widget present with a printed date")
    else:
        rep.expect("C15", not os_right, f"text in the date slot: {[s.text for s in os_right]}")
        want = [540 - 8.5 * size, memo.os - 1.06 * size, 540, memo.os + 0.44 * size]
        if rep.expect("C16", len(date_widgets) == 1, f"{len(date_widgets)} Date widgets"):
            pg, _, kind, rect, xref = date_widgets[0]
            got = list(rect)
            rep.expect("C16", pg == 0 and all(abs(a - b) <= RECT for a, b in zip(got, want)), f"rect {fmt(got)} (want {fmt(want)})")
            rep.expect("C16", kind == "Text", f"type {kind}")
            q = doc.xref_get_key(xref, "Q")
            rep.expect("C16", q[1] == "2", f"quadding {q[1]} (want 2, right)")

    # C17 suspense.
    if memo.suspense:
        s = p1.suspense
        if rep.expect("C17", s is not None, "no suspense line"):
            seg = s.segs[0]
            rep.expect("C17", len(s.segs) == 1 and seg.text == f"S: {memo.suspense}", f"text {s.text!r}")
            rep.expect("C17", seg.bold, "not bold")
            rep.near("C17", "advance end", seg.end, 540.0)
            rep.near("C17", "baseline", seg.base, memo.os - 2 * lu)
        for pg in pages[1:]:
            rep.expect("C17", not any(r.text.startswith("S:") for r in pg.header + pg.flow[:1]), f"suspense on page {pg.index + 1}")
    else:
        rep.expect("C17", p1.suspense is None, "suspense printed without a suspense date") if p1.suspense else None

    # Addresses.
    if subj_i is None:
        rep.expect("C26", False, "no SUBJECT line")
        return rep, doc
    address_rows = [r for r in flow1[: subj_i] if r.base > last_os + 0.5]
    for r in address_rows:
        for seg in r.left(350):
            toks = seg.tokens
            for k, g in enumerate(seg.gaps):
                want = word_gap(toks[k], toks[k + 1], memo.space)
                if abs(g - want) > GAP:
                    rep.expect("C19", False, f"word gap {g:.2f} between {toks[k]!r} and {toks[k + 1]!r} (want {want:.2f})")
    if address_rows:
        rep.steps("C18", "first address line", last_os, address_rows[0].base, 3, lu)
    upper = lambda k, s: s.upper()
    if not memo.memo_thru:
        if not memo.memo_for:
            rep.expect("C20", len(address_rows) == 1 and address_rows[0].text == "MEMORANDUM FOR RECORD",
                       f"address block {[r.text for r in address_rows]}")
        elif len(memo.memo_for) == 1:
            cid = "C22" if norm(memo.memo_for[0]).upper() == "SEE DISTRIBUTION" else "C19"
            _, problems = match_lines(address_rows, ["MEMORANDUM FOR " + memo.memo_for[0]], 72.0, 72.0, transform=upper)
            rep.expect(cid, not problems, "; ".join(problems) or "single address")
            if cid == "C22":
                rep.expect("C22", len(address_rows) == 1, f"{len(address_rows)} lines")
            if address_rows and len(address_rows[0].segs[0].gaps) >= 2:
                rep.near("C19", "gap after FOR", address_rows[0].segs[0].gaps[1], memo.space, GAP)
            for a, b in zip(address_rows, address_rows[1:]):
                rep.steps(cid, "address line", a.base, b.base, 1, lu)
        else:
            rows = address_rows
            rep.expect("C21", rows and rows[0].text == "MEMORANDUM FOR", f"lead {rows[0].text if rows else None!r}")
            _, problems = match_lines(rows[1:], memo.memo_for, 72.0, 90.0, transform=upper)
            rep.expect("C21", not problems, "; ".join(problems) or "addresses")
            for a, b in zip(rows, rows[1:]):
                rep.steps("C21", "address line", a.base, b.base, 1, lu)
    else:
        for_i = next((k for k, r in enumerate(address_rows) if k > 0 and re.match(r"^FOR( |$)", r.text)), len(address_rows))
        thru_block = address_rows[:for_i]
        for_rows = address_rows[for_i:]
        cid = "C23" if len(memo.memo_thru) == 1 else "C24"
        if len(memo.memo_thru) == 1:
            groups, problems = match_lines(thru_block, ["MEMORANDUM THRU " + memo.memo_thru[0]], 72.0, 72.0, transform=upper)
            thru_groups = [rows for _, rows in groups]
            for a, b in zip(thru_block, thru_block[1:]):
                rep.steps(cid, "THRU line", a.base, b.base, 1, lu)
        else:
            rep.expect(cid, thru_block and thru_block[0].text == "MEMORANDUM THRU", f"lead {thru_block[0].text if thru_block else None!r}")
            groups, problems = match_lines(thru_block[1:], memo.memo_thru, 72.0, 90.0, transform=upper)
            thru_groups = [rows for _, rows in groups]
            # One blank line between THRU addresses, none inside one or after the lead.
            if thru_groups and thru_groups[0]:
                rep.steps(cid, "first THRU address", thru_block[0].base, thru_groups[0][0].base, 1, lu)
            for rows in thru_groups:
                for a, b in zip(rows, rows[1:]):
                    rep.steps(cid, "THRU turnover", a.base, b.base, 1, lu)
            for a, b in zip(thru_groups, thru_groups[1:]):
                if a and b:
                    rep.steps(cid, "next THRU address", a[-1].base, b[0].base, 2, lu)
        rep.expect(cid, not problems, "; ".join(problems) or "THRU addresses")
        for r in thru_block:
            rep.expect(cid, max(s.end for s in r.segs) <= 348 + 0.01, f"THRU line ends at {max(s.end for s in r.segs):.2f}")
        if memo.memo_for and thru_block and for_rows:
            rep.steps(cid, "FOR after the last THRU line", thru_block[-1].base, for_rows[0].base, 2, lu)
            if len(memo.memo_for) == 1:
                _, problems = match_lines(for_rows, ["FOR " + memo.memo_for[0]], 72.0, 72.0, transform=upper)
            else:
                rep.expect(cid, for_rows[0].text == "FOR", f"FOR lead {for_rows[0].text!r}")
                _, problems = match_lines(for_rows[1:], memo.memo_for, 72.0, 90.0, transform=upper)
                rep.expect("C21", not problems, "; ".join(problems) or "FOR addresses")
            rep.expect(cid, not problems, "; ".join(problems) or "FOR addresses")
            for a, b in zip(for_rows, for_rows[1:]):
                rep.steps(cid, "FOR line", a.base, b.base, 1, lu)
        # C25 THRU widgets.
        for k, rows in enumerate(thru_groups, start=1):
            if not rows:
                continue
            b1, bn = rows[0].base, rows[-1].base
            top, bottom = b1 - (memo.cap + 3), bn + (0.488 * size - 3) + lu - 2
            for name, x0, x1 in ((f"Thru_{k}_Signature", 450, 540), (f"Thru_{k}_Comment", 354, 444)):
                found = [w for w in widgets if w[1] == name]
                if rep.expect("C25", len(found) == 1, f"{name}: {len(found)} widgets"):
                    got = list(found[0][3])
                    want = [x0, top, x1, bottom]
                    rep.expect("C25", all(abs(a - b) <= RECT for a, b in zip(got, want)), f"{name} {fmt(got)} (want {fmt(want)})")

    # C26 subject.
    subject_rows = run_of(flow1, subj_i, lu)
    last_address = address_rows[-1].base if address_rows else last_os
    rep.steps("C26", "SUBJECT below the address", last_address, subject_rows[0].base, 2, lu)
    text = norm(" ".join(r.text for r in subject_rows))
    want_subject = norm(f"SUBJECT: {memo.subject}")
    rep.expect("C26", text == want_subject, f"subject {text!r} (want {want_subject!r})")
    for r in subject_rows:
        rep.near("C26", "x0", r.x0, 72.0)
        for g in r.segs[0].gaps:
            rep.near("C26", "word gap", g, memo.space, GAP)

    # The body and closing, page by page.
    name_row = auth_row = None
    auth_rows = []
    closing_page = None
    if memo.signature:
        want_name = norm(memo.signature[0]).upper()
        for pg in pages:
            for r in pg.flow:
                for s in r.segs:
                    if abs(s.x0 - 306) <= 1 and want_name.startswith(s.text) and len(s.text) >= min(4, len(want_name)):
                        name_row = r
                        break
                if name_row:
                    break
            if name_row:
                closing_page = pg.index
                break
    if memo.authority_text:
        search = [pages[closing_page]] if closing_page is not None else pages
        for pg in search:
            for r in pg.flow:
                t = norm(r.text)
                if t == memo.authority_text or (len(t) >= min(8, len(memo.authority_text)) and memo.authority_text.startswith(t)) \
                        or t.upper().startswith(memo.authority_text.rstrip(":")):
                    if name_row is None or (r.base < name_row.base):
                        auth_row = r
            if auth_row:
                closing_page = pg.index
        # An authority line wider than the text turns over at the margin.
        if auth_row:
            flow = pages[closing_page].flow
            auth_rows = [auth_row]
            for r in flow[flow.index(auth_row) + 1:]:
                joined = norm(" ".join(a.text for a in auth_rows))
                if (len(joined) >= len(memo.authority_text) or abs(r.x0 - 72) > POS
                        or abs(r.base - auth_rows[-1].base - lu) > LU_TOL * lu or r is name_row):
                    break
                auth_rows.append(r)
            auth_row = auth_rows[-1]
    closing_start = auth_rows[0].base if auth_rows else name_row.base if name_row else None

    body = []  # (page, rows and tables in order)
    for pg in pages:
        start = subject_rows[-1].base + 0.5 if pg.index == 0 else 0
        items = [("row", r.base, r) for r in pg.flow if r.base > start]
        if closing_page is not None and pg.index > closing_page:
            items = []
        elif closing_page is not None and pg.index == closing_page:
            items = [it for it in items if it[1] < closing_start - 0.5]
        if closing_page is None or pg.index <= closing_page:
            items += [("table", t[1], t) for t in pg.tables + pg.rules if t[1] > start]
        items.sort(key=lambda it: it[1])
        body.append(items)

    # C27 body start.
    first_items = body[0]
    if first_items:
        it = first_items[0]
        b = it[1] + memo.cap if it[0] == "table" else it[1]
        rep.steps("C27", "first body line below SUBJECT", subject_rows[-1].base, b, 3, lu)

    def opens_quote(row):
        return any(norm(row.text).startswith(strip_md(q)[:20]) for q in memo.quotes)

    # Paragraphs.
    paragraphs = []  # each: list of rows (and possibly ("table",...))
    pitches = []
    for pg_items in body:
        prev = None
        for kind, y, obj in pg_items:
            if kind == "table":
                if prev is not None:
                    prev_bottom = prev[2].base if prev[0] == "row" else prev[2][3]
                    want = 2 * lu - memo.cap if prev[0] == "row" else 2 * lu - memo.cap
                    rep.expect("C28", abs((obj[1] - prev_bottom) - want) <= LU_TOL * lu,
                               f"table top {obj[1]:.2f} is {obj[1] - prev_bottom:.2f} below the text (want {want:.2f})")
                paragraphs.append([("table", obj)])
                prev = (kind, y, obj)
                continue
            if prev is None:
                cont = bool(paragraphs) and paragraphs[-1][-1][0] == "row" and not starts_paragraph(obj) and not opens_quote(obj)
                if cont:
                    paragraphs[-1].append(("row", obj))
                else:
                    paragraphs.append([("row", obj)])
            elif prev[0] == "table":
                rep.steps("C28", "text below a table", prev[2][3], obj.base, 2, lu)
                paragraphs.append([("row", obj)])
            else:
                n = (obj.base - prev[2].base) / lu
                if abs(n - 1) <= LU_TOL:
                    pitches.append(obj.base - prev[2].base)
                    paragraphs[-1].append(("row", obj))
                    if starts_paragraph(obj) and obj.x0 > 72 + POS:
                        rep.expect("C28", False, f"{obj!r} follows the line above with no blank line")
                elif abs(n - 2) <= LU_TOL:
                    paragraphs.append([("row", obj)])
                else:
                    rep.expect("C28", False, f"{n:.3f} LU between {prev[2]!r} and {obj!r}")
                    paragraphs.append([("row", obj)])
            prev = (kind, y, obj)
    if any(paragraphs):
        rep.expect("C28", True, "paragraph pitches")

    # C02 measured LU.
    for pg in pages:
        for a, b in zip(pg.header, pg.header[1:]):
            pitches.append(b.base - a.base)
    for a, b in zip(subject_rows, subject_rows[1:]):
        pitches.append(b.base - a.base)
    if pitches:
        measured = statistics.median(pitches)
        rep.near("C02", "LU", measured, 1.15 * size, 0.02)
        spread = max(pitches) - min(pitches)
        rep.expect("C02", spread <= 0.02, f"pitch spread {spread:.3f}")

    text_paragraphs = [[r for k, r in p if k == "row"] for p in paragraphs if p[0][0] == "row"]
    numbered = len(memo.top_paragraphs) + (1 if memo.references else 0) > 1

    # C29, C30, C31 designators and turnovers.
    x_by_level = {1: 72.0, 2: 90.0, 3: 108.0, 4: 108.0}
    for para in text_paragraphs:
        first = para[0]
        seg = first.segs[0]
        level = designator(seg)
        if level and (numbered or level > 1):
            rep.near("C29", f"{seg.tokens[0]} x0", seg.x0, x_by_level[level])
            rep.near("C30", f"gap after {seg.tokens[0]}", seg.gaps[0], 2 * memo.space, GAP)
        elif numbered and first.x0 <= 72 + POS and not opens_quote(first):
            rep.expect("C29", False, f"numbered memo paragraph without a designator: {first!r}")
        for r in para[1:]:
            rep.near("C31", f"turnover {r!r} x0", r.x0, 72.0)
    if numbered:
        tops = [p[0].segs[0].tokens[0] for p in text_paragraphs if designator(p[0].segs[0]) == 1]
        want = [f"{i + 1}." for i in range(len(memo.top_paragraphs) + (1 if memo.references else 0))]
        rep.expect("C29", tops == want, f"paragraph numbers {tops} (want {want})")

    # C32 one-paragraph memo.
    if not numbered and text_paragraphs:
        first = text_paragraphs[0][0]
        rep.expect("C32", designator(first.segs[0]) is None, f"first line has a designator: {first!r}")
        rep.near("C32", "first line x0", first.x0, 72.0)
        subs = [p[0] for p in text_paragraphs[1:] if designator(p[0].segs[0]) == 2]
        for r in subs:
            rep.near("C32", f"{r.segs[0].tokens[0]} x0", r.x0, 90.0)

    # C33 sentence gaps, in the text and in table cells.
    def sentence_gaps(toks, gaps, before, skip_first=False, max_gap=None):
        for k, g in enumerate(gaps):
            if (k == 0 and skip_first) or (max_gap and g > max_gap):
                continue
            wide = ends_sentence(toks[k], toks[k + 1], toks[k - 1] if k else before)
            want = 2 * memo.space if wide else word_gap(toks[k], toks[k + 1], memo.space)
            ok = abs(g - want) <= GAP
            if wide or toks[k].endswith((".", "?", ".,", ".)", '."', ".\u201d", "?\u201d")) or not ok:
                rep.expect("C33", ok, f"{g:.2f} between {toks[k]!r} and {toks[k + 1]!r} (want {want:.2f})")

    for para in text_paragraphs:
        before = ""
        for j, r in enumerate(para):
            seg = r.segs[0]
            if all(g.font.startswith("LiberationMono") for g in seg.glyphs):
                continue
            # Levels 5 and 6 are an underlined number or letter.
            deep = seg.x0 > 140 and re.fullmatch(r"\d+|[a-z]", seg.tokens[0])
            sentence_gaps(seg.tokens, seg.gaps, before, skip_first=j == 0 and (designator(seg) is not None or deep))
            before = seg.tokens[-1]
    for pg in pages:
        for r in rows_of(pg.table_glyphs, pg.index) if pg.table_glyphs else []:
            for seg in r.segs:
                sentence_gaps(seg.tokens, seg.gaps, "", max_gap=9)

    # C34, C35 references.
    para_text = [norm(" ".join(r.text for r in p)) for p in text_paragraphs]
    if len(memo.references) >= 2 and text_paragraphs:
        rep.expect("C34", para_text[0] == "1. References.", f"first paragraph {para_text[0]!r}")
        rep.near("C34", "gap after 1.", text_paragraphs[0][0].segs[0].gaps[0], 2 * memo.space, GAP)
        for k, ref in enumerate(memo.references, start=1):
            if k >= len(text_paragraphs):
                rep.expect("C34", False, f"reference {k} missing")
                break
            para = text_paragraphs[k]
            want = f"{chr(96 + k)}. {norm(strip_md(ref))}"
            rep.expect("C34", para_text[k] == want, f"reference {k} reads {para_text[k]!r} (want {want!r})")
            rep.near("C34", f"reference {k} x0", para[0].x0, 90.0)
        nxt = len(memo.references) + 1
        if nxt < len(text_paragraphs):
            rep.expect("C34", text_paragraphs[nxt][0].segs[0].tokens[0] == "2.", f"next paragraph {para_text[nxt][:20]!r}")
    if len(memo.references) == 1 and text_paragraphs:
        want = f"1. Reference. {norm(strip_md(memo.references[0]))}"
        rep.expect("C35", para_text[0] == want, f"first paragraph {para_text[0]!r} (want {want!r})")
        seg = text_paragraphs[0][0].segs[0]
        rep.near("C35", "gap after 1.", seg.gaps[0], 2 * memo.space, GAP)
        rep.near("C35", "gap after Reference.", seg.gaps[1], 2 * memo.space, GAP)

    # C36 table.
    if memo.has_table:
        tables = [t for pg in pages for t in pg.tables]
        rep.expect("C36", tables, "no table rules")
        for t in tables:
            half = max((d.get("width") or 0) for d in t[4]) / 2
            rep.expect("C36", t[0] - half >= 72 - 0.01 and t[2] + half <= 540 + 0.01,
                       f"table rule ink x {t[0] - half:.2f} to {t[2] + half:.2f}")
            for d in t[4]:
                rep.expect("C36", d.get("fill") is None, f"filled path at {fmt(list(d['rect']))}")
                if d.get("color") is not None:
                    rep.expect("C36", abs((d.get("width") or 0) - 0.5) < 0.01, f"stroke width {d.get('width')}")
                    rep.expect("C36", tuple(d["color"]) == (0, 0, 0), f"stroke color {d['color']}")
        # A Markdown table's first row is its header, and only the header is bold.
        for pg in pages:
            for t in pg.tables:
                rules = sorted({round(it[1].y, 2) for d in t[4] for it in d["items"]
                                if it[0] == "l" and abs(it[1].y - it[2].y) < 0.01})
                if len(rules) < 3:
                    continue
                band = lambda lo, hi: [g for g in pg.table_glyphs if t[0] <= g.x <= t[2] and lo < g.y < hi]
                head, row = band(rules[0], rules[1]), band(rules[1], rules[2])
                rep.expect("C36", head and all("Bold" in g.font for g in head),
                           f"page {pg.index + 1} table header fonts {sorted({g.font for g in head})}")
                rep.expect("C36", row and not all("Bold" in g.font for g in row),
                           f"page {pg.index + 1} table first body row is all bold")
        # A row never splits across pages: each page's frame repeats the
        # header, and the frames hold the source's body rows once each.
        source_rows = sum(m.group(0).strip().count("\n") - 1
                          for m in re.finditer(r"(?:^\|.*\|[ \t]*(?:\n|$))+", memo.body, re.M))
        printed = 0
        for pg in pages:
            for t in pg.tables:
                rules = {round(it[1].y, 2) for d in t[4] for it in d["items"]
                         if it[0] == "l" and abs(it[1].y - it[2].y) < 0.01}
                printed += max(len(rules) - 2, 0)
        rep.expect("C36", printed == source_rows, f"{printed} table rows printed for the source's {source_rows}")
    for pg in pages:
        if not memo.has_table and pg.tables:
            rep.expect("C36", False, f"page {pg.index + 1} has drawings {fmt(pg.tables[0][:4])}")

    # The last body line above the closing.
    last_body = last_item = None
    if closing_page is not None and body[closing_page]:
        last_item = body[closing_page][-1]
        last_body = last_item[2].base if last_item[0] == "row" else last_item[2][3]

    # C37 authority line.
    if memo.authority_text:
        if rep.expect("C37", auth_row is not None, "no authority line"):
            text = norm(" ".join(r.text for r in auth_rows))
            rep.expect("C37", text == memo.authority_text, f"text {text!r} (want {memo.authority_text!r})")
            for r in auth_rows:
                rep.near("C37", "x0", r.x0, 72.0)
            rep.steps("C37", "below the text", last_body, auth_rows[0].base, 2, lu)
    elif auth_row:
        rep.expect("C37", False, f"unexpected authority line {auth_row!r}")

    # C38-C40 signature block.
    sig_rows = []
    if memo.signature:
        if rep.expect("C38", name_row is not None, "no signature name"):
            name = name_row.right()[0]
            rep.near("C38", "x0", name.x0, 306.0)
            rep.expect("C38", name.text == norm(memo.signature[0]).upper() or norm(memo.signature[0]).upper().startswith(name.text),
                       f"name {name.text!r}")
            if auth_row:
                rep.steps("C38", "below the authority line", auth_row.base, name_row.base, 5, lu)
            else:
                rep.steps("C38", "below the text", last_body, name_row.base, 5, lu)
            flow = pages[closing_page].flow
            start = flow.index(name_row)
            sig_rows = [Row(name_row.page, name_row.right())]
            for r in flow[start + 1 :]:
                right = r.right()
                if right and abs((r.base - sig_rows[-1].base) / lu - 1) <= LU_TOL:
                    sig_rows.append(Row(r.page, right))
                else:
                    break
            _, problems = match_lines(sig_rows, memo.signature, 306.0, 324.0,
                                      transform=lambda k, s: s.upper() if k == 0 else s)
            rep.expect("C39", not problems, "; ".join(problems) or "signature lines")
            for a, b in zip(sig_rows, sig_rows[1:]):
                rep.steps("C39", "signature line", a.base, b.base, 1, lu)
            for r in sig_rows:
                rep.expect("C39", r.segs[-1].end <= 540 + 0.01, f"signature line ends at {r.segs[-1].end:.2f}")
    sig_widgets = [w for w in widgets if w[1] == "Signature"]
    if name_row is not None and sig_widgets:
        n = name_row.base
        want = [306.0, n - memo.cap - 3 - 2.5 * size, 506.0, n - memo.cap - 3]
        got = list(sig_widgets[0][3])
        rep.expect("C40", sig_widgets[0][0] == closing_page and all(abs(a - b) <= RECT for a, b in zip(got, want)),
                   f"rect {fmt(got)} on page {sig_widgets[0][0] + 1} (want {fmt(want)})")
    elif memo.signature:
        rep.expect("C40", False, "no Signature widget")

    # C41, C42 enclosures.
    header, items = memo.enclosure_listing()
    encl_rows = []
    if name_row is not None:
        flow = pages[closing_page].flow
        for r in flow[flow.index(name_row) :]:
            want_base = encl_rows[-1].base + lu if encl_rows else name_row.base
            left = r.left()
            if abs(r.base - want_base) > LU_TOL * lu or not left:
                break
            encl_rows.append(Row(r.page, left))
    if header is None:
        rep.expect("C41", not encl_rows, f"unexpected enclosure lines {encl_rows[:2]}") if encl_rows else None
    else:
        if rep.expect("C41", encl_rows, "no enclosure listing"):
            rep.expect("C41", encl_rows[0].text == header, f"header {encl_rows[0].text!r} (want {header!r})")
            rep.near("C41", "x0", encl_rows[0].x0, 72.0)
            rep.near("C41", "baseline vs name", encl_rows[0].base, name_row.base)
            rows = encl_rows[1:]
            for a, b in zip(encl_rows, encl_rows[1:]):
                rep.steps("C42", "enclosure line", a.base, b.base, 1, lu)
            for r in encl_rows:
                rep.expect("C42", r.segs[-1].end <= 288 + 0.01, f"enclosure line ends at {r.segs[-1].end:.2f}")
            i = 0
            for label, text in items:
                if i >= len(rows):
                    rep.expect("C42", False, f"item {label} missing")
                    break
                first = rows[i]
                seg = first.segs[0]
                if label is None:
                    want_x, text_x = 72.0, 72.0
                    got = first.text
                else:
                    rep.expect("C42", seg.tokens[0] == label, f"label {seg.tokens[0]!r} (want {label!r})")
                    rep.near("C42", f"{label} x0", seg.x0, 72.0)
                    rep.near("C42", f"gap after {label}", seg.gaps[0] if seg.gaps else None, 2 * memo.space, GAP)
                    text_x = seg.after(1) if len(seg.words) > 1 else None
                    got = " ".join(seg.tokens[1:])
                i += 1
                while i < len(rows) and len(norm(got)) < len(norm(strip_md(text))):
                    rep.near("C42", f"item {label} turnover x0", rows[i].x0, text_x if text_x else 72.0)
                    got = join(got, rows[i].text)
                    i += 1
                rep.expect("C42", norm(got) == norm(strip_md(text)), f"item {label} reads {norm(got)!r}")
            rep.expect("C42", i == len(rows), f"{len(rows) - i} extra enclosure lines")

    # C43, C44 distribution and copies.
    listing_rows = []
    if closing_page is not None:
        after = max([r.base for r in sig_rows + encl_rows] or [closing_start or 0])
        for pg in pages[closing_page:]:
            for r in pg.flow:
                if pg.index == closing_page and r.base <= after + 0.5:
                    continue
                listing_rows.append(r)
    last_closing = (closing_page, max([r.base for r in sig_rows + encl_rows] or [0]))
    li = 0

    def listing(cid, label, entries):
        nonlocal li, last_closing
        if not entries:
            found = [r for r in listing_rows if r.text.startswith(label.split()[0])]
            rep.expect(cid, not found, f"unexpected {label} {found[:1]}") if found else None
            return
        if not rep.expect(cid, li < len(listing_rows), f"no {label} line"):
            return
        lab = listing_rows[li]
        rep.near(cid, f"{label} x0", lab.x0, 72.0)
        # The label sits on the second line below the line above it, on its page.
        if rep.expect(cid, lab.page == last_closing[0], f"{label} on page {lab.page + 1}, the line above on page {last_closing[0] + 1}"):
            rep.steps(cid, f"{label} below the closing", last_closing[1], lab.base, 2, lu)
        li += 1
        see_next = label == "DISTRIBUTION:" and lab.text == "DISTRIBUTION: (see next page)"
        see_row = lab
        if see_next:
            nxt = listing_rows[li] if li < len(listing_rows) else None
            if rep.expect(cid, nxt is not None and nxt.text == label and nxt.page == lab.page + 1,
                          f"no {label} at the top of page {lab.page + 2}"):
                rep.near(cid, f"{label} x0 on page {nxt.page + 1}", nxt.x0, 72.0)
                hdr = pages[nxt.page].header
                if hdr:
                    rep.steps(cid, f"{label} below the header", hdr[-1].base, nxt.base, 3, lu)
                lab = nxt
                li += 1
        else:
            rep.expect(cid, lab.text == label, f"label {lab.text!r} (want {label!r})")
        got_rows = []
        while li < len(listing_rows) and not listing_rows[li].text.startswith(("DISTRIBUTION:", "CF:")):
            got_rows.append(listing_rows[li])
            li += 1
        groups, problems = match_lines(got_rows, entries, 72.0, 72.0, transform=upper)
        rep.expect(cid, not problems, "; ".join(problems) or f"{label} entries")
        if see_next and groups and groups[0][1]:
            limit = 720.0 - DESCENDER * size
            if see_row.page == 0 and p1.cui:
                limit = min(limit, p1.cui[0].base - 0.662 * 10 - 0.488 * size)
            first_lines = len(groups[0][1])
            # A lone entry keeps the CF label and first CF entry with it.
            if len(entries) == 1 and memo.cf:
                k = next((j for j in range(li, len(listing_rows)) if listing_rows[j].text.startswith("CF:")), None)
                if k is not None:
                    cf_groups, _ = match_lines(listing_rows[k + 1:], memo.cf, 72.0, 72.0, transform=upper)
                    first_lines += 2 + (len(cf_groups[0][1]) if cf_groups and cf_groups[0][1] else 1)
            rep.expect(cid, see_row.base + first_lines * lu > limit - 0.01,
                       "(see next page) though the first entry fits below the label")
        seq = [lab] + got_rows
        for a, b in zip(seq, seq[1:]):
            if a.page == b.page:
                rep.steps(cid, f"{label} line", a.base, b.base, 1, lu)
            else:
                rep.expect(cid, a is not lab, f"{label} label ends page {a.page + 1}")
        if seq:
            last_closing = (seq[-1].page, seq[-1].base)

    listing("C43", "DISTRIBUTION:", memo.distribution)
    cf_label = "CF: (w/o encls)" if memo.cf_without and memo.enclosures else "CF:"
    listing("C44", cf_label, memo.cf)
    rep.expect("C44", li == len(listing_rows), f"text after the closing: {listing_rows[li:li + 2]}") if li < len(listing_rows) else None
    all_text = " ".join(r.text for pg in pages for r in pg.flow)
    if memo.cf:
        rep.expect("C44", "cc:" not in all_text.lower(), "a cc: line")

    # C45-C47 continuation pages.
    for pg in pages[1:]:
        hdr = pg.header
        if not rep.expect("C45", hdr, f"page {pg.index + 1} has no header"):
            continue
        subj = next((k for k, r in enumerate(hdr) if r.text.startswith("SUBJECT:")), None)
        sym = hdr[:subj] if subj is not None else hdr
        if memo.office_symbol:
            rep.near("C45", f"page {pg.index + 1} office symbol baseline", sym[0].base if sym else None, 72 + memo.cap)
            rep.near("C45", f"page {pg.index + 1} office symbol x0", sym[0].x0 if sym else None, 72.0)
            got = norm(" ".join(r.text for r in sym))
            rep.expect("C45", got == memo.office_symbol, f"page {pg.index + 1} office symbol {got!r} (want {memo.office_symbol!r})")
        if rep.expect("C45", subj is not None, f"page {pg.index + 1} has no SUBJECT"):
            srows = hdr[subj:]
            rep.expect("C45", [r.text for r in srows] == [r.text for r in subject_rows],
                       f"page {pg.index + 1} subject lines {[r.text for r in srows]}")
            seq = hdr
            for a, b in zip(seq, seq[1:]):
                rep.steps("C45", f"page {pg.index + 1} header line", a.base, b.base, 1, lu)
            for r in srows:
                rep.near("C45", "subject x0", r.x0, 72.0)
        first = [it for it in body[pg.index]] if pg.index < len(body) else []
        firsts = []
        if first:
            kind, y, obj = first[0]
            firsts.append(y + memo.cap if kind == "table" else y)
        elif pg.flow:
            firsts.append(pg.flow[0].base)
        if firsts:
            rep.steps("C46", f"page {pg.index + 1} text below the header", hdr[-1].base, firsts[0], 3, lu)
    for pg in pages:
        if pg.index == 0:
            rep.expect("C47", not pg.number, "page 1 is numbered") if pg.number else None
            continue
        if rep.expect("C47", len(pg.number) == 1, f"page {pg.index + 1}: {len(pg.number)} page numbers"):
            seg = pg.number[0].segs[0]
            rep.expect("C47", seg.text == str(pg.index + 1), f"page {pg.index + 1} number {seg.text!r}")
            rep.near("C47", f"page {pg.index + 1} number baseline", seg.base, 732.70)
            rep.near("C47", f"page {pg.index + 1} number center", (seg.x0 + seg.end) / 2, 306.0)
            rep.expect("C47", seg.sizes == {round(size, 2)}, f"page number size {seg.sizes}")

    # C48 page count.
    for pg in pages:
        has = pg.flow or pg.tables
        rep.expect("C48", has, f"page {pg.index + 1} has no body or closing text")
    if Path(fixture_arg).stem == "clp_example2":
        rep.expect("C48", len(pages) == 3, f"{len(pages)} pages (want 3)")

    # C49 widows and orphans; C50 the closing keeps two lines.
    for para in text_paragraphs:
        by_page = {}
        for r in para:
            by_page.setdefault(r.page, []).append(r)
        if len(by_page) > 1:
            rep.expect("C49", len(para) > 3, f"{len(para)}-line paragraph splits: {para[0]!r}")
            for p, rows in by_page.items():
                rep.expect("C49", len(rows) >= 2, f"page {p + 1} holds {len(rows)} line(s) of {para[0]!r}")
            pages_in = sorted(by_page)
            for a, b in zip(pages_in, pages_in[1:]):
                split = sentence_split(by_page[a][-1], by_page[b][0])
                if split:
                    rep.expect("C49", min(split) >= 2, f"sentence split {split[0]} | {split[1]} words across pages {a + 1}-{b + 1}")
    if len(pages) > 1 and text_paragraphs:
        rep.expect("C49", True, "page breaks")
    if last_item and last_item[0] == "table":
        t = last_item[2]
        rows = {round(g.y, 1) for g in pages[closing_page].table_glyphs
                if t[0] <= g.x <= t[2] and t[1] < g.y < t[3] and "Bold" not in g.font}
        rep.expect("C50", len(rows) >= 2, f"{len(rows)} table row(s) above the closing on page {closing_page + 1}")
    elif closing_page is not None and text_paragraphs:
        last_para = text_paragraphs[-1]
        above = [r for r in last_para if r.page == closing_page]
        ok = len(above) >= 2 or (len(last_para) == 1 and above)
        rep.expect("C50", ok, f"{len(above)} line(s) of the last paragraph above the closing on page {closing_page + 1}")

    # C51 hyphenation.
    flat = [r for pg in pages for r in pg.flow]
    source = memo.source
    for a, b in zip(flat, flat[1:]):
        for seg in a.segs:
            tok = seg.tokens[-1]
            if tok.endswith(("-", "‐")) and len(tok) > 1:
                nxt = next((s for s in b.segs if abs(s.x0 - seg.x0) < 250), b.segs[0]).tokens[0]
                rep.expect("C51", (tok + nxt) in source, f"{tok}|{nxt} is hyphenated")
    # AR 25-50 2-5c(3): no page ends in a divided word.
    for a, b in zip(pages, pages[1:]):
        if a.flow and b.flow:
            tok = a.flow[-1].segs[-1].tokens[-1]
            rep.expect("C51", not (tok.endswith(("-", "‐")) and len(tok) > 1), f"page {a.index + 1} ends on {tok!r}")
    rep.expect("C51", True, "hyphenation")

    # C52-C54 classification.
    if memo.banner:
        for pg in pages:
            tops = [r for r in pg.banners if r.base < 400]
            bottoms = [r for r in pg.banners if r.base > 400]
            for where, rows, base in (("top", tops, 35.11), ("bottom", bottoms, 765.00)):
                if not rep.expect("C52", len(rows) == 1, f"page {pg.index + 1} {where} banners {len(rows)}"):
                    continue
                seg = rows[0].segs[0]
                rep.expect("C52", rows[0].text == memo.banner, f"page {pg.index + 1} {where} {rows[0].text!r} (want {memo.banner!r})")
                rep.near("C52", f"page {pg.index + 1} {where} baseline", seg.base, base)
                rep.near("C52", f"page {pg.index + 1} {where} center", (seg.x0 + rows[0].segs[-1].end) / 2, 306.0)
                rep.expect("C52", seg.bold and seg.sizes == {12.0}, f"{where} bold {seg.bold} sizes {seg.sizes}")
                rep.expect("C52", all(g.color == 0 for s in rows[0].segs for g in s.glyphs), f"{where} not black")
        clip = pymupdf.Rect(150, 20, 462, 50)
        pix = clean[0].get_pixmap(dpi=600, clip=clip, alpha=False, annots=False)
        dark = []
        for y in range(pix.height):
            row = pix.samples[y * pix.stride : y * pix.stride + pix.width * pix.n]
            if min(row) < 128:
                dark.append(y)
        clusters = []
        for y in dark:
            if clusters and y == clusters[-1][1] + 1:
                clusters[-1][1] = y
            else:
                clusters.append([y, y])
        k = 72 / 600
        if rep.expect("C53", len(clusters) >= 2, f"{len(clusters)} ink bands between y 20 and 50"):
            banner_bottom = clip.y0 + (clusters[0][1] + 1) * k
            letter_top = clip.y0 + clusters[1][0] * k
            rep.expect("C53", banner_bottom < letter_top and banner_bottom < 38,
                       f"banner ink bottom {banner_bottom:.2f}, letterhead ink top {letter_top:.2f}")
    else:
        for pg in pages:
            rep.expect("C52", not pg.banners, f"page {pg.index + 1} has a banner") if pg.banners else None
    cui_lines = []
    if memo.classification.startswith("CUI"):
        for key, lab in (("controlled_by", "Controlled By: "), ("category", "CUI Category: "),
                         ("limited_dissemination", "LDC: "), ("poc", "POC: ")):
            v = memo.cui.get(key)
            if v:
                cui_lines.append(lab + (v.upper() if key == "limited_dissemination" else v))
    if cui_lines:
        rows = sorted(p1.cui, key=lambda r: r.base)
        rep.expect("C54", [r.text for r in rows] == cui_lines, f"lines {[r.text for r in rows]} (want {cui_lines})")
        if rows:
            rep.near("C54", "right edge", max(r.segs[-1].end for r in rows), 576.0)
            rep.near("C54", "last baseline", rows[-1].base, CUI_LAST_BASELINE)
            banner_top = 765.0 - 0.662 * 12
            rep.expect("C54", rows[-1].base + 0.22 * 10 < banner_top - 2,
                       f"descenders at {rows[-1].base + 2.2:.2f} meet the banner's cap top {banner_top:.2f}")
            rep.expect("C54", all(s.sizes == {10.0} for r in rows for s in r.segs), "not 10pt")
            body_bottom = max((r.base for r in p1.flow), default=0)
            rep.expect("C54", body_bottom < rows[0].base - 10, f"body at {body_bottom:.2f} meets the CUI block at {rows[0].base:.2f}")
        for pg in pages[1:]:
            rep.expect("C54", not pg.cui, f"CUI block on page {pg.index + 1}") if pg.cui else None
    elif p1.cui:
        rep.expect("C54", False, f"unexpected 10pt lines {p1.cui[:1]}")

    # C55 widgets.
    names = [w[1] for w in widgets]
    want = {"Signature"} | ({"Date"} if not memo.date else set())
    for k in range(1, len(memo.memo_thru) + 1):
        want |= {f"Thru_{k}_Signature", f"Thru_{k}_Comment"}
    rep.expect("C55", set(names) == want and len(names) == len(set(names)), f"widgets {sorted(names)} (want {sorted(want)})")
    rep.expect("C55", all(WIDGET_NAME.match(n) for n in names), f"names {names}")

    # C56 scaling.
    if size != 12:
        rep.near("C56", "office symbol baseline", symbol_rows[0].base if symbol_rows else None, 100.95 + 26.37 * size / 12)
        if date_widgets:
            r = date_widgets[0][3]
            rep.near("C56", "Date widget height", r.y1 - r.y0, 1.5 * size, RECT)
        for para in text_paragraphs:
            seg = para[0].segs[0]
            level = designator(seg)
            if level and (numbered or level > 1):
                rep.near("C56", f"gap after {seg.tokens[0]}", seg.gaps[0], 2 * memo.space if level <= 2 else 18.0, GAP)
        for pg in pages[1:]:
            rep.near("C56", "continuation office symbol", pg.header[0].base if pg.header else None, 72 + memo.cap)

    # C57 cardinality, C58 load warnings, C59 render warnings.
    warnings = render_warnings(fixture_arg, pdf_path, today)
    if warnings is None:
        rep.expect("C59", False, "render_fixture.mjs failed")
    else:
        quill_w = [w for w in warnings if w.startswith("quill warning:")]
        rep.expect("C58", not quill_w, "; ".join(quill_w) or "no quill warnings")
        other = [w for w in warnings if not w.startswith("quill warning:")]
        overflow = len(memo.memo_for) > 5 or len(memo.letterhead) > 5
        if overflow:
            want_w = []
            if len(memo.memo_for) > 5:
                want_w.append("main.addressing.memo_for")
            if len(memo.letterhead) > 5:
                want_w.append("main.letterhead.letterhead_title")
            got_w = sorted(re.sub(r"^.*?at (\S+):.*$", r"\1", w) for w in other if "validation::cardinality" in w)
            rep.expect("C57", got_w == sorted(want_w) and len(got_w) == len(other), f"warnings {other}")
            rows = address_rows[1:] if memo.memo_for else []
            got = norm(" ".join(r.text for r in rows))
            rep.expect("C57", got == norm(" ".join(memo.memo_for)).upper(), f"addresses {got!r}")
            rep.expect("C57", len(p1.letterhead) == len(memo.letterhead), f"{len(p1.letterhead)} letterhead lines")
        rep.expect("C59", overflow or not other, "; ".join(other) or "no warnings")

    return rep, doc


def capitalize(s):
    """AR 25-50 4-2c(1): a listed enclosure begins with a capital letter."""
    return re.sub(r"^([\W_]*)([^\W_])", lambda m: m.group(1) + m.group(2).upper(), s)


def strip_md(s):
    return re.sub(r"(\*\*|__|\*|_|`)", "", s)


def starts_paragraph(row):
    seg = row.segs[0]
    level = designator(seg)
    return bool(level) and abs(seg.x0 - {1: 72.0, 2: 90.0, 3: 108.0, 4: 126.0}[level]) <= POS


def sentence_split(before, after):
    """The words on each side of a sentence that spans a page break, or None
    when a sentence ends at the break."""
    bt, at = before.segs[0].tokens, after.segs[0].tokens
    if ends_sentence(bt[-1], at[0], bt[-2] if len(bt) > 1 else ""):
        return None
    tail = len(bt)
    for k in range(len(bt) - 1):
        if ends_sentence(bt[k], bt[k + 1], bt[k - 1] if k else ""):
            tail = len(bt) - 1 - k
    head = len(at)
    for k in range(len(at) - 1):
        if ends_sentence(at[k], at[k + 1], at[k - 1] if k else bt[-1]):
            head = k + 1
            break
    return tail, head


def render_warnings(fixture_arg, pdf_path, today):
    out_dir = Path(pdf_path).resolve().parent
    with tempfile.TemporaryDirectory(dir=out_dir) as tmp:
        args = [str(RENDERER)]
        if fixture_arg != "seed":
            args.append(str(Path(fixture_arg).resolve()))
        args += [os.path.join(tmp, "warnings.pdf"), today.isoformat()]
        res = node(args)
    if res.returncode:
        return None
    return [l for l in res.stderr.splitlines() if "warning" in l]


def main():
    args = sys.argv[1:]
    verbose = bool(args) and args[0] == "-v"
    args = args[1:] if verbose else args
    if len(args) not in (2, 3):
        sys.exit(__doc__)
    today = dt.date.fromisoformat(args[2]) if len(args) == 3 else dt.date(2026, 10, 13)
    rep, _ = validate(args[0], args[1], today)
    sys.exit(1 if rep.print(verbose) else 0)


if __name__ == "__main__":
    main()
