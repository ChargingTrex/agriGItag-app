/**
 * Error-envelope handling: turns any failed API response into an `ApiError` and maps its `code` to the
 * message shown to the user via the table generated from docs/api/error-codes.md.
 * Serves: docs/api/conventions.md "Error envelope" and "retry only on network errors, 5xx and 429"; plan §7.3 P00.
 * Called by: src/api/client.ts (unwrap), src/auth/authApi.ts, src/queryClient.ts (retry), every screen
 * that shows an error (via `errorMessage`).
 */
import { z } from 'zod';
import { ERROR_MESSAGES } from './generated/error-messages';

const envelopeSchema = z.object({
  error: z.object({ code: z.string(), message: z.string(), details: z.unknown().optional() }),
});

/** Shown when the browser cannot reach the API at all (fetch rejected). */
export const NETWORK_MESSAGE = 'Cannot reach the server. Check the connection and try again.';
/** Shown for codes missing from error-codes.md and for non-API failures. */
export const FALLBACK_MESSAGE = 'Something went wrong. Please try again.';

/** A non-2xx API response, parsed from the `{"error": {code, message, details}}` envelope. */
export class ApiError extends Error {
  /**
   * Creates the error.
   * @param status HTTP status of the response.
   * @param code Registered snake_case code (docs/api/error-codes.md), or `internal_error` when the body was
   *   not an envelope and the status is 5xx, else `unknown_error`.
   * @param message English developer message from the envelope (never shown to users).
   * @param details Optional context from the envelope (failing fields, ids, limits).
   */
  constructor(
    readonly status: number,
    readonly code: string,
    message: string,
    readonly details?: unknown,
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

/**
 * Builds an `ApiError` from a failed response's status and parsed JSON body.
 * @param status HTTP status code.
 * @param body Parsed JSON body, or anything else when the body was not JSON.
 * @returns The error; a body that is not an error envelope still yields an `ApiError` with a fallback code.
 */
export function toApiError(status: number, body: unknown): ApiError {
  const parsed = envelopeSchema.safeParse(body);
  if (parsed.success) {
    const { code, message, details } = parsed.data.error;
    return new ApiError(status, code, message, details);
  }
  return new ApiError(
    status,
    status >= 500 ? 'internal_error' : 'unknown_error',
    `HTTP ${String(status)}`,
  );
}

/**
 * The user-facing message for any error thrown by an API call.
 * @param error Whatever the call threw or rejected with.
 * @returns The generated message for an `ApiError` code, a network message for a rejected fetch, else a
 *   generic fallback.
 */
export function errorMessage(error: unknown): string {
  if (error instanceof ApiError) return ERROR_MESSAGES[error.code] ?? FALLBACK_MESSAGE;
  if (error instanceof TypeError) return NETWORK_MESSAGE;
  return FALLBACK_MESSAGE;
}

/**
 * Whether a failed request may be retried: network errors, 5xx and 429 only (conventions.md).
 * @param error Whatever the request threw.
 * @returns True for retryable failures.
 */
export function isRetryable(error: unknown): boolean {
  if (!(error instanceof ApiError)) return error instanceof TypeError;
  return error.status >= 500 || error.status === 429;
}
