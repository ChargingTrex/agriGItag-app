/**
 * The FPO admin chain end to end, run twice in one session without reseeding: sign in with the dev OTP →
 * upload one farmer and approve them → review and clear a flag → Ready lots → create a batch → batch page:
 * approve grading, sign off final packing, publish → download the labels. axe runs on every screen it opens
 * and each run must finish in under 10 minutes.
 * Serves: plan §7.3 P07 acceptance ("login → approve → review flag → create batch → approve → publish →
 * labels, green < 10 min, twice without reseed"; "0 serious axe violations"), FR9, FR13–FR15, FR29, FR60,
 * FR62, FR70, UserFlows "FPO admin and QC flows", D-052. Called by: `npm run e2e` (CI `portal` job, mock mode).
 *
 * Mock mode (default): Playwright starts `npm run dev:mock`; every run opens a fresh page, so MSW starts from
 * its seed (`resetMockData` state) and the second run needs no reseed. Live mode (`E2E_LIVE=1`, after
 * `make up && make seed`): the seeded admin works on the B12 reference batch FGP8T4033HM7; each run uploads a
 * farmer with a new name and clears one more open flag, and steps already done (graded, packed, published)
 * are recognised from the page and skipped, so a second run without reseeding is green too.
 */
import { randomUUID } from 'node:crypto';
import { expect, test, type APIRequestContext, type Page } from '@playwright/test';
import { expectNoSeriousAxe, LIVE, OTP, openNav, PIN, signIn } from './support.ts';

/** The chain must finish well inside the acceptance budget. */
const BUDGET_MS = 10 * 60_000;
/** B12's reference batch (apps/api/agritrace/seed/demo.py `BATCH_CODE`). */
const LIVE_BATCH_CODE = 'FGP8T4033HM7';
/** Graded and packed kg: the whole 320 kg mock batch; the reference batch's 20 kg (B12 fixes path). */
const KG = LIVE ? '20' : '320';

test.describe.configure({ mode: 'serial' });

/**
 * Checks an API answer and returns its JSON body.
 * @param response The pending Playwright API response.
 * @returns The parsed body.
 * @throws {Error} Assertion failure with the body text when the status is not 2xx.
 */
async function ok(
  response: ReturnType<APIRequestContext['get']>,
): Promise<Record<string, unknown>> {
  const r = await response;
  expect(r.ok(), await r.text()).toBe(true);
  return (await r.json()) as Record<string, unknown>;
}

/**
 * Stands in for the QC officer's phone (D-052): on the live stack, signs in as the seeded QC officer over
 * the API, registers a moisture meter and grades the reference batch "Standard" on one reading, as B12's
 * documented fixes path does. Skipped when the batch is past `created` (a later run).
 * @param request The API request context (portal origin; Vite proxies `/v1`).
 * @returns Resolves when the batch has a grade the admin can approve.
 * @throws {Error} Assertion failure on any refused call.
 * Side effects: on the first run, sets the QC officer's PIN, adds an instrument, a reading and a grade.
 */
async function liveQcGrade(request: APIRequestContext): Promise<void> {
  const phone = '+919000000003';
  await ok(request.post('/v1/auth/otp/request', { data: { phone } }));
  const device = { phone, code: OTP, device_id: randomUUID(), platform: 'web' };
  const otp = await ok(request.post('/v1/auth/otp/verify', { data: device }));
  const pinAuth = { Authorization: `Bearer ${String(otp['pin_token'])}` };
  const session = await ok(
    request.post('/v1/auth/pin/verify', { data: { pin: PIN }, headers: pinAuth }),
  );
  const headers = { Authorization: `Bearer ${String(session['access_token'])}` };
  const list = await ok(request.get('/v1/batches', { headers, params: { limit: 200 } }));
  const batch = (list['items'] as { id: string; code: string; status: string }[]).find(
    (b) => b.code === LIVE_BATCH_CODE,
  );
  expect(batch, `${LIVE_BATCH_CODE} missing: run make seed`).toBeDefined();
  if (batch?.status !== 'created') return;
  const meter = {
    kind: 'moisture_meter',
    make_model: 'E2E meter',
    serial_no: `E2E-${randomUUID().slice(0, 8)}`,
    calibrated_on: '2026-01-01',
    calibration_due_on: '2027-12-31',
  };
  const instrument = await ok(request.post('/v1/instruments', { headers, data: meter }));
  const reading = {
    client_id: randomUUID(),
    stage: 'grading',
    parameter_code: 'moisture',
    measurement: { value: '10.5', unit: '%' },
    source: 'instrument',
    instrument_id: instrument['id'],
    measured_at: new Date().toISOString(),
    batch_id: batch.id,
  };
  await ok(
    request.post(`/v1/batches/${batch.id}/grading`, {
      headers,
      data: { declared_grade: 'Standard', readings: [reading] },
    }),
  );
}

