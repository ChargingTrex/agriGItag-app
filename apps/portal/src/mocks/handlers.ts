/**
 * MSW request handlers: a mock of the API for tests, `npm run dev:mock` and the Playwright mock-mode specs.
 * Serves: plan §7.3 P00 (MSW from spec; login passes with MSW), P01 (identity + registry handlers for the
 * Members screens, Stage 0 approval) and P02 (flags list/detail/resolve, lot events with evidence photos,
 * farmer plots, plot correction; FR70, Dataflow "Review & flags"), P03 (lots, batch create with shares and
 * GI re-check, second sign-off, features, `/v1/me`; FR9, FR29, FR60), P04 (batch list, readings, grade,
 * instruments, standards profile, grading approve, final packing, publish, builds with a simulated worker, rebuild,
 * qr.png, labels.pdf; FR15, FR48, FR49, FR62) and P08 (field config, import templates and CSV imports with dry
 * run; gap analysis "Master data uploads"). Called by: src/mocks/browser.ts,
 * src/test/setup.ts (Node server), tests (MOCK_* constants, `mockState`, `resetMockData`).
 *
 * Every body is typed with the generated `components` schemas, so a contract change breaks
 * `npm run typecheck` here. State (farmers, processors, plots, flags, lots, batches, grades, readings, builds,
 * features, import calls, the session's user and roles, the refresh "cookie") is module-level and reset by
 * `resetMockData` after each test.
 */
import { http, HttpResponse } from 'msw';
import type { components } from '../api/generated/schema';
import { GI_ONLY_HOLD_CODES, splitShares, toGrams } from '../features/batches/batchModel';

type Schemas = components['schemas'];
type Health = Schemas['Health'];
type ErrorEnvelope = Schemas['ErrorEnvelope'];
type FarmerOut = Schemas['FarmerOut'];
type FarmerStatus = Schemas['FarmerStatus'];
type PlotOut = Schemas['PlotOut'];
type ProcessorOut = Schemas['ProcessorOut'];
type ProcessorIn = Schemas['ProcessorIn'];
type SessionOut = Schemas['SessionOut'];
type PinRequiredOut = Schemas['PinRequiredOut'];
type FlagOut = Schemas['FlagOut'];
type EventOut = Schemas['EventOut'];
type Role = Schemas['Role'];
type LotOut = Schemas['LotOut'];
type BatchOut = Schemas['BatchOut'];
type BatchIn = Schemas['BatchIn'];
type BuildOut = Schemas['BuildOut'];
type FieldSpec = Schemas['FieldSpec'];
type ImportReport = Schemas['ImportReport'];

/** The SMS code the mock accepts. */
export const MOCK_OTP = '123456';
/** The PIN the mock accepts for an office user whose PIN is set. */
export const MOCK_PIN = '1234';
/** A PIN the mock answers with `pin_locked`. */
export const MOCK_LOCKED_PIN = '0000';
/** Ten-digit number of an office user signing in for the first time (`pin_set: false`). */
export const MOCK_NEW_USER_PHONE = '9000000001';
/** Prefix of mock access tokens; each refresh issues a new one (`mock-access-token-<n>`), like the real API. */
export const MOCK_ACCESS_TOKEN = 'mock-access-token';
export const MOCK_FPO_ID = '0b9d6a52-3f7e-4c1a-9a51-6d3c1f0e2a10';
export const MOCK_GI_TAG_ID = '5a1f3c2e-8d4b-4e6a-b7c9-1e2d3f4a5b6c';
export const MOCK_PLOT_ID = '7c3e9b1a-2d4f-4a6b-8c0d-9e1f2a3b4c5d';
/** A map-pin plot of the same farmer that waits for review (FR70). */
export const MOCK_REVIEW_PLOT_ID = '7c3e9b1a-2d4f-4a6b-8c0d-9e1f2a3b4c5e';
/** The farmer's lot that carries a hold flag (yield over the ceiling). */
export const MOCK_LOT_ID = '1a2b3c4d-5e6f-4a7b-8c9d-0e1f2a3b4c5d';
/** Hold on the lot (yield over the ceiling, assigned to the FPO admin). */
export const MOCK_HOLD_FLAG_ID = 'f0000000-0000-7000-8000-000000000001';
/** Warn on the lot (quantity chain). */
export const MOCK_QTY_FLAG_ID = 'f0000000-0000-7000-8000-000000000002';
/** Warn on the map-pin plot. */
export const MOCK_PIN_FLAG_ID = 'f0000000-0000-7000-8000-000000000003';
/** Info on an event, already cleared. */
export const MOCK_CLEARED_FLAG_ID = 'f0000000-0000-7000-8000-000000000004';
/** Escalated practice-tag warn on the lot. */
export const MOCK_PRACTICE_FLAG_ID = 'f0000000-0000-7000-8000-000000000005';
/** Off-plot warn on an event. */
export const MOCK_EVENT_FLAG_ID = 'f0000000-0000-7000-8000-000000000006';
const MOCK_EVENT_ID = 'e0000000-0000-7000-8000-000000000001';
/** Id of the first pending farmer. */
export const MOCK_PENDING_FARMER_ID = farmerId(1);
/** Id of an active farmer who owns MOCK_PLOT_ID. */
export const MOCK_ACTIVE_FARMER_ID = farmerId(10);
/** Farmers in the seed: 2 pending, 1 suspended, the rest active. More than one page of 50. */
export const MOCK_FARMER_COUNT = 57;
/** User id of the signed-in office user (`GET /v1/me`); tests switch it to act as a second admin. */
export const MOCK_USER_ID = 'a0000000-0000-7000-8000-000000000001';
/** The PRD §12 reference lots, received, GI eligible: 100, 200 and 20 kg. */
export const MOCK_REF_LOT_IDS = [lotId(1), lotId(2), lotId(3)] as const;
/** A received lot whose plot is outside the GI region: the lot stays `gi_eligible`, the plot carries the hold. */
export const MOCK_OUT_OF_GI_LOT_ID = lotId(4);
/** The plot of MOCK_OUT_OF_GI_LOT_ID, with an open `plot_outside_gi_region` hold flag (B08 plot check). */
export const MOCK_OUT_OF_GI_PLOT_ID = '7c3e9b1a-2d4f-4a6b-8c0d-9e1f2a3b4c60';
/** Open hold flag on MOCK_OUT_OF_GI_PLOT_ID. */
export const MOCK_PLOT_HOLD_FLAG_ID = 'f0000000-0000-7000-8000-000000000007';
/** A received lot with no packing event (the server batches it from intake kg). */
export const MOCK_UNPACKED_LOT_ID = lotId(6);
/** A lot that is ready for sale but has no intake yet. */
export const MOCK_WAITING_LOT_ID = lotId(5);

