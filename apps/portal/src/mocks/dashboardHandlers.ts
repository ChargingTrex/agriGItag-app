/**
 * MSW handlers for the P06 screens: villages master, FPO dashboard and its farmer table, audit log, FPO read and
 * field config. Kept apart from handlers.ts so P04/P08 merges touch one spread line, not this seed.
 * Serves: plan §7.3 P06 (MSW for every endpoint the screens call), FR13, FR20, FR25, FR62, plan §13 F1.
 * Called by: src/test/setup.ts and src/mocks/browser.ts (spread after `handlers`); tests import the MOCK_*
 * constants.
 *
 * The seed mirrors backend-design.md §5: the three PRD §12 reference lots (farmers 1, 4 and 5, every one of the
 * seven farm stages recorded and now batched), batch FGP8T4033HM7 after fixes (published, 20 kg), and one
 * `event.correct` audit row. Farmers and their villages come from handlers.ts `mockState.farmers`. Read-only:
 * nothing here mutates, so `resetMockData` needs no change.
 */
import { http, HttpResponse } from 'msw';
import type { components } from '../api/generated/schema';
import { authed, fail, MOCK_FPO_ID, MOCK_USER_ID, mockState } from './handlers';

type Schemas = components['schemas'];
type FarmerRow = Schemas['FarmerRow'];
type AuditRow = Schemas['AuditRow'];
type AreaStats = Schemas['AreaStats'];

const CROP_ID = '3d2c1b0a-9f8e-4d7c-8b6a-5f4e3d2c1b0a';
/** Villages master (LGD sample). Elayirampannai has no farmers; it proves the block → village dependency. */
export const MOCK_VILLAGES: Schemas['VillageOut'][] = [
  ['Aruppukottai', 'Aruppukottai'],
  ['Elayirampannai', 'Sattur'],
  ['Sattur', 'Sattur'],
  ['Srivilliputhur', 'Srivilliputhur'],
].map(([name, block], i) => ({
  id: `20000000-0000-4000-8000-${String(i + 1).padStart(12, '0')}`,
  name_en: name ?? '',
  name_local: null,
  block: block ?? null,
  taluk: block ?? null,
  district: 'Virudhunagar',
  state: 'Tamil Nadu',
  lgd_code: `SAMPLE000${String(i + 1)}`,
  pincode: null,
}));
/** Farmer numbers (1-based) owning the three reference lots. */
const REF_LOT_FARMERS = [1, 4, 5];
/** Farm stages in order, as B11 returns them. */
const STAGES = [
  'land_preparation',
  'nursery',
  'sowing',
  'input_application',
  'harvest',
  'drying',
  'packing',
];
/** The seeded correction's event version id. */
export const MOCK_CORRECTION_VERSION_ID = 'e0000000-0000-7000-8000-000000000102';
/** The field officer who entered the seeded correction. */
export const MOCK_OFFICER_ID = 'a0000000-0000-7000-8000-000000000002';

const AUDIT_ROWS: AuditRow[] = [
  {
    id: 'ad000000-0000-7000-8000-000000000003',
    at: '2026-03-14T05:30:00Z',
    actor_user_id: MOCK_OFFICER_ID,
    on_behalf_of_farmer_id: '00000000-0000-4000-8000-000000000001',
    assist_session_id: 'a5000000-0000-7000-8000-000000000001',
    action: 'event.correct',
    entity_type: 'event_versions',
    entity_id: MOCK_CORRECTION_VERSION_ID,
    request_id: null,
    // Exactly what B11 returns today: the reason lives on the version, not in this diff (TODO.md B11 → P06).
    diff: {
      event_id: 'e0000000-0000-7000-8000-000000000101',
      event_type: 'packing',
      version_no: 2,
      change_kind: 'correct',
      photos: [{ client_id: 'p1', exif_gps: '[hidden]' }],
    },
  },
  {
    id: 'ad000000-0000-7000-8000-000000000002',
    at: '2026-02-14T04:00:00Z',
    actor_user_id: MOCK_USER_ID,
    on_behalf_of_farmer_id: null,
    assist_session_id: null,
    action: 'update',
    entity_type: 'plots',
    entity_id: '7c3e9b1a-2d4f-4a6b-8c0d-9e1f2a3b4c5d',
    request_id: 'req-1',
    diff: { pin: '[hidden]', declared_area_acres: ['0.4', '0.5'] },
  },
  {
    id: 'ad000000-0000-7000-8000-000000000001',
    at: '2026-01-10T04:00:00Z',
    actor_user_id: MOCK_USER_ID,
    on_behalf_of_farmer_id: null,
    assist_session_id: null,
    action: 'create',
    entity_type: 'farmers',
    entity_id: '00000000-0000-4000-8000-000000000004',
    request_id: null,
    diff: { code: 'VSV-0004', name: 'Farmer 04', pin_hash: '[redacted]' },
  },
];

/**
 * A quantity body.
 * @param value Number to print.
 * @param unit Unit code.
 * @param digits Decimals.
 * @returns `{value, unit}`.
 */
