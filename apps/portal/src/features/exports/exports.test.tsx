/**
 * Tests the labels and exports: the CSV writer (quoting, formula guard, BOM), the lots CSV with a unit on every
 * quantity, the farmers CSV allow-list (never a phone or a coordinate pair), the batch page's Labels and exports
 * section against the MSW mock API (`labels-<batchId>.pdf`, audit CSV, lots CSV, greyed reasons by role and
 * packing state, axe) and the `/exports` page (visible dashboard columns, every page, file name, errors).
 * Serves: plan §7.3 P05 acceptance (`labels-<batchId>.pdf`; CSV unit on every quantity), FR21, FR58, FR60, FR62,
 * CLAUDE.md §6. Called by: Vitest (`npm test`).
 */
import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import axe from 'axe-core';
import { http, HttpResponse } from 'msw';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { MOCK_FPO_ID, MOCK_REF_LOT_IDS, MOCK_USER_ID, mockState } from '../../mocks/handlers';
import { renderApp } from '../../test/render';
import { server } from '../../test/setup';
import type { BatchOut } from '../batches/batchModel';
import { csvCell, farmersCsvRows, lotsCsvRows, toCsv, type FarmerRow } from './exportModel';
import { visibleColumns } from './ExportsPage';

const BATCH_ID = 'b0000000-0000-7000-8000-000000000005';
const CODE = 'FGP8T4033HM7';
/** An Indian mobile number, with or without +91. */
const PHONE = /(?:\+91)?[6-9]\d{9}/;
/** Two decimal degrees side by side ("9.58, 77.96" or "POINT(77.96 9.58)"). */
const COORDS = /-?\d{1,3}\.\d+\s*[, ]\s*-?\d{1,3}\.\d+/;

/**
 * The PRD §12 reference batch (100 + 200 + 20 kg from farmers 1, 4 and 5), packed at 300 kg.
 * @param extra Fields to override.
 * @returns The batch.
 */
function batch(extra: Partial<BatchOut> = {}): BatchOut {
  const kg = ['100', '200', '20'];
  const pct = ['31.250', '62.500', '6.250'];
  return {
    id: BATCH_ID,
    code: CODE,
    crop_id: '3d2c1b0a-9f8e-4d7c-8b6a-5f4e3d2c1b0a',
    processor_id: 'c0000000-0000-7000-8000-000000000001',
    created_by: MOCK_USER_ID,
    status: 'packed',
    current_build_no: 0,
    gi_label_requested: true,
    gi_verified: true,
    gi_block_reasons: [],
    second_signoff_required: false,
    second_signoff_by: null,
    total_received: { value: '320', unit: 'kg' },
    graded: { value: '300', unit: 'kg' },
    packed: { value: '300', unit: 'kg' },
    pack_date: '2026-11-02',
    best_before_date: '2027-11-01',
    shares: MOCK_REF_LOT_IDS.map((lotId, i) => ({
      lot_id: lotId,
      farmer_id: `00000000-0000-4000-8000-${String([1, 4, 5][i]).padStart(12, '0')}`,
      contributed: { value: kg[i] ?? '', unit: 'kg' },
      share_pct: pct[i] ?? '',
    })),
    ...extra,
  };
}

/**
 * Replaces object URLs and link clicks so each download is recorded instead of started.
 * @returns The downloads so far: file name and blob.
 */
function captureDownloads(): { name: string; blob: Blob }[] {
  const files: { name: string; blob: Blob }[] = [];
  const blobs = new Map<string, Blob>();
  Object.assign(URL, {
    createObjectURL: (blob: Blob) => {
      const href = `blob:${String(blobs.size)}`;
      blobs.set(href, blob);
      return href;
    },
    revokeObjectURL: vi.fn(),
  });
  vi.spyOn(HTMLAnchorElement.prototype, 'click').mockImplementation(function (
    this: HTMLAnchorElement,
  ) {
    const blob = blobs.get(this.getAttribute('href') ?? '');
    if (blob) files.push({ name: this.download, blob });
  });
  return files;
}

/**
 * A downloaded file's bytes and text.
 * @param blob The file.
 * @returns First three bytes and the UTF-8 text (BOM stripped by the decoder).
 */
