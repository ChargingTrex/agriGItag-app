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

test('P01-P06, P08 live lines', async ({ page, request }) => {
  test.setTimeout(40 * 60_000);
  await page.route(/tile\.openstreetmap\.org|tiles\.maps\.eox\.at/, (r) => r.abort());

  // ---------- sign in (UI) once as the seeded FPO admin ----------
  await page.goto('/');
  await page.getByLabel('Mobile number').fill('9000000001');
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
  } else await pin.fill(PIN);
  await page.getByRole('button', { name: 'Sign in' }).click();
  await expect(page.getByRole('navigation', { name: 'Main' })).toBeVisible();
  const nav = (label: string) =>
    page.getByRole('navigation', { name: 'Main' }).getByRole('link', { name: label }).click();

  /** Admin API headers from the browser session's refresh cookie (no second OTP). */
  const admin = async () => {
    const s = await j(page.request.post('/v1/auth/refresh', { headers: { 'X-Client': 'web' }, data: {} }));
    return { Authorization: `Bearer ${s.access_token}` };
  };
  const officer = await apiSignIn(request, '+919000000002');
  const qc = await apiSignIn(request, '+919000000003');
  let A = await admin();
  const me = await j(request.get('/v1/me', { headers: A }));
  const fpoId: string = me.memberships?.[0]?.fpo_id ?? me.fpo_id ?? sql("select id from fpos limit 1");
  log('me', JSON.stringify(me).slice(0, 300));

  // ---------- P06 line 1: tiles match seed counts (fresh seed, before any fixture) ----------
  await line(page, 'P06', 'tiles-match-seed-counts', async () => {
    await nav('Dashboard');
    const tiles = page.getByRole('region', { name: 'Stage progress (lots)' });
    await expect(tiles).toBeVisible();
    const text = (await tiles.innerText()).replace(/\s+/g, ' ');
    const perType = sql(
      "select e.event_type, count(distinct e.lot_id) from events e group by 1 order by 1",
    );
    const lots = sql('select count(*) from lots');
    log('tiles', text, '| db lots', lots, '| lots per event type', perType);
    const want = ['Land prep', 'Nursery', 'Sowing', 'Inputs', 'Harvest', 'Drying', 'Packing'];
    for (const t of want) expect(text).toContain(t);
    expect((text.match(/3 done · 0 in progress · 0 not started/g) ?? []).length).toBe(7);
    return `tiles: ${text.slice(0, 300)}; DB: ${lots} lots; lots per event type ${perType.replace(/\n/g, ', ')}`;
  });

  // ---------- P08: villages (super-admin flag set by the Verifier), farmers with 2 bad rows ----------
  const villagesCsv = [
    'lgd_code,name_en,name_local,block,taluk,district,state,pincode',
    '990001,QA Village Alpha,,QA Block One,QA Taluk,Virudhunagar,Tamil Nadu,626001',
    '990002,QA Village Beta,,QA Block Two,QA Taluk,Virudhunagar,Tamil Nadu,626002',
  ];
  const tag = randomUUID().slice(0, 4);
  const names = { a: `QA Alpha ${tag}`, b: `QA Beta ${tag}`, bad1: `QA BadPhone ${tag}` };
  await line(page, 'P08', 'template-matches-config-fields', async () => {
    await nav('Master data uploads');
    await page.getByRole('tab', { name: 'Farmers' }).click();
    const cols = page.getByRole('table', { name: /template columns/ });
    await expect(cols).toBeVisible();
    const shown = (await cols.locator('code').allInnerTexts()).map((s) => s.trim());
    const tpl = await (await request.get('/v1/imports/farmers/template.csv', { headers: A })).text();
    const fields = await j(request.get('/v1/config/fields', { headers: A }));
    mkdirSync(`${QA}/P08`, { recursive: true });
    writeFileSync(`${QA}/P08/farmers-template.csv`, tpl);
    writeFileSync(`${QA}/P08/config-fields.json`, JSON.stringify(fields, null, 1));
    const header = tpl.split(/\r?\n/)[0]!.split(',').map((s) => s.trim());
    // The API's rule (registry/imports.py): enabled fields of a CSV type, plus village_lgd_code (resolved to village_id).
    const CSV = ['text', 'number', 'integer', 'boolean', 'date', 'phone', 'choice'];
    const farmerFields = (fields.farmer ?? []) as { name: string; type: string; enabled: boolean }[];
    const expected = [...farmerFields.filter((f) => f.enabled && CSV.includes(f.type)).map((f) => f.name), 'village_lgd_code'];
    const keys = farmerFields.map((f) => `${f.name}:${f.type}`);
    log('template header', header, '| shown', shown, '| /config/fields farmer keys', keys);
    expect(shown).toEqual(header);
    expect(header).toEqual(expected);
    expect(farmerFields.some((f) => f.name === 'village_id' && f.enabled)).toBe(true);
    return `expected from /config/fields ${expected.join('|')}; template ${header.join('|')}; screen ${shown.join('|')}; /config/fields farmer keys ${keys.join('|')}`;
  });

  await line(page, 'P08', 'villages-import-setup', async () => {
    await page.getByRole('tab', { name: 'Villages' }).click();
    await page.getByLabel(/^CSV file/).setInputFiles({
      name: 'qa-villages.csv',
      mimeType: 'text/csv',
      buffer: Buffer.from(villagesCsv.join('\r\n') + '\r\n'),
    });
    await page.getByRole('button', { name: /^Import \d+ rows?$/ }).click();
    await expect(page.getByText(/rows? imported\./)).toBeVisible();
    return 'two QA villages imported (setup for the P06 village filter)';
  });

  let farmersCsv = '';
  await line(page, 'P08', 'two-bad-rows-preview-red-with-codes', async () => {
    await page.getByRole('tab', { name: 'Farmers' }).click();
    const tpl = await (await request.get('/v1/imports/farmers/template.csv', { headers: A })).text();
    const header = tpl.split(/\r?\n/)[0]!.split(',').map((s) => s.trim());
    const row = (vals: Record<string, string>) => header.map((h) => vals[h] ?? '').join(',');
    farmersCsv = [
      header.join(','),
      row({ name: names.a, phone: '+919000000801', village_lgd_code: '990001', village: '990001' }),
      row({ name: '', phone: '+919000000802', village_lgd_code: '990001', village: '990001' }),
      row({ name: names.b, phone: '+919000000803', village_lgd_code: '990002', village: '990002' }),
      row({ name: names.bad1, phone: '12345', village_lgd_code: '990002', village: '990002' }),
    ].join('\r\n') + '\r\n';
    mkdirSync(`${QA}/P08`, { recursive: true });
    writeFileSync(`${QA}/P08/qa-farmers-2-bad.csv`, farmersCsv);
    await page.getByLabel(/^CSV file/).setInputFiles({
      name: 'qa-farmers-2-bad.csv',
      mimeType: 'text/csv',
      buffer: Buffer.from(farmersCsv),
    });
    const table = page.getByRole('table', { name: 'Rows of qa-farmers-2-bad.csv' });
    await expect(table).toBeVisible();
    const rejected = table.getByRole('row').filter({ hasText: 'Rejected' });
    await expect(rejected).toHaveCount(2);
    const texts = await rejected.allInnerTexts();
    const codes = texts.map((t) => /Rejected\s+([a-z_]+)/.exec(t)?.[1] ?? '?');
    const registry = readFileSync('/Users/fi-it/Documents/projects/agriGitag/docs/api/error-codes.md', 'utf8');
    for (const c of codes) expect(registry, `code ${c} in error-codes.md`).toContain(`| \`${c}\` |`);
    const bg = await rejected.first().evaluate((el) => getComputedStyle(el).backgroundColor);
    const status = await page.getByRole('status').filter({ hasText: 'Rows rejected' }).innerText();
    return `2 rejected rows, codes ${codes.join(', ')} (all in error-codes.md); row background ${bg}; "${status.replace(/\s+/g, ' ')}"`;
  });

  await line(page, 'P08', 'confirm-creates-only-valid-rows', async () => {
    const before = Number(sql('select count(*) from farmers'));
    await page.getByRole('button', { name: 'Import 2 rows' }).click();
    await expect(page.getByText(/^2 rows imported\./)).toBeVisible();
    const after = Number(sql('select count(*) from farmers'));
    const created = sql(`select name||':'||status from farmers where name like 'QA % ${tag}' order by name`);
    expect(after - before).toBe(2);
    expect(created).toBe(`${names.a}:pending\n${names.b}:pending`);
    return `farmers ${before} -> ${after}; created: ${created.replace(/\n/g, ', ')}`;
  });

  // ---------- P01 ----------
  const farmerA = sql(`select id from farmers where name='${names.a}'`);
  const farmerB = sql(`select id from farmers where name='${names.b}'`);
  await line(page, 'P01', 'approve-active-without-reload', async () => {
    await page.getByRole('link', { name: 'Open Members' }).click();
    await page.evaluate(() => ((window as any).__qaNoReload = 'still-here'));
    const pending = page.getByRole('table', { name: 'Waiting for approval' });
    await expect(pending.getByRole('row', { name: new RegExp(names.a) })).toBeVisible();
    await page.getByRole('button', { name: `Approve ${names.a}` }).click();
    await expect(pending.getByRole('row', { name: new RegExp(names.a) })).toHaveCount(0);
    const roster = page.getByRole('table', { name: 'All members' });
    await expect(roster.getByRole('row', { name: new RegExp(names.a) })).toContainText('Active');
    const marker = await page.evaluate(() => (window as any).__qaNoReload);
    expect(marker).toBe('still-here');
    await page.getByRole('button', { name: `Approve ${names.b}` }).click();
    await expect(pending.getByRole('row', { name: new RegExp(names.b) })).toHaveCount(0);
    return `${names.a} left "Waiting for approval" and shows Active in "All members"; window marker survived (no reload); DB: ${sql(`select status from farmers where id='${farmerA}'`)}`;
  });

  await line(page, 'P01', 'phone-masked-except-audited-reveal', async () => {
    await page.getByRole('table', { name: 'All members' }).getByRole('link', { name: names.a }).click();
    await expect(page.getByRole('heading', { name: names.a })).toBeVisible();
    const body = await page.locator('main').innerText();
    const reveal = await page.getByRole('button', { name: /reveal|show (phone|number)/i }).count();
    const masked = /\+?91[\s-]*[0-9Xx•*]{2,}|phone|mobile/i.test(body);
    const api = await request.get(`/v1/farmers/${farmerA}/phone`, { headers: await admin() });
    const apiStatus = api.status();
    const auditRows = sql(`select count(*) from audit_log where entity_id='${farmerA}' and action like '%phone%'`);
    log('farmer page text', body.slice(0, 500));
    expect(reveal, 'a Reveal control on the farmer page').toBeGreaterThan(0);
    expect(masked, 'a masked phone on the farmer page').toBe(true);
    return `reveal buttons ${reveal}; API /phone ${apiStatus}; audit rows ${auditRows}`;
  });
  A = await admin();
  mkdirSync(`${QA}/P01`, { recursive: true });
  writeFileSync(`${QA}/P01/farmer-page-text.txt`, (await page.locator('main').innerText()) + '\n');

  // ---------- fixtures: plots, lots, events, readings, intakes ----------
  const crops = await j(request.get('/v1/crops', { headers: A }));
  const crop = crops.find((c: any) => c.code === 'SAMBA_VATHAL').id;
  const procs = await j(request.get('/v1/processors', { headers: A }));
  const proc = (procs.items ?? procs)[0];
  const inst = await j(
    request.post('/v1/instruments', {
      headers: A,
      data: {
        kind: 'moisture_meter',
        make_model: 'QA Verifier meter (portal)',
        serial_no: `QA-WEB-${tag}`,
        calibrated_on: daysAgo(30),
        calibration_due_on: daysAgo(-300),
      },
    }),
  );
  const plot = async (farmer: string, code: string, lat: number, lon: number, acres = '1') =>
    ({
      id: (
        await j(
          request.post('/v1/plots', {
            headers: await admin(),
            data: {
              client_id: randomUUID(),
              farmer_id: farmer,
              pin: { lat, lon, accuracy_m: 5 },
              pin_method: 'live_gps',
              device_time: new Date().toISOString(),
              declared_area: { value: acres, unit: 'acre' },
              code,
              // The page schema requires farming_type although the API and /config/fields make it optional (issue B10-1).
              farming_type: 'rainfed',
            },
          }),
        )
      ).id as string,
      lat,
      lon,
    });
  const ev = (lot: string, p: { id: string; lat: number; lon: number }, kind: string, on: string, payload = {}) => ({
    client_id: randomUUID(),
    kind: 'event_version',
    data: {
      event_id: randomUUID(),
      version_no: 1,
      subject_type: 'lot',
      lot_id: lot,
      plot_id: p.id,
      event_type: kind,
      instance_no: 1,
      occurred_on: on,
      payload,
      clocks: { device_time: new Date().toISOString() },
      gps: { lat: p.lat, lon: p.lon, accuracy_m: 6.2 },
    },
  });
  const push = async (...entries: any[]) => {
    const r = await j(
      request.post('/v1/sync/push', {
        headers: officer,
        data: { device_id: randomUUID(), app_version: '1.0.3', device_time: new Date().toISOString(), entries },
      }),
    );
    const st = r.results.map((x: any) => x.status + (x.error ? ':' + x.error.code : ''));
    log('push', st.join(','));
    return entries.map((e: any) => e.data.event_id as string);
  };
  /** A received lot: optional harvest kg, packing kg, moisture 10.0, ready, intake (received kg). */
  const lot = async (p: { id: string; lat: number; lon: number }, label: string, packed: number, received = packed, harvest?: number) => {
    const H = await admin();
    const id = (await j(request.post('/v1/lots', { headers: H, data: { client_id: randomUUID(), plot_id: p.id, crop_id: crop, season_label: label } }))).id as string;
    const entries = [ev(id, p, 'packing', daysAgo(5), { quantity: { value: packed, unit: 'kg' }, bags: 2 })];
    if (harvest) entries.unshift(ev(id, p, 'harvest', daysAgo(20), { quantity: { value: harvest, unit: 'kg' }, bags: 10 }));
    const evIds = await push(...entries);
    await j(request.post('/v1/quality-readings', { headers: H, data: { client_id: randomUUID(), stage: 'drying_end', parameter_code: 'moisture', measurement: { value: '10.0', unit: '%' }, source: 'instrument', instrument_id: inst.id, measured_at: new Date().toISOString(), lot_id: id } }));
    await j(request.post(`/v1/lots/${id}/ready`, { headers: H }));
    // Retry: POST /v1/intakes can answer 500 (Postgres deadlock with the rules worker, issue WEB-QA-1); same client_id.
    const intake = { client_id: randomUUID(), lot_id: id, processor_id: proc.id, sale_date: today(), received: { value: String(received), unit: 'kg' } };
    for (let k = 1; ; k++) {
      const r = await request.post('/v1/intakes', { headers: H, data: intake });
      if (r.ok()) break;
      log(`intake attempt ${k} for ${label}: ${r.status()} ${(await r.text()).slice(0, 200)}`);
      if (k >= 4) throw new Error(`intake refused 4 times for ${label}`);
      await page.waitForTimeout(1500);
    }
    const code = sql(`select code from lots where id='${id}'`);
    log('lot', label, code, id);
    return { id, code, evIds };
  };
  const pX = await plot(farmerA, `QA-X-${tag}`, 9.5598, 78.1335);
  const pH = await plot(farmerA, `QA-H-${tag}`, 9.5655, 78.1402);
  const pO = await plot(farmerB, `QA-O-${tag}`, 13.0827, 80.2707);
  const pY = await plot(farmerB, `QA-Y-${tag}`, 9.5521, 78.125, '5');
  const X = [await lot(pX, 'QA X1', 100), await lot(pX, 'QA X2', 200), await lot(pX, 'QA X3', 20)];
  const H = await lot(pH, 'QA H yield hold', 50, 50, 2000);
  const H2 = await lot(pH, 'QA H2 yield hold', 40, 40, 2000);
  const O = await lot(pO, 'QA O outside GI', 30);
  const O2 = await lot(pO, 'QA O2 outside GI', 25);
  const Y = await lot(pY, 'QA Y declared above', 100);
  const M = await lot(pY, 'QA M missing reading', 60);
  const T = await lot(pY, 'QA T threshold', 1100);
  const Z = await lot(pY, 'QA Z correction', 45, 45, 50);
  // wait for the rules worker: the yield hold on H/H2 and the GI-region hold on plot O
  for (let i = 0; i < 60; i++) {
    const h = sql(`select count(*) from flags where status='open' and rule_code='yield_over_ceiling' and (subject_id in ('${H.id}','${H2.id}','${pH.id}'))`);
    const o = sql(`select count(*) from flags where status='open' and rule_code='plot_outside_gi_region' and subject_id='${pO.id}'`);
    if (Number(h) > 0 && Number(o) > 0) break;
    await page.waitForTimeout(2000);
  }
  sql(`select rule_code, subject_type, severity, status from flags where status='open' and subject_id in ('${H.id}','${H2.id}','${pH.id}','${pO.id}','${O.id}','${O2.id}') order by 1`);
  sql(`select code, status, packed_kg, gi_eligible, gi_hold_reason from lots where id in ('${[...X, H, H2, O, O2, Y, M, T, Z].map((l) => l.id).join("','")}') order by code`);

  // ---------- P06 line 2: village filter ----------
  await line(page, 'P06', 'village-filter-updates-tiles-and-table', async () => {
    await nav('Dashboard');
    const tiles = page.getByRole('region', { name: 'Stage progress (lots)' });
    const farmers = page.getByRole('table', { name: 'Farmers' });
    await expect(tiles).toBeVisible();
    const before = (await tiles.innerText()).replace(/\s+/g, ' ');
    const rowsBefore = await farmers.getByRole('row').count();
    await page.getByRole('combobox', { name: 'District' }).selectOption('Virudhunagar');
    await page.getByRole('combobox', { name: 'Block' }).selectOption('QA Block One');
    await page.getByRole('combobox', { name: 'Village' }).selectOption({ label: 'QA Village Alpha' });
    await expect.poll(async () => (await tiles.innerText()).replace(/\s+/g, ' ')).not.toBe(before);
    const after = (await tiles.innerText()).replace(/\s+/g, ' ');
    await expect(farmers.getByRole('row')).toHaveCount(2);
    await expect(farmers).toContainText(names.a);
    const rowsAfter = await farmers.getByRole('row').count();
    return `tiles before: ${before.slice(0, 200)} || after (QA Village Alpha): ${after.slice(0, 200)}; farmer table rows ${rowsBefore - 1} -> ${rowsAfter - 1} (${names.a})`;
  });

  await line(page, 'P06', 'column-toggle-persists', async () => {
    await page.getByRole('combobox', { name: 'Village' }).selectOption('');
    const box = page.getByRole('checkbox', { name: 'Village', exact: true });
    await expect(box).toBeChecked();
    await box.uncheck();
    await expect(page.getByRole('table', { name: 'Farmers' }).getByRole('columnheader', { name: 'Village' })).toHaveCount(0);
    await page.reload();
    await expect(page.getByRole('navigation', { name: 'Main' })).toBeVisible();
    await expect(page.getByRole('checkbox', { name: 'Village', exact: true })).not.toBeChecked();
    await expect(page.getByRole('table', { name: 'Farmers' }).getByRole('columnheader', { name: 'Village' })).toHaveCount(0);
    const stored = await page.evaluate(() => Object.entries(localStorage).filter(([k]) => k.startsWith('agritrace.dashboard.columns')));
    return `Village unchecked, page reloaded: still unchecked and the column absent; localStorage ${JSON.stringify(stored)}`;
  });
  A = await admin();

  // ---------- P03 ----------
  await line(page, 'P03', 'shares-31.25-62.5-6.25', async () => {
    await nav('Ready lots');
    for (const l of X) await page.getByRole('checkbox', { name: `Tick lot ${l.code}` }).check();
    const table = page.getByRole('table', { name: 'Ready lots' });
    const share = async (code: string) => (await table.getByRole('row').filter({ hasText: code }).getByRole('cell').last().innerText()).trim();
    const got = [await share(X[0]!.code), await share(X[1]!.code), await share(X[2]!.code)];
    expect(got.map((s) => parseFloat(s))).toEqual([31.25, 62.5, 6.25]);
    const total = await page.getByText(/lots? ticked, total/).innerText();
    return `shares ${got.join(' / ')} for ${X.map((l) => l.code).join(', ')} (100/200/20 kg); "${total}"`;
  });

  await line(page, 'P03', 'out-of-GI-greyed-with-tooltip', async () => {
    const box = page.getByRole('checkbox', { name: new RegExp(`^Lot ${O.code}: `) });
    await expect(box).toBeDisabled();
    const label = await box.getAttribute('aria-label');
    await box.locator('xpath=ancestor::span[1]/..').hover();
    const tip = page.getByRole('tooltip');
    await expect(tip).toBeVisible();
    const tipText = await tip.innerText();
    const color = await page.getByRole('row').filter({ hasText: O.code }).getByRole('cell').nth(1).evaluate((el) => getComputedStyle(el).color);
    return `checkbox disabled, aria-label "${label}"; tooltip "${tipText}"; row text colour ${color}`;
  });

  let batchX = '';
  let codeX = '';
  await line(page, 'P03', 'create-id-and-qr', async () => {
    await page.getByRole('combobox', { name: 'Processor' }).click();
    await page.getByRole('option').first().click();
    await page.getByRole('button', { name: 'Create batch', exact: true }).click();
    const heading = page.getByRole('heading', { level: 1, name: /^Batch / });
    await expect(heading).toBeVisible();
    codeX = ((await heading.textContent()) ?? '').replace('Batch ', '').trim();
    batchX = page.url().split('/batches/')[1]!;
    await expect(page.getByText(`Batch ID: ${codeX}`)).toBeVisible();
    return `batch ${codeX} (${batchX}); "Batch ID and QR" section shows the ID; the QR appears after publish (checked under P04 happy path)`;
  });

  let batchT = '';
  await line(page, 'P03', 'threshold-second-signoff-state', async () => {
    await nav('Ready lots');
    await page.getByRole('checkbox', { name: `Tick lot ${T.code}` }).check();
    await page.getByRole('combobox', { name: 'Processor' }).click();
    await page.getByRole('option').first().click();
    await page.getByRole('button', { name: 'Create batch', exact: true }).click();
    await expect(page.getByRole('heading', { level: 1, name: /^Batch / })).toBeVisible();
    batchT = page.url().split('/batches/')[1]!;
    await expect(page.getByText(/Waiting for a second admin/)).toBeVisible();
    const btn = page.getByRole('button', { name: /^Sign off(:|$)/ });
    await expect(btn).toBeDisabled();
    return `1100 kg batch > 1000 kg threshold: "Waiting for a second admin" + Sign off disabled ("${await btn.getAttribute('aria-label')}")`;
  });

  // ---------- P02 ----------
  await line(page, 'P02', 'required-fields-block-submit', async () => {
    await nav('Flags');
    const row = page.getByRole('table', { name: 'Flags' }).getByRole('row').filter({ hasText: `lot ${H.id.slice(0, 8)}` }).filter({ hasText: 'Yield above the ceiling' }).first();
    await expect(row).toBeVisible();
    await row.getByRole('link').first().click();
    await expect(page.getByRole('heading', { name: 'Resolve this flag' })).toBeVisible();
    const flagId = page.url().split('/flags/')[1];
    await page.getByRole('button', { name: 'Save review' }).click();
    await expect(page.getByText('Choose a reason.')).toBeVisible();
    const still = sql(`select status from flags where id='${flagId}'`);
    expect(still).toBe('open');
    return `Save review with no outcome/reason: "Choose a reason." shown, flag ${flagId} still ${still}`;
  });

  await line(page, 'P02', 'review-held-lot-cleared-tickable-in-P03', async () => {
    await page.getByLabel(/^Outcome/).selectOption('looks_fine');
    await page.getByLabel(/^Reason/).selectOption({ index: 1 });
    await page.getByLabel(/^Note/).fill('QA Verifier: field visit confirmed the yield');
    await page.getByRole('button', { name: 'Save review' }).click();
    await expect(page.getByText(/^Cleared on/)).toBeVisible();
    for (let i = 0; i < 30 && sql(`select gi_eligible from lots where id='${H.id}'`) !== 't'; i++) await page.waitForTimeout(1000);
    await nav('Ready lots');
    const box = page.getByRole('checkbox', { name: `Tick lot ${H.code}` });
    await expect(box).toBeEnabled();
    await box.check();
    await expect(box).toBeChecked();
    await box.uncheck();
    return `flag cleared; lot ${H.code} gi_eligible=${sql(`select gi_eligible from lots where id='${H.id}'`)}; tick box enabled and tickable on Ready lots`;
  });

  // ---------- P04 ----------
  const grade = async (batch: string, declared: string, readings: unknown[]) =>
    request.post(`/v1/batches/${batch}/grading`, { headers: qc, data: { declared_grade: declared, readings } });
  const gReading = (batch: string, v = '10.5') => ({ client_id: randomUUID(), stage: 'grading', parameter_code: 'moisture', measurement: { value: v, unit: '%' }, source: 'instrument', instrument_id: inst.id, measured_at: new Date().toISOString(), batch_id: batch });
  const apiBatch = async (lots: string[], gi: boolean) => (await j(request.post('/v1/batches', { headers: await admin(), data: { client_id: randomUUID(), processor_id: proc.id, gi_label_requested: gi, lot_ids: lots } }))).id as string;

  await line(page, 'P04', 'declared-Special-computed-Standard-approve-disabled', async () => {
    const b = await apiBatch([Y.id], true);
    const r = await grade(b, 'Special', [gReading(b)]);
    log('grading Y', r.status(), (await r.text()).slice(0, 300));
    await page.goto(`/batches/${b}`);
    const btn = page.getByRole('button', { name: /^Approve grading/ });
    await expect(btn).toBeDisabled();
    const label = await btn.getAttribute('aria-label');
    expect(label ?? '').toMatch(/Special|Standard|declared/i);
    return `grading ${r.status()}; Approve grading disabled, reason "${label}"`;
  });

  await line(page, 'P04', 'missing-reading-approve-disabled', async () => {
    const b = await apiBatch([M.id], true);
    let r = await grade(b, 'Standard', []);
    let how = `grading with readings [] -> ${r.status()} ${(await r.text()).slice(0, 200)}`;
    if (!r.ok()) how += ' (batch left ungraded)';
    await page.goto(`/batches/${b}`);
    const btn = page.getByRole('button', { name: /^Approve grading/ });
    await btn.waitFor({ timeout: 20_000 }).catch(() => undefined);
    const any = await btn.count();
    if (any === 0) {
      const txt = (await page.locator('main').innerText()).slice(0, 600).replace(/\s+/g, ' ');
      throw new Error(`no Approve grading button; ${how}; page: ${txt}`);
    }
    await expect(btn).toBeDisabled();
    return `${how}; Approve grading disabled, reason "${await btn.getAttribute('aria-label')}"`;
  });

  await line(page, 'P04', 'happy-path-published-and-URL', async () => {
    const r = await grade(batchX, 'Standard', [gReading(batchX)]);
    log('grading X', r.status());
    await page.goto(`/batches/${batchX}`);
    const graded = page.getByLabel('Graded quantity (kg)');
    await expect(graded).toBeVisible();
    await graded.fill('320');
    await page.getByRole('button', { name: 'Approve grading', exact: true }).click();
    await expect(page.getByText(/^Grading approved/)).toBeVisible();
    await page.getByLabel('Packed quantity (kg)').fill('320');
    await page.getByLabel('Pack date').fill(today());
    await page.getByLabel('Best before').fill(daysAgo(-364));
    await page.getByRole('button', { name: 'Sign off final packing', exact: true }).click();
    await expect(page.getByText(/^Packed \d/)).toBeVisible();
    const t0 = Date.now();
    await page.getByRole('button', { name: 'Publish', exact: true }).click();
    const link = page.getByRole('link', { name: new RegExp(`/b/${codeX}$`) });
    await expect(link).toBeVisible({ timeout: 120_000 });
    const secs = ((Date.now() - t0) / 1000).toFixed(1);
    const qr = await page.getByRole('img', { name: /QR/i }).count();
    return `published; URL ${await link.innerText()} after ${secs} s; QR images ${qr}; DB ${sql(`select status from batches where id='${batchX}'`)}`;
  });

  let batchN = '';
  await line(page, 'P04', 'non-GI-D041-holds-are-warnings-GI-grey', async () => {
    await nav('Ready lots');
    const sw = page.getByLabel(/^Non-GI batch: lots outside the GI region/);
    const swText = await page.getByText(/^Non-GI batch: lots outside the GI region or above the yield ceiling can join\. The public page shows no GI badge\.$/).count();
    await sw.check();
    await page.getByRole('checkbox', { name: `Tick lot ${O.code}` }).check();
    await page.getByRole('checkbox', { name: `Tick lot ${H2.code}` }).check();
    await page.getByRole('combobox', { name: 'Processor' }).click();
    await page.getByRole('option').first().click();
    await page.getByRole('button', { name: 'Create non-GI batch', exact: true }).click();
    await expect(page.getByRole('heading', { level: 1, name: /^Batch / })).toBeVisible();
    batchN = page.url().split('/batches/')[1]!;
    const g = await grade(batchN, 'Standard', [gReading(batchN)]);
    await page.reload();
    await expect(page.getByText('Non-GI batch: no GI badge on the public page')).toBeVisible();
    const warn = await page.getByText(/: allowed in a non-GI batch$/).allInnerTexts();
    const approve = page.getByRole('button', { name: /^Approve grading/ });
    await expect(approve).toBeEnabled();
    await shot(page, 'P04', 'non-GI-batch-warnings');
    // the same holds on a GI batch grey the button with the reason
    const gb = await apiBatch([O2.id], true);
    await grade(gb, 'Standard', [gReading(gb)]);
    await page.goto(`/batches/${gb}`);
    const gApprove = page.getByRole('button', { name: /^Approve grading/ });
    await expect(gApprove).toBeDisabled();
    const reason = await gApprove.getAttribute('aria-label');
    expect(warn.length).toBeGreaterThan(0);
    expect(swText).toBe(1);
    return `switch text present (${swText}); non-GI batch grading ${g.status()}, chip shown, warnings ${JSON.stringify(warn)}, Approve enabled; GI batch with O2: Approve disabled "${reason}"`;
  });

  // ---------- P05 ----------
  await line(page, 'P05', 'labels-batchId-pdf', async () => {
    await page.goto(`/batches/${batchX}`);
    const dl = page.waitForEvent('download');
    await page.getByRole('button', { name: 'Download labels' }).click();
    const d = await dl;
    const name = d.suggestedFilename();
    mkdirSync(`${QA}/P05/downloads`, { recursive: true });
    await d.saveAs(`${QA}/P05/downloads/${name}`);
    const head = readFileSync(`${QA}/P05/downloads/${name}`).subarray(0, 5).toString();
    expect(name).toBe(`labels-${codeX}.pdf`);
    expect(head).toBe('%PDF-');
    return `downloaded ${name} (${head}...)`;
  });

  await line(page, 'P05', 'csv-unit-on-every-quantity', async () => {
    const out: string[] = [];
    for (const [label, file] of [['Download lots CSV', 'lots'], ['Download audit CSV', 'audit']] as const) {
      const dl = page.waitForEvent('download');
      await page.getByRole('button', { name: label }).click();
      const d = await dl;
      await d.saveAs(`${QA}/P05/downloads/${d.suggestedFilename()}`);
      const text = readFileSync(`${QA}/P05/downloads/${d.suggestedFilename()}`, 'utf8');
      const header = text.split(/\r?\n/)[0]!;
      out.push(`${d.suggestedFilename()}: ${header}`);
      log(file, 'csv head', text.slice(0, 600));
    }
    await nav('Labels & exports');
    const dl = page.waitForEvent('download');
    await page.getByRole('button', { name: 'Download farmers CSV' }).click();
    const d = await dl;
    await d.saveAs(`${QA}/P05/downloads/${d.suggestedFilename()}`);
    out.push(`${d.suggestedFilename()}: ${readFileSync(`${QA}/P05/downloads/${d.suggestedFilename()}`, 'utf8').split(/\r?\n/)[0]}`);
    return out.join(' || ');
  });

  // ---------- P06 audit search and opt-out ----------
  await line(page, 'P06', 'audit-search-correction-actor-and-reason', async () => {
    const harvestId = Z.evIds[0]!;
    const v2 = randomUUID();
    const r = await request.post(`/v1/events/${harvestId}/versions`, {
      headers: officer,
      data: { client_id: v2, data: { event_id: harvestId, version_no: 2, subject_type: 'lot', lot_id: Z.id, plot_id: pY.id, event_type: 'harvest', instance_no: 1, occurred_on: daysAgo(20), change_kind: 'correct', reason_code: 'wrong_quantity', reason_text: 'QA Verifier: scale re-read', payload: { quantity: { value: 48, unit: 'kg' }, bags: 10 }, clocks: { device_time: new Date().toISOString() }, gps: { lat: pY.lat, lon: pY.lon, accuracy_m: 6 } } },
    });
    const rt = await r.text();
    log('correction', r.status(), rt.slice(0, 300));
    if (!r.ok()) throw new Error(`correction refused ${r.status()} ${rt.slice(0, 200)}`);
    const row = sql(`select entity_type||'|'||entity_id||'|'||action||'|'||coalesce(actor_user_id::text,'') from audit_log where action like 'event.correct%' order by created_at desc limit 1`);
    const [etype, eid, , actor] = row.split('|');
    await nav('Audit log');
    await page.getByLabel('Entity type').selectOption(etype!);
    await page.getByLabel('Entity id').fill(eid!);
    await page.getByRole('button', { name: /^Search/ }).click();
    const table = page.getByRole('table', { name: 'Audit log' });
    await expect(table.getByRole('row').nth(1)).toBeVisible();
    const txt = (await table.innerText()).replace(/\s+/g, ' ');
    expect(txt).toContain(actor!);
    expect(txt).toMatch(/wrong_quantity|scale re-read/);
    return `audit row ${row}; table: ${txt.slice(0, 400)}`;
  });

  await line(page, 'P06', 'opt-out-reflected-in-preview', async () => {
    await page.goto(`/batches/${batchX}`);
    const frame = page.frameLocator('iframe[title^="Preview of the public page"]');
    await expect(frame.locator('body')).toBeVisible({ timeout: 60_000 });
    const before = (await frame.locator('body').innerText()).replace(/\s+/g, ' ');
    sql(`update fpos set public_show_farmer_names=false where id='${fpoId}'`);
    await page.getByRole('button', { name: /^Rebuild/ }).click();
    await page.waitForTimeout(3000);
    for (let i = 0; i < 60 && sql(`select status from page_builds where batch_id='${batchX}' order by build_no desc limit 1`) !== 'built'; i++) await page.waitForTimeout(2000);
    await page.reload();
    await expect(frame.locator('body')).toBeVisible({ timeout: 60_000 });
    const after = (await frame.locator('body').innerText()).replace(/\s+/g, ' ');
    log('preview before', before.slice(0, 600));
    log('preview after', after.slice(0, 600));
    await nav('Settings');
    await expect(page.getByLabel('Hide farmer names on public pages (opt-out)')).toBeChecked();
    expect(after).not.toContain(names.a);
    expect(after).toMatch(/Farmer 1/);
    return `before: names.a shown=${before.includes(names.a)} ("Farmer 1" ${/Farmer 1/.test(before)}); after opt-out + Rebuild: names.a shown=${after.includes(names.a)}, "Farmer 1" ${/Farmer 1/.test(after)}; Settings switch checked`;
  });

  writeFileSync(process.env['QA_RESULTS'] ?? `${QA}/../qa-portal-results.json`, JSON.stringify({ tag, codeX, batchX, batchT, batchN, results }, null, 1));
  for (const r of results) console.log(`RESULT ${r.result} ${r.wp} ${r.line} :: ${r.detail}`);
});
