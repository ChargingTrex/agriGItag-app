/**
 * Pure helpers of the portal's downloads: a CSV writer (quoting, formula-injection guard, UTF-8 BOM), the batch's
 * lots-and-shares CSV and the dashboard farmer table CSV (every quantity with its unit in its own column), and the
 * one place that saves a fetched blob as a file.
 * Serves: FR58 (a unit on every quantity), FR21 (CSV export of traceability data), FR60 (shares), FR62 (labels
 * download), plan §7.3 P05 (`labels-<batchId>.pdf`; CSV unit on every quantity), CLAUDE.md §6 (no phone, survey
 * number or coordinates in an export).
 * Called by: BatchExports.tsx, ExportsPage.tsx; tests in exports.test.tsx.
 */
import type { components } from '../../api/generated/schema';
import { toGrams, type BatchOut, type LotOut } from '../batches/batchModel';

type Quantity = components['schemas']['Quantity-Output'];
export type FarmerRow = components['schemas']['FarmerRow'];

/** A CSV cell value; null and undefined become an empty cell. */
type Cell = string | number | null | undefined;

/** Leading characters a spreadsheet runs as a formula (OWASP CSV injection list, same as B11 `csv_cell`). */
const FORMULA = /^[=+\-@\t\r]/;

/**
 * One CSV cell: formula guard, then RFC 4180 quoting.
 * @param value The value.
 * @returns The cell text, `'`-prefixed when it starts with `= + - @`, tab or CR, quoted when it holds a comma,
 *   quote or line break.
 */
export function csvCell(value: Cell): string {
  const text = value === null || value === undefined ? '' : String(value);
  const safe = FORMULA.test(text) ? `'${text}` : text;
  return /[",\r\n]/.test(safe) ? `"${safe.replaceAll('"', '""')}"` : safe;
}

/**
 * A CSV document.
 * @param rows Header row first, then the data rows.
 * @returns The text with a UTF-8 BOM and CRLF line ends.
 */
export function toCsv(rows: readonly (readonly Cell[])[]): string {
  // DECISION D-051: CSVs start with a UTF-8 BOM and every cell passes the formula guard.
  //   ADV: Excel opens Tamil names correctly on a double-click; a name such as "=HYPERLINK(…)" stays text.
  //   COMPROMISE: a cell that really starts with "-" (none today: quantities are not negative) gains a "'".
  return `\uFEFF${rows.map((row) => row.map(csvCell).join(',')).join('\r\n')}\r\n`;
}

/**
 * Saves a blob as a download through a temporary object URL.
 * @param blob The file contents.
 * @param fileName The suggested file name.
 * Side effects: clicks a detached link; revokes the object URL after 40 s.
 */
export function saveBlob(blob: Blob, fileName: string): void {
  const href = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = href;
  a.download = fileName;
  a.click();
  // Some browsers start the download after the click handler returns; FileSaver.js waits 40 s too.
  setTimeout(() => {
    URL.revokeObjectURL(href);
  }, 40_000);
}

/**
 * Saves CSV rows as a UTF-8 file.
 * @param rows Header row first, then the data rows.
 * @param fileName The suggested file name.
 * Side effects: see `saveBlob`.
 */
export const saveCsv = (rows: readonly (readonly Cell[])[], fileName: string) => {
  saveBlob(new Blob([toCsv(rows)], { type: 'text/csv;charset=utf-8' }), fileName);
};

/**
 * A quantity as two cells.
 * @param q The API quantity, or null.
 * @returns `[value, unit]`, both empty when there is no quantity.
 */
const qty = (q: Quantity | null | undefined): [Cell, Cell] => (q ? [q.value, q.unit] : ['', '']);

/**
 * The batch's lots and shares as CSV rows: lot code, farmer name, the recorded harvested, on-farm packed and received
 * kg, the derived share of the final packed kg and the share %, each quantity followed by its unit (FR58).
 * @param batch The batch.
 * @param lots The share lots by id (a lot not loaded shows its id and empty harvested / on-farm packed cells).
 * @param farmerName Name per farmer id (P03 `useFarmerNames`, names only).
 * @returns Header plus one row per share.
 */
export function lotsCsvRows(
  batch: BatchOut,
  lots: ReadonlyMap<string, LotOut>,
  farmerName: (id: string) => string,
): Cell[][] {
  const packedGrams = batch.packed ? toGrams(batch.packed.value) : null;
  const quantities = ['harvested', 'farm_packed', 'received', 'final_packed_share_derived'];
  return [
    [
      'lot_code',
      'farmer_name',
      ...quantities.flatMap((q) => [q, `${q}_unit`]),
      'share',
      'share_unit',
    ],
    ...batch.shares.map((s) => {
      const lot = lots.get(s.lot_id);
      // DECISION D-051: final packing is recorded per batch (`BatchOut.packed`), so a lot's part of it is derived
      //   (batch packed kg × share %) and its column says so, next to the lot's recorded quantities.
      //   ADV: the export answers "how much of the packed output came from this farmer" (FR60) with no new route.
      //   COMPROMISE: a derived figure rounded to the gram; the shares' rounding can make the column sum differ
      //   from the packed kg by a few grams.
      const derived =
        packedGrams === null
          ? null
          : {
              value: String(Math.round((packedGrams * Number(s.share_pct)) / 100) / 1000),
              unit: 'kg',
            };
      return [
        lot?.code ?? s.lot_id,
        farmerName(s.farmer_id),
        ...qty(lot?.harvested),
        ...qty(lot?.packed),
        ...qty(s.contributed),
        ...qty(derived),
        s.share_pct,
        '%',
      ];
    }),
  ];
}

/** Farmer table columns in the dashboard's order (P06 `COLUMNS`); the allow-list of the farmers CSV. */
export const FARMER_COLUMNS = [
  'code',
  'name',
  'village',
  'block',
  'status',
  'plots',
  'declared_area',
  'walked_area',
  'lots',
  'lots_complete',
] as const satisfies readonly (keyof FarmerRow)[];
export type FarmerColumn = (typeof FARMER_COLUMNS)[number];

/**
 * The farmer table as CSV rows. Only allow-listed columns are written, whatever else a row holds, so a phone,
 * survey number or coordinate can never reach the file (CLAUDE.md §6).
 * @param rows Farmer rows (partial when read with `?fields=`).
 * @param columns The visible columns.
 * @returns Header plus one row per farmer; a quantity column becomes `<column>` and `<column>_unit`.
 */
export function farmersCsvRows(
  rows: readonly Partial<FarmerRow>[],
  columns: readonly string[],
): Cell[][] {
  const shown = FARMER_COLUMNS.filter((c) => columns.includes(c));
  /**
   * Whether a column holds a quantity.
   * @param c The column.
   * @returns True for the area columns.
   */
  const isQty = (c: FarmerColumn) => c === 'declared_area' || c === 'walked_area';
  return [
    shown.flatMap((c) => (isQty(c) ? [c, `${c}_unit`] : [c])),
    ...rows.map((row) =>
      shown.flatMap((c): Cell[] => {
        const value = row[c];
        const quantity = typeof value === 'object' ? value : null;
        return isQty(c) ? qty(quantity) : [quantity ? null : (value as Cell)];
      }),
    ),
  ];
}
