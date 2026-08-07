/**
 * Serve `site/` over HTTP, for looking at the quills through studio locally. The
 * client is static files and a wasm binary, so a static server is the whole
 * requirement; this one is hand-rolled to keep the repository dependency-free.
 *
 * The deployed site is the same tree, so what is looked at here is what a
 * reviewer opens. A quiver packed at build time is frozen: `npm run preview`
 * again is how an edit to a quill reaches the page.
 */

import { createReadStream } from 'node:fs';
import { stat } from 'node:fs/promises';
import { createServer } from 'node:http';
import { extname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';

const SITE = fileURLToPath(new URL('../site', import.meta.url));
const PORT = Number(process.env.PORT ?? 4173);

/** Wasm and JSON are load-bearing: the client refuses a wasm binary served as
 *  anything but `application/wasm`, and the quiver's pointer and manifests are
 *  fetched as JSON. */
const TYPES = {
	'.html': 'text/html; charset=utf-8',
	'.js': 'text/javascript; charset=utf-8',
	'.css': 'text/css; charset=utf-8',
	'.json': 'application/json; charset=utf-8',
	'.wasm': 'application/wasm',
	'.svg': 'image/svg+xml',
	'.png': 'image/png',
	'.jpg': 'image/jpeg',
	'.otf': 'font/otf',
	'.ttf': 'font/ttf',
	'.woff2': 'font/woff2'
};

createServer(async (req, res) => {
	// Resolved under the site root, then checked against it: a `..` in the request
	// path would otherwise reach the rest of the disk.
	const path = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
	let file = normalize(join(SITE, path));
	if (!file.startsWith(SITE)) {
		res.writeHead(403).end('forbidden');
		return;
	}

	try {
		if ((await stat(file)).isDirectory()) file = join(file, 'index.html');
	} catch {
		res.writeHead(404).end('not found');
		return;
	}

	try {
		const { size } = await stat(file);
		res.writeHead(200, {
			'content-type': TYPES[extname(file)] ?? 'application/octet-stream',
			'content-length': size,
			// The pointer is the one name a stale copy of which silently pins the
			// client to the old catalog; a repack is why this server is running.
			'cache-control': 'no-cache'
		});
		createReadStream(file).pipe(res);
	} catch {
		res.writeHead(404).end('not found');
	}
}).listen(PORT, () => console.log(`studio: http://localhost:${PORT}/`));
