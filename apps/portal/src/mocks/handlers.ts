/**
 * MSW request handlers: a mock of the API for tests, `npm run dev:mock` and the Playwright mock-mode specs.
 * Serves: plan §7.3 P00 (MSW from spec; login passes with MSW) and P01 (identity + registry handlers for the
 * Members screens, Stage 0 approval). Called by: src/mocks/browser.ts, src/test/setup.ts (Node server),
 * tests (MOCK_* constants, `mockState`, `resetMockData`).
 *
 * Every body is typed with the generated `components` schemas, so a contract change breaks
 * `npm run typecheck` here. State (farmer statuses, processors, the refresh "cookie") is module-level and
 * reset by `resetMockData` after each test.
 */
import { http, HttpResponse } from 'msw';
import type { components } from '../api/generated/schema';

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
/** Id of the first pending farmer. */
export const MOCK_PENDING_FARMER_ID = farmerId(1);
/** Id of an active farmer who owns MOCK_PLOT_ID. */
export const MOCK_ACTIVE_FARMER_ID = farmerId(10);
/** Farmers in the seed: 2 pending, 1 suspended, the rest active. More than one page of 50. */
export const MOCK_FARMER_COUNT = 57;

/** Mutable mock state. `signedIn` stands in for the httpOnly refresh cookie. */
export const mockState = {
  signedIn: false,
  farmers: seedFarmers(),
  processors: [] as ProcessorOut[],
};

/** Restores the seed state (called after every test). */
export function resetMockData(): void {
  mockState.signedIn = false;
  mockState.farmers = seedFarmers();
  mockState.processors = [];
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

const session: SessionOut = {
  kind: 'session',
  access_token: MOCK_ACCESS_TOKEN,
  refresh_token: null,
  expires_in: 900,
  roles: ['fpo_admin'],
  fpo_id: MOCK_FPO_ID,
};

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
      return HttpResponse.json(session);
    }
    if (auth !== 'Bearer mock-pin-token') return fail(401, 'unauthorized');
    if (pin === MOCK_LOCKED_PIN) {
      return fail(409, 'pin_locked', { locked_until: '2026-10-31T10:35:00Z' });
    }
    if (pin !== MOCK_PIN) return fail(422, 'pin_invalid', { attempts_left: 3 });
    mockState.signedIn = true;
    return HttpResponse.json(session);
  }),
  http.post('/v1/auth/refresh', () =>
    mockState.signedIn
      ? HttpResponse.json({ ...session, access_token: `${MOCK_ACCESS_TOKEN}-${String(++issued)}` })
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
    return params['plotId'] === MOCK_PLOT_ID ? HttpResponse.json(plot) : fail(404, 'not_found');
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
  http.get('/v1/processors', ({ request }) =>
    authed(request) ? HttpResponse.json(mockState.processors) : fail(401, 'unauthorized'),
  ),
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
