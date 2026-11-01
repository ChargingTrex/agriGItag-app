"""Verifier live check of the B14 acceptance lines on the compose stack.

Purpose: drive the registry additions (phone_masked + audited reveal, reject, farmer plots, list filters, FPO bbox) as
the seeded FPO admin and field officer, and read audit rows back with psql. Writes: one audit row per reveal and one
new pending farmer that is then rejected. Caller: the Verifier, with live_common.py from docs/agents/qa/B06/logs.
"""

import json
import os
import re
import subprocess
import sys
import uuid

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "../../B06/logs"))
from live_common import ADMIN, OFFICER, client, show  # noqa: E402

W = json.load(open(os.environ["QA_WORLD"]))
PHONE_RE = re.compile(r"\+?91?9000000\d{3}")


def sql(q: str) -> str:
    """Run one SQL query on the compose DB and print it with its result."""
    out = subprocess.run(["psql", "-h", "localhost", "-p", "5433", "-U", "agritrace", "agritrace", "-Atc", q],
                         env={**os.environ, "PGPASSWORD": "agritrace"}, capture_output=True, text=True, check=True)
    print(f"  sql> {q}\n  =>  {out.stdout.strip()!r}")
    return out.stdout.strip()


with client(ADMIN) as a, client(OFFICER) as o:
    print("== 1. list shows phone_masked, never the full phone; reveal: officer 403, admin 200 + one audit row")
    for who, c in (("admin", a), ("officer", o)):
        r = show(c.get("/farmers", params={"limit": 50}), body_limit=700)
        items = r.json()["items"]
        print(f"  {who}: {len(items)} farmers; phone_masked values: {sorted({i.get('phone_masked') for i in items}, key=str)}; "
              f"full-phone matches in body: {PHONE_RE.findall(r.text)}; 'phone' key present: {any('phone' in i for i in items)}")
    fid = W["farmer"]
    aq = f"select count(*) from audit_log where action='farmer.phone_reveal' and entity_id='{fid}'"
    before = sql(aq)
    r = show(o.get(f"/farmers/{fid}/phone"))
    print(f"RESULT line1 officer: HTTP {r.status_code} {r.json().get('error', {}).get('code')}")
    r = show(a.get(f"/farmers/{fid}/phone"))
    print(f"RESULT line1 admin: HTTP {r.status_code}")
    after = sql(aq)
    sql(f"select action, actor_user_id is not null, diff from audit_log where action='farmer.phone_reveal' "
        f"and entity_id='{fid}' order by at desc limit 1")
    print(f"RESULT line1 audit rows: before={before} after={after}")
    r = show(a.get(f"/farmers/{uuid.uuid4()}/phone"))
    print(f"  unknown / not-in-FPO farmer id -> HTTP {r.status_code} {r.json().get('error', {}).get('code')}")

    print("\n== 2. reject a pending farmer -> status changes + audit row with reason; reject an active farmer -> 409")
    p = show(a.post("/farmers", json={"name": "QA Verifier Reject Me", "lang": "en", "no_smartphone": True,
                                      "client_id": str(uuid.uuid4())})).json()
    body = {"reason_code": "duplicate_registration", "reason_text": "QA verifier: registered twice"}
    r = show(a.post(f"/farmers/{p['id']}/reject", json=body))
    print(f"RESULT line2 pending: HTTP {r.status_code} status {p['status']} -> {r.json().get('status')}")
    sql(f"select action, diff from audit_log where action='farmer.reject' and entity_id='{p['id']}'")
    r = show(a.post(f"/farmers/{fid}/reject", json=body))
    print(f"RESULT line2 active: HTTP {r.status_code} {r.json().get('error', {}).get('code')}")

    print("\n== 3. GET /farmers/{id}/plots returns that farmer's plots only; PlotOut carries gi_tag_id")
    r = show(a.get(f"/farmers/{fid}/plots"), body_limit=400)
    items = r.json()["items"]
    print(f"RESULT line3: {len(items)} plots {[i['code'] for i in items]}; all farmer_id == QA farmer: "
          f"{all(i['farmer_id'] == fid for i in items)}; gi_tag_id key on every row: {all('gi_tag_id' in i for i in items)}")
    sql(f"select count(*) from plots where farmer_id='{fid}'")
    seeded = [i for i in a.get("/farmers", params={"limit": 50}).json()["items"] if i["code"] != "FF88C00"
              and i["status"] == "active"][0]
    r = a.get(f"/farmers/{seeded['id']}/plots")
    print(f"  seeded farmer {seeded['code']}: {[(i['code'], i['farmer_id'] == seeded['id'], i['gi_tag_id']) for i in r.json()['items']]}")

    print("\n== 4. ?village_id= and ?q= filter server-side; ?fields=code,name trims the rows")
    allf = a.get("/farmers", params={"limit": 50}).json()["items"]
    print(f"  all: {[(i['code'], i['name'], i['village_id']) for i in allf]}")
    vid = next((i["village_id"] for i in allf if i["village_id"]), None)
    if vid:
        r = show(a.get("/farmers", params={"village_id": vid}), body_limit=300)
        print(f"RESULT line4 village_id: {[i['code'] for i in r.json()['items']]} (expected {[i['code'] for i in allf if i['village_id'] == vid]})")
    for q in ("selvi", "FF88", "0091"):
        r = show(a.get("/farmers", params={"q": q}), body_limit=200)
        print(f"RESULT line4 q={q}: {[i['code'] + ' ' + i['name'] for i in r.json()['items']]}")
    r = show(a.get("/farmers", params={"fields": "code,name", "limit": 2}))
    print(f"RESULT line4 fields: row keys {[sorted(i) for i in r.json()['items']]}")

    print("\n== 5. GET /v1/fpos/{id} carries bbox")
    r = show(a.get(f"/fpos/{a.get('/farmers', params={'limit': 1}).json()['items'][0]['fpo_id']}"))
    print(f"RESULT line5: bbox={r.json().get('bbox')}")
