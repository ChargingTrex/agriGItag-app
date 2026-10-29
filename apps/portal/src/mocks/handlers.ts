/**
 * MSW request handlers: a mock of the API for tests and `npm run dev:mock`.
 * Serves: plan §7.3 P00 (MSW from spec; login passes with MSW). Called by: src/mocks/browser.ts,
 * src/test/setup.ts (Node server).
 *
 * Handlers for paths in openapi.json are typed with the generated `components` schemas, so a contract change
 * breaks `npm run typecheck` here. The `/v1/auth/*` handlers are hand-written, see TODO(B02) below.
 */
import { http, HttpResponse } from 'msw';
import type { components } from '../api/generated/schema';

type Health = components['schemas']['Health'];
type ErrorEnvelope = components['schemas']['ErrorEnvelope'];

/** The SMS code the mock accepts. */
export const MOCK_OTP = '123456';
/** The PIN the mock accepts. */
export const MOCK_PIN = '1234';

/**
 * A 422 `validation_error` envelope.
 * @param message Developer message.
 * @returns The mock response.
 */
const invalid = (message: string) =>
  HttpResponse.json<ErrorEnvelope>(
    { error: { code: 'validation_error', message, details: null } },
    { status: 422 },
  );

/**
 * Token response in the shape src/auth/authApi.ts assumes.
 * @param pinRequired Whether the PIN step is still needed.
 * @returns The response body.
 */
const tokens = (pinRequired: boolean) => ({
  access_token: pinRequired ? 'mock-otp-token' : 'mock-access-token',
  refresh_token: 'mock-refresh-token',
  role: 'fpo_admin',
  fpo_id: 'mock-fpo',
  pin_required: pinRequired,
});

/**
 * Reads the JSON body as a string map; anything else becomes an empty object.
 * @param request The intercepted request.
 * @returns The body fields.
 */
async function body(request: Request): Promise<Record<string, unknown>> {
  const json: unknown = await request.json().catch(() => null);
  return typeof json === 'object' && json !== null ? (json as Record<string, unknown>) : {};
}

export const handlers = [
  http.get('/v1/healthz', () => HttpResponse.json<Health>({ db: 'ok', redis: 'ok', s3: 'ok' })),
  http.head('/v1/healthz', () => new HttpResponse(null, { status: 200 })),

  // TODO(B02): replace with the real contract once /v1/auth/* is in openapi.json.
  http.post('/v1/auth/otp/request', () => HttpResponse.json({ expires_in_s: 300 })),
  http.post('/v1/auth/otp/verify', async ({ request }) =>
    (await body(request))['code'] === MOCK_OTP
      ? HttpResponse.json(tokens(true))
      : invalid('wrong code'),
  ),
  http.post('/v1/auth/pin/verify', async ({ request }) =>
    request.headers.get('Authorization') === 'Bearer mock-otp-token' &&
    (await body(request))['pin'] === MOCK_PIN
      ? HttpResponse.json(tokens(false))
      : invalid('wrong PIN'),
  ),
];
