/**
 * Vitest setup: jest-dom matchers, the MSW Node server with the shared handlers, and per-test cleanup.
 * Serves: plan §7.3 P00/P01 (Vitest + RTL, MSW), P06 (dashboard, audit and settings handlers). Called by: vite.config.ts `test.setupFiles`.
 */
import '@testing-library/jest-dom/vitest';
import { cleanup, configure } from '@testing-library/react';
import { setupServer } from 'msw/node';
import { afterAll, afterEach, beforeAll } from 'vitest';
import { dashboardHandlers } from '../mocks/dashboardHandlers';
import { handlers, resetMockData } from '../mocks/handlers';

export const server = setupServer(...handlers, ...dashboardHandlers);

// `findBy*`/`waitFor` give up after 1 s by default; on a loaded CI runner (or several agents' test runs at once)
// the first render of a page takes longer, so wait up to 5 s. Passing tests are not slowed down.
configure({ asyncUtilTimeout: 5000 });

beforeAll(() => {
  server.listen({ onUnhandledFrame: 'error' });
});
afterEach(() => {
  cleanup();
  server.resetHandlers();
  resetMockData();
});
afterAll(() => {
  server.close();
});