/** The seed instrument (moisture meter) and the chilli standards profile version the mock grades on. */
export const MOCK_INSTRUMENT_ID = 'd0000000-0000-7000-8000-000000000001';
export const MOCK_PROFILE_VERSION_ID = 'e1000000-0000-7000-8000-000000000001';
const MOCK_PROFILE_ID = 'e1000000-0000-7000-8000-000000000000';

/** Mutable mock state. `signedIn` stands in for the httpOnly refresh cookie. */
export const mockState = {
  signedIn: false,
  /** Roles of the signed-in office user; tests set `['field_officer']` before rendering. */
  roles: ['fpo_admin'] as Role[],
  farmers: seedFarmers(),
  processors: [] as ProcessorOut[],
  plots: seedPlots(),
  flags: seedFlags(),
  lots: seedLots(),
  batches: [] as BatchOut[],
  /** Latest grade computation per batch id (`GET /v1/batches/{id}/grade`); tests add them. */
  grades: {} as Record<string, Schemas['GradeOut']>,
  /** Quality readings on batches; tests add them. */
  readings: [] as Schemas['QualityReadingOut'][],
  /** Public page builds; `GET …/builds` turns a queued build into `built` after showing it once (the worker). */
  builds: [] as BuildOut[],
  /** True: the mock worker never runs, so builds stay `queued` (B10 after a broker or S3 failure). */
  holdBuilds: false,
  userId: MOCK_USER_ID,
  /** `GET /v1/config/features`; tests lower `second_signoff_threshold_kg`. */
  features: seedFeatures(),
  /** Every `POST /v1/imports/{kind}` received, in order: the file text and the `dry_run` flag. */
  imports: [] as { kind: string; dryRun: boolean; text: string }[],
  /** The `users.is_super_admin` flag: adds `super_admin` to the session roles and `/v1/me`; villages need it. */
  superAdmin: false,
};

/** Restores the seed state (called after every test). */
export function resetMockData(): void {
  mockState.signedIn = false;
  mockState.roles = ['fpo_admin'];
  mockState.farmers = seedFarmers();
  mockState.processors = [];
  mockState.plots = seedPlots();
  mockState.flags = seedFlags();
  mockState.imports = [];
  mockState.superAdmin = false;
  mockState.lots = seedLots();
  mockState.batches = [];
  mockState.grades = {};
  mockState.readings = [];
  mockState.builds = [];
  mockState.holdBuilds = false;
  mockState.userId = MOCK_USER_ID;
  mockState.features = seedFeatures();
}

/**
 * A deterministic lot UUID.
 * @param n Sequence number, 1 upwards.
 * @returns The UUID.
 */
function lotId(n: number): string {
  return `10000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
}

/**
 * The FPO's feature flags as `features.yaml` ships them.
 * @returns A `Features` body.
 */
function seedFeatures(): Schemas['Features'] {
  return {
    boundary_walk: true,
    farmer_pin_login: false,
    grading_loss_warn_pct: 40,
    id_document_capture: false,
    otp_daily_cap: 10,
    producer_groups: false,
    second_signoff_threshold_kg: 5000,
    sync_push_max_bytes: 1048576,
    sync_push_max_entries: 500,
    wifi_only_photos_default: true,
  };
}

/**
 * Builds the seed lots: the reference trio, the held lot (MOCK_LOT_ID), a lot on an out-of-GI plot, one without
 * intake and one without a packing event.
 * @returns Seven lots of MOCK_FPO_ID.
 */
function seedLots(): LotOut[] {
  /**
   * One lot.
   * @param id Lot id.
   * @param n Farmer sequence number.
   * @param kg Packed kg.
   * @param extra Overrides.
   * @returns The lot.
   */
  const lot = (id: string, n: number, kg: string, extra: Partial<LotOut> = {}): LotOut => ({
    id,
    code: `VSV-${String(n).padStart(4, '0')}-L1`,
    crop_id: '3d2c1b0a-9f8e-4d7c-8b6a-5f4e3d2c1b0a',
    farmer_id: farmerId(n),
    plot_id: MOCK_PLOT_ID,
    season_label: '2026',
    status: 'received',
    harvested: { value: kg, unit: 'kg' },
    packed: { value: kg, unit: 'kg' },
    ready_at: '2026-02-14T06:00:00Z',
    gi_eligible: true,
    gi_hold_reason: null,
    ...extra,
  });
  return [
    lot(MOCK_REF_LOT_IDS[0], 1, '100'),
    lot(MOCK_REF_LOT_IDS[1], 4, '200'),
    lot(MOCK_REF_LOT_IDS[2], 5, '20'),
    lot(MOCK_LOT_ID, 10, '272.6', {
      code: 'VSV-0010-L2',
      gi_eligible: false,
      gi_hold_reason: 'flags: yield_over_ceiling',
    }),
    lot(MOCK_OUT_OF_GI_LOT_ID, 6, '50', { plot_id: MOCK_OUT_OF_GI_PLOT_ID }),
    lot(MOCK_WAITING_LOT_ID, 7, '80', { status: 'ready_for_sale' }),
    lot(MOCK_UNPACKED_LOT_ID, 8, '40', { packed: null }),
  ];
}

/**
 * One field of the mock field config.
 * @param name Payload key / CSV column.
 * @param type Value kind.
 * @param en English label.
 * @param required Whether a value is needed.
 * @returns The field, enabled, internal, master-data stage (the screen reads only name, type, label, required).
 */
const field = (name: string, type: FieldSpec['type'], en: string, required = false): FieldSpec => ({
  name,
  type,
  required,
  enabled: true,
  core: required,
  visibility: 'internal',
  stage: 'master_data',
  label: { en, ta: `${en} (ta)` },
});

/** `GET /v1/config/fields` for the demo tenant: the farmer, village and input entities of apps/api/config. */
export const MOCK_FIELDS: Record<string, FieldSpec[]> = {
  farmer: [
    field('name', 'text', 'Name', true),
    field('name_local', 'text', 'Name in Tamil'),
    field('phone', 'phone', 'Mobile number'),
    field('lang', 'choice', 'Language'),
    field('village_id', 'id', 'Village'),
    field('address', 'address', 'Address'),
    field('gi_authorised_user_no', 'text', 'GI authorised user number'),
    field('no_smartphone', 'boolean', 'No smartphone'),
    field('photo_key', 'photo', 'Farmer photo'),
  ],
  village: [
    field('lgd_code', 'text', 'LGD village code', true),
    field('name_en', 'text', 'Village name', true),
    field('district', 'text', 'District', true),
    field('state', 'text', 'State', true),
    field('pincode', 'text', 'PIN code'),
  ],
  input: [
    field('name_en', 'text', 'Product name', true),
    field('manufacturer', 'text', 'Manufacturer'),
    field('category', 'choice', 'Category', true),
    field('unit', 'text', 'Unit', true),
    field('photo_key', 'photo', 'Product photo'),
  ],
};

const IMPORT_ENTITY: Record<string, string> = {
  farmers: 'farmer',
  villages: 'village',
  inputs: 'input',
};

/**
 * Template columns like the API's `imports.template_columns`: CSV-capable fields, plus the farmer village key.
 * @param kind farmers, villages or inputs.
 * @returns The header names.
 */
function templateColumns(kind: string): string[] {
  const csvTypes = ['text', 'number', 'integer', 'boolean', 'date', 'phone', 'choice'];
  const columns = (MOCK_FIELDS[IMPORT_ENTITY[kind] ?? ''] ?? [])
    .filter((f) => csvTypes.includes(f.type))
    .map((f) => f.name);
  return kind === 'farmers' ? [...columns, 'village_lgd_code'] : columns;
}

/**
 * A simplified server import: a missing required value gives `field_required`, a malformed phone
 * `import_row_invalid`; a commit of farmers adds the accepted rows as pending farmers. Rows are numbered by
 * line (the fixtures have no quoted line breaks). Side effect: a farmers commit appends to `mockState.farmers`.
 * @param kind farmers, villages or inputs.
 * @param text The uploaded CSV.
 * @param dryRun Report only.
 * @returns The row-level report.
 */
function mockImport(kind: string, text: string, dryRun: boolean): ImportReport {
  const lines = text.split(/\r?\n/);
  const header = (lines[0] ?? '').split(',');
  const required = (MOCK_FIELDS[IMPORT_ENTITY[kind] ?? ''] ?? []).filter((f) => f.required);
  const report: ImportReport = { dry_run: dryRun, accepted: 0, rejected: [] };
  lines.slice(1).forEach((line, index) => {
    if (!line.trim()) return;
    const cells = Object.fromEntries(line.split(',').map((v, i) => [header[i] ?? '', v.trim()]));
    const missing = required.find((f) => !cells[f.name]);
    const row = index + 2;
    if (missing) report.rejected.push({ row, code: 'field_required', field: missing.name });
    else if (cells['phone'] && !/^\+91\d{10}$/.test(cells['phone']))
      report.rejected.push({ row, code: 'import_row_invalid', field: 'phone' });
    else {
      report.accepted += 1;
      if (kind === 'farmers' && !dryRun) {
        const n = mockState.farmers.length + 1;
        mockState.farmers.push({
          ...(seedFarmers()[0] as FarmerOut),
          id: farmerId(n),
          code: `VSV-${String(n).padStart(4, '0')}`,
          name: cells['name'] ?? '',
          name_local: null,
        });
      }
    }
  });
  return report;
}

/**
 * A deterministic farmer UUID.
 * @param n Sequence number, 1 upwards.
 * @returns The UUID.
 */
function farmerId(n: number): string {
  return `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
}