const q = (value: number, unit: string, digits = 3) => ({ value: value.toFixed(digits), unit });

/**
 * One farmer's dashboard row, from the shared farmer seed: one 0.5-acre plot each (PRD §12 farm area), walked
 * on even numbers, GI-confirmed when walked.
 * @param n Farmer number, 1-based.
 * @param cropId The `crop_id` filter, or null.
 * @returns The row, or undefined past the seed.
 */
function farmerRow(n: number, cropId: string | null): FarmerRow | undefined {
  const f = mockState.farmers[n - 1];
  if (!f) return undefined;
  const village = MOCK_VILLAGES.find((v) => v.name_en === f.address?.village);
  const lots = REF_LOT_FARMERS.includes(n) && (cropId === null || cropId === CROP_ID) ? 1 : 0;
  return {
    id: f.id,
    code: f.code,
    name: f.name,
    name_local: f.name_local,
    status: f.status,
    village_id: village?.id ?? null,
    village: village?.name_en ?? null,
    block: village?.block ?? null,
    plots: 1,
    declared_area: q(0.5, 'acre'),
    walked_area: q(n % 2 === 0 ? 0.45 : 0, 'acre'),
    lots,
    lots_complete: lots,
  };
}

/**
 * Farmer rows matching the dashboard filters of a request URL.
 * @param url The request URL (`crop_id`, `district`, `block`, `village_id`).
 * @returns Matching rows in onboarding order.
 */
function rowsFor(url: URL): FarmerRow[] {
  const p = url.searchParams;
  return mockState.farmers
    .map((_, i) => farmerRow(i + 1, p.get('crop_id')))
    .filter((row): row is FarmerRow => {
      if (!row) return false;
      const village = MOCK_VILLAGES.find((v) => v.id === row.village_id);
      return (
        (!p.get('village_id') || row.village_id === p.get('village_id')) &&
        (!p.get('block') || row.block === p.get('block')) &&
        (!p.get('district') || village?.district === p.get('district'))
      );
    });
}

/**
 * Land Area Analytics numbers of some farmer rows.
 * @param rows Rows in the group.
 * @returns The group's `AreaStats`.
 */
function areaStats(rows: FarmerRow[]): AreaStats {
  const walked = rows.filter((r) => Number(r.walked_area.value) > 0);
  const declared = rows.length * 0.5;
  const gi = walked.length * 0.5;
  return {
    plots: rows.length,
    walked_plots: walked.length,
    declared_area: q(declared, 'acre'),
    walked_area: q(walked.length * 0.45, 'acre'),
    walked_declared_area: q(gi, 'acre'),
    gi_confirmed_area: q(gi, 'acre'),
    gi_confirmed_share: declared ? q((gi / declared) * 100, '%', 1) : null,
  };
}

/**
 * Groups rows by a key, keeping first-seen order sorted by key.
 * @param rows Rows to group.
 * @param key Group key of a row.
 * @returns `[key, rows]` pairs sorted by key.
 */
function groupBy(rows: FarmerRow[], key: (row: FarmerRow) => string): [string, FarmerRow[]][] {
  const groups = new Map<string, FarmerRow[]>();
  for (const row of rows) groups.set(key(row), [...(groups.get(key(row)) ?? []), row]);
  return [...groups.entries()].sort(([a], [b]) => a.localeCompare(b));
}

/**
 * The dashboard body for the filters of a request URL.
 * @param url The request URL.
 * @returns A `Dashboard`.
 */
function dashboard(url: URL): Schemas['Dashboard'] {
  const rows = rowsFor(url);
  const lots = rows.reduce((sum, r) => sum + r.lots, 0);
  return {
    fpo_id: MOCK_FPO_ID,
    completeness: { lots, complete_lots: lots, complete: lots ? q(100, '%', 1) : null },
    stages: STAGES.map((stage) => ({ stage, done: lots, in_progress: 0, not_started: 0 })),
    flags: { hold: 0, warn: 13, info: 0 },
    batches: { created: 0, graded: 0, packed: 0, published: 1 },
    land_area: {
      total: areaStats(rows),
      by_block: groupBy(rows, (r) => r.block ?? '').map(([block, group]) => ({
        block: block || null,
        ...areaStats(group),
      })),
      by_village: groupBy(rows, (r) => `${r.block ?? ''}/${r.village ?? ''}`).map(([, group]) => ({
        village_id: group[0]?.village_id ?? null,
        village: group[0]?.village ?? null,
        block: group[0]?.block ?? null,
        ...areaStats(group),
      })),
    },
    finished_goods: {
      batches: 1,
      packed: q(20, 'kg'),
      items: [
        {
          batch_id: 'b0000000-0000-4000-8000-000000000001',
          code: 'FGP8T4033HM7',
          status: 'published',
          pack_date: '2026-07-30',
          packed: q(20, 'kg'),
          remaining: q(20, 'kg'),
          scans: 2,
        },
      ],
    },
    scans: { total: 2, last_7_days: 1 },
    sync_health: [
      {
        network_type: '2g',
        entries: 12,
        save_to_ack_p50: q(6000, 'ms', 0),
        save_to_ack_p95: q(14000, 'ms', 0),
        photo_upload_p50: q(21000, 'ms', 0),
        photo_upload_p95: q(48000, 'ms', 0),
        failure_rate: q(33.3, '%', 1),
      },
      {
        network_type: 'lte',
        entries: 40,
        save_to_ack_p50: q(800, 'ms', 0),
        save_to_ack_p95: q(2100, 'ms', 0),
        photo_upload_p50: null,
        photo_upload_p95: null,
        failure_rate: q(2.4, '%', 1),
      },
    ],
  };
}