async function read(blob: Blob): Promise<{ head: number[]; text: string }> {
  const bytes = new Uint8Array(await blob.arrayBuffer());
  return { head: [...bytes.slice(0, 3)], text: new TextDecoder().decode(bytes) };
}

/**
 * Asserts that axe finds no violations (colour contrast needs layout, absent in jsdom).
 * @param container The element to check.
 */
async function expectNoAxeViolations(container: HTMLElement): Promise<void> {
  const result = await axe.run(container, {
    iframes: false,
    rules: { 'color-contrast': { enabled: false } },
  });
  expect(result.violations.map((v) => `${v.id}: ${v.help}`)).toEqual([]);
}

afterEach(() => {
  vi.restoreAllMocks();
  localStorage.clear();
});

describe('CSV writer', () => {
  it('guards every formula trigger, quotes commas, quotes and line breaks', () => {
    for (const lead of ['=', '+', '-', '@', '\t', '\r']) {
      expect(csvCell(`${lead}1+1`).replace(/^"/, '')).toMatch(/^'/);
    }
    expect(csvCell('=HYPERLINK("x")')).toBe(`"'=HYPERLINK(""x"")"`);
    expect(csvCell('Sattur, Virudhunagar')).toBe('"Sattur, Virudhunagar"');
    expect(csvCell('two\nlines')).toBe('"two\nlines"');
    expect(csvCell(null)).toBe('');
    expect(csvCell(undefined)).toBe('');
    expect(csvCell(12.5)).toBe('12.5');
    expect(csvCell('முத்து குமார்')).toBe('முத்து குமார்');
  });

  it('starts with a BOM and ends every row with CRLF', () => {
    expect(
      toCsv([
        ['a', 'b'],
        [1, null],
      ]),
    ).toBe('\uFEFFa,b\r\n1,\r\n');
  });
});

describe('lots CSV', () => {
  it('has a unit next to every quantity (FR58) and the packed share by share %', () => {
    const b = batch();
    const lots = new Map(
      mockState.lots.filter((l) => MOCK_REF_LOT_IDS.includes(l.id as never)).map((l) => [l.id, l]),
    );
    const rows = lotsCsvRows(b, lots, (id) => `Farmer ${id.slice(-2)}`);
    expect(rows).toEqual([
      [
        'lot_code',
        'farmer_name',
        'received',
        'received_unit',
        'packed_share',
        'packed_share_unit',
        'share',
        'share_unit',
      ],
      ['VSV-0001-L1', 'Farmer 01', '100', 'kg', '93.75', 'kg', '31.250', '%'],
      ['VSV-0004-L1', 'Farmer 04', '200', 'kg', '187.5', 'kg', '62.500', '%'],
      ['VSV-0005-L1', 'Farmer 05', '20', 'kg', '18.75', 'kg', '6.250', '%'],
    ]);
    // Every quantity column is followed by its unit column, and a value always has a unit.
    const header = rows[0] ?? [];
    for (const row of rows.slice(1)) {
      header.forEach((name, i) => {
        if (String(name).endsWith('_unit')) expect(row[i]).toBeTruthy();
      });
    }
  });

  it('leaves the packed share empty before packing and shows a lot id when the lot is not loaded', () => {
    const rows = lotsCsvRows(batch({ packed: null }), new Map(), () => 'X');
    expect(rows[1]).toEqual([MOCK_REF_LOT_IDS[0], 'X', '100', 'kg', '', '', '31.250', '%']);
  });
});

describe('farmers CSV', () => {
  const row = {
    id: '00000000-0000-4000-8000-000000000001',
    code: 'VSV-0001',
    name: 'Muthu Kumar',
    name_local: 'முத்து குமார்',
    village: 'Sattur',
    village_id: null,
    block: 'Sattur',
    status: 'active',
    plots: 2,
    declared_area: { value: '1.5', unit: 'acre' },
    walked_area: { value: '1.2', unit: 'acre' },
    lots: 3,
    lots_complete: 1,
    // A row that somehow carried private fields: the allow-list must drop them (CLAUDE.md §6).
    phone: '+919876543210',
    land_record_ref: '123/4A',
    pin: 'POINT(77.96 9.58)',
    lat: 9.58,
    lon: 77.96,
  } as FarmerRow;

  it('never contains a phone pattern, survey number or coordinate pair, even if the API sent one', () => {
    const text = toCsv(farmersCsvRows([row], [...Object.keys(row), 'phone', 'pin']));
    expect(text).not.toMatch(PHONE);
    expect(text).not.toMatch(COORDS);
    expect(text).not.toContain('123/4A');
    expect(text.split('\r\n')[0]).toBe(
      '\uFEFFcode,name,village,block,status,plots,declared_area,declared_area_unit,walked_area,' +
        'walked_area_unit,lots,lots_complete',
    );
    expect(text).toContain('VSV-0001,Muthu Kumar,Sattur,Sattur,active,2,1.5,acre,1.2,acre,3,1');
  });

  it('writes only the visible columns, in the dashboard order', () => {
    expect(farmersCsvRows([row], ['walked_area', 'name'])).toEqual([
      ['name', 'walked_area', 'walked_area_unit'],
      ['Muthu Kumar', '1.2', 'acre'],
    ]);
    expect(farmersCsvRows([{ name: 'A' }], ['name', 'declared_area'])[1]).toEqual(['A', '', '']);
  });

  it('reads the dashboard column choice, else every column', () => {
    expect(visibleColumns('x')).toHaveLength(10);
    localStorage.setItem(
      'agritrace.dashboard.columns.x',
      JSON.stringify(['lots', 'name', 'phone']),
    );
    expect(visibleColumns('x')).toEqual(['name', 'lots']);
    localStorage.setItem('agritrace.dashboard.columns.x', '{not json');
    expect(visibleColumns('x')).toHaveLength(10);
    localStorage.setItem('agritrace.dashboard.columns.x', '["phone"]');
    expect(visibleColumns('x')).toHaveLength(10);
  });
});

describe('batch page labels and exports', () => {
  it('downloads labels-<batchId>.pdf, the audit CSV and the lots CSV with units; axe clean', async () => {
    mockState.batches.push(batch());
    const files = captureDownloads();
    const user = userEvent.setup();
    renderApp(`/batches/${BATCH_ID}`, true);

    const section = within(
      (await screen.findByRole('heading', { name: 'Labels and exports' })).closest('section') ??
        document.body,
    );
    expect(section.getByText(/one A4 sheet of 8 labels/)).toHaveTextContent(
      `batch ID ${CODE}, net 300 kg`,
    );
    expect(section.getByText(/^Print at 100 %/)).toBeInTheDocument();

    await user.click(section.getByRole('button', { name: 'Download labels' }));
    await waitFor(() => {
      expect(files).toHaveLength(1);
    });
    expect(files[0]?.name).toBe(`labels-${CODE}.pdf`);
    expect((await read(files[0]?.blob ?? new Blob())).text).toMatch(/^%PDF-/);

    await user.click(section.getByRole('button', { name: 'Download audit CSV' }));
    await waitFor(() => {
      expect(files).toHaveLength(2);
    });
    expect(files[1]?.name).toBe(`audit-${CODE}.csv`);
    expect((await read(files[1]?.blob ?? new Blob())).text).toContain('entered_by');

    // Names come from P03's farmer reads; wait for them before exporting.
    await screen.findByRole('cell', { name: 'Muthu Kumar' });
    const lotsButton = section.getByRole('button', { name: 'Download lots CSV' });
    await waitFor(() => {
      expect(lotsButton).toBeEnabled();
    });
    await user.click(lotsButton);
    expect(files[2]?.name).toBe(`batch-${CODE}-lots.csv`);
    const lotsCsv = await read(files[2]?.blob ?? new Blob());
    expect(lotsCsv.head).toEqual([0xef, 0xbb, 0xbf]);
    expect(lotsCsv.text.split('\r\n').slice(0, 2)).toEqual([
      'lot_code,farmer_name,received,received_unit,packed_share,packed_share_unit,share,share_unit',
      'VSV-0001-L1,Muthu Kumar,100,kg,93.75,kg,31.250,%',
    ]);
    expect(lotsCsv.text).not.toMatch(PHONE);

    await expectNoAxeViolations(document.body);
  });

  it('greys labels before packing and the audit CSV for a QC officer, with the reasons', async () => {
    mockState.roles = ['qc_officer'];
    mockState.batches.push(batch({ status: 'created', packed: null, graded: null }));
    renderApp(`/batches/${BATCH_ID}`, true);
    expect(
      await screen.findByRole('button', {
        name: 'Download labels: Final packing has not been signed off.',
      }),
    ).toBeDisabled();
    expect(
      screen.getByRole('button', {
        name: 'Download audit CSV: Only an FPO admin or viewer can download the audit trail.',
      }),
    ).toBeDisabled();
  });

  it('greys labels for a viewer and shows the server refusal of the audit CSV', async () => {
    mockState.roles = ['viewer'];
    mockState.batches.push(batch());
    server.use(
      http.get('/v1/batches/:batchId/audit-export.csv', () =>
        HttpResponse.json(
          { error: { code: 'forbidden', message: 'forbidden', details: null } },
          { status: 403 },
        ),
      ),
    );
    const user = userEvent.setup();
    renderApp(`/batches/${BATCH_ID}`, true);
    expect(
      await screen.findByRole('button', {
        name: 'Download labels: Only an FPO admin or QC officer prints labels.',
      }),
    ).toBeDisabled();
    const section = within(
      screen.getByRole('heading', { name: 'Labels and exports' }).closest('section') ??
        document.body,
    );
    await user.click(section.getByRole('button', { name: 'Download audit CSV' }));
    expect(await section.findByRole('alert')).toBeInTheDocument();
  });
});

describe('/exports page', () => {
  /** Farmer rows of the mock table, two pages; the mock ignores `fields` and also sends a phone. */
  const rows = [
    {
      id: 'f1',
      name: 'Muthu Kumar',
      declared_area: { value: '1.5', unit: 'acre' },
      phone: '9876543210',
    },
    { id: 'f2', name: 'Farmer, 02', declared_area: { value: '0.75', unit: 'acre' } },
  ];

  it('is in the sidebar and downloads the visible farmer columns of every page, no phone', async () => {
    localStorage.setItem(
      `agritrace.dashboard.columns.${MOCK_FPO_ID}`,
      JSON.stringify(['declared_area', 'name']),
    );
    const requested: (string | null)[] = [];
    server.use(
      http.get('/v1/fpos/:fpoId', () => HttpResponse.json({ code: 'VSV_FPO' })),
      http.get('/v1/dashboard/fpo/:fpoId/farmers', ({ request }) => {
        const query = new URL(request.url).searchParams;
        requested.push(query.get('fields'));
        const second = query.get('cursor') === 'p2';
        return HttpResponse.json({
          items: second ? rows.slice(1) : rows.slice(0, 1),
          has_more: !second,
          next_cursor: second ? null : 'p2',
        });
      }),
    );
    const files = captureDownloads();
    const user = userEvent.setup();
    renderApp('/exports', true);

    expect(await screen.findByRole('heading', { name: 'Labels and exports' })).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Labels & exports' })).toHaveAttribute(
      'href',
      '/exports',
    );
    expect(within(screen.getByRole('main')).getByRole('link', { name: 'Batches' })).toHaveAttribute(
      'href',
      '/batches',
    );
    await user.click(screen.getByRole('button', { name: 'Download farmers CSV' }));
    await waitFor(() => {
      expect(files).toHaveLength(1);
    });
    expect(files[0]?.name).toMatch(/^farmers-VSV_FPO-\d{4}-\d{2}-\d{2}\.csv$/);
    expect(requested).toEqual(['name,declared_area', 'name,declared_area']);
    const { text } = await read(files[0]?.blob ?? new Blob());
    expect(text).toBe(
      'name,declared_area,declared_area_unit\r\nMuthu Kumar,1.5,acre\r\n"Farmer, 02",0.75,acre\r\n',
    );
    expect(text).not.toMatch(PHONE);
    expect(text).not.toMatch(COORDS);
    await expectNoAxeViolations(document.body);
  });

  it('shows the error when the table cannot be read', async () => {
    server.use(
      http.get('/v1/fpos/:fpoId', () =>
        HttpResponse.json(
          { error: { code: 'not_found', message: 'not_found', details: null } },
          { status: 404 },
        ),
      ),
    );
    const user = userEvent.setup();
    renderApp('/exports', true);
    await user.click(await screen.findByRole('button', { name: 'Download farmers CSV' }));
    expect(await screen.findByRole('alert')).toBeInTheDocument();
  });
});
