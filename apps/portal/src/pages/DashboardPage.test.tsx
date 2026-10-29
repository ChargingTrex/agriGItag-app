/**
 * Tests the dashboard's API status line: generated client -> MSW healthz handler -> TanStack Query -> UI,
 * and the error path through the error-envelope mapper.
 * Serves: plan §7.3 P00 (generated client, MSW from spec). Called by: Vitest (`npm test`).
 */
import { screen } from '@testing-library/react';
import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { server } from '../test/setup';
import { renderApp, TEST_SESSION } from '../test/render';

describe('DashboardPage', () => {
  it('shows the API health from GET /v1/healthz', async () => {
    renderApp('/', TEST_SESSION);
    expect(await screen.findByText(/API reachable/)).toHaveTextContent('database ok');
  });

  it('signs out on a 401 and shows the sign-in page', async () => {
    server.use(
      http.get('/v1/healthz', () =>
        HttpResponse.json(
          { error: { code: 'unauthorized', message: 'expired', details: null } },
          { status: 401 },
        ),
      ),
    );
    renderApp('/', TEST_SESSION);
    expect(
      await screen.findByRole('heading', { name: 'Sign in to AgriTrace' }),
    ).toBeInTheDocument();
  });
});
