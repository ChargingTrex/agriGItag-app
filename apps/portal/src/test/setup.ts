/**
 * Vitest setup: jest-dom matchers, the MSW Node server with the shared handlers, and per-test cleanup.
 * Serves: plan §7.3 P00/P01 (Vitest + RTL, MSW). Called by: vite.config.ts `test.setupFiles`.
 */
import '@testing-library/jest-dom/vitest';
import { cleanup } from '@testing-library/react';
import { setupServer } from 'msw/node';
import { afterAll, afterEach, beforeAll } from 'vitest';
import { handlers, resetMockData } from '../mocks/handlers';

export const server = setupServer(...handlers);

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
