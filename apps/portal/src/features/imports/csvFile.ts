/**
 * Reads a picked import CSV for the preview: SHA-256 of its bytes, its rows numbered like the server's report,
 * and the phone mask. Pure helpers, no React.
 * Serves: PLAN gap analysis "Master data uploads" (dry-run preview with row-level codes), plan §7.3 P08, FR53
 * (village master rows), CLAUDE.md §6 (no raw phone numbers on screen).
 * Called by: src/features/imports/MasterDataPage.tsx; src/features/imports/imports.test.tsx.
 */

/** One data row of the file. */
export interface CsvRow {
  /** Line number the server reports for it (header = 1; Python `csv` `line_num`, so blank lines count). */
  row: number;
  /** Column name → stripped cell value ('' when blank). */
  cells: Record<string, string>;
}

/** A picked file, read once: what the preview shows and the exact bytes sent to the API. */
export interface CsvFile {
  /** File name, kept for the multipart part. */
  name: string;
  /** Hex SHA-256 of the bytes; the preview belongs to this hash only. */
  hash: string;
  /** The bytes that were hashed and parsed. */
  blob: Blob;
  /** Non-blank header names in file order. */
  columns: string[];
  /** Data rows that have at least one value (the server skips the others too). */
  rows: CsvRow[];
}

/**
 * Splits CSV text into rows, numbering each by the line it ends on, exactly as the API's reader does.
 *
 * DECISION D-044: a 30-line reader instead of a CSV library.
 *   ADV: the row numbers must equal the server's `csv` `line_num` (quoted line breaks and blank lines count),
 *   which no common JS parser reports; the server stays the only judge of the file (it re-parses it).
 *   COMPROMISE: in-house parsing code; covered by a test against numbers taken from Python's `csv`.
 * @param text The file decoded as UTF-8 (BOM already removed).
 * @returns The non-blank header names and the non-blank data rows.
 */
export function parseCsv(text: string): { columns: string[]; rows: CsvRow[] } {
  const records: { line: number; cells: string[] }[] = [];
  let cells: string[] = [];
  let cell = '';
  let quoted = false;
  let line = 1;
  for (let i = 0; i < text.length; i += 1) {
    const c = text.charAt(i);
    if (quoted) {
      if (c !== '"') {
        if (c === '\n') line += 1;
        cell += c;
      } else if (text[i + 1] === '"') {
        cell += '"';
        i += 1;
      } else quoted = false;
    } else if (c === '"' && cell === '') quoted = true;
    else if (c === ',') {
      cells.push(cell);
      cell = '';
    } else if (c === '\n') {
      records.push({ line, cells: [...cells, cell] });
      cells = [];
      cell = '';
      line += 1;
    } else if (c !== '\r') cell += c;
  }
  if (cell !== '' || cells.length > 0) records.push({ line, cells: [...cells, cell] });

  const header = (records[0]?.cells ?? []).map((name) => name.trim());
  const rows = records.slice(1).map(({ line: row, cells: values }) => ({
    row,
    cells: Object.fromEntries(header.map((name, i) => [name, (values[i] ?? '').trim()])),
  }));
  return {
    columns: header.filter(Boolean),
    rows: rows.filter((r) => Object.entries(r.cells).some(([name, value]) => name && value)),
  };
}

/**
 * Reads a picked file once: hashes the bytes with SubtleCrypto and parses them.
 * @param file The file from the `<input type="file">`.
 * @returns The hash, the bytes and the parsed rows.
 * @throws {DOMException} When the browser cannot read the file (e.g. it changed on disk after it was picked) or
 *   SubtleCrypto is unavailable (page not served over HTTPS or localhost).
 */
export async function readCsvFile(file: File): Promise<CsvFile> {
  const bytes = await file.arrayBuffer();
  const digest = await crypto.subtle.digest('SHA-256', bytes);
  const hash = Array.from(new Uint8Array(digest), (b) => b.toString(16).padStart(2, '0')).join('');
  // TextDecoder drops the BOM spreadsheet programs add, like the server's `utf-8-sig`.
  return {
    name: file.name,
    hash,
    blob: new Blob([bytes], { type: 'text/csv' }),
    ...parseCsv(new TextDecoder().decode(bytes)),
  };
}

/**
 * Masks a phone number the way the API's `phone_masked` does (registry `mask_phone`): six X then the last 4.
 * @param value The cell value.
 * @returns `XXXXXX3210`, or '' for a blank cell.
 */
export const maskPhone = (value: string): string => (value ? 'XXXXXX' + value.slice(-4) : '');
