/**
 * Tests the Master data uploads page against the MSW mock API: the template and its column legend from the
 * field config, a file with 2 bad rows (red rows with codes, masked phones, counts), Confirm sending the same
 * bytes with `dry_run=false`, a file changed after the check, tabs per role (villages for a super-admin only, a
 * note for non-admins), the server's file hint, preview paging, the CSV reader's row numbers against Python's
 * `csv`, and axe. Limit: the template comes from the mock API, so "template matches /config/fields" is proven
 * here only for what the portal does with the API's template; the YAML parity is B13's server test
 * (`imports.template_columns`) and the live check is the Verifier's.
 * Serves: plan §7.3 P08 acceptance ("upload with 2 bad rows → preview shows 2 red rows with codes; confirm →
 * only valid rows created; template matches /config/fields"), PLAN gap analysis "Master data uploads", FR53.
 * Called by: Vitest (`npm test`).
 */
import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import axe from 'axe-core';
import { http, HttpResponse } from 'msw';
import { afterEach, beforeAll, beforeEach, describe, expect, it, vi } from 'vitest';
import { mockState } from '../../mocks/handlers';
import { renderApp } from '../../test/render';
import { server } from '../../test/setup';
import { maskPhone, parseCsv } from './csvFile';

/**
 * Asserts that axe finds no violations (colour contrast needs layout, absent in jsdom).
 * @param container The RTL container.
 */
async function expectNoAxeViolations(container: HTMLElement): Promise<void> {
  const result = await axe.run(container, { rules: { 'color-contrast': { enabled: false } } });
  expect(result.violations.map((v) => `${v.id}: ${v.help}`)).toEqual([]);
}

/**
 * Body rows of the table with the given accessible name.
 * @param name The table's aria-label.
 * @returns Its rows without the header row.
 */
const bodyRows = (name: string) =>
  within(screen.getByRole('table', { name })).getAllByRole<HTMLTableRowElement>('row').slice(1);

// Rows 3 (no name) and 5 (malformed phone) are bad; the blank line 6 is skipped like the server does.
const FARMERS_CSV = [
  'name,phone,village_lgd_code',
  'Arun,+919800000001,SAMPLE0001',
  ',+919800000002,SAMPLE0001',
  'Bala,+919800000003,SAMPLE0002',
  'Chitra,98000-04,SAMPLE0002',
  '',
  'Devi,,SAMPLE0003',
].join('\r\n');

/**
 * Opens the uploads page on a tab and picks a CSV file.
 * @param text The file content.
 * @param tab The tab to open first.
 * @returns The picked file and the render container.
 */
async function upload(text: string, tab = 'Farmers') {
  const user = userEvent.setup();
  const { container } = renderApp('/uploads', true);
  await user.click(await screen.findByRole('tab', { name: tab }));
  const file = new File([text], 'members.csv', { type: 'text/csv' });
  await user.upload(await screen.findByLabelText(/^CSV file/), file);
  return { user, file, container };
}

