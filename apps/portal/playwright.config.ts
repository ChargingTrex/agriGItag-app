/**
 * Playwright configuration for portal end-to-end tests against the docker-compose stack.
 * Serves: plan §7.3 P00 (e2e config) and P07 (the e2e chain, which adds the tests and installs the browser
 * with `npx playwright install chromium`). Called by: `npm run e2e`. Not run in P00.
 *
 * URLs: the portal at PORTAL_URL (default: Vite dev server on 5173, which proxies `/v1` to API_URL, default
 * http://localhost:8000 = the compose `api` service on API_PORT).
 */
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  timeout: 60_000,
  retries: process.env['CI'] ? 1 : 0,
  reporter: [['list'], ['html', { open: 'never' }]],
  use: {
    baseURL: process.env['PORTAL_URL'] ?? 'http://localhost:5173',
    trace: 'retain-on-failure',
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
});
