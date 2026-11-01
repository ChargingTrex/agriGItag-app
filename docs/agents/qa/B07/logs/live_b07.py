"""Verifier live check of the B07 acceptance lines on the compose stack.

Purpose: as the QA farmer (and the seeded farmer +919000000011 for scoping), download the bundle manifest and every
part, send each ETag back (expect 304), compare the `standards` part with the active profile rules in the DB, then
drain `/v1/sync/pull`, add one flag on the QA farmer's lot 4 with psql (as tests/integration/test_bundle_pull.py
does), wait past PULL_SETTLE (30 s), and pull again. $QA_WORLD is the second QA farmer (live_setup2.py), which no
other script writes to. Caller: the Verifier.
"""

import json
import os
import subprocess
import sys
import time
import uuid

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "../../B06/logs"))
from live_common import client, show  # noqa: E402

W = json.load(open(os.environ["QA_WORLD"]))
SEEDED = "+919000000011"


def sql(q: str) -> str:
    """Run one SQL query on the compose DB and print it with its result."""
    out = subprocess.run(["psql", "-h", "localhost", "-p", "5433", "-U", "agritrace", "agritrace", "-Atc", q],
                         env={**os.environ, "PGPASSWORD": "agritrace"}, capture_output=True, text=True, check=True)
    print(f"  sql> {q[:300]}\n  =>  {out.stdout.strip()[:300]!r}")
    return out.stdout.strip()


def drain(c, cursor=None):
    """Pull every page from a cursor; return (changes, last cursor)."""
    changes = []
    while True:
        page = c.get("/sync/pull", params={"cursor": cursor} if cursor else {}).json()
        changes += page["changes"]
        cursor = page["next_cursor"]
        if not page["has_more"]:
            return changes, cursor


with client(W["phone"]) as f, client(SEEDED) as s:
    print("== 1. matching If-None-Match -> 304 (manifest and every part)")
    m = show(f.get("/sync/bundle"), body_limit=900)
    r = f.get("/sync/bundle", headers={"If-None-Match": m.headers.get("etag", "")})
    print(f"RESULT line1 manifest: If-None-Match {m.headers.get('etag')} -> HTTP {r.status_code}, body {len(r.content)} B")
    parts = m.json()["parts"]
    for part, entry in parts.items():
        first = f.get(f"/sync/bundle/{part}")
        again = f.get(f"/sync/bundle/{part}", headers={"If-None-Match": entry["etag"]})
        stale = f.get(f"/sync/bundle/{part}", headers={"If-None-Match": '"stale"'})
        print(f"RESULT line1 part={part}: 200 etag==manifest {first.headers.get('etag') == entry['etag']}, "
              f"{len(first.content)} B; matching -> HTTP {again.status_code} ({len(again.content)} B); stale -> {stale.status_code}")

    since = ",".join(f"{p}:{v['version']}" for p, v in parts.items())
    r = f.get("/sync/reference", params={"since": since})
    print(f"RESULT line1 /sync/reference with every current version -> HTTP {r.status_code} ({len(r.content)} B)")
    r = f.get("/sync/reference", params={"since": since.replace("plots:", "plots:1")})
    print(f"  /sync/reference with an old plots version -> HTTP {r.status_code}, parts {list(r.json()['parts'])}")

    print("\n== 2. standards part carries the full profile rules JSON per active version")
    body = show(f.get("/sync/bundle/standards"), body_limit=300).json()
    db = json.loads(sql(
        "select json_object_agg(sp.crop_id, v.rules) from standards_profile_versions v "
        "join standards_profiles sp on sp.id = v.profile_id "
        "where v.version_no = (select max(version_no) from standards_profile_versions w where w.profile_id = v.profile_id)"))
    sql("select sp.crop_id, v.version_no, v.status from standards_profile_versions v join standards_profiles sp on sp.id=v.profile_id")
    for crop, rules in body["profiles"].items():
        print(f"RESULT line2 crop {crop}: bundle rules == DB rules: {rules == db.get(crop)}; top-level keys {sorted(rules)}")
    print(f"  crops in DB {sorted(db)} vs bundle {sorted(body['profiles'])}")

    print("\n== 3. pull after a new flag returns exactly that flag")
    first, cur = drain(f)
    print(f"  QA farmer first drain: {len(first)} changes {sorted({c['entity'] for c in first})}")
    sfirst, scur = drain(s)
    print(f"  seeded farmer first drain: {len(sfirst)} changes")
    again, cur2 = drain(f, cur)
    print(f"  QA farmer drain again before the flag: {len(again)} changes")
    fid = str(uuid.uuid4())
    lot = W["lots"][3]
    sql(f"insert into flags (id, fpo_id, subject_type, subject_id, rule_code, severity, details, dedupe_key, status, "
        f"assigned_role, raised_at, created_at, updated_at) select '{fid}', fpo_id, 'lot', id, 'quantity_mismatch', "
        f"'warn', '{{\"qa_verifier\": true}}', 'quantity_mismatch:{lot}:qa', 'open', 'field_officer', "
        f"now(), now(), now() from lots where id = '{lot}' returning id")
    print("  waiting 35 s (PULL_SETTLE = 30 s holds back rows younger than that)")
    time.sleep(35)
    second, _ = drain(f, cur2 or cur)
    print(f"RESULT line3 QA farmer: {[(c['entity'], c['op'], c['data'].get('id')) for c in second]} (new flag id {fid})")
    sec_seeded, _ = drain(s, scur)
    print(f"RESULT line3 seeded farmer (other lots): {[(c['entity'], c['data'].get('id')) for c in sec_seeded]}")
    sql(f"select device_id, last_pull_cursor is not null from sync_cursors where device_id in "
        f"(select id from devices where user_id = (select user_id from farmers where id = '{W['farmer']}'))")
