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

test('Q02 live re-verify P01, P06 line 5, P07 batch page', async ({ browser, request }) => {
  test.setTimeout(15 * 60_000);
  const page = await adminPage(browser);
  const admin = tokenTap(page);
  await page.goto('/');
  const nav = page.getByRole('navigation', { name: 'Main' });
  if (!(await nav.isVisible({ timeout: 20_000 }).catch(() => false))) {
    log('no stored admin session: OTP sign-in');
    await uiSignIn(page, '9000000001');
  } else log('admin session restored from refresh cookie (no OTP)');
  await page.context().storageState({ path: STATE });
  await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
  const A = admin();
  const me = await j(request.get('/v1/me', { headers: A }));
  const adminId: string = me.id ?? me.user?.id ?? me.user_id;
  log('me', JSON.stringify(me).slice(0, 300));

  // ---------- P01: masked by default, audited reveal ----------
  const farmers = (await j(request.get('/v1/farmers?limit=50&status=active', { headers: A }))).items as any[];
  const f = farmers.find((x) => x.phone_masked);
  if (!f) throw new Error('no active farmer with a phone');
  log('farmer', f.id, f.name, f.phone_masked);

  await line(page, 'P01', 'phone-masked-by-default', async () => {
    await page.goto(`/members/${f.id}`);
    await expect(page.getByText(`Mobile: ${f.phone_masked}`)).toBeVisible();
    const body = await page.locator('main').innerText();
    expect(body).not.toMatch(/\+91\d{10}/);
    await expect(page.getByRole('button', { name: 'Reveal number' })).toBeVisible();
    return `farmer ${f.name} (${f.id}): "Mobile: ${f.phone_masked}" shown, no +91 number on the page, admin sees "Reveal number"`;
  });

  await line(page, 'P01', 'admin-reveal-full-number-audited', async () => {
    const q = `select count(*) from audit_log where action='farmer.phone_reveal' and entity_id='${f.id}'`;
    const before = Number(sql(q));
    const resp = page.waitForResponse((r) => r.url().includes(`/v1/farmers/${f.id}/phone`));
    await page.getByRole('button', { name: 'Reveal number' }).click();
    const r = await resp;
    const body = await r.json();
    await expect(page.getByText(`Mobile: ${body.phone}`)).toBeVisible();
    expect(body.phone).toMatch(/^\+91\d{10}$/);
    expect(body.phone.slice(-4)).toBe(f.phone_masked.slice(-4));
    await expect(page.getByRole('button', { name: 'Reveal number' })).toHaveCount(0);
    await page.waitForTimeout(500);
    const after = Number(sql(q));
    const row = sql(`select action||'|'||entity_type||'|'||entity_id||'|'||coalesce(actor_user_id::text,'')||'|'||diff::text from audit_log where action='farmer.phone_reveal' and entity_id='${f.id}' order by created_at desc limit 1`);
    expect(after).toBe(before + 1);
    expect(row).toContain(adminId);
    // Never write the full number into the evidence: keep only the last 4 digits.
    return `GET /phone ${r.status()}, page shows the full +91 number (ends ${body.phone.slice(-4)}, matches the mask); button gone; audit rows for this farmer ${before} -> ${after}; latest row ${row.replace(/\+91\d{6}/g, '+91XXXXXX')}`;
  });

  await line(page, 'P01', 'reveal-row-in-audit-log-page', async () => {
    await page.getByRole('navigation', { name: 'Main' }).getByRole('link', { name: 'Audit log' }).click();
    await page.getByLabel('Entity type').selectOption('farmers');
    await page.getByLabel('Entity id').fill(f.id);
    await page.getByRole('button', { name: /^Search/ }).click();
    const table = page.getByRole('table', { name: 'Audit log' });
    await expect(table.getByText('farmer.phone_reveal').first()).toBeVisible();
    const txt = (await table.innerText()).replace(/\s+/g, ' ');
    expect(txt).toContain(adminId);
    expect(txt).not.toMatch(/\+91\d{10}/);
    return `Audit log page, farmers + ${f.id}: ${txt.slice(0, 300)}`;
  });

  // ---------- P06 line 5: a correction with a reason, then the audit search ----------
  await line(page, 'P06', 'audit-search-correction-actor-and-reason', async () => {
    const officer = await apiSignIn(request, '+919000000002');
    const crop = sql("select id from crops where code='SAMBA_VATHAL'");
    const p = sql(
      "select p.id||'|'||st_y(p.pin::geometry)||'|'||st_x(p.pin::geometry) from plots p join batches b on true where b.code='VSDR6JJ0X6NM' and p.created_at < b.created_at order by p.created_at desc limit 1",
    ).split('|');
    const [plotId, lat, lon] = [p[0]!, Number(p[1]), Number(p[2])];
    const lot = await j(request.post('/v1/lots', { headers: admin(), data: { client_id: randomUUID(), plot_id: plotId, crop_id: crop, season_label: `Q02 correction ${new Date().toISOString().slice(0, 16)}` } }));
    const eventId = randomUUID();
    const base = { event_id: eventId, subject_type: 'lot', lot_id: lot.id, plot_id: plotId, event_type: 'harvest', instance_no: 1, occurred_on: new Date(Date.now() - 3 * 864e5).toISOString().slice(0, 10), clocks: { device_time: new Date().toISOString() }, gps: { lat, lon, accuracy_m: 6 } };
    const push = await j(request.post('/v1/sync/push', { headers: officer, data: { device_id: randomUUID(), app_version: '1.0.3', device_time: new Date().toISOString(), entries: [{ client_id: randomUUID(), kind: 'event_version', data: { ...base, version_no: 1, payload: { quantity: { value: 50, unit: 'kg' }, bags: 10 } } }] } }));
    log('push', JSON.stringify(push.results));
    if (push.results?.[0]?.status !== 'applied' && push.results?.[0]?.error) throw new Error(`push refused ${JSON.stringify(push.results)}`);
    const v2 = await j(request.post(`/v1/events/${eventId}/versions`, { headers: officer, data: { client_id: randomUUID(), data: { ...base, version_no: 2, change_kind: 'correct', reason_code: 'wrong_quantity', reason_text: 'Q02 Verifier: scale re-read', payload: { quantity: { value: 48, unit: 'kg' }, bags: 10 } } } }));
    log('v2', JSON.stringify(v2).slice(0, 300));
    const row = sql(`select entity_type||'|'||entity_id||'|'||action||'|'||coalesce(actor_user_id::text,'')||'|'||diff::text from audit_log where action='event.correct' and diff->>'event_id'='${eventId}' order by created_at desc limit 1`);
    const [etype, eid, , actor] = row.split('|');
    await page.getByRole('navigation', { name: 'Main' }).getByRole('link', { name: 'Audit log' }).click();
    await page.reload();
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
    return `lot ${lot.id}; harvest ${eventId} v1 50 kg -> v2 48 kg (correct, wrong_quantity); DB row ${row}; table: ${txt.slice(0, 500)}`;
  });

  // ---------- P07: the live chain's last batch, as the admin sees it ----------
  await line(page, 'P07', 'live-chain-batch-published', async () => {
    const id = sql("select id from batches where code='VSDR6JJ0X6NM'");
    await page.goto(`/batches/${id}`);
    await expect(page.getByRole('heading', { level: 1, name: /^Batch / })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Download labels' })).toBeVisible({ timeout: 60_000 });
    return `batch VSDR6JJ0X6NM (chain run 2) page: ${(await page.locator('main').innerText()).replace(/\s+/g, ' ').slice(0, 300)}`;
  });
  await page.context().storageState({ path: STATE });

  // ---------- P01: field officer sees no Reveal (web sign-in, > 60 s after the API OTP) ----------
  const ctx = await browser.newContext();
  const fo = await ctx.newPage();
  await line(fo, 'P01', 'field-officer-no-reveal-button', async () => {
    await fo.waitForTimeout(62_000);
    await uiSignIn(fo, '9000000002');
    const foAuth = tokenTap(fo);
    await fo.goto(`/members/${f.id}`);
    await expect(fo.getByRole('heading', { level: 1 })).toBeVisible();
    await fo.waitForTimeout(3000);
    const main = (await fo.locator('main').innerText()).replace(/\s+/g, ' ');
    await expect(fo.getByRole('button', { name: 'Reveal number' })).toHaveCount(0);
    expect(main).not.toMatch(/\+91\d{10}/);
    const r = await request.get(`/v1/farmers/${f.id}/phone`, { headers: foAuth() });
    return `field officer on /members/${f.id}: 0 "Reveal number" buttons, no +91 number; page: ${main.slice(0, 250)}; API GET /phone as officer -> ${r.status()} ${(await r.text()).slice(0, 120)}`;
  });
  await ctx.close();

  writeFileSync(`${QA}/Q02/logs/10-reverify-results.json`, JSON.stringify(results, null, 1));
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
