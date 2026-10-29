/**
 * Sign-in calls: OTP request, OTP verify and the office PIN step.
 * Serves: System Architecture "Login: phone number plus one-time SMS code ... admins add a 4-digit PIN",
 * FR14 role-based access, plan §7.3 P00 (auth guard + login against MSW). Called by: src/auth/LoginPage.tsx.
 *
 * TODO(B02): `/v1/auth/*` is not in openapi.json yet. These calls use plain fetch and the request/response
 * shapes below are P00's assumption (mirrored in src/mocks/handlers.ts). When B02 lands, regenerate the
 * client and replace this file with `unwrap(api.POST('/v1/auth/...'))` calls; adjust the zod schema to the
 * real response.
 */
import { z } from 'zod';
import { toApiError } from '../api/errors';

/** Response of OTP verify and PIN verify (assumed until B02). */
export const tokenResponseSchema = z.object({
  access_token: z.string(),
  refresh_token: z.string(),
  role: z.string(),
  fpo_id: z.string(),
  /** True when the role must also enter its 4-digit PIN before the tokens are full session tokens. */
  pin_required: z.boolean(),
});

/** Parsed token response. */
export type TokenResponse = z.infer<typeof tokenResponseSchema>;

/**
 * POSTs JSON to a same-origin API path.
 * @param path Path starting with `/v1/`.
 * @param body Request body, serialised as JSON.
 * @param accessToken Bearer token for the PIN step; omitted for the OTP calls.
 * @returns The parsed JSON body (null when the body is not JSON).
 * @throws {ApiError} When the status is not 2xx (code from the error envelope).
 * @throws {TypeError} When the network request fails.
 */
async function postJson(path: string, body: unknown, accessToken?: string): Promise<unknown> {
  const headers: Record<string, string> = { 'Content-Type': 'application/json' };
  if (accessToken) headers['Authorization'] = `Bearer ${accessToken}`;
  const response = await fetch(new URL(path, window.location.origin), {
    method: 'POST',
    headers,
    body: JSON.stringify(body),
  });
  const json: unknown = await response.json().catch(() => null);
  if (!response.ok) throw toApiError(response.status, json);
  return json;
}

/**
 * Asks the API to send a one-time code by SMS.
 * @param phone Phone number in E.164 form, e.g. `+919876543210`.
 * @returns Resolves when the code has been requested.
 * @throws {ApiError} E.g. `rate_limited` when asked twice within 60 s (B02 acceptance).
 */
export async function requestOtp(phone: string): Promise<void> {
  await postJson('/v1/auth/otp/request', { phone });
}

/**
 * Exchanges the SMS code for tokens.
 * @param phone The phone number the code was sent to (E.164).
 * @param code The code the user typed.
 * @returns Tokens; `pin_required` tells the login page to ask for the PIN next.
 * @throws {ApiError} When the code is wrong, expired or locked.
 * @throws {z.ZodError} When the response does not match the assumed shape.
 */
export async function verifyOtp(phone: string, code: string): Promise<TokenResponse> {
  return tokenResponseSchema.parse(await postJson('/v1/auth/otp/verify', { phone, code }));
}

/**
 * Completes sign-in for office roles with the 4-digit PIN.
 * @param accessToken The token returned by `verifyOtp`.
 * @param pin The PIN the user typed.
 * @returns Full session tokens (`pin_required` false).
 * @throws {ApiError} When the PIN is wrong or locked.
 * @throws {z.ZodError} When the response does not match the assumed shape.
 */
export async function verifyPin(accessToken: string, pin: string): Promise<TokenResponse> {
  return tokenResponseSchema.parse(await postJson('/v1/auth/pin/verify', { pin }, accessToken));
}
