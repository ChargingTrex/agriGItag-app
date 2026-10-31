/**
 * axe on every routed screen of the portal in MSW mock mode: the sign-in page, then each route of
 * src/AppRoutes.tsx with the mock seed's ids, failing on any serious or critical violation (colour contrast
 * included: a real browser lays the page out, unlike the jsdom checks in the Vitest suites).
 * The batch page is checked by e2e/chain.spec.ts in each of its states (created, awaiting approval, published).
 * Serves: plan §7.3 P07 acceptance "0 serious axe violations", NFR accessibility (WCAG 2.1 AA), D-052.
 * Called by: `npm run e2e` (CI `portal` job). Skipped with `E2E_LIVE=1`: the ids are MSW seed ids.
 */
import { expect, test } from '@playwright/test';
import { expectNoSeriousAxe, goInApp, LIVE, signIn } from './support.ts';

test.skip(LIVE, 'mock-mode spec (MSW seed ids)');

/** Every route of src/AppRoutes.tsx except `/batches/:batchId`; ids are the MSW seed's (src/mocks/handlers.ts). */
const ROUTES: readonly (readonly [string, string])[] = [
  ['dashboard', '/'],
  ['members', '/members'],
  ['farmer', '/members/00000000-0000-4000-8000-000000000010'], // MOCK_ACTIVE_FARMER_ID
  ['plot', '/members/plots/7c3e9b1a-2d4f-4a6b-8c0d-9e1f2a3b4c5d'], // MOCK_PLOT_ID
  ['processors', '/processors'],
  ['flags', '/flags'],
  ['flag', '/flags/f0000000-0000-7000-8000-000000000001'], // MOCK_HOLD_FLAG_ID
  ['lot', '/lots/1a2b3c4d-5e6f-4a7b-8c9d-0e1f2a3b4c5d'], // MOCK_LOT_ID
  ['ready lots', '/ready-lots'],
  ['batches', '/batches'],
  ['labels & exports (placeholder)', '/labels'],
  ['master data uploads', '/uploads'],
  ['audit log', '/audit'],
  ['settings', '/settings'],
];

test('every routed screen has no serious or critical axe violation', async ({ page }) => {
  test.setTimeout(5 * 60_000);
  await page.route(/tile\.openstreetmap\.org|tiles\.maps\.eox\.at/, (route) => route.abort());
  await page.goto('/');
  await expect(page.getByRole('heading', { name: 'Sign in to AgriTrace' })).toBeVisible();
  await expectNoSeriousAxe(page, 'login');
  await signIn(page);

  for (const [name, path] of ROUTES) {
    await test.step(name, async () => {
      await goInApp(page, path);
      await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
      // Loading bars gone: the screen shows its data, not a skeleton.
      await expect(page.getByRole('progressbar')).toHaveCount(0, { timeout: 20_000 });
      await expectNoSeriousAxe(page, name);
    });
  }
});