/**
 * Builds the seed farmers in onboarding order.
 * @returns MOCK_FARMER_COUNT farmers: #1–2 pending, #3 suspended, the rest active.
 */
function seedFarmers(): FarmerOut[] {
  const villages = ['Sattur', 'Aruppukottai', 'Srivilliputhur'];
  return Array.from({ length: MOCK_FARMER_COUNT }, (_, index) => {
    const n = index + 1;
    const status: FarmerStatus = n <= 2 ? 'pending' : n === 3 ? 'suspended' : 'active';
    const village = villages[n % villages.length] ?? 'Sattur';
    return {
      id: farmerId(n),
      fpo_id: MOCK_FPO_ID,
      user_id: null,
      code: `VSV-${String(n).padStart(4, '0')}`,
      name: n === 1 ? 'Muthu Kumar' : `Farmer ${String(n).padStart(2, '0')}`,
      name_local: n === 1 ? 'முத்து குமார்' : null,
      photo_key: null,
      address: { village, district: 'Virudhunagar', state: 'Tamil Nadu' },
      address_line: `${village}, Virudhunagar, Tamil Nadu`,
      village_id: null,
      gi_authorised_user_no: n === 10 ? 'GI-AU-883-0010' : null,
      status,
      approved_by: status === 'pending' ? null : MOCK_FPO_ID,
      approved_at: status === 'pending' ? null : '2026-10-01T09:30:00Z',
      no_smartphone: n % 7 === 0,
    };
  });
}

/**
 * Builds the seed plots: one checked live-GPS plot and one map-pin plot waiting for review.
 * @returns Two plots of MOCK_ACTIVE_FARMER_ID.
 */
function seedPlots(): PlotOut[] {
  const plot: PlotOut = {
    id: MOCK_PLOT_ID,
    fpo_id: MOCK_FPO_ID,
    farmer_id: MOCK_ACTIVE_FARMER_ID,
    code: 'VSV-0010-P1',
    pin: { lat: 9.5121, lon: 77.9606, accuracy_m: 6 },
    pin_method: 'live_gps',
    pin_device_time: '2026-10-02T08:00:00Z',
    pin_gps_time: '2026-10-02T08:00:01Z',
    pin_server_received_at: '2026-10-02T08:05:00Z',
    declared_area: { value: '2.50', unit: 'acre' },
    land_record_ref: null,
    walked_area: { value: '3.20', unit: 'acre' },
    area_gap_pct: '28.0',
    area_gap_exceeds: true,
    farming_type: 'rainfed',
    irrigation_source: null,
    soil_type: 'black',
    location_status: 'near_edge',
    location_method_label: 'Live GPS pin',
    region_check: null,
    revision_no: 1,
    reviewed_at: null,
    review_method: null,
    review_outcome: null,
  };
  return [
    plot,
    {
      ...plot,
      id: MOCK_REVIEW_PLOT_ID,
      code: 'VSV-0010-P2',
      pin: { lat: 9.6012, lon: 78.0101, accuracy_m: null },
      pin_method: 'map_pin',
      pin_gps_time: null,
      walked_area: null,
      area_gap_pct: null,
      area_gap_exceeds: false,
      location_status: 'needs_review',
      location_method_label: 'Map pin',
    },
  ];
}

