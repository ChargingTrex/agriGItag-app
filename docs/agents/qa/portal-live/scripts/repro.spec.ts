/**
 * Verifier scratch spec (not repo code): the P01-P06 and P08 acceptance lines marked "live API deferred",
 * driven through the live-mode portal (Vite dev server proxying /v1 to an isolated compose stack, fresh seed).
 * API calls only build the Verifier's own fixtures (plots, lots, events, readings, intakes, QC grading); every
 * acceptance line itself is checked in the browser. One test with one step per line, so a failing line is
 * recorded and the rest still run (each line catches its own error). Results go to $QA_RESULTS (JSON).
 */
import { execSync } from 'node:child_process';
import { randomUUID } from 'node:crypto';
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { expect, test, type APIRequestContext, type Page } from '@playwright/test';

const QA = '/Users/fi-it/Documents/projects/agriGitag/docs/agents/qa';
const DB = process.env['QA_DB'] ?? 'agritrace-p07qa-db-1';
const OTP = '123456';
const PIN = '1234';
const results: { wp: string; line: string; result: string; detail: string; shot: string }[] = [];
const log = (...a: unknown[]) => console.log('[qa]', ...a);

/** Runs one SQL statement on the isolated stack's DB and returns unaligned output. */
function sql(q: string): string {
  const out = execSync(`docker exec ${DB} psql -U agritrace -d agritrace -Atc ${JSON.stringify(q)}`).toString().trim();
  log('sql>', q, '=>', out.slice(0, 400));
  return out;
}

/** Parses a response, throwing with the body when not 2xx. */
async function j(p: Promise<import('@playwright/test').APIResponse>): Promise<any> {
  const r = await p;
  const t = await r.text();
  if (!r.ok()) throw new Error(`${r.url()} -> ${r.status()} ${t.slice(0, 600)}`);
  return t ? JSON.parse(t) : {};
}

/** Signs a staff phone in over the API (dev OTP, first PIN becomes the PIN) and returns auth headers. */
async function apiSignIn(req: APIRequestContext, phone: string): Promise<Record<string, string>> {
  await j(req.post('/v1/auth/otp/request', { data: { phone } }));
  const otp = await j(
    req.post('/v1/auth/otp/verify', { data: { phone, code: OTP, device_id: randomUUID(), platform: 'android' } }),
  );
  let token = otp.access_token as string | undefined;
  if (otp.kind === 'pin_required') {
    const s = await j(
      req.post('/v1/auth/pin/verify', { data: { pin: PIN }, headers: { Authorization: `Bearer ${otp.pin_token}` } }),
    );
    token = s.access_token;
  }
  return { Authorization: `Bearer ${token}` };
}

async function shot(page: Page, wp: string, name: string): Promise<string> {
  mkdirSync(`${QA}/${wp}/shots`, { recursive: true });
  const path = `${QA}/${wp}/shots/${name}_en.png`;
  await page.screenshot({ path, fullPage: true });
  return `${wp}/shots/${name}_en.png`;
}

/** Runs one acceptance line; records PASS/FAIL, a detail string and the screenshot path. */
async function line(page: Page, wp: string, name: string, fn: () => Promise<string>) {
  await test.step(`${wp} ${name}`, async () => {
    let result = 'PASS';
    let detail = '';
    try {
      detail = await fn();
    } catch (e) {
      result = 'FAIL';
      detail = String(e instanceof Error ? e.message : e).split('\n').slice(0, 6).join(' | ');
    }
    let path = '';
    try {
      path = await shot(page, wp, name);
    } catch {
      /* page gone */
    }
    results.push({ wp, line: name, result, detail, shot: path });
    log(`${result} ${wp} ${name}: ${detail}`);
  });
}

const today = () => new Date().toISOString().slice(0, 10);
const daysAgo = (n: number) => new Date(Date.now() - n * 864e5).toISOString().slice(0, 10);


