/**
 * Q02 Verifier scratch spec (not repo code): live re-verification of P01 (masked phone + audited Reveal) and
 * P06 line 5 (audit search shows actor + reason) on the shared compose stack (:8000) through the live-mode
 * portal (Vite dev server on 5173 proxying /v1). API calls only build fixtures (a lot, a harvest entry and its
 * correction); each line is checked in the browser plus a DB read. OTP budget: the admin signs in once and the
 * session is kept in $Q02_STATE (refresh cookie) so a rerun costs no OTP; the field officer signs in over the
 * API once (android, for the sync push) and once in the browser (web, for "no Reveal button").
 * FGP8T4033HM7 is never touched.
 */
import { execSync } from 'node:child_process';
import { randomUUID } from 'node:crypto';
import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { expect, test, type APIRequestContext, type Browser, type Page } from '@playwright/test';

const QA = '/Users/fi-it/Documents/projects/agriGitag/docs/agents/qa';
const STATE = process.env['Q02_STATE']!;
const OTP = '123456';
const PIN = '2468';
const results: { wp: string; line: string; result: string; detail: string; shot: string }[] = [];
const log = (...a: unknown[]) => console.log('[qa]', ...a);

function sql(q: string): string {
  const out = execSync(`docker exec agritrace-db-1 psql -U agritrace -d agritrace -XAtc ${JSON.stringify(q)}`).toString().trim();
  log('sql>', q, '=>', out.slice(0, 500));
  return out;
}

async function j(p: Promise<import('@playwright/test').APIResponse>): Promise<any> {
  const r = await p;
  const t = await r.text();
  if (!r.ok()) throw new Error(`${r.url()} -> ${r.status()} ${t.slice(0, 600)}`);
  return t ? JSON.parse(t) : {};
}

async function shot(page: Page, wp: string, name: string): Promise<string> {
  mkdirSync(`${QA}/Q02/shots`, { recursive: true });
  const path = `${QA}/Q02/shots/${wp}-${name}_en.png`;
  await page.screenshot({ path, fullPage: true });
  return `Q02/shots/${wp}-${name}_en.png`;
}

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

/** Signs in through the login form (OTP then PIN). */
async function uiSignIn(page: Page, phone10: string) {
  await page.goto('/');
  await page.getByLabel('Mobile number').fill(phone10);
  await page.getByRole('button', { name: 'Send code' }).click();
  await page.getByLabel('SMS code').fill(OTP);
  await page.getByRole('button', { name: 'Verify code' }).click();
  await page.getByLabel('PIN', { exact: true }).fill(PIN);
  await page.getByRole('button', { name: 'Sign in' }).click();
  await expect(page.getByRole('navigation', { name: 'Main' })).toBeVisible();
}

/** Keeps the last bearer token the portal sent (no extra refresh call, so no cookie rotation race). */
function tokenTap(page: Page): () => Record<string, string> {
  let auth = '';
  page.on('request', (r) => {
    const a = r.headers()['authorization'];
    if (a?.startsWith('Bearer ') && r.url().includes('/v1/')) auth = a;
  });
  return () => {
    if (!auth) throw new Error('no bearer token seen yet');
    return { Authorization: auth };
  };
}

async function adminPage(browser: Browser): Promise<Page> {
  const ctx = await browser.newContext(existsSync(STATE) ? { storageState: STATE } : {});
  const page = await ctx.newPage();
  await page.route(/tile\.openstreetmap\.org|tiles\.maps\.eox\.at/, (r) => r.abort());
  return page;
}

const B20 = process.env['B20_API'] ?? 'http://localhost:8030';

