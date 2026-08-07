/**
 * A static server over the site tree, hand-rolled to keep the repository
 * dependency-free: the client is files and a wasm binary, so serving them is the
 * whole requirement.
 */

import { createReadStream } from 'node:fs';
import { stat } from 'node:fs/promises';
import { createServer } from 'node:http';
import { extname, join, normalize } from 'node:path';

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

/** Serve `root` on `port`. Resolves once the socket is listening. */
export function serve(root, port) {
	const server = createServer(async (req, res) => {
		// Resolved under the root, then checked against it: a `..` in the request
		// path would otherwise reach the rest of the disk.
		const path = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
		let file = normalize(join(root, path));
		if (!file.startsWith(root)) {
			res.writeHead(403).end('forbidden');
			return;
		}

		try {
			if ((await stat(file)).isDirectory()) file = join(file, 'index.html');
			const { size } = await stat(file);
			res.writeHead(200, {
				'content-type': TYPES[extname(file)] ?? 'application/octet-stream',
				'content-length': size,
				// A repack is why this server is running, and the pointer is the one
				// name a stale copy of which silently pins the client to the old
				// catalog. Everything is revalidated rather than reasoning per-file.
				'cache-control': 'no-cache'
			});
			createReadStream(file).pipe(res);
		} catch {
			res.writeHead(404).end('not found');
		}
	});
	return new Promise((resolve) => server.listen(port, () => resolve(server)));
}