test('P06 opt-out on a consented batch; B10-1 repro', async ({ page, request }) => {
  test.setTimeout(15 * 60_000);
  await page.goto('/');
  await page.getByLabel('Mobile number').fill('9000000001');
  await page.getByRole('button', { name: 'Send code' }).click();
  await page.getByLabel('SMS code').fill(OTP);
  await page.getByRole('button', { name: 'Verify code' }).click();
  await page.getByLabel('PIN', { exact: true }).fill(PIN);
  await page.getByRole('button', { name: 'Sign in' }).click();
  await expect(page.getByRole('navigation', { name: 'Main' })).toBeVisible();
  const admin = async () => {
    const s = await j(page.request.post('/v1/auth/refresh', { headers: { 'X-Client': 'web' }, data: {} }));
    return { Authorization: `Bearer ${s.access_token}` };
  };
  const fpoId = sql('select id from fpos limit 1');
  const ref = sql("select id from batches where code='FGP8T4033HM7'");
  const names = sql(`select f.name from farmers f join lots l on l.farmer_id=f.id join batch_shares s on s.lot_id=l.id where s.batch_id='${ref}' order by 1`).split('\n');
  sql(`select f.name, c.consent_type, c.revoked_at is null from consent_records c join farmers f on f.id=c.farmer_id order by 1,2`);
  const frame = page.frameLocator('iframe[title^="Preview of the public page"]');
  const rebuild = async () => {
    const n = Number(sql(`select max(build_no) from page_builds where batch_id='${ref}'`));
    await page.getByRole('button', { name: /^Rebuild/ }).click();
    for (let i = 0; i < 60 && sql(`select coalesce(max(build_no),0)||':'||coalesce((select status from page_builds where batch_id='${ref}' order by build_no desc limit 1),'') from page_builds where batch_id='${ref}'`) !== `${n + 1}:built`; i++) await page.waitForTimeout(2000);
    // The preview (/v1/public/batches/<code>) is sent with Cache-Control max-age=60: wait it out (P3 observation).
    await page.waitForTimeout(65_000);
    await page.reload();
    await expect(frame.locator('body')).toBeVisible({ timeout: 60_000 });
    await page.waitForTimeout(1500);
    // textContent: farmer names sit inside collapsed <details> lot cards, which innerText skips.
    return ((await frame.locator('body').textContent()) ?? '').replace(/\s+/g, ' ');
  };
  await line(page, 'P06', 'opt-out-reflected-in-preview-consented-batch', async () => {
    if (process.env['SKIP_CONSENT']) { /* consents already recorded */ } else {
    // Fixture: the seed records no public_name consent, so record one per reference farmer (field officer, recorded).
    const officer = await apiSignIn(request, '+919000000002');
    for (const fid of sql(`select distinct l.farmer_id from lots l join batch_shares s on s.lot_id=l.id where s.batch_id='${ref}'`).split('\n')) {
      const assist = await j(request.post('/v1/assist/start', { headers: officer, data: { client_id: randomUUID(), farmer_id: fid } }));
      log('assist', JSON.stringify(assist).slice(0, 200));
      let r = await request.post('/v1/consents', { headers: { ...officer, 'X-Assist-Session': String(assist.id ?? assist.assist_session_id) }, data: { client_id: randomUUID(), farmer_id: fid, consent_type: 'public_name', consent_version: 'v1', given_at: new Date().toISOString(), recording_ref: 'QA verifier fixture' } });
      if (!r.ok()) r = await request.post('/v1/consents', { headers: await admin(), data: { client_id: randomUUID(), farmer_id: fid, consent_type: 'public_name', consent_version: 'v1', given_at: new Date().toISOString(), recording_ref: 'QA verifier fixture' } });
      log('consent', fid, r.status(), (await r.text()).slice(0, 200));
    }
    }
    await page.goto(`/batches/${ref}`);
    sql(`update fpos set public_show_farmer_names=true where id='${fpoId}'`);
    const shown = await rebuild();
    await shot(page, 'P06', 'opt-out-off-names-shown');
    sql(`update fpos set public_show_farmer_names=false where id='${fpoId}'`);
    const hidden = await rebuild();
    await page.getByRole('heading', { name: 'Public page' }).scrollIntoViewIfNeeded().catch(() => undefined);
    const on = names.filter((n) => shown.includes(n));
    const off = names.filter((n) => hidden.includes(n));
    log('preview opt-out off', shown.slice(0, 800));
    log('preview opt-out on', hidden.slice(0, 800));
    expect(on.length).toBeGreaterThan(0);
    expect(off).toEqual([]);
    expect(hidden).toMatch(/Farmer 1/);
    return `opt-out off: names in preview ${JSON.stringify(on)}; opt-out on + Rebuild: names ${JSON.stringify(off)}, "Farmer 1" ${/Farmer 1/.test(hidden)}`;
  });

  if (!process.env['SKIP_B10']) await line(page, 'P04', 'B10-1-plot-without-farming-type-build-failed', async () => {
    const A = await admin();
    const officer = await apiSignIn(request, '+919000000002');
    const qc = await apiSignIn(request, '+919000000003');
    const farmer = sql("select id from farmers where name like 'QA Alpha %' limit 1");
    const crop = sql("select id from crops where code='SAMBA_VATHAL'");
    const proc = sql('select id from processors limit 1');
    const inst = sql("select id from instruments where make_model like 'QA Verifier%' limit 1");
    const p = (await j(request.post('/v1/plots', { headers: A, data: { client_id: randomUUID(), farmer_id: farmer, pin: { lat: 9.56, lon: 78.13, accuracy_m: 5 }, pin_method: 'live_gps', device_time: new Date().toISOString(), declared_area: { value: '1', unit: 'acre' }, code: `QA-NOFT-${randomUUID().slice(0, 4)}` } }))).id;
    const lot = (await j(request.post('/v1/lots', { headers: A, data: { client_id: randomUUID(), plot_id: p, crop_id: crop, season_label: 'QA no farming type' } }))).id;
    await j(request.post('/v1/sync/push', { headers: officer, data: { device_id: randomUUID(), app_version: '1.0.3', device_time: new Date().toISOString(), entries: [{ client_id: randomUUID(), kind: 'event_version', data: { event_id: randomUUID(), version_no: 1, subject_type: 'lot', lot_id: lot, plot_id: p, event_type: 'packing', instance_no: 1, occurred_on: daysAgo(5), payload: { quantity: { value: 30, unit: 'kg' }, bags: 1 }, clocks: { device_time: new Date().toISOString() }, gps: { lat: 9.56, lon: 78.13, accuracy_m: 6 } } }] } }));
    await j(request.post('/v1/quality-readings', { headers: A, data: { client_id: randomUUID(), stage: 'drying_end', parameter_code: 'moisture', measurement: { value: '10.0', unit: '%' }, source: 'instrument', instrument_id: inst, measured_at: new Date().toISOString(), lot_id: lot } }));
    await j(request.post(`/v1/lots/${lot}/ready`, { headers: A }));
    await page.waitForTimeout(3000);
    await j(request.post('/v1/intakes', { headers: A, data: { client_id: randomUUID(), lot_id: lot, processor_id: proc, sale_date: today(), received: { value: '30', unit: 'kg' } } }));
    const b = (await j(request.post('/v1/batches', { headers: A, data: { client_id: randomUUID(), processor_id: proc, gi_label_requested: true, lot_ids: [lot] } }))).id;
    await j(request.post(`/v1/batches/${b}/grading`, { headers: qc, data: { declared_grade: 'Standard', readings: [{ client_id: randomUUID(), stage: 'grading', parameter_code: 'moisture', measurement: { value: '10.5', unit: '%' }, source: 'instrument', instrument_id: inst, measured_at: new Date().toISOString(), batch_id: b }] } }));
    await j(request.post(`/v1/batches/${b}/grading/approve`, { headers: A, data: { graded: { value: 30, unit: 'kg' } } }));
    await j(request.post(`/v1/batches/${b}/final-packing`, { headers: A, data: { packed: { value: 30, unit: 'kg' }, pack_date: today(), best_before_date: daysAgo(-300) } }));
    await j(request.post(`/v1/batches/${b}/publish`, { headers: A }));
    for (let i = 0; i < 60 && !['built', 'failed'].includes(sql(`select status from page_builds where batch_id='${b}' order by build_no desc limit 1`)); i++) await page.waitForTimeout(2000);
    await page.goto(`/batches/${b}`);
    const alert = page.getByText(/Build 1 failed/);
    await expect(alert).toBeVisible({ timeout: 30_000 });
    await alert.scrollIntoViewIfNeeded();
    const txt = (await page.getByRole('region', { name: 'Public page' }).innerText()).replace(/\s+/g, ' ');
    return `plot without farming_type -> publish 202 -> ${txt.slice(0, 300)}`;
  });
  for (const r of results) console.log(`RESULT ${r.result} ${r.wp} ${r.line} :: ${r.detail}`);
});
