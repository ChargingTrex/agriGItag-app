/**
 * Tests how the portal keeps a session: a 401 from a data call tries the refresh cookie once and signs out
 * only when that is refused (one logout for several concurrent 401s); the scheduled refresh runs 60 s before
 * expiry and survives a network error; "Start again" leaves the PIN step.
 * Serves: D-024 session model, docs/api/conventions.md "Refresh", plan §7.3 P01 (review r1 P2-2, P3-4,
 * P3-7, P3-8). Called by: Vitest (`npm test`).
 */
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { MOCK_OTP } from '../mocks/handlers';
import { renderApp } from '../test/render';
import { server } from '../test/setup';

/**
 * Counts requests to one path while the test runs.
 * @param pathname The API path, e.g. `/v1/auth/refresh`.
 * @returns An object whose `n` is the number of requests seen so far.
 */
function countRequests(pathname: string): { n: number } {
  const counter = { n: 0 };
  server.events.on('request:start', ({ request }) => {
    if (new URL(request.url).pathname === pathname) counter.n += 1;
  });
  return counter;
}

/**
 * A refresh handler that accepts the first call (the session restore on mount) and then answers `then`.
 * @param then The response for every later refresh.
 * @returns The MSW handler.
 */
function refreshOnceThen(then: () => Response) {
  let calls = 0;
  return http.post('/v1/auth/refresh', () => {
    calls += 1;
    return calls === 1
      ? HttpResponse.json({
          kind: 'session',
          access_token: 'mock-access-token-boot',
          refresh_token: null,
          expires_in: 900,
          roles: ['fpo_admin'],
          fpo_id: 'f',
        })
      : then();
  });
}

/**
 * A 401 `unauthorized` envelope.
 * @returns The mock response.
 */
const unauthorized = () =>
  HttpResponse.json(
    { error: { code: 'unauthorized', message: 'x', details: null } },
    { status: 401 },
  );

afterEach(() => {
  server.events.removeAllListeners();
  vi.useRealTimers();
});

describe('401 from a data call', () => {
  it('refreshes through the cookie once and stays signed in', async () => {
    let healthCalls = 0;
    server.use(
      http.get('/v1/healthz', () =>
        ++healthCalls === 1
          ? unauthorized()
          : HttpResponse.json({ db: 'ok', redis: 'ok', s3: 'ok' }),
      ),
    );
    const refreshes = countRequests('/v1/auth/refresh');
    renderApp('/', true);

    expect(await screen.findByText(/API reachable/)).toBeInTheDocument();
    expect(refreshes.n).toBe(2);
    expect(screen.queryByRole('heading', { name: 'Sign in to AgriTrace' })).not.toBeInTheDocument();
  });

  it('signs out with one logout when several calls get 401 and the refresh is refused', async () => {
    server.use(http.get('/v1/farmers', unauthorized), refreshOnceThen(unauthorized));
    const logouts = countRequests('/v1/auth/logout');
    const refreshes = countRequests('/v1/auth/refresh');
    renderApp('/members', true);

    expect(
      await screen.findByRole('heading', { name: 'Sign in to AgriTrace' }),
    ).toBeInTheDocument();
    await waitFor(() => {
      expect(logouts.n).toBe(1);
    });
    expect(refreshes.n).toBe(2);
  });
});

describe('scheduled refresh', () => {
  it('runs 60 s before the 900 s access token expires', async () => {
    vi.useFakeTimers({ toFake: ['setTimeout', 'clearTimeout'], shouldAdvanceTime: true });
    const refreshes = countRequests('/v1/auth/refresh');
    renderApp('/', true);
    await screen.findByRole('heading', { name: 'Dashboard' });
    expect(refreshes.n).toBe(1);

    await vi.advanceTimersByTimeAsync(838_000);
    expect(refreshes.n).toBe(1);
    await vi.advanceTimersByTimeAsync(3_000);
    await waitFor(() => {
      expect(refreshes.n).toBe(2);
    });
  });

  it('keeps the session when the scheduled refresh hits a network error', async () => {
    vi.useFakeTimers({ toFake: ['setTimeout', 'clearTimeout'], shouldAdvanceTime: true });
    server.use(refreshOnceThen(() => HttpResponse.error()));
    const logouts = countRequests('/v1/auth/logout');
    renderApp('/', true);
    await screen.findByRole('heading', { name: 'Dashboard' });

    await vi.advanceTimersByTimeAsync(841_000);

    expect(screen.getByRole('heading', { name: 'Dashboard' })).toBeInTheDocument();
    expect(logouts.n).toBe(0);
  });
});

describe('PIN step', () => {
  it('"Start again" returns to the phone step (pin token expired or wrong number)', async () => {
    const user = userEvent.setup();
    renderApp('/');
    await user.type(await screen.findByLabelText('Mobile number'), '9876543210');
    await user.click(screen.getByRole('button', { name: 'Send code' }));
    await user.type(await screen.findByLabelText('SMS code'), MOCK_OTP);
    await user.click(screen.getByRole('button', { name: 'Verify code' }));
    await screen.findByLabelText('PIN');

    await user.click(screen.getByRole('button', { name: 'Start again' }));

    expect(await screen.findByLabelText('Mobile number')).toBeInTheDocument();
  });
});
