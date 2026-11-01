/**
 * Shared helpers of the P07 specs: the run mode (MSW mock or live stack), sign-in through the real login
 * form, in-app navigation that keeps the MSW state, and the axe check that fails on serious/critical issues.
 * Serves: plan §7.3 P07 (e2e chain, 0 serious axe violations), UserFlows "FPO admin and QC flows", D-052.
 * Called by: e2e/chain.spec.ts, e2e/axe.spec.ts.
 */
import { createRequire } from 'node:module';
import { expect, type Page } from '@playwright/test';
import type AxeCore from 'axe-core';

/** True with `E2E_LIVE=1`: the specs drive the compose stack seeded by `make seed` (B12) instead of MSW. */
export const LIVE = process.env['E2E_LIVE'] === '1';

/** The dev OTP: MSW's `MOCK_OTP`, and `OTP_DEV_CODE` in infra/docker-compose.yml for the live stack. */
export const OTP = '123456';
/**
 * The office PIN: MSW's `MOCK_PIN`; live, `E2E_STAFF_PIN` (default 1234) — the first sign-in of a staff
 * account chooses it, later ones type it (the shared stack's staff PIN is 2468).
 */
export const PIN = LIVE ? (process.env['E2E_STAFF_PIN'] ?? '1234') : '1234';
/** Ten-digit mobile of the FPO admin: any number in MSW, the seeded admin (+91 90000 00001) when live. */
export const ADMIN_PHONE = LIVE ? '9000000001' : '9876543210';

const AXE_PATH = createRequire(import.meta.url).resolve('axe-core/axe.min.js');
/** When this worker last asked for a sign-in code; the live API sends one per phone per 60 s. */
let lastCodeAt = 0;

/**
 * Signs in through the login form: mobile number, SMS code, then the PIN step. A first live sign-in has no
 * PIN yet, so the PIN is chosen and typed twice (LoginPage "Choose a 4-digit PIN"). Live, a second sign-in in
 * the same worker first waits out the API's one-code-per-60 s limit (`OTP_RESEND_AFTER`), so chain run 2
 * signs in through the real form instead of getting `429 rate_limited`.
 * @param page The page, already showing the sign-in form (any guarded route redirects there).
 * @param phone Ten-digit mobile number without +91.
 * @returns Resolves when the PIN is accepted and the portal shell is visible.
 * @throws {Error} When a step is not reached in time (assertion failure).
 * Side effects: live, may wait up to 61 s.
 */
export async function signIn(page: Page, phone = ADMIN_PHONE): Promise<void> {
  await page.getByLabel('Mobile number').fill(phone);
  if (LIVE) await page.waitForTimeout(Math.max(0, lastCodeAt + 61_000 - Date.now()));
  lastCodeAt = Date.now();
  await page.getByRole('button', { name: 'Send code' }).click();
  await page.getByLabel('SMS code').fill(OTP);
  await page.getByRole('button', { name: 'Verify code' }).click();
  const pin = page.getByLabel('PIN', { exact: true });
  const choose = page.getByLabel('Choose a 4-digit PIN');
  await expect(pin.or(choose)).toBeVisible();
  if (await choose.isVisible()) {
    await choose.fill(PIN);
    await page.getByRole('button', { name: 'Next' }).click();
    await page.getByLabel('Type the PIN again').fill(PIN);
  } else {
    await pin.fill(PIN);
  }
  await page.getByRole('button', { name: 'Sign in' }).click();
  await expect(page.getByRole('navigation', { name: 'Main' })).toBeVisible();
}

/**
 * Opens a sidebar screen by its label (a client-side navigation, so MSW state survives).
 * @param page The signed-in page.
 * @param label The NAV_ITEMS label, e.g. "Ready lots".
 * @returns Resolves after the click.
 */
export async function openNav(page: Page, label: string): Promise<void> {
  await page.getByRole('navigation', { name: 'Main' }).getByRole('link', { name: label }).click();
}

/**
 * Navigates inside the single-page app without a reload: a reload restarts MSW and drops its state (the
 * mock session included), so detail routes are reached with `pushState` + `popstate`, which React Router's
 * BrowserRouter listens to.
 * @param page The signed-in page.
 * @param path Absolute route, e.g. `/flags/<id>`.
 * @returns Resolves once the event is dispatched.
 */
export async function goInApp(page: Page, path: string): Promise<void> {
  await page.evaluate((to) => {
    history.pushState(null, '', to);
    dispatchEvent(new PopStateEvent('popstate'));
  }, path);
}

/**
 * Runs axe-core (injected from node_modules; no wrapper package) on the whole page, prints a one-line summary
 * and fails the test (softly, so later screens are still checked) on any serious or critical violation.
 * Moderate and minor ones are counted, not failed.
 * @param page The page, settled on the screen to check.
 * @param name Screen name for the summary line, e.g. "batch (published)".
 * @returns Resolves when the page has no serious/critical violation.
 * @throws {Error} Assertion failure listing each serious/critical violation with its nodes and why they fail.
 * Side effects: adds the axe script to the page once; writes the summary line to stdout.
 */
export async function expectNoSeriousAxe(page: Page, name: string): Promise<void> {
  if (!(await page.evaluate(() => 'axe' in globalThis)))
    await page.addScriptTag({ path: AXE_PATH });
  const violations = await page.evaluate(async () => {
    // Let finite CSS transitions end first (a button fading from disabled grey to green reads as low
    // contrast mid-way); infinite ones (progress bars) never finish and are skipped.
    await Promise.all(
      document
        .getAnimations()
        .filter((a) => a.effect?.getComputedTiming().endTime !== Infinity)
        .map((a) => a.finished.catch(() => undefined)),
    );
    const { axe } = globalThis as unknown as { axe: typeof AxeCore };
    const result = await axe.run(document, { resultTypes: ['violations'] });
    return result.violations.map((v) => ({
      id: v.id,
      impact: v.impact,
      nodes: v.nodes.map((n) => `${n.target.join(' ')}: ${n.failureSummary ?? ''}`),
    }));
  });
  const serious = violations.filter((v) => v.impact === 'serious' || v.impact === 'critical');
  const other = violations.filter((v) => !serious.includes(v));
  const detail = other.map((v) => `${v.id} ${String(v.impact)}`).join(', ');
  console.log(
    `axe ${name}: ${String(serious.length)} serious/critical, ${String(other.length)} moderate/minor` +
      (detail ? ` (${detail})` : ''),
  );
  // Soft: one run reports every screen's violations; the test still fails at the end.
  expect
    .soft(
      serious.map((v) => `${v.id} (${String(v.impact)}): ${v.nodes.join(' | ')}`),
      `serious axe violations on ${name}`,
    )
    .toEqual([]);
}