/**
 * Builds the seed flags, newest first, one or more per rule family the detail page renders.
 * @returns Seven flags of MOCK_FPO_ID.
 */
function seedFlags(): FlagOut[] {
  const base = {
    fpo_id: MOCK_FPO_ID,
    status: 'open',
    assigned_role: 'field_officer',
    resolved_by: null,
    resolution_reason_code: null,
    resolution_note: null,
    resolved_at: null,
  } as const;
  return [
    {
      ...base,
      id: MOCK_EVENT_FLAG_ID,
      subject_type: 'event',
      subject_id: MOCK_EVENT_ID,
      rule_code: 'event_off_plot',
      severity: 'warn',
      details: { pin_radius_m: 200, buffer_m: 50 },
      raised_at: '2026-02-16T06:00:00Z',
    },
    {
      ...base,
      id: MOCK_PRACTICE_FLAG_ID,
      subject_type: 'lot',
      subject_id: MOCK_LOT_ID,
      rule_code: 'practice_tag_contradiction',
      severity: 'warn',
      status: 'escalated',
      assigned_role: 'fpo_admin',
      details: {
        declared: ['organic'],
        derived: ['inorganic'],
        input_categories: ['chemical_fertilizer'],
      },
      raised_at: '2026-02-15T06:00:00Z',
    },
    {
      ...base,
      id: MOCK_CLEARED_FLAG_ID,
      subject_type: 'event',
      subject_id: MOCK_EVENT_ID,
      rule_code: 'gps_poor_accuracy',
      severity: 'info',
      status: 'cleared',
      details: { accuracy_m: 42, limit_m: 30 },
      raised_at: '2026-02-14T06:00:00Z',
      resolved_by: MOCK_FPO_ID,
      resolution_reason_code: 'field_visit',
      resolved_at: '2026-02-15T09:00:00Z',
    },
    {
      ...base,
      id: MOCK_PIN_FLAG_ID,
      subject_type: 'plot',
      subject_id: MOCK_REVIEW_PLOT_ID,
      rule_code: 'plot_map_pin',
      severity: 'warn',
      details: {},
      raised_at: '2026-02-14T05:00:00Z',
    },
    {
      ...base,
      id: MOCK_QTY_FLAG_ID,
      subject_type: 'lot',
      subject_id: MOCK_LOT_ID,
      rule_code: 'quantity_mismatch',
      severity: 'warn',
      details: {
        harvested: '300',
        packed: '272.6',
        received: '400',
        unit: 'kg',
        problems: [{ from: 'packed', to: 'received', variance_pct: '46.7' }],
      },
      raised_at: '2026-02-14T04:00:00Z',
    },
    {
      ...base,
      id: MOCK_HOLD_FLAG_ID,
      subject_type: 'lot',
      subject_id: MOCK_LOT_ID,
      rule_code: 'yield_over_ceiling',
      severity: 'hold',
      assigned_role: 'fpo_admin',
      details: {
        harvested_kg: '1350',
        declared_acres: '1.00',
        ceiling_kg_per_acre: '1000',
        warn_margin_pct: '20',
        hold_margin_pct: '30',
      },
      raised_at: '2026-02-14T03:00:00Z',
    },
    {
      ...base,
      id: MOCK_PLOT_HOLD_FLAG_ID,
      subject_type: 'plot',
      subject_id: MOCK_OUT_OF_GI_PLOT_ID,
      rule_code: 'plot_outside_gi_region',
      severity: 'hold',
      assigned_role: 'fpo_admin',
      details: { distance_m: 4200 },
      raised_at: '2026-02-13T03:00:00Z',
    },
  ];
}

// Presigned variant links stand in as data URLs, so `dev:mock` shows a thumbnail without storage.
const THUMB =
  'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="96" height="96"%3E%3Crect width="96" height="96" fill="%232e7d32"/%3E%3C/svg%3E';

/** The lot's timeline: one harvest with a verified photo. */
const lotEvents: EventOut[] = [
  {
    id: MOCK_EVENT_ID,
    event_type: 'harvest',
    instance_no: 1,
    status: 'submitted',
    occurred_on: '2026-02-12',
    occurred_end_on: null,
    version_no: 1,
    change_kind: 'create',
    payload: { quantity: { value: '1350', unit: 'kg' } },
    entered_by_user_id: MOCK_FPO_ID,
    on_behalf_of_farmer_id: null,
    is_system_generated: false,
    reason_code: null,
    photos: [
      {
        id: 'b0000000-0000-7000-8000-000000000001',
        status: 'verified',
        variants: { thumb_url: THUMB, medium_url: THUMB, width: 96, height: 96 },
      },
    ],
  },
];

/**
 * The mock session with the roles currently set in `mockState`.
 * @param token Access token to hand out.
 * @returns A `SessionOut`.
 */
const session = (token = MOCK_ACCESS_TOKEN): SessionOut => ({
  kind: 'session',
  access_token: token,
  refresh_token: null,
  expires_in: 900,
  roles: [...mockState.roles, ...(mockState.superAdmin ? ['super_admin'] : [])],
  fpo_id: MOCK_FPO_ID,
});

/**
 * An error envelope response.
 * @param status HTTP status.
 * @param code Registered error code.
 * @param details Optional details object.
 * @returns The mock response.
 */
const fail = (
  status: number,
  code: string,
  details: Record<string, unknown> | null = null,
): Response =>
  HttpResponse.json<ErrorEnvelope>({ error: { code, message: code, details } }, { status });

/**
 * Reads the JSON body as a string map; anything else becomes an empty object.
 * @param request The intercepted request.
 * @returns The body fields.
 */
async function body(request: Request): Promise<Record<string, unknown>> {
  const json: unknown = await request.json().catch(() => null);
  return typeof json === 'object' && json !== null ? (json as Record<string, unknown>) : {};
}

/**
 * Whether the request carries the mock session's access token.
 * @param request The intercepted request.
 * @returns True when signed in.
 */
const authed = (request: Request) =>
  request.headers.get('Authorization')?.startsWith(`Bearer ${MOCK_ACCESS_TOKEN}`) === true;

/** A 1×1 transparent PNG, the mock QR image. */
const PNG_1PX = Uint8Array.from(
  atob(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
  ),
  (c) => c.charCodeAt(0),
);

/**
 * Adds a queued page build as B09 `publish` / B10 `rebuild` do: `current_build_no` + 1.
 * @param batch The batch (mutated).
 * @param trigger `publish` or `rebuild`.
 * @returns The new build row.
 */
