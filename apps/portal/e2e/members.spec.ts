/**
 * Members end to end in MSW mock mode (no Docker): sign in with OTP + PIN, approve a pending farmer, see them
 * Active without a reload; open a plot and check the lazy map loads with the satellite layer off until asked.
 * Serves: plan §7.3 P01 acceptance "approve → active without reload", §13 D3 (satellite only on request),
 * FR8, FR28. Called by: `npm run e2e` (Playwright starts `npm run dev:mock` when PORTAL_URL is unset).
 * Against the real stack (PORTAL_URL set) the mock ids and codes do not exist: P07 owns that chain.
 */
import { expect, test, type Page } from '@playwright/test';

test.skip(Boolean(process.env['PORTAL_URL']), 'mock-mode spec (MSW data and codes)');

/**
 * Signs in as the mock FPO admin through the real login form.
 * @param page The Playwright page, already on a guarded route.
 * @returns Resolves when the PIN step is submitted.
 */
async function signIn(page: Page): Promise<void> {
  await page.getByLabel('Mobile number').fill('9876543210');
  await page.getByRole('button', { name: 'Send code' }).click();
  await page.getByLabel('SMS code').fill('123456');
  await page.getByRole('button', { name: 'Verify code' }).click();
  await page.getByLabel('PIN').fill('1234');
  await page.getByRole('button', { name: 'Sign in' }).click();
}

test('login → members → approve: the farmer becomes Active without a reload', async ({ page }) => {
  await page.goto('/members');
  await signIn(page);

  const pending = page.getByRole('table', { name: 'Waiting for approval' });
  await expect(pending.getByRole('row')).toHaveCount(3);
  let navigations = 0;
  page.on('framenavigated', () => (navigations += 1));

  await page.getByRole('button', { name: 'Approve Muthu Kumar' }).click();

  await expect(pending.getByRole('row')).toHaveCount(2);
  const roster = page.getByRole('table', { name: 'All members' });
  await expect(roster.getByRole('row', { name: /Muthu Kumar/ })).toContainText('Active');
  expect(navigations).toBe(0);
});

test('plot page: the map chunk loads lazily and satellite tiles wait for the toggle', async ({
  page,
}) => {
  const hosts: string[] = [];
  page.on('request', (request) => hosts.push(new URL(request.url()).host));

  await page.goto('/members/plots/7c3e9b1a-2d4f-4a6b-8c0d-9e1f2a3b4c5d');
  await signIn(page);

  await expect(page.getByText('Near the GI region edge')).toBeVisible();
  await expect(page.locator('.maplibregl-canvas')).toBeVisible();
  const toggle = page.getByRole('button', { name: 'Show satellite view' });
  await expect(toggle).toBeEnabled({ timeout: 20_000 });
  expect(hosts).not.toContain('tiles.maps.eox.at');

  await toggle.click();
  await expect(page.getByRole('button', { name: 'Hide satellite view' })).toBeVisible();
  await expect.poll(() => hosts.includes('tiles.maps.eox.at')).toBe(true);
});
