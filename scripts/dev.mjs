/**
 * The author's loop: serve the site, watch the collection, repack what changed.
 * The tree served is the one a deploy makes, so what is looked at here is what a
 * reviewer opens.
 *
 * **Reload is the whole of the refresh verb.** A repack mints a new
 * content-addressed manifest and moves the pointer, which the client fetches
 * `no-cache`, so F5 lands the new catalog. The published client carries no HMR
 * channel — that is studio's own dev server's, not a consumer's — so nothing
 * here signals the page.
 */

import { existsSync } from 'node:fs';
import { mkdir, readdir, rename, rm, stat } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { build } from '@quillmark/quiver/node';
import { SITE, SOURCE, buildSite } from './site.mjs';
import { serve } from './serve.mjs';

const PORT = Number(process.env.PORT ?? 4173);
const QUIVER = join(SITE, 'quiver');
/** Where a pack is assembled, and where the tree it replaces waits to be
 *  deleted. Outside the served tree, so a half-written generation is never
 *  reachable; under `node_modules`, which is already ignored. */
const NEXT = join(SOURCE, 'node_modules/.airmark/quiver-next');
const PREV = join(SOURCE, 'node_modules/.airmark/quiver-prev');
/** What is watched: the collection, and nothing the pack itself writes, so a
 *  repack never looks like a change. */
const WATCHED = [join(SOURCE, 'quills'), join(SOURCE, 'Quiver.yaml')];
/** A poll settles a burst of writes as a side effect: an editor's save is one
 *  signature change however many syscalls it took. */
const POLL_MS = 400;

/**
 * Pack into a staging tree, then move it into place: a generation becomes
 * visible in one rename rather than over the length of a pack. `build` clears
 * its output before writing it, so packing straight into the served tree leaves
 * a window where the pointer is missing or torn, and a client reading it there
 * reports a broken quiver for an edit that was fine.
 */
async function swapIn() {
	await mkdir(dirname(NEXT), { recursive: true });
	await build(SOURCE, NEXT);
	await rm(PREV, { recursive: true, force: true });
	if (existsSync(QUIVER)) await rename(QUIVER, PREV);
	await rename(NEXT, QUIVER);
	await rm(PREV, { recursive: true, force: true });
}

/**
 * The collection's shape as a string: every file's path, size and mtime.
 *
 * A poll rather than `fs.watch`, and the reason is measured: the recursive
 * watcher drops events on Linux. A `touch` fired one minute and was missed the
 * next, and a write-temp-then-rename — what `git checkout` and most editors do
 * on save — was missed outright. A loop an author cannot trust is worse than no
 * loop, since a stale page is indistinguishable from an edit that did nothing.
 * One scan of this collection is ~14ms across 99 entries, which is not a price
 * worth a dropped save.
 */
async function signature() {
	const parts = [];
	for (const target of WATCHED) {
		const info = await stat(target).catch(() => null);
		if (!info) continue;
		if (info.isFile()) {
			parts.push(`${target}:${info.size}:${info.mtimeMs}`);
			continue;
		}
		for (const name of (await readdir(target, { recursive: true })).sort()) {
			const path = join(target, name);
			const entry = await stat(path).catch(() => null);
			if (entry?.isFile()) parts.push(`${path}:${entry.size}:${entry.mtimeMs}`);
		}
	}
	return parts.join('\n');
}

const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

await buildSite();
await serve(SITE, PORT);
console.log(`studio: http://localhost:${PORT}/`);
console.log(`watching ${WATCHED.length} path(s) — save a quill, then reload the page`);

// Sequential by construction: the next poll is taken after the pack it triggered
// has landed, so two packs never race over the output directory `build` clears.
// A save arriving mid-pack changes the signature again and is caught next round.
let last = await signature();
for (;;) {
	await wait(POLL_MS);
	const now = await signature();
	if (now === last) continue;
	last = now;
	try {
		await swapIn();
		console.log(`repacked ${new Date().toTimeString().slice(0, 8)} — reload to see it`);
	} catch (err) {
		// `build` packs files and validates none of them, so a half-written
		// `Quill.yaml` packs and the client reports it against that quill alone, with
		// the line and a hint — which is what an author wants to read. A throw here is
		// a tree-level problem instead (an unreadable `Quiver.yaml`, a layout the scan
		// refuses), and never reaches the swap, so the last good generation stays
		// served and the failure is a log line.
		console.error(`pack failed: ${err.message}`);
	}
}