/**
 * Cuts a list into a `Page[T]` with the offset as the cursor (the real API's cursor is opaque).
 * @param items Every item.
 * @param url The request URL (`cursor`, `limit`).
 * @returns One page.
 */
function page<T>(items: T[], url: URL) {
  const start = Number(url.searchParams.get('cursor') ?? 0);
  const limit = Number(url.searchParams.get('limit') ?? 50);
  const end = start + limit;
  return { items: items.slice(start, end), next_cursor: String(end), has_more: end < items.length };
}

export const dashboardHandlers = [
  http.get('/v1/villages', ({ request }) =>
    authed(request)
      ? HttpResponse.json(page(MOCK_VILLAGES, new URL(request.url)))
      : fail(401, 'unauthorized'),
  ),
  http.get('/v1/dashboard/fpo/:fpoId', ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    if (params['fpoId'] !== MOCK_FPO_ID) return fail(404, 'not_found');
    return HttpResponse.json(dashboard(new URL(request.url)));
  }),
  // `?fields=` keeps only the named keys; unknown names are a 422 like the API.
  http.get('/v1/dashboard/fpo/:fpoId/farmers', ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    if (params['fpoId'] !== MOCK_FPO_ID) return fail(404, 'not_found');
    const url = new URL(request.url);
    const fields = url.searchParams.get('fields')?.split(',');
    const rows = rowsFor(url);
    if (fields?.some((f) => !(f in (rows[0] ?? { id: '' })))) return fail(422, 'validation_error');
    const picked = fields
      ? rows.map((r) => Object.fromEntries(Object.entries(r).filter(([k]) => fields.includes(k))))
      : rows;
    return HttpResponse.json(page(picked, url));
  }),
  http.get('/v1/audit-log', ({ request }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    if (!mockState.roles.includes('fpo_admin')) return fail(403, 'forbidden');
    const url = new URL(request.url);
    const p = url.searchParams;
    const rows = AUDIT_ROWS.filter(
      (r) =>
        (!p.get('actor_user_id') || r.actor_user_id === p.get('actor_user_id')) &&
        (!p.get('entity_type') || r.entity_type === p.get('entity_type')) &&
        (!p.get('entity_id') || r.entity_id === p.get('entity_id')) &&
        (!p.get('from') || Date.parse(r.at) >= Date.parse(p.get('from') ?? '')) &&
        (!p.get('to') || Date.parse(r.at) < Date.parse(p.get('to') ?? '')),
    );
    return HttpResponse.json(page(rows, url));
  }),
  http.get('/v1/fpos/:fpoId', ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    if (params['fpoId'] !== MOCK_FPO_ID) return fail(404, 'not_found');
    return HttpResponse.json<Schemas['FpoOut']>({
      id: MOCK_FPO_ID,
      code: 'VIRUDHAI_SCFC_VINOBA_BHAVA_FPO',
      name: 'Virudhai SCFC Vinoba Bhava FPO',
      kind: 'fpo',
      address: { village: 'P Thottiyangulam', block: 'Tiruchuli', district: 'Virudhunagar' },
      address_line: 'P Thottiyangulam, Tiruchuli, Virudhunagar',
      fssai_no: 'DEMO-FSSAI-0001',
      gi_authorised_user_no: 'DEMO-GI-AU-883',
      public_show_farmer_names: false,
      bbox: null,
    });
  }),
  http.get('/v1/config/fields', ({ request }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    /**
     * One field spec.
     * @param name Payload key.
     * @param en English label.
     * @param required Whether a payload needs it.
     * @param visibility Who may see it.
     * @returns A `FieldSpec`.
     */
    const field = (
      name: string,
      en: string,
      required: boolean,
      visibility: Schemas['FieldSpec']['visibility'],
    ): Schemas['FieldSpec'] => ({
      name,
      label: { en, ta: en },
      required,
      enabled: true,
      visibility,
      stage: 'onboarding',
      type: 'text',
      core: required,
    });
    return HttpResponse.json({
      farmer: [
        field('name', 'Name', true, 'public'),
        field('phone', 'Mobile number', true, 'internal'),
      ],
      plot: [field('declared_area', 'Farm area', true, 'public')],
    });
  }),
];