function queueBuild(batch: BatchOut, trigger: 'publish' | 'rebuild'): BuildOut {
  batch.current_build_no += 1;
  const build: BuildOut = {
    id: crypto.randomUUID(),
    batch_id: batch.id,
    build_no: batch.current_build_no,
    generation: batch.current_build_no,
    status: 'queued',
    trigger,
    built_at: null,
    error: null,
    html_key: null,
    json_key: null,
    qr_key: null,
  };
  mockState.builds.push(build);
  return build;
}

/**
 * The batch of a `:batchId` route, if the mock has it.
 * @param id The route parameter.
 * @returns The batch or undefined.
 */
const findBatch = (id: unknown) => mockState.batches.find((b) => b.id === id);

/**
 * The `open_hold_flag` reasons of B09's gates: active holds on the batch, its lots and their plots; in a non-GI
 * batch the GI-only codes do not block (D-041, modelled here until B16 merges).
 * @param batch The batch.
 * @returns One reason per blocking hold.
 */
function holdReasons(batch: BatchOut): Record<string, unknown>[] {
  const lotIds = batch.shares.map((s) => s.lot_id);
  const subjects = new Set([
    batch.id,
    ...lotIds,
    ...mockState.lots.filter((l) => lotIds.includes(l.id)).map((l) => l.plot_id),
  ]);
  return mockState.flags
    .filter(
      (f) =>
        subjects.has(f.subject_id) &&
        f.severity === 'hold' &&
        (f.status === 'open' || f.status === 'escalated') &&
        (batch.gi_label_requested || !GI_ONLY_HOLD_CODES.includes(f.rule_code)),
    )
    .map((f) => ({ code: 'open_hold_flag', rule_code: f.rule_code, flag_id: f.id }));
}

let issued = 0;

