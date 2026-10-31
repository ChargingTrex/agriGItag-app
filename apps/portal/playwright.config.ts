/**
 * Playwright configuration for portal end-to-end tests against the docker-compose stack or MSW mock mode.
 * Serves: plan §7.3 P00 (e2e config) and P07 (the e2e chain, which adds the tests and installs the browser
 * with `npx playwright install chromium`). Called by: `npm run e2e`. Not run in P00.
 *
 * URLs: with PORTAL_URL set, tests run against that portal (e.g. the Vite dev server on 5173 proxying `/v1` to
 * the compose `api` service). Without it, Playwright starts the portal in MSW mock mode (`npm run dev:mock`) on
 * port 5174, so specs such as e2e/members.spec.ts (P01) run without Docker.
 */
import { defineConfig, devices } from '@playwright/test';

const portalUrl = process.env['PORTAL_URL'];
const MOCK_URL = 'http://localhost:5174';

export default defineConfig({
  testDir: './e2e',
  timeout: 60_000,
  retries: process.env['CI'] ? 1 : 0,
  reporter: [['list'], ['html', { open: 'never' }]],
  use: {
    baseURL: portalUrl ?? MOCK_URL,
    trace: 'retain-on-failure',
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
  ...(portalUrl
    ? {}
    : {
        webServer: {
          command: 'npm run dev:mock -- --port 5174 --strictPort',
          url: MOCK_URL,
          reuseExistingServer: !process.env['CI'],
        },
      }),
});
