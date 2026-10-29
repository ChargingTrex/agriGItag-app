/**
 * Tests the error-envelope parser, the code -> message mapper and the retry rule.
 * Serves: docs/api/conventions.md "Error envelope", plan §7.3 P00. Called by: Vitest (`npm test`).
 */
import { describe, expect, it } from 'vitest';
import {
  ApiError,
  errorMessage,
  FALLBACK_MESSAGE,
  isRetryable,
  NETWORK_MESSAGE,
  toApiError,
} from './errors';

describe('toApiError', () => {
  it('reads code, message and details from the envelope', () => {
    const error = toApiError(409, {
      error: { code: 'gate_not_met', message: 'not yet', details: { open_flags: 2 } },
    });
    expect(error).toMatchObject({
      status: 409,
      code: 'gate_not_met',
      message: 'not yet',
      details: { open_flags: 2 },
    });
  });

  it('falls back to internal_error for a 5xx body that is not an envelope', () => {
    expect(toApiError(503, { db: 'error: Timeout' }).code).toBe('internal_error');
    expect(toApiError(400, 'oops').code).toBe('unknown_error');
  });
});

describe('errorMessage', () => {
  it('maps a registered code to its generated message', () => {
    expect(errorMessage(new ApiError(403, 'forbidden', 'x'))).toBe(
      'Your role does not allow this action.',
    );
  });

  it('uses the fallback for unknown codes and non-API errors, and a network message for fetch failures', () => {
    expect(errorMessage(new ApiError(418, 'not_a_code', 'x'))).toBe(FALLBACK_MESSAGE);
    expect(errorMessage(new Error('x'))).toBe(FALLBACK_MESSAGE);
    expect(errorMessage(new TypeError('Failed to fetch'))).toBe(NETWORK_MESSAGE);
  });
});

describe('isRetryable', () => {
  it('retries network errors, 5xx and 429 only', () => {
    expect(isRetryable(new TypeError('Failed to fetch'))).toBe(true);
    expect(isRetryable(new ApiError(503, 'internal_error', 'x'))).toBe(true);
    expect(isRetryable(new ApiError(429, 'rate_limited', 'x'))).toBe(true);
    expect(isRetryable(new ApiError(422, 'validation_error', 'x'))).toBe(false);
    expect(isRetryable(new Error('x'))).toBe(false);
  });
});
