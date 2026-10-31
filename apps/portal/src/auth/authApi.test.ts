/**
 * Tests the single-flight refresh: concurrent callers share one `POST /v1/auth/refresh`, because the API
 * treats two refreshes of one token as reuse and signs the device out (D-024).
 * Serves: docs/api/conventions.md "Refresh" (never two refreshes at once), plan §7.3 P01 (review r1 P2-3).
 * Called by: Vitest (`npm test`).
 */
import { describe, expect, it } from 'vitest';
import { mockState } from '../mocks/handlers';
import { server } from '../test/setup';
import { refreshSession } from './authApi';

describe('refreshSession', () => {
  it('sends one request for concurrent callers and a new one after it settles', async () => {
    mockState.signedIn = true;
    let hits = 0;
    server.events.on('request:start', ({ request }) => {
      if (new URL(request.url).pathname === '/v1/auth/refresh') hits += 1;
    });

    const [first, second] = await Promise.all([refreshSession(), refreshSession()]);
    expect(hits).toBe(1);
    expect(second).toBe(first);

    await refreshSession();
    expect(hits).toBe(2);
    server.events.removeAllListeners();
  });
});