export const handlers = [
  http.get('/v1/healthz', () => HttpResponse.json<Health>({ db: 'ok', redis: 'ok', s3: 'ok' })),
  http.head('/v1/healthz', () => new HttpResponse(null, { status: 200 })),

  // Identity (B02 contract, docs/api/conventions.md "Authentication").
  http.post('/v1/auth/otp/request', () => new HttpResponse(null, { status: 204 })),
  http.post('/v1/auth/otp/verify', async ({ request }) => {
    const { code, phone } = await body(request);
    if (code !== MOCK_OTP) return fail(422, 'otp_invalid');
    const newUser = phone === `+91${MOCK_NEW_USER_PHONE}`;
    return HttpResponse.json<PinRequiredOut>({
      kind: 'pin_required',
      pin_token: newUser ? 'mock-pin-token-new' : 'mock-pin-token',
      expires_in: 300,
      pin_set: !newUser,
    });
  }),
  http.post('/v1/auth/pin/verify', async ({ request }) => {
    const auth = request.headers.get('Authorization');
    const { pin } = await body(request);
    if (auth === 'Bearer mock-pin-token-new' && typeof pin === 'string') {
      mockState.signedIn = true;
      return HttpResponse.json(session());
    }
    if (auth !== 'Bearer mock-pin-token') return fail(401, 'unauthorized');
    if (pin === MOCK_LOCKED_PIN) {
      return fail(409, 'pin_locked', { locked_until: '2026-10-31T10:35:00Z' });
    }
    if (pin !== MOCK_PIN) return fail(422, 'pin_invalid', { attempts_left: 3 });
    mockState.signedIn = true;
    return HttpResponse.json(session());
  }),
  http.post('/v1/auth/refresh', () =>
    mockState.signedIn
      ? HttpResponse.json(session(`${MOCK_ACCESS_TOKEN}-${String(++issued)}`))
      : fail(401, 'unauthorized'),
  ),
  http.post('/v1/auth/logout', () => {
    mockState.signedIn = false;
    return new HttpResponse(null, { status: 204 });
  }),

  // Registry (B03 contract).
  http.get('/v1/farmers', ({ request }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    const query = new URL(request.url).searchParams;
    const status = query.get('status');
    const start = Number(query.get('cursor') ?? '0');
    const limit = Number(query.get('limit') ?? '50');
    const all = mockState.farmers.filter((farmer) => !status || farmer.status === status);
    const end = start + limit;
    return HttpResponse.json({
      items: all.slice(start, end),
      next_cursor: end < all.length ? String(end) : null,
      has_more: end < all.length,
    });
  }),
  http.get('/v1/farmers/:farmerId', ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    const farmer = mockState.farmers.find((item) => item.id === params['farmerId']);
    return farmer ? HttpResponse.json(farmer) : fail(404, 'not_found');
  }),
  http.post('/v1/farmers/:farmerId/approve', ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    const farmer = mockState.farmers.find((item) => item.id === params['farmerId']);
    if (!farmer) return fail(404, 'not_found');
    if (farmer.status !== 'pending') return fail(409, 'farmer_not_pending');
    Object.assign(farmer, {
      status: 'active',
      approved_by: MOCK_FPO_ID,
      approved_at: new Date().toISOString(),
    });
    return HttpResponse.json(farmer);
  }),
  http.get('/v1/plots/:plotId', ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    const plot = mockState.plots.find((item) => item.id === params['plotId']);
    return plot ? HttpResponse.json(plot) : fail(404, 'not_found');
  }),
  http.get('/v1/farmers/:farmerId/plots', ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    const items = mockState.plots.filter((item) => item.farmer_id === params['farmerId']);
    return HttpResponse.json({ items, next_cursor: null, has_more: false });
  }),
  // Plot correction (B03/B14): FPO admin only, reason required. An accepted review closes the plot's open
  // flags the way the server's `rules.check_plot` re-run does (`fixed` / `rule_passed`).
  http.post('/v1/plots/:plotId/correct', async ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    if (!mockState.roles.includes('fpo_admin')) return fail(403, 'forbidden');
    const plot = mockState.plots.find((item) => item.id === params['plotId']);
    if (!plot) return fail(404, 'not_found');
    const input = (await body(request)) as Schemas['PlotCorrection'];
    if (!input.reason_code) return fail(422, 'reason_required');
    if (input.pin) plot.pin = input.pin;
    if (input.review_outcome) {
      plot.review_outcome = input.review_outcome;
      plot.review_method = input.review_method ?? null;
      plot.reviewed_at = new Date().toISOString();
      plot.location_status = input.review_outcome === 'accepted' ? 'confirmed' : 'needs_review';
    }
    plot.revision_no += 1;
    const confirmed = plot.location_status === 'confirmed';
    for (const flag of mockState.flags) {
      if (confirmed && flag.subject_id === plot.id && flag.status === 'open') {
        Object.assign(flag, { status: 'fixed', resolution_reason_code: 'rule_passed' });
      }
    }
    return HttpResponse.json(plot);
  }),

  // Rules & flags (B08 contract).
  http.get('/v1/flags', ({ request }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    const query = new URL(request.url).searchParams;
    const start = Number(query.get('cursor') ?? '0');
    const limit = Number(query.get('limit') ?? '50');
    const { status, severity, assignee } = Object.fromEntries(query);
    const all = mockState.flags.filter(
      (flag) =>
        (!status || flag.status === status) &&
        (!severity || flag.severity === severity) &&
        (!assignee || flag.assigned_role === assignee),
    );
    const end = start + limit;
    return HttpResponse.json({
      items: all.slice(start, end),
      next_cursor: end < all.length ? String(end) : null,
      has_more: end < all.length,
    });
  }),
  http.get('/v1/flags/:flagId', ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    const flag = mockState.flags.find((item) => item.id === params['flagId']);
    return flag ? HttpResponse.json(flag) : fail(404, 'not_found');
  }),
  http.post('/v1/flags/:flagId/resolve', async ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    const flag = mockState.flags.find((item) => item.id === params['flagId']);
    if (!flag) return fail(404, 'not_found');
    const input = (await body(request)) as Schemas['FlagResolveIn'];
    if (!input.reason_code) return fail(422, 'reason_required');
    if (flag.status !== 'open' && flag.status !== 'escalated') return fail(409, 'flag_not_open');
    const admin = mockState.roles.includes('fpo_admin');
    if (!admin && (flag.severity === 'hold' || flag.status === 'escalated')) {
      return fail(403, 'resolution_forbidden');
    }
    const escalated = input.resolution === 'escalated';
    const status = { looks_fine: 'cleared', fixed: 'fixed', escalated: 'escalated' } as const;
    Object.assign(flag, {
      status: status[input.resolution],
      assigned_role: escalated ? 'fpo_admin' : flag.assigned_role,
      resolution_reason_code: input.reason_code,
      resolution_note: input.note ?? null,
      resolved_by: escalated ? null : MOCK_FPO_ID,
      resolved_at: escalated ? null : new Date().toISOString(),
    });
    return HttpResponse.json(flag);
  }),
  http.get('/v1/lots/:lotId/events', ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    if (params['lotId'] !== MOCK_LOT_ID) return fail(404, 'not_found');
    return HttpResponse.json({ items: lotEvents, next_cursor: null, has_more: false });
  }),
  http.get('/v1/crops', () =>
    HttpResponse.json<Schemas['CropOut'][]>([
      {
        id: '3d2c1b0a-9f8e-4d7c-8b6a-5f4e3d2c1b0a',
        code: 'samba_vathal',
        name_en: 'Samba Vathal dry chilli',
        name_local: 'சம்பா வத்தல்',
        lang: 'ta',
        gi_tag_id: MOCK_GI_TAG_ID,
        event_schema: {},
        active: true,
      },
    ]),
  ),
  http.get('/v1/gi-tags/:giTagId/region', ({ params }) =>
    params['giTagId'] === MOCK_GI_TAG_ID
      ? HttpResponse.json<Schemas['GiRegionOut']>({
          geometry: {
            type: 'Polygon',
            coordinates: [
              [
                [77.7, 9.3],
                [78.3, 9.3],
                [78.3, 9.8],
                [77.7, 9.8],
                [77.7, 9.3],
              ],
            ],
          },
          simplified_tolerance_m: 50,
          version: {
            id: '9e8d7c6b-5a4f-4e3d-9c2b-1a0f9e8d7c6b',
            gi_tag_id: MOCK_GI_TAG_ID,
            version_no: 1,
            tolerance_buffer_m: '500',
            taluks: ['Sattur', 'Aruppukottai'],
            source_ref: 'mock',
            licence: 'ODbL-1.0',
            confidence: 'taluk_union',
            effective_from: '2026-01-01',
          },
        })
      : fail(404, 'gi_region_missing'),
  ),
  // Field config and master data imports (B13 contract).
  http.get('/v1/config/fields', ({ request }) =>
    authed(request) ? HttpResponse.json(MOCK_FIELDS) : fail(401, 'unauthorized'),
  ),
  http.get('/v1/imports/:kind/template.csv', ({ request, params }) =>
    authed(request)
      ? HttpResponse.text(`${templateColumns(String(params['kind'])).join(',')}\r\n`, {
          headers: { 'Content-Type': 'text/csv; charset=utf-8' },
        })
      : fail(401, 'unauthorized'),
  ),
  http.post('/v1/imports/:kind', async ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    const kind = String(params['kind']);
    if (kind === 'villages' && !mockState.superAdmin) return fail(403, 'forbidden');
    const file = (await request.formData()).get('file');
    // Not `instanceof Blob`: under Vitest the part is Node's File, not jsdom's Blob.
    if (file === null || typeof file === 'string')
      return fail(422, 'validation_error', { file: 'missing' });
    const text = await file.text();
    const dryRun = new URL(request.url).searchParams.get('dry_run') === 'true';
    mockState.imports.push({ kind, dryRun, text });
    return HttpResponse.json<ImportReport>(mockImport(kind, text, dryRun));
  }),
  http.get('/v1/processors', ({ request }) =>
    authed(request) ? HttpResponse.json(mockState.processors) : fail(401, 'unauthorized'),
  ),
  // Lots and batches (B09 contract).
  http.get('/v1/lots', ({ request }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    const status = new URL(request.url).searchParams.get('status');
    const items = mockState.lots.filter((lot) => !status || lot.status === status);
    return HttpResponse.json({ items, next_cursor: null, has_more: false });
  }),
  http.get('/v1/config/features', () => HttpResponse.json(mockState.features)),
  http.get('/v1/me', ({ request }) =>
    authed(request)
      ? HttpResponse.json<Schemas['MeOut']>({
          user: {
            id: mockState.userId,
            is_super_admin: mockState.superAdmin,
            lang: 'en',
            name: 'Office user',
            name_local: null,
            phone: '+919000000000',
          },
          memberships: mockState.roles.map((role) => ({ fpo_id: MOCK_FPO_ID, role })),
          device: null,
        })
      : fail(401, 'unauthorized'),
  ),
  // Idempotent on `client_id` (200 with the stored batch); refuses with one `gate_not_met` listing every
  // reason (D-033); shares from the lots' kg with the server's rounding; GI re-check from `gi_eligible`.
  http.post('/v1/batches', async ({ request }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    if (!mockState.roles.includes('fpo_admin')) return fail(403, 'forbidden');
    const input = (await body(request)) as unknown as BatchIn;
    const stored = mockState.batches.find((b) => b.id === input.client_id);
    if (stored) return HttpResponse.json(stored);
    if (!mockState.processors.some((p) => p.id === input.processor_id)) {
      return fail(404, 'not_found', { processor_id: input.processor_id });
    }
    const lots = input.lot_ids.map((id) => mockState.lots.find((lot) => lot.id === id));
    if (lots.some((lot) => !lot)) return fail(404, 'not_found', { lot_ids: input.lot_ids });
    const chosen = lots as LotOut[];
    const reasons = chosen
      .filter((lot) => lot.status !== 'received')
      .map((lot) => ({
        code: 'lot_not_received',
        message: 'The lot has no intake yet or is already batched.',
        lot_id: lot.id,
      }));
    if (reasons.length > 0) return fail(409, 'gate_not_met', { reasons });
    // Stand-in for intake kg: packed, else harvested (the mock keeps no intake rows).
    const grams = chosen.map(
      (lot) => [lot.id, toGrams(lot.packed?.value ?? lot.harvested?.value ?? 0)] as const,
    );
    const pct = splitShares(grams);
    const total = grams.reduce((sum, [, g]) => sum + g, 0);
    /**
     * GI re-check as B09 `_gi_check`: whether the lot's plot carries an active hold flag.
     * @param lot The lot.
     * @returns True when the plot is held.
     */
    const plotHeld = (lot: LotOut) =>
      mockState.flags.some(
        (f) =>
          f.subject_id === lot.plot_id &&
          f.severity === 'hold' &&
          (f.status === 'open' || f.status === 'escalated'),
      );
    const batch: BatchOut = {
      id: input.client_id,
      code: `FGP${String(mockState.batches.length + 1).padStart(9, '0')}`,
      superlot_code: null,
      crop_id: chosen[0]?.crop_id ?? '',
      processor_id: input.processor_id,
      created_by: mockState.userId,
      status: 'created',
      current_build_no: 0,
      gi_label_requested: input.gi_label_requested,
      gi_verified: input.gi_label_requested && !chosen.some((l) => !l.gi_eligible || plotHeld(l)),
      gi_block_reasons: input.gi_label_requested
        ? chosen.flatMap((lot) => [
            ...(lot.gi_eligible
              ? []
              : [{ reason: 'lot_on_hold', lot_id: lot.id, detail: lot.gi_hold_reason }]),
            ...(plotHeld(lot) ? [{ reason: 'plot_outside_gi_region', lot_id: lot.id }] : []),
          ])
        : [],
      second_signoff_required: total > toGrams(mockState.features.second_signoff_threshold_kg),
      second_signoff_by: null,
      total_received: { value: String(total / 1000), unit: 'kg' },
      shares: chosen.map((lot, i) => ({
        lot_id: lot.id,
        farmer_id: lot.farmer_id,
        contributed: { value: String((grams[i]?.[1] ?? 0) / 1000), unit: 'kg' },
        share_pct: pct.get(lot.id) ?? '0.000',
      })),
    };
    mockState.batches.push(batch);
    for (const lot of chosen) lot.status = 'batched';
    return HttpResponse.json(batch, { status: 201 });
  }),
  http.get('/v1/batches/:batchId', ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    const batch = mockState.batches.find((b) => b.id === params['batchId']);
    return batch ? HttpResponse.json(batch) : fail(404, 'not_found');
  }),
  http.post('/v1/batches/:batchId/second-signoff', ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    if (!mockState.roles.includes('fpo_admin')) return fail(403, 'forbidden');
    const batch = mockState.batches.find((b) => b.id === params['batchId']);
    if (!batch) return fail(404, 'not_found');
    if (batch.second_signoff_by === null && batch.created_by === mockState.userId) {
      return fail(409, 'gate_not_met', {
        reasons: [
          { code: 'same_approver', message: 'The second sign-off must come from another admin.' },
        ],
      });
    }
    batch.second_signoff_by ??= mockState.userId;
    return HttpResponse.json(batch);
  }),
  // Batch detail (B05 grade and readings, B09 gates, B10 builds). Gate answers list every reason (D-033).
  http.get('/v1/batches', ({ request }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    const query = new URL(request.url).searchParams;
    const status = query.get('status');
    const start = Number(query.get('cursor') ?? 0);
    const limit = Number(query.get('limit') ?? 50);
    const all = mockState.batches.filter((b) => !status || b.status === status);
    const more = start + limit < all.length;
    return HttpResponse.json({
      items: all.slice(start, start + limit),
      has_more: more,
      next_cursor: more ? String(start + limit) : null,
    });
  }),
  http.get('/v1/lots/:lotId', ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    const lot = mockState.lots.find((l) => l.id === params['lotId']);
    return lot ? HttpResponse.json(lot) : fail(404, 'not_found');
  }),
  http.get('/v1/batches/:batchId/readings', ({ request, params }) =>
    authed(request)
      ? HttpResponse.json({
          items: mockState.readings.filter((r) => r.batch_id === params['batchId']),
          has_more: false,
          next_cursor: null,
        })
      : fail(401, 'unauthorized'),
  ),
  http.get('/v1/batches/:batchId/grade', ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    const grade = mockState.grades[String(params['batchId'])];
    return grade ? HttpResponse.json(grade) : fail(404, 'not_found');
  }),
  http.get('/v1/instruments', () =>
    HttpResponse.json({
      items: [
        {
          id: MOCK_INSTRUMENT_ID,
          fpo_id: MOCK_FPO_ID,
          kind: 'moisture_meter',
          make_model: 'Draminski GMM',
          serial_no: 'DR-0042',
          active: true,
          calibrated_on: '2026-06-01',
          calibration_due_on: '2027-06-01',
          calibration_cert_photo_id: null,
        },
      ],
      has_more: false,
      next_cursor: null,
    }),
  ),
  http.get('/v1/standards-profiles', () =>
    HttpResponse.json({
      items: [
        {
          id: MOCK_PROFILE_ID,
          crop_id: '3d2c1b0a-9f8e-4d7c-8b6a-5f4e3d2c1b0a',
          name: 'Dry chilli (Agmark)',
          scheme: 'agmark',
          standard_ref: 'Agmark Chillies Grading and Marking Rules',
          published_version_no: 1,
        },
      ],
      has_more: false,
      next_cursor: null,
    }),
  ),
  http.get('/v1/standards-profiles/:profileId/versions/:versionNo', () =>
    HttpResponse.json({
      id: MOCK_PROFILE_VERSION_ID,
      profile_id: MOCK_PROFILE_ID,
      version_no: 1,
      edition: '2005',
      clause_ref: 'Schedule II',
      status: 'published',
      published_at: '2026-06-01T00:00:00Z',
      rules: {},
    }),
  ),
  http.post('/v1/batches/:batchId/grading/approve', async ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    if (!mockState.roles.includes('fpo_admin')) return fail(403, 'forbidden');
    const batch = findBatch(params['batchId']);
    if (!batch) return fail(404, 'not_found');
    const input = (await body(request)) as unknown as Schemas['GradingApproveIn'];
    const grade = mockState.grades[batch.id];
    const reasons = [
      ...(batch.status === 'created' ? [] : [{ code: 'batch_status' }]),
      ...(grade ? [] : [{ code: 'not_graded' }]),
      ...(grade?.status === 'incomplete' ? [{ code: 'grade_incomplete' }] : []),
      ...(grade?.status === 'declared_above_computed'
        ? [
            {
              code: 'declared_above_computed',
              declared: grade.declared_grade,
              computed: grade.computed_grade,
            },
          ]
        : []),
      ...holdReasons(batch),
    ];
    if (reasons.length > 0 || !grade) return fail(409, 'gate_not_met', { reasons });
    batch.status = 'graded';
    batch.graded = { value: String(input.graded.value), unit: 'kg' };
    batch.computed_grade = grade.computed_grade;
    batch.standards_profile_version_id = grade.profile_version_id;
    return HttpResponse.json(batch);
  }),
  http.post('/v1/batches/:batchId/final-packing', async ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    if (!mockState.roles.includes('fpo_admin')) return fail(403, 'forbidden');
    const batch = findBatch(params['batchId']);
    if (!batch) return fail(404, 'not_found');
    const input = (await body(request)) as unknown as Schemas['FinalPackingIn'];
    const holds = holdReasons(batch);
    if (batch.status !== 'graded' || holds.length > 0) {
      return fail(409, 'gate_not_met', {
        reasons: [
          ...(batch.status === 'graded' ? [] : [{ code: 'grading_not_approved' }]),
          ...holds,
        ],
      });
    }
    if (toGrams(input.packed.value) > toGrams(batch.graded?.value ?? 0)) {
      return fail(409, 'gate_not_met', {
        reasons: [{ code: 'packed_above_graded', graded_kg: batch.graded?.value }],
      });
    }
    batch.status = 'packed';
    batch.packed = { value: String(input.packed.value), unit: 'kg' };
    batch.pack_date = input.pack_date;
    batch.best_before_date = input.best_before_date;
    return HttpResponse.json(batch);
  }),
  http.post('/v1/batches/:batchId/publish', ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    if (!mockState.roles.includes('fpo_admin')) return fail(403, 'forbidden');
    const batch = findBatch(params['batchId']);
    if (!batch) return fail(404, 'not_found');
    const reasons = [
      ...(batch.status === 'published' ? [{ code: 'already_published' }] : []),
      ...(batch.status === 'created' ? [{ code: 'grading_not_approved' }] : []),
      ...(batch.status === 'created' || batch.status === 'graded'
        ? [{ code: 'final_packing_missing' }]
        : []),
      ...(batch.second_signoff_required && !batch.second_signoff_by
        ? [{ code: 'second_signoff_missing' }]
        : []),
      ...holdReasons(batch),
    ];
    if (reasons.length > 0) return fail(409, 'gate_not_met', { reasons });
    batch.status = 'published';
    const build = queueBuild(batch, 'publish');
    return HttpResponse.json<Schemas['PublishOut']>(
      {
        batch_id: batch.id,
        build_no: build.build_no,
        code: batch.code,
        page_build_id: build.id,
        status: 'queued',
      },
      { status: 202 },
    );
  }),
  http.post('/v1/batches/:batchId/rebuild', ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    if (!mockState.roles.includes('fpo_admin')) return fail(403, 'forbidden');
    const batch = findBatch(params['batchId']);
    if (!batch) return fail(404, 'not_found');
    if (batch.status !== 'published') {
      return fail(409, 'gate_not_met', { reasons: [{ code: 'not_published' }] });
    }
    return HttpResponse.json(queueBuild(batch, 'rebuild'), { status: 202 });
  }),
  http.get('/v1/batches/:batchId/builds', ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    const items = mockState.builds.filter((b) => b.batch_id === params['batchId']);
    const response = HttpResponse.json({
      items: structuredClone(items),
      has_more: false,
      next_cursor: null,
    });
    // The worker: a queued build is written right after the page has seen it queued once.
    for (const b of items) {
      if (b.status !== 'queued' || mockState.holdBuilds) continue;
      b.status = 'built';
      b.built_at = new Date().toISOString();
      b.html_key = `batches/${b.batch_id}/index.html`;
    }
    return response;
  }),
  http.get('/v1/batches/:batchId/qr.png', ({ request }) =>
    authed(request)
      ? new HttpResponse(PNG_1PX, { headers: { 'Content-Type': 'image/png' } })
      : fail(401, 'unauthorized'),
  ),
  http.get('/v1/batches/:batchId/labels.pdf', ({ request, params }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    const batch = findBatch(params['batchId']);
    if (!batch) return fail(404, 'not_found');
    if (batch.status !== 'packed' && batch.status !== 'published') {
      return fail(409, 'gate_not_met', { reasons: [{ code: 'final_packing_missing' }] });
    }
    return new HttpResponse('%PDF-1.4 mock', { headers: { 'Content-Type': 'application/pdf' } });
  }),
  http.post('/v1/processors', async ({ request }) => {
    if (!authed(request)) return fail(401, 'unauthorized');
    const input = (await body(request)) as unknown as ProcessorIn;
    if (!input.name) return fail(422, 'validation_error');
    const created: ProcessorOut = {
      id: crypto.randomUUID(),
      fpo_id: MOCK_FPO_ID,
      name: input.name,
      kind: input.kind,
      address: null,
      address_line: '',
      fssai_no: input.fssai_no ?? null,
      gi_authorised_user_no: input.gi_authorised_user_no ?? null,
    };
    mockState.processors.push(created);
    return HttpResponse.json(created, { status: 201 });
  }),
];