/**
 * Stands in for the QC officer's phone in mock mode (D-052): from now on every batch in the MSW state (exposed
 * by src/mocks/browser.ts as `agritraceMock`) reads as graded "Special" on an instrument reading. Installed
 * before the batch exists because the portal caches a "never graded" answer for 30 s (staleTime).
 * @param page The signed-in mock page.
 * @returns Resolves when the grades map is replaced.
 * Side effects: replaces `mockState.grades` in the page with a map that grades any existing batch id.
 */
async function mockQcGrade(page: Page): Promise<void> {
  await page.evaluate(() => {
    const mock = (
      globalThis as unknown as {
        agritraceMock: { batches: { id: string }[]; grades: Record<string, unknown> };
      }
    ).agritraceMock;
    // Same shape as src/features/batches/batchDetail.test.tsx `grade()`.
    mock.grades = new Proxy(
      {},
      {
        get: (_target, id) =>
          mock.batches.some((b) => b.id === id)
            ? {
                id: `grade-${String(id)}`,
                batch_id: id,
                computed_at: '2026-10-30T06:00:00Z',
                computed_grade: 'Special',
                declared_grade: 'Special',
                lab_certified: false,
                profile_version_id: 'e1000000-0000-7000-8000-000000000001',
                status: 'ok',
                per_parameter: {
                  moisture: {
                    parameter: 'moisture',
                    outcome: 'graded',
                    grade: 'Special',
                    source: 'instrument',
                    capped_by_source: false,
                    lab_certified: false,
                  },
                },
              }
            : undefined,
      },
    );
  });
}

/**
 * Uploads a one-row farmers CSV on Master data uploads and approves that farmer on Members. A new name per
 * run keeps the live database reusable.
 * @param page The signed-in page.
 * @returns Resolves when the farmer has left the approval list.
 * @throws {Error} Assertion failure when a step does not show its result.
 */
async function importAndApproveFarmer(page: Page): Promise<void> {
  const name = `E2E Farmer ${randomUUID().slice(0, 8)}`;
  await openNav(page, 'Master data uploads');
  await page.getByRole('tab', { name: 'Farmers' }).click();
  await page.getByLabel(/^CSV file/).setInputFiles({
    name: 'e2e-farmer.csv',
    mimeType: 'text/csv',
    buffer: Buffer.from(`name\r\n${name}\r\n`),
  });
  await page.getByRole('button', { name: 'Import 1 row' }).click();
  await expect(page.getByText(/^1 row imported\./)).toBeVisible();
  await expectNoSeriousAxe(page, 'master data uploads (imported)');

  await page.getByRole('link', { name: 'Open Members' }).click();
  const pending = page.getByRole('table', { name: 'Waiting for approval' });
  await expect(pending.getByRole('row', { name: new RegExp(name) })).toBeVisible();
  await expectNoSeriousAxe(page, 'members');
  await page.getByRole('button', { name: `Approve ${name}` }).click();
  await expect(pending.getByRole('row', { name: new RegExp(name) })).toHaveCount(0);
}

/**
 * Reviews one open flag as "Looks fine" with the first coded reason. Mock: the hold on the held lot (yield
 * above the ceiling), after which the lot shows no hold. Live: the first open flag of the reference lots.
 * @param page The signed-in page.
 * @returns Resolves when the flag shows as cleared.
 * @throws {Error} Assertion failure when no open flag is listed or the review is refused.
 */
async function reviewFlag(page: Page): Promise<void> {
  await openNav(page, 'Flags');
  const rows = page.getByRole('table', { name: 'Flags' }).getByRole('row');
  await expect(rows.nth(1)).toBeVisible();
  await expectNoSeriousAxe(page, 'flags');
  const row = rows.filter({ hasText: LIVE ? 'Open' : 'Yield above the ceiling' }).first();
  await row.getByRole('link').first().click();
  await expect(page.getByRole('heading', { name: 'Resolve this flag' })).toBeVisible();
  await expectNoSeriousAxe(page, 'flag');
  await page.getByLabel(/^Outcome/).selectOption('looks_fine');
  await page.getByLabel(/^Reason/).selectOption({ index: 1 });
  await page.getByLabel(/^Note/).fill('Checked by the P07 e2e chain');
  await page.getByRole('button', { name: 'Save review' }).click();
  await expect(page.getByText(/^Cleared on/)).toBeVisible();
  if (!LIVE) await expect(page.getByText('No hold flag on this lot.')).toBeVisible();
}

/**
 * Mock: registers a processor, ticks the three PRD §12 reference lots (100 + 200 + 20 kg) on Ready lots and
 * creates the GI batch, which the QC phone stand-in grades. Live: the seed already batched every received lot
 * into FGP8T4033HM7, so Ready lots is only opened and checked.
 * @param page The signed-in page.
 * @returns The code of the batch the rest of the chain works on.
 * @throws {Error} Assertion failure when the batch is not created.
 */