test('Q02 live re-verify P06 line 5 with B20 code (correction written through the side API on the shared DB)', async ({ browser, request }) => {
  test.setTimeout(10 * 60_000);
  const page = await adminPage(browser);
  const admin = tokenTap(page);
  await page.goto('/');
  // isVisible() does not wait; wait for the shell, and never spend an admin OTP here (daily cap reached).
  const restored = await page.getByRole('navigation', { name: 'Main' }).waitFor({ timeout: 45_000 }).then(() => true, () => false);
  if (!restored) throw new Error('stored admin session not accepted (no OTP left today)');
  log('admin session restored from refresh cookie (no OTP)');
  await page.context().storageState({ path: STATE });
  await expect(page.getByRole('heading', { level: 1 })).toBeVisible();

  await line(page, 'P06', 'audit-search-correction-actor-and-reason-b20', async () => {
    const officer = await apiSignIn(request, '+919000000002');
    const crop = sql("select id from crops where code='SAMBA_VATHAL'");
    const p = sql(
      "select p.id||'|'||st_y(p.pin::geometry)||'|'||st_x(p.pin::geometry) from plots p join batches b on true where b.code='VSDR6JJ0X6NM' and p.created_at < b.created_at order by p.created_at desc limit 1",
    ).split('|');
    const [plotId, lat, lon] = [p[0]!, Number(p[1]), Number(p[2])];
    const lot = await j(request.post('/v1/lots', { headers: admin(), data: { client_id: randomUUID(), plot_id: plotId, crop_id: crop, season_label: `Q02 correction B20 ${new Date().toISOString().slice(0, 16)}` } }));
    const eventId = randomUUID();
    const base = { event_id: eventId, subject_type: 'lot', lot_id: lot.id, plot_id: plotId, event_type: 'harvest', instance_no: 1, occurred_on: new Date(Date.now() - 3 * 864e5).toISOString().slice(0, 10), clocks: { device_time: new Date().toISOString() }, gps: { lat, lon, accuracy_m: 6 } };
    const push = await j(request.post('/v1/sync/push', { headers: officer, data: { device_id: randomUUID(), app_version: '1.0.3', device_time: new Date().toISOString(), entries: [{ client_id: randomUUID(), kind: 'event_version', data: { ...base, version_no: 1, payload: { quantity: { value: 50, unit: 'kg' }, bags: 10 } } }] } }));
    log('push', JSON.stringify(push.results));
    // The correction goes to the side API (main's code incl. B20, same DB); everything else uses the shared API.
    const v2 = await j(request.post(`${B20}/v1/events/${eventId}/versions`, { headers: officer, data: { client_id: randomUUID(), data: { ...base, version_no: 2, change_kind: 'correct', reason_code: 'wrong_quantity', reason_text: 'Q02 Verifier: scale re-read', payload: { quantity: { value: 48, unit: 'kg' }, bags: 10 } } } }));
    log('v2', JSON.stringify(v2).slice(0, 300));
    const row = sql(`select entity_type||'|'||entity_id||'|'||action||'|'||coalesce(actor_user_id::text,'')||'|'||diff::text from audit_log where action='event.correct' and diff->>'event_id'='${eventId}' order by created_at desc limit 1`);
    const [etype, eid, , actor] = row.split('|');
    await page.getByRole('navigation', { name: 'Main' }).getByRole('link', { name: 'Audit log' }).click();
    await page.getByLabel('Entity type').selectOption(etype!);
    await page.getByLabel('Entity id').fill(eid!);
    await page.getByRole('button', { name: /^Search/ }).click();
    const table = page.getByRole('table', { name: 'Audit log' });
    await expect(table.getByText('event.correct').first()).toBeVisible();
    const txt = (await table.innerText()).replace(/\s+/g, ' ');
    expect(txt).toContain(actor!);
    expect(txt).toMatch(/wrong_quantity/);
    expect(txt).toMatch(/scale re-read/);
    expect(txt).not.toMatch(/not in the audit log yet/);
    return `lot ${lot.id}; harvest ${eventId} v1 50 kg (shared API) -> v2 48 kg via ${B20} (correct, wrong_quantity); DB row ${row}; table: ${txt.slice(0, 500)}`;
  });
  await page.context().storageState({ path: STATE });
  writeFileSync(`${QA}/Q02/logs/14-reverify-p06-b20-results.json`, JSON.stringify(results, null, 1));
  for (const r of results) console.log(`RESULT ${r.result} ${r.wp} ${r.line} :: ${r.detail}`);
});

/** Field officer over the API (android device, for the sync push). */
async function apiSignIn(req: APIRequestContext, phone: string): Promise<Record<string, string>> {
  await j(req.post('/v1/auth/otp/request', { data: { phone } }));
  const otp = await j(req.post('/v1/auth/otp/verify', { data: { phone, code: OTP, device_id: randomUUID(), platform: 'android' } }));
  let token = otp.access_token as string | undefined;
  if (otp.kind === 'pin_required') {
    const s = await j(req.post('/v1/auth/pin/verify', { data: { pin: PIN }, headers: { Authorization: `Bearer ${otp.pin_token}` } }));
    token = s.access_token;
  }
  return { Authorization: `Bearer ${token}` };
}
