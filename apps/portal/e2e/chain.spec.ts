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
 * `make up && make seed`; `E2E_STAFF_PIN` when the stack's staff PIN is not 1234): each run imports and
 * approves its own farmer, gives them a plot and a 20 kg lot over the API (admin token taken from the
 * portal's own requests; moisture reading and intake by the QC officer), clears that lot's flag, batches the
 * lot on Ready lots and walks the batch to its labels. It never touches the B12 reference batch
 * FGP8T4033HM7, so a second run without reseeding is green too. The QC officer signs in once per worker and
 * the admin's second sign-in waits out the one-code-per-60 s limit (support.ts `signIn`).
 */
import { randomUUID } from 'node:crypto';
import { expect, test, type APIRequestContext, type Page } from '@playwright/test';
import { expectNoSeriousAxe, goInApp, LIVE, OTP, openNav, PIN, signIn } from './support.ts';

/** The chain must finish well inside the acceptance budget. */
const BUDGET_MS = 10 * 60_000;
/** Graded and packed kg: the whole 320 kg mock batch; the one 20 kg lot the live run makes. */
const KG = LIVE ? '20' : '320';

/** Headers of an API session. */
type Auth = Record<string, string>;
/** The live lot a run makes ready and receives, and the flag its intake raised. */
interface LiveLot {
  code: string;
  flagId: string;
  processor: string;
}

test.describe.configure({ mode: 'serial' });

/**
 * Checks an API answer and returns its JSON body.
 * @param response The pending Playwright API response.
 * @returns The parsed body; null for an empty body (`204`, e.g. `POST /v1/auth/otp/request`).
 * @throws {Error} Assertion failure with the body text when the status is not 2xx.
 */
async function ok<T = Record<string, unknown>>(
  response: ReturnType<APIRequestContext['get']>,
): Promise<T> {
  const r = await response;
  const text = await r.text();
  expect(r.ok(), text).toBe(true);
  return (text ? JSON.parse(text) : null) as T;
}

/** The QC officer's session and moisture meter, made once per worker: one OTP per phone per 60 s. */
let qc: { headers: Auth; instrumentId: string } | undefined;

/**
 * Signs the seeded QC officer in over the API and registers a moisture meter, once per Playwright worker.
 * @param request The API request context (portal origin; Vite proxies `/v1`).
 * @returns The QC session headers and the instrument id.
 * @throws {Error} Assertion failure on any refused call.
 * Side effects: the first call requests an OTP, sets the PIN on a first sign-in, adds an instrument.
 */
async function liveQc(request: APIRequestContext): Promise<NonNullable<typeof qc>> {
  if (qc) return qc;
  const phone = '+919000000003';
  await ok(request.post('/v1/auth/otp/request', { data: { phone } }));
  const device = { phone, code: OTP, device_id: randomUUID(), platform: 'web' };
  const otp = await ok(request.post('/v1/auth/otp/verify', { data: device }));
  const pinAuth = { Authorization: `Bearer ${String(otp['pin_token'])}` };
  const session = await ok(
    request.post('/v1/auth/pin/verify', { data: { pin: PIN }, headers: pinAuth }),
  );
  const headers = { Authorization: `Bearer ${String(session['access_token'])}` };
  const meter = {
    kind: 'moisture_meter',
    make_model: 'E2E meter',
    serial_no: `E2E-${randomUUID().slice(0, 8)}`,
    calibrated_on: '2026-01-01',
    calibration_due_on: '2027-12-31',
  };
  const instrument = await ok(request.post('/v1/instruments', { headers, data: meter }));
  qc = { headers, instrumentId: String(instrument['id']) };
  return qc;
}

/**
 * An instrument moisture reading body.
 * @param instrumentId The QC officer's meter.
 * @param stage `drying_end` (lot ready gate) or `grading` (batch).
 * @param subject `{ lot_id }` or `{ batch_id }`.
 * @returns The `POST /v1/quality-readings` body.
 */
const moisture = (instrumentId: string, stage: string, subject: Record<string, string>) => ({
  client_id: randomUUID(),
  stage,
  parameter_code: 'moisture',
  measurement: { value: '10.5', unit: '%' },
  source: 'instrument',
  instrument_id: instrumentId,
  measured_at: new Date().toISOString(),
  ...subject,
});

/**
 * Live only: gives the farmer this run imported a plot inside the GI region and a 20 kg chilli lot, as the
 * phones would: the admin adds the farmer's village address, registers the plot and opens the lot, the QC officer records the drying-end
 * moisture and receives the lot at the FPO's processor (the intake runs the ready gate, D-040).
 * @param request The API request context.
 * @param admin The admin session headers (taken from the signed-in portal).
 * @param farmerName The imported farmer's unique name.
 * @returns The lot code, the flag its intake raised (no harvest quantity → `yield_check_unavailable`) and
 *   the processor's name.
 * @throws {Error} Assertion failure on any refused call or when the intake raised no flag.
 * Side effects: sets the farmer's address; adds a plot, a lot, a reading and an intake on the live stack.
 */
async function liveReadyLot(
  request: APIRequestContext,
  admin: Auth,
  farmerName: string,
): Promise<LiveLot> {
  const { headers, instrumentId } = await liveQc(request);
  const farmers = await ok<{ items: { id: string }[] }>(
    request.get('/v1/farmers', { headers: admin, params: { q: farmerName, limit: 1 } }),
  );
  const farmerId = farmers.items[0]?.id ?? '';
  // The public page needs the farmer's village-level place (a name-only CSV row has none).
  const address = {
    village: 'Sattur',
    block: 'Sattur',
    district: 'Virudhunagar',
    state: 'Tamil Nadu',
  };
  await ok(request.patch(`/v1/farmers/${farmerId}`, { headers: admin, data: { address } }));
  const crops = await ok<{ id: string; gi_tag_id: string | null }[]>(
    request.get('/v1/crops', { headers: admin }),
  );
  const plot = await ok(
    request.post('/v1/plots', {
      headers: admin,
      // Beside the seeded reference plots, inside the GI region (confirmed, no plot flag).
      data: {
        client_id: randomUUID(),
        farmer_id: farmerId,
        pin: { lat: 9.586, lon: 78.112, accuracy_m: 5 },
        farming_type: 'rainfed',
        device_time: new Date().toISOString(),
        declared_area: { value: '1', unit: 'acre' },
      },
    }),
  );
  const lot = await ok(
    request.post('/v1/lots', {
      headers: admin,
      data: {
        client_id: randomUUID(),
        plot_id: plot['id'],
        crop_id: crops.find((c) => c.gi_tag_id)?.id,
        season_label: '2026-27',
      },
    }),
  );
  const lotId = String(lot['id']);
  await ok(
    request.post('/v1/quality-readings', {
      headers,
      data: moisture(instrumentId, 'drying_end', { lot_id: lotId }),
    }),
  );
  const [processor] = await ok<{ id: string; name: string }[]>(
    request.get('/v1/processors', { headers }),
  );
  const intake = await ok<{ flags: { id: string }[] }>(
    request.post('/v1/intakes', {
      headers,
      data: {
        client_id: randomUUID(),
        lot_id: lotId,
        processor_id: processor?.id,
        sale_date: new Date().toISOString().slice(0, 10),
        received: { value: KG, unit: 'kg' },
      },
    }),
  );
  const [flag] = intake.flags;
  expect(flag, 'the intake raised no flag to review').toBeDefined();
  return { code: String(lot['code']), flagId: flag?.id ?? '', processor: processor?.name ?? '' };
}

/**
 * Stands in for the QC officer's phone on the live stack (D-052): grades the run's batch "Standard" on one
 * instrument moisture reading, as B12's documented fixes path does.
 * @param request The API request context.
 * @param batchId The batch the run created.
 * @returns Resolves when the batch has a grade the admin can approve.
 * @throws {Error} Assertion failure on any refused call.
 * Side effects: adds a reading and a grade.
 */
async function liveQcGrade(request: APIRequestContext, batchId: string): Promise<void> {
  const { headers, instrumentId } = await liveQc(request);
  const reading = moisture(instrumentId, 'grading', { batch_id: batchId });
  await ok(
    request.post(`/v1/batches/${batchId}/grading`, {
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
 * @returns The farmer's name, once they have left the approval list.
 * @throws {Error} Assertion failure when a step does not show its result.
 */
async function importAndApproveFarmer(page: Page): Promise<string> {
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
  return name;
}

/**
 * Reviews one open flag as "Looks fine" with the first coded reason. Mock: the hold on the held lot (yield
 * above the ceiling), after which the lot shows no hold. Live: the flag the run's own intake raised, opened
 * by id (the shared list may hold it on a later page).
 * @param page The signed-in page.
 * @param flagId Live only: the flag to review.
 * @returns Resolves when the flag shows as cleared.
 * @throws {Error} Assertion failure when no open flag is listed or the review is refused.
 */
async function reviewFlag(page: Page, flagId?: string): Promise<void> {
  await openNav(page, 'Flags');
  const rows = page.getByRole('table', { name: 'Flags' }).getByRole('row');
  await expect(rows.nth(1)).toBeVisible();
  await expectNoSeriousAxe(page, 'flags');
  if (flagId) await goInApp(page, `/flags/${flagId}`);
  else
    await rows
      .filter({ hasText: 'Yield above the ceiling' })
      .first()
      .getByRole('link')
      .first()
      .click();
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
 * Creates the GI batch on Ready lots. Mock: registers a processor, ticks the three PRD §12 reference lots
 * (100 + 200 + 20 kg), and installs the QC phone stand-in that grades it. Live: ticks the run's own lot and
 * picks the processor that received it.
 * @param page The signed-in page.
 * @param lot Live only: the lot `liveReadyLot` made.
 * @returns The new batch's code and id.
 * @throws {Error} Assertion failure when the batch is not created.
 */
async function createBatch(page: Page, lot?: LiveLot): Promise<{ code: string; id: string }> {
  if (lot) {
    await openNav(page, 'Ready lots');
    await page.getByRole('checkbox', { name: `Tick lot ${lot.code}` }).check();
    await page.getByRole('combobox', { name: 'Processor' }).click();
    await page.getByRole('option', { name: lot.processor }).click();
    // The API-made lot has no packing event, so the total reads 0 kg (shares come from the intake).
    await expect(page.getByText('1 lot ticked, total')).toBeVisible();
    await expectNoSeriousAxe(page, 'ready lots (1 ticked)');
  } else {
    await createMockSelection(page);
  }
  await page.getByRole('button', { name: 'Create batch' }).click();
  // Live batch codes are random (e.g. 99FAZVS17PXQ); the mock's start with FGP.
  const heading = page.getByRole('heading', { level: 1, name: /^Batch / });
  await expect(heading).toBeVisible();
  await expectNoSeriousAxe(page, 'batch (created)');
  const code = ((await heading.textContent()) ?? '').replace('Batch ', '');
  return { code, id: new URL(page.url()).pathname.split('/').pop() ?? '' };
}

/**
 * Mock only: registers a processor, ticks the three PRD §12 reference lots and installs the grade stand-in.
 * @param page The signed-in mock page.
 * @returns Resolves when the three lots and the processor are chosen.
 * @throws {Error} Assertion failure when a step does not show its result.
 */
async function createMockSelection(page: Page): Promise<void> {
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
}

/**
 * Opens the batch from the Batches list and walks its gates: approve grading, sign off final packing,
 * publish, then downloads the labels. Every run has a new batch, so each gate is expected exactly.
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
  await expect(graded).toBeVisible();
  await expectNoSeriousAxe(page, 'batch (graded, awaiting approval)');
  await graded.fill(KG);
  await page.getByRole('button', { name: 'Approve grading', exact: true }).click();
  await expect(page.getByText(/^Grading approved/)).toBeVisible();

  const packed = page.getByLabel('Packed quantity (kg)');
  const today = new Date();
  const later = new Date(today.getTime() + 364 * 24 * 3600_000);
  await packed.fill(KG);
  await page.getByLabel('Pack date').fill(today.toISOString().slice(0, 10));
  await page.getByLabel('Best before').fill(later.toISOString().slice(0, 10));
  await page.getByRole('button', { name: 'Sign off final packing', exact: true }).click();
  await expect(page.getByText(/^Packed \d/)).toBeVisible();

  // P05 shows "Download labels" (greyed with its reason) before publishing too, so publish first, exactly.
  await page.getByRole('button', { name: 'Publish', exact: true }).click();
  const labels = page.getByRole('button', { name: 'Download labels' });
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
    // Live: the admin's API calls reuse the portal's own token (no second OTP for the same phone).
    const admin: Auth = {};
    page.on('request', (r) => {
      const token = r.headers()['authorization'];
      if (token) admin['Authorization'] = token;
    });

    await page.goto('/');
    await expect(page.getByRole('heading', { name: 'Sign in to AgriTrace' })).toBeVisible();
    await expectNoSeriousAxe(page, 'login');
    await signIn(page);
    await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();
    await expectNoSeriousAxe(page, 'dashboard');

    const farmer = await importAndApproveFarmer(page);
    const lot = LIVE ? await liveReadyLot(request, admin, farmer) : undefined;
    await reviewFlag(page, lot?.flagId);
    const batch = await createBatch(page, lot);
    if (LIVE) {
      await liveQcGrade(request, batch.id);
      // The batch page cached "not graded yet" (staleTime); the live portal survives a reload (cookie).
      await page.reload();
    }
    await walkBatchGates(page, batch.code);

    const seconds = (Date.now() - started) / 1000;
    console.log(`chain run ${String(run)} (${LIVE ? 'live' : 'mock'}): ${seconds.toFixed(1)} s`);
    test.info().annotations.push({ type: 'duration', description: `${seconds.toFixed(1)} s` });
  });
}