describe('Master data uploads', () => {
  // Node's fetch wraps every multipart part in the global `File`; jsdom's File cannot stream Node bytes, so the
  // request body never ends. Node's own File is used while these tests run (browsers are unaffected).
  // (The portal's tsconfig has no Node types, hence the specifier in a variable: TypeScript leaves it untyped.)
  const nodeBuffer = 'node:buffer';
  const jsdomFile = globalThis.File;
  let nodeFile = jsdomFile;
  beforeAll(async () => {
    nodeFile = ((await import(nodeBuffer)) as { File: typeof File }).File;
  });
  beforeEach(() => {
    globalThis.File = nodeFile;
  });
  afterEach(() => {
    globalThis.File = jsdomFile;
  });

  it('offers the API template and lists its columns with the labels from /config/fields (mock API)', async () => {
    const { container } = renderApp('/uploads', true);
    // First render of the file pays the module cold start; give it more than the 5 s default on a loaded runner.
    const link = await screen.findByRole(
      'link',
      { name: 'Download farmers template' },
      { timeout: 15_000 },
    );
    const template = decodeURIComponent(
      (link.getAttribute('href') ?? '').split(',').slice(1).join(','),
    );
    // The CSV-capable fields of apps/api/config/fields/farmer.yaml in YAML order, plus the village key
    // (imports.template_columns); written out here, not derived from the mock's field list.
    const expected = [
      'name',
      'name_local',
      'phone',
      'lang',
      'gi_authorised_user_no',
      'no_smartphone',
      'village_lgd_code',
    ];
    expect(template.trim()).toBe(expected.join(','));
    expect(link).toHaveAttribute('download', 'farmers-template.csv');
    const legend = bodyRows('Farmers template columns');
    expect(legend.map((row) => row.cells[0]?.textContent)).toEqual(expected);
    expect(legend[0]?.cells[1]).toHaveTextContent('Name');
    expect(legend[0]?.cells[2]).toHaveTextContent('Required');
    expect(legend[2]?.cells[1]).toHaveTextContent('Mobile number');
    await expectNoAxeViolations(container);
  });

  it('upload with 2 bad rows → 2 red rows with codes; confirm sends the same file and creates only valid rows', async () => {
    const { user, container } = await upload(FARMERS_CSV);
    await screen.findByRole('heading', { name: '3. Preview of members.csv' });
    expect(screen.getByRole('status')).toHaveTextContent(
      'Rows that can be imported: 3 · Rows rejected: 2 (row 3, 5)',
    );
    const rows = bodyRows('Rows of members.csv');
    expect(rows.map((row) => row.cells[0]?.textContent)).toEqual(['2', '3', '4', '5', '7']);
    const bad = rows.filter((row) => within(row).queryByText('Rejected'));
    expect(bad.map((row) => row.cells[0]?.textContent)).toEqual(['3', '5']);
    expect(bad[0]).toHaveTextContent('field_required in name: A required field is missing.');
    expect(bad[1]).toHaveTextContent(
      'import_row_invalid in phone: A value in this row is not valid.',
    );
    // No raw phone number on screen: the API's mask, six X and the last 4 characters.
    expect(container.textContent).not.toContain('9800000001');
    expect(rows[0]?.cells[2]).toHaveTextContent('XXXXXX0001');
    await expectNoAxeViolations(container);

    await user.click(screen.getByRole('button', { name: 'Import 3 rows' }));
    await screen.findByText(/3 rows imported\./);
    expect(mockState.imports.map((call) => call.dryRun)).toEqual([true, false]);
    expect(mockState.imports[1]?.text).toBe(mockState.imports[0]?.text);
    expect(mockState.imports[1]?.text).toBe(FARMERS_CSV);
    const names = mockState.farmers.map((f) => f.name);
    expect(names).toEqual(expect.arrayContaining(['Arun', 'Bala', 'Devi']));
    expect(names).not.toContain('Chitra');
    expect(screen.queryByRole('button', { name: /^Import/ })).not.toBeInTheDocument();

    await user.click(screen.getByRole('link', { name: 'Open Members' }));
    expect(await screen.findAllByText('Arun')).not.toHaveLength(0);
  });

  it('refuses to import when the file changed after the check', async () => {
    const { user, file } = await upload(FARMERS_CSV);
    const button = await screen.findByRole('button', { name: 'Import 3 rows' });
    vi.spyOn(file, 'arrayBuffer').mockResolvedValue(new TextEncoder().encode('name\nZed').buffer);
    await user.click(button);
    expect(await screen.findByText(/The file changed after it was checked/)).toBeInTheDocument();
    expect(mockState.imports.map((call) => call.dryRun)).toEqual([true]);
  });

  it('hides the Villages tab unless the caller is a super-admin', async () => {
    renderApp('/uploads', true);
    expect(await screen.findByRole('tab', { name: 'Farmers' })).toBeInTheDocument();
    expect(screen.getByRole('tab', { name: 'Inputs' })).toBeInTheDocument();
    expect(screen.queryByRole('tab', { name: 'Villages' })).not.toBeInTheDocument();
  });

  it('shows a note instead of the uploads to a role that cannot import', async () => {
    mockState.roles = ['field_officer'];
    renderApp('/uploads', true);
    expect(
      await screen.findByText('Only an FPO admin can upload master data.'),
    ).toBeInTheDocument();
    expect(screen.queryByRole('tab')).not.toBeInTheDocument();
    expect(screen.queryByLabelText(/^CSV file/)).not.toBeInTheDocument();
  });

  it('imports villages for a super-admin, with no Members link', async () => {
    mockState.superAdmin = true;
    const villages = 'lgd_code,name_en,district,state\nSAMPLE0009,Sattur,Virudhunagar,Tamil Nadu';
    const { user } = await upload(villages, 'Villages');
    await user.click(await screen.findByRole('button', { name: 'Import 1 row' }));
    await screen.findByText(/1 row imported\./);
    expect(screen.queryByRole('link', { name: 'Open Members' })).not.toBeInTheDocument();
  });

  it("adds the server's hint to an unreadable-file error", async () => {
    server.use(
      http.post('/v1/imports/:kind', () =>
        HttpResponse.json(
          {
            error: {
              code: 'validation_error',
              message: 'x',
              details: { file: 'save the CSV as UTF-8' },
            },
          },
          { status: 422 },
        ),
      ),
    );
    await upload('name\nA', 'Inputs');
    expect(
      await screen.findByText(
        'The request has invalid or implausible values. (save the CSV as UTF-8)',
      ),
    ).toBeInTheDocument();
  });

  it('pages a large preview 100 rows at a time', async () => {
    const lines = Array.from({ length: 250 }, (_, i) => `Farmer ${String(i)},,`);
    const { user } = await upload(['name,phone,village_lgd_code', ...lines].join('\n'));
    await screen.findByRole('heading', { name: '3. Preview of members.csv' });
    expect(bodyRows('Rows of members.csv')).toHaveLength(100);
    await user.click(screen.getByRole('button', { name: 'Go to next page' }));
    await waitFor(() => {
      expect(bodyRows('Rows of members.csv')[0]?.cells[0]).toHaveTextContent('102');
    });
  });
});

describe('CSV reader', () => {
  it('numbers rows like Python csv line_num (quoted line breaks, blank lines, escaped quotes)', () => {
    // Expected numbers and values printed by Python's csv.DictReader for the same text (2, 5, 7, 8; the
    // all-blank line 6 is skipped like imports.parse_csv does).
    const text =
      'name,phone,\r\nA,+919800000001,\r\n\r\n"B, Jr","line1\nline2"\r\n,,\r\n"say ""hi""",x\r\nlast,1';
    const { columns, rows } = parseCsv(text);
    expect(columns).toEqual(['name', 'phone']);
    expect(rows.map((r) => r.row)).toEqual([2, 5, 7, 8]);
    expect(rows[1]?.cells).toEqual({ name: 'B, Jr', phone: 'line1\nline2', '': '' });
    expect(rows[2]?.cells['name']).toBe('say "hi"');
  });

  it('masks phones like the API and leaves blanks blank', () => {
    expect(maskPhone('+919876543210')).toBe('XXXXXX3210');
    expect(maskPhone('')).toBe('');
    expect(parseCsv('')).toEqual({ columns: [], rows: [] });
  });
});