async function createBatch(page: Page): Promise<string> {
  if (LIVE) {
    await openNav(page, 'Ready lots');
    await expect(page.getByRole('heading', { name: 'New batch' })).toBeVisible();
    await expectNoSeriousAxe(page, 'ready lots');
    return LIVE_BATCH_CODE;
  }
  await openNav(page, 'Processors');
  await page.getByLabel(/^Registered name/).fill('Sattur Spices Pvt Ltd');
  await page.getByRole('button', { name: 'Register processor' }).click();
  await expect(page.getByRole('table', { name: 'Registered processors' })).toContainText(
    'Sattur Spices Pvt Ltd',
  );
  await expectNoSeriousAxe(page, 'processors');

  await openNav(page, 'Ready lots');
  for (const code of ['VSV-0001-L1', 'VSV-0004-L1', 'VSV-0005-L1']) {
    await page.getByRole('checkbox', { name: `Tick lot ${code}` }).check();
  }
  await page.getByRole('combobox', { name: 'Processor' }).click();
  await page.getByRole('option', { name: 'Sattur Spices Pvt Ltd' }).click();
  await expect(page.getByText('3 lots ticked, total')).toContainText('320 kg');
  await expectNoSeriousAxe(page, 'ready lots (3 ticked)');
  await mockQcGrade(page);
  await page.getByRole('button', { name: 'Create batch' }).click();
  const heading = page.getByRole('heading', { name: /^Batch FGP/ });
  await expect(heading).toBeVisible();
  await expectNoSeriousAxe(page, 'batch (created)');
  return ((await heading.textContent()) ?? '').replace('Batch ', '');
}

/**
 * Opens the batch from the Batches list and walks its gates: approve grading, sign off final packing,
 * publish, then downloads the labels. A gate already passed (live second run) is recognised and skipped.
 * @param page The signed-in page.
 * @param code The batch code.
 * @returns Resolves when the labels PDF has been downloaded.
 * @throws {Error} Assertion failure when a gate is refused or the public page is not built.
 */
async function walkBatchGates(page: Page, code: string): Promise<void> {
  await openNav(page, 'Batches');
  await expectNoSeriousAxe(page, 'batches');
  await page.getByRole('link', { name: code, exact: true }).click();
  await expect(page.getByRole('heading', { name: `Batch ${code}` })).toBeVisible();

  const graded = page.getByLabel('Graded quantity (kg)');
  await expect(graded.or(page.getByText(/^Grading approved/))).toBeVisible();
  if (await graded.isVisible()) {
    await expectNoSeriousAxe(page, 'batch (graded, awaiting approval)');
    await graded.fill(KG);
    await page.getByRole('button', { name: 'Approve grading', exact: true }).click();
    await expect(page.getByText(/^Grading approved/)).toBeVisible();
  }

  const packed = page.getByLabel('Packed quantity (kg)');
  await expect(packed.or(page.getByText(/^Packed \d/))).toBeVisible();
  if (await packed.isVisible()) {
    const today = new Date();
    const later = new Date(today.getTime() + 364 * 24 * 3600_000);
    await packed.fill(KG);
    await page.getByLabel('Pack date').fill(today.toISOString().slice(0, 10));
    await page.getByLabel('Best before').fill(later.toISOString().slice(0, 10));
    await page.getByRole('button', { name: 'Sign off final packing', exact: true }).click();
    await expect(page.getByText(/^Packed \d/)).toBeVisible();
  }

  const publish = page.getByRole('button', { name: 'Publish', exact: true });
  const labels = page.getByRole('button', { name: 'Download labels' });
  await expect(publish.or(labels)).toBeVisible();
  if (await publish.isVisible()) await publish.click();
  // The worker builds the page (the MSW worker after one poll; Celery on the live stack).
  await expect(page.getByRole('link', { name: new RegExp(`/b/${code}$`) })).toBeVisible({
    timeout: 120_000,
  });
  await expectNoSeriousAxe(page, 'batch (published)');

  const download = page.waitForEvent('download');
  await labels.click();
  expect((await download).suggestedFilename()).toBe(`labels-${code}.pdf`);
}

for (const run of [1, 2]) {
  test(`chain run ${String(run)}: login → approve → review flag → batch → approve → publish → labels`, async ({
    page,
    request,
  }) => {
    test.setTimeout(BUDGET_MS);
    const started = Date.now();
    // Tiles are never fetched in tests (OSM tile policy; no network dependency).
    await page.route(/tile\.openstreetmap\.org|tiles\.maps\.eox\.at/, (route) => route.abort());
    if (LIVE) await liveQcGrade(request);

    await page.goto('/');
    await expect(page.getByRole('heading', { name: 'Sign in to AgriTrace' })).toBeVisible();
    await expectNoSeriousAxe(page, 'login');
    await signIn(page);
    await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();
    await expectNoSeriousAxe(page, 'dashboard');

    await importAndApproveFarmer(page);
    await reviewFlag(page);
    const code = await createBatch(page);
    await walkBatchGates(page, code);

    const seconds = (Date.now() - started) / 1000;
    console.log(`chain run ${String(run)} (${LIVE ? 'live' : 'mock'}): ${seconds.toFixed(1)} s`);
    test.info().annotations.push({ type: 'duration', description: `${seconds.toFixed(1)} s` });
    expect(Date.now() - started).toBeLessThan(BUDGET_MS);
  });
}
