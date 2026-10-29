/**
 * Measures the initial bundle (every JS/CSS file dist/index.html loads up front) gzipped, prints a markdown
 * table and fails when it exceeds the budget.
 * Serves: plan §7.3 P00 acceptance "initial bundle < 400 KB gz". Called by: `npm run size` (after
 * `npm run build`), CI `portal` job (output appended to the job summary). Run with plain `node`.
 */
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { gzipSync } from 'node:zlib';

const BUDGET_BYTES = 400 * 1024;
const dist = resolve(import.meta.dirname, '../dist');
const html = readFileSync(resolve(dist, 'index.html'), 'utf8');

// Entry script, modulepreload links and stylesheets are exactly what the first page load fetches.
const assets = [...html.matchAll(/(?:src|href)="\/(assets\/[^"]+\.(?:js|css))"/g)].map(
  (match) => match[1] ?? '',
);
const rows = assets.map((asset) => {
  const bytes = readFileSync(resolve(dist, asset));
  return { asset, raw: bytes.length, gz: gzipSync(bytes, { level: 6 }).length };
});
const total = rows.reduce((sum, row) => sum + row.gz, 0);
/**
 * Formats a byte count.
 * @param bytes Size in bytes.
 * @returns Size in KB (1024 bytes) with one decimal.
 */
const kb = (bytes: number) => `${(bytes / 1024).toFixed(1)} KB`;

console.log('| Initial asset | Raw | Gzip (level 6) |\n|---|---|---|');
for (const row of rows) console.log(`| ${row.asset} | ${kb(row.raw)} | ${kb(row.gz)} |`);
console.log(`| **Total** | | **${kb(total)}** (budget ${kb(BUDGET_BYTES)}) |`);

if (rows.length === 0 || total > BUDGET_BYTES) {
  console.error(rows.length === 0 ? 'No assets found in dist/index.html' : 'Over budget');
  process.exit(1);
}
