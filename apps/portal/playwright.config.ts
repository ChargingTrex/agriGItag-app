/**
 * Playwright configuration for portal end-to-end tests in MSW mock mode or against the docker-compose stack.
 * Serves: plan §7.3 P00 (e2e config) and P07 (the e2e chain and axe specs, mock and live modes, D-052).
 * Called by: `npm run e2e` (locally and in the CI `portal` job, Chromium only).
 *
 * Modes:
 * - Mock (default): Playwright starts the portal with MSW (`npm run dev:mock`) on port 5174; no Docker.
 * - Live (`E2E_LIVE=1`, after `make up && make seed`): Playwright starts the Vite dev server on 5173, which
 *   proxies `/v1` to the compose `api` service (`API_URL`, default http://localhost:8000); mock-only specs skip.
 * `E2E_BASE_URL` points either mode at a portal that is already running, and then nothing is started.
 */
import { defineConfig, devices } from '@playwright/test';

const live = process.env['E2E_LIVE'] === '1';
const startUrl = live ? 'http://localhost:5173' : 'http://localhost:5174';
const baseURL = process.env['E2E_BASE_URL'] ?? startUrl;

export default defineConfig({
  testDir: './e2e',
  timeout: 60_000,
  // Vite compiles modules on first request; with several workers on a busy runner the first screens of a
  // test can take longer than the default 5 s.
  expect: { timeout: 15_000 },
  retries: process.env['CI'] ? 1 : 0,
  reporter: [['list'], ['html', { open: 'never' }]],
  use: {
    baseURL,
    // A missing element fails the step in 30 s instead of waiting out the chain's 10-minute budget; 20 s was
    // too short for the first screens under host load (P07 review P2).
    actionTimeout: 30_000,
    trace: 'retain-on-failure',
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
  ...(process.env['E2E_BASE_URL']
    ? {}
    : {
        webServer: {
          command: live
            ? 'npm run dev -- --port 5173 --strictPort'
            : 'npm run dev:mock -- --port 5174 --strictPort',
          url: startUrl,
          reuseExistingServer: !process.env['CI'],
        },
      }),
});
