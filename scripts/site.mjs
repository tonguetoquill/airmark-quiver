/**
 * Lay a servable site out of the studio client and this quiver: the client at the
 * root, the quiver packed beside it under `quiver/`, which is where the client
 * looks (it resolves its quiver off `document.baseURI`). One door, so what a
 * deploy serves is what `npm run site` builds locally.
 *
 * The assertions are the point. The tree the client is laid into decides what it
 * loads: a `quiver/` inside the client would occupy the URL this script writes
 * ours to, and the winner would be whichever copy landed last.
 */

import { access, cp, rm } from 'node:fs/promises';
import { createRequire } from 'node:module';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { build } from '@quillmark/quiver/node';

/** The collection root: `Quiver.yaml` and `quills/` live here. */
const SOURCE = fileURLToPath(new URL('..', import.meta.url));
const SITE = join(SOURCE, 'site');
/** The published client, whole. It exports no JS, so it is reached as files. */
const CLIENT = join(
	dirname(createRequire(import.meta.url).resolve('@quillmark/studio/package.json')),
	'dist'
);

const exists = async (path) => {
	try {
		await access(path);
		return true;
	} catch {
		return false;
	}
};

function fail(message) {
	console.error(`error: ${message}`);
	process.exit(1);
}

if (!(await exists(join(CLIENT, 'index.html')))) fail(`no client at ${CLIENT} — run \`npm install\``);
if (await exists(join(CLIENT, 'quiver'))) fail(`${CLIENT}/quiver — the client carries no quiver`);

await rm(SITE, { recursive: true, force: true });
await cp(CLIENT, SITE, { recursive: true });
await build(SOURCE, join(SITE, 'quiver'));

// What the client fetches first, and the one file whose absence reads to it as a
// quiver that is not there rather than a layout that is wrong.
if (!(await exists(join(SITE, 'quiver', 'latest.json')))) fail(`${SITE}/quiver holds no pointer`);

console.log(`site: ${SITE}`);
