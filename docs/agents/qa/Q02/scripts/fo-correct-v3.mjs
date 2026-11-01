// Q02 Verifier scratch: field officer (android) corrects the Q02 harvest entry to v3 through the side API that runs
// main's code (B20) on the shared DB. Prints status codes only, never tokens.
import { randomUUID } from 'node:crypto';
const SHARED = 'http://localhost:8000', B20 = process.env.B20_API ?? 'http://localhost:8030';
const post = async (url, body, auth) => {
  const r = await fetch(url, { method: 'POST', headers: { 'content-type': 'application/json', ...(auth ? { authorization: `Bearer ${auth}` } : {}) }, body: JSON.stringify(body) });
  const t = await r.text(); console.log('POST', url.replace(/\/\/[^/]+/, ''), r.status);
  if (!r.ok) throw new Error(`${r.status} ${t.slice(0, 300)}`);
  return t ? JSON.parse(t) : {};
};
const phone = '+919000000002';
await post(`${SHARED}/v1/auth/otp/request`, { phone });
const otp = await post(`${SHARED}/v1/auth/otp/verify`, { phone, code: '123456', device_id: randomUUID(), platform: 'android' });
const s = otp.kind === 'pin_required' ? await post(`${SHARED}/v1/auth/pin/verify`, { pin: '2468' }, otp.pin_token) : otp;
const [eventId, lotId, plotId, lat, lon] = process.argv.slice(2);
const v3 = await post(`${B20}/v1/events/${eventId}/versions`, { client_id: randomUUID(), data: {
  event_id: eventId, version_no: 3, subject_type: 'lot', lot_id: lotId, plot_id: plotId, event_type: 'harvest', instance_no: 1,
  occurred_on: '2026-10-29', change_kind: 'correct', reason_code: 'wrong_quantity', reason_text: 'Q02 Verifier: scale re-read (B20 side API)',
  payload: { quantity: { value: 47, unit: 'kg' }, bags: 10 }, clocks: { device_time: new Date().toISOString() }, gps: { lat: Number(lat), lon: Number(lon), accuracy_m: 6 } } }, s.access_token);
console.log('v3', JSON.stringify(v3).slice(0, 300));
