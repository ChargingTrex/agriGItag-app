/**
 * Smoke test proving the Playwright setup: an unauthenticated visit lands on the sign-in page.
 * Serves: plan §7.3 P00 (e2e config); P07 extends this folder with the full chain. Called by: `npm run e2e`
 * (needs the portal running at E2E_BASE_URL and `npx playwright install chromium`).
 */
import { expect, test } from '@playwright/test';

test('a signed-out visit to a screen shows the sign-in page', async ({ page }) => {
  await page.goto('/batches');
  await expect(page.getByRole('heading', { name: 'Sign in to AgriTrace' })).toBeVisible();
});
