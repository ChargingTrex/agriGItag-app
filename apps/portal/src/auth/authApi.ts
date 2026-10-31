/**
 * Sign-in calls of the final B02 contract: OTP request, OTP verify, the office PIN step, cookie refresh and
 * sign-out, all through the generated client.
 * Serves: FR14 role-based access, System Architecture "Login" (OTP, admins add a 4-digit PIN), D-024, D-022,
 * docs/api/conventions.md "Authentication" (web transport), plan §7.3 P01 (portal adapts to the B02 contract).
 * Called by: src/auth/LoginPage.tsx (requestOtp, verifyOtp, verifyPin), src/auth/AuthProvider.tsx
 * (refreshSession, logout).
 */
import createClient from 'openapi-fetch';
import { unwrap } from '../api/client';
import type { components, paths } from '../api/generated/schema';

/** A full session as the API returns it; `refresh_token` is always null for the portal (cookie transport). */
export type SessionOut = components['schemas']['SessionOut'];
/** OTP verify result for office roles: the PIN step must follow. */
export type PinRequiredOut = components['schemas']['PinRequiredOut'];

/** localStorage key of this browser's device id (the API ties the session to it). */
export const DEVICE_ID_KEY = 'agritrace.device_id';

// DECISION D-022: every auth call says `X-Client: web`, so the API delivers the refresh token only as the
// httpOnly, SameSite=Strict `agritrace_refresh` cookie and nulls it in the body (D-024 "Web").
//   ADV: page scripts never see the refresh token; the portal and API share one origin, so fetch's default
//   `credentials: 'same-origin'` already sends and stores the cookie (no `include`, no CORS).
//   COMPROMISE: the portal cannot refresh from another origin; a second tab refreshing at the same moment can
//   trip reuse detection (`refresh_reused`) and sign this browser out.
const authClient = createClient<paths>({
  baseUrl: window.location.origin,
  headers: { 'X-Client': 'web' },
  // Look fetch up per call: this client is built at import time, before test mocks patch `fetch`.
  fetch: (request) => globalThis.fetch(request),
});

/**
 * Returns this browser's device id, creating and storing one on first use.
 * @returns A UUID kept in localStorage (not a secret: it only names the browser installation).
 * @throws {DOMException} When localStorage is unavailable (private mode with storage disabled).
 */
export function deviceId(): string {
  let id = localStorage.getItem(DEVICE_ID_KEY);
  if (!id) {
    id = crypto.randomUUID();
    localStorage.setItem(DEVICE_ID_KEY, id);
  }
  return id;
}

/**
 * Asks the API to send a one-time code by SMS (204, the same for unknown numbers).
 * @param phone Phone number in E.164 form, e.g. `+919876543210`.
 * @returns Resolves when the code has been requested.
 * @throws {ApiError} `rate_limited` (429, `details.retry_after_s`) within 60 s or over the daily cap.
 * @throws {TypeError} When the network request fails.
 */
export async function requestOtp(phone: string): Promise<void> {
  await unwrap(authClient.POST('/v1/auth/otp/request', { body: { phone } }));
}

/**
 * Trades the SMS code for a session (farmers) or a pin token (office roles and super-admins).
 * @param phone The phone number the code was sent to (E.164).
 * @param code The 6-digit code the user typed.
 * @returns The `kind`-discriminated result: `session` or `pin_required` (with `pin_set`).
 * @throws {ApiError} `otp_invalid`/`otp_expired` (422), `otp_locked` or `device_in_use` (409).
 * @throws {TypeError} When the network request fails.
 * @throws {DOMException} When localStorage is unavailable for the device id.
 */
export async function verifyOtp(phone: string, code: string): Promise<SessionOut | PinRequiredOut> {
  return unwrap(
    authClient.POST('/v1/auth/otp/verify', {
      body: { phone, code, device_id: deviceId(), platform: 'web' },
    }),
  );
}

/**
 * Completes an office sign-in with the PIN; when `pin_set` was false this PIN becomes the user's PIN.
 * @param pinToken The `pin_token` from `verifyOtp` (sent as Bearer; never an access token).
 * @param pin The 4-digit PIN.
 * @returns The full session; the refresh token arrives as the httpOnly cookie.
 * @throws {ApiError} `pin_invalid` (422, `details.attempts_left`), `pin_locked` (409, `details.locked_until`),
 *   `unauthorized` (401, pin token expired or spent).
 * @throws {TypeError} When the network request fails.
 */
export async function verifyPin(pinToken: string, pin: string): Promise<SessionOut> {
  return unwrap(
    authClient.POST('/v1/auth/pin/verify', {
      body: { pin },
      headers: { Authorization: `Bearer ${pinToken}` },
    }),
  );
}

let refreshing: Promise<SessionOut> | null = null;

/**
 * Rotates the refresh cookie and returns a new session. Concurrent callers share one request because the
 * API treats two refreshes of the same token as reuse and signs the device out (conventions.md "Refresh").
 * @returns The new session (`refresh_token` null; the rotated token is in the cookie).
 * @throws {ApiError} `unauthorized` (no or unknown cookie) or `refresh_reused` (401).
 * @throws {TypeError} When the network request fails.
 */
export function refreshSession(): Promise<SessionOut> {
  refreshing ??= unwrap(authClient.POST('/v1/auth/refresh', { body: {} })).finally(() => {
    refreshing = null;
  });
  return refreshing;
}

/**
 * Signs this device out on the server: the refresh cookie is cleared and every token of the device dies.
 * @param accessToken The current access token.
 * @returns Resolves when the server answered 204.
 * @throws {ApiError} `unauthorized` (401) when the token is already dead.
 * @throws {TypeError} When the network request fails.
 */
export async function logout(accessToken: string): Promise<void> {
  await unwrap(
    authClient.POST('/v1/auth/logout', { headers: { Authorization: `Bearer ${accessToken}` } }),
  );
}
