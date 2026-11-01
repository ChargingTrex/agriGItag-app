// Verifier scratch config: the repo's apps/portal/playwright.config.ts settings, testDir chosen by PW_DIR.
import { defineConfig, devices } from '@playwright/test';
export default defineConfig({
  testDir: process.env['PW_DIR'] ?? './live',
  timeout: 60_000,
  expect: { timeout: 15_000 },
  retries: 0,
  workers: 1,
  reporter: [['list']],
  outputDir: process.env['PW_OUT'] ?? './test-results',
  use: { baseURL: process.env['E2E_BASE_URL'], actionTimeout: 30_000, trace: 'retain-on-failure' },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
});
