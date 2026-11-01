"""Verifier live check of the B06 acceptance lines plus BM-06 and BM-15 on the compose stack.

Purpose: drive `POST /v1/sync/push`, the presigned photo PUT, `/sync/photos/confirm`, undo and correction as the QA
farmer from live_setup.py (never the seeded reference batch), let the real Celery worker run verify_photo and the
rules, and read the rows back with psql. Prints every call; writes benchmark JSON to $QA_BENCH. Caller: the Verifier.
"""

import hashlib
import json
import os
import subprocess
import sys
import time
import uuid
from datetime import UTC, datetime, timedelta
from io import BytesIO

import boto3
import httpx
from PIL import ExifTags, Image

sys.path.insert(0, os.path.dirname(__file__))
from live_common import OFFICER, client, show  # noqa: E402

from agritrace.core.ids import uuid7  # noqa: E402

W = json.load(open(os.environ["QA_WORLD"]))
LOT, PLOT = W["lots"][0], W["plots"][0]
DEVICE = str(uuid.uuid4())


def sql(q: str) -> str:
    """Run one SQL query on the compose DB and return the unaligned output."""
    out = subprocess.run(["psql", "-h", "localhost", "-p", "5433", "-U", "agritrace", "agritrace", "-Atc", q],
                         env={**os.environ, "PGPASSWORD": "agritrace"}, capture_output=True, text=True, check=True)
    print(f"  sql> {q}\n  =>  {out.stdout.strip()!r}")
    return out.stdout.strip()


def harvest(kg: int = 195, *, lot: str = LOT, plot: dict = PLOT, device_time: datetime | None = None,
            photos: list | None = None, lat: float | None = None) -> dict:
    """Build a harvest event_version entry (version 1) on a QA lot."""
    data = {"event_id": str(uuid7()), "version_no": 1, "subject_type": "lot", "lot_id": lot, "plot_id": plot["id"],
            "event_type": "harvest", "instance_no": 1, "occurred_on": datetime.now(UTC).date().isoformat(),
            "payload": {"quantity": {"value": kg, "unit": "kg"}, "bags": 13},
            "clocks": {"device_time": (device_time or datetime.now(UTC)).isoformat()},
            "gps": {"lat": lat or plot["lat"], "lon": plot["lon"], "accuracy_m": 6.2}}
    if photos:
        data["photos"] = photos
    return {"client_id": str(uuid7()), "kind": "event_version", "data": data}


def env(*entries: dict) -> dict:
    """Wrap entries in a push envelope from the QA device."""
    return {"device_id": DEVICE, "app_version": "1.0.3", "device_time": datetime.now(UTC).isoformat(),
            "entries": list(entries)}


def jpeg() -> bytes:
    """A JPEG whose EXIF time is now (IST) and GPS is plot 1."""
    exif = Image.Exif()
    exif.get_ifd(ExifTags.IFD.Exif).update({ExifTags.Base.DateTimeOriginal: datetime.now(
        UTC).astimezone().strftime("%Y:%m:%d %H:%M:%S"), ExifTags.Base.OffsetTimeOriginal: "+05:30"})
    buf = BytesIO()
    Image.new("RGB", (1600, 1200), "darkred").save(buf, "JPEG", exif=exif, quality=80)
    return buf.getvalue()


def wait_sql(q: str, want, secs: int = 180) -> str:
    """Poll a query until want(result) is true (the Celery worker runs asynchronously)."""
    t0 = time.time()
    while True:
        r = subprocess.run(["psql", "-h", "localhost", "-p", "5433", "-U", "agritrace", "agritrace", "-Atc", q],
                           env={**os.environ, "PGPASSWORD": "agritrace"}, capture_output=True, text=True).stdout.strip()
        if want(r) or time.time() - t0 > secs:
            print(f"  sql (after {time.time() - t0:.0f}s)> {q}\n  =>  {r!r}")
            return r
        time.sleep(3)


bench = {}
f = client(W["phone"])
lots_in = f"('{LOT}','{W['lots'][1]}','{W['lots'][2]}')"
count_q = f"select count(*) from event_versions ev join events e on e.id=ev.event_id where e.lot_id in {lots_in}"

print("\n== 1. same client_id 2x -> 1 row, 2nd duplicate")
e1 = harvest()
r1 = show(f.post("/sync/push", json=env(e1))).json()["results"][0]
r2 = show(f.post("/sync/push", json=env(e1))).json()["results"][0]
n = sql(f"select count(*) from event_versions where id='{e1['client_id']}'")
print(f"RESULT line1: first={r1['status']} second={r2['status']} rows={n} server_ids_equal={r1['server_id'] == r2['server_id']}")

print("\n== BM-15: the same push replayed 5x -> exactly one record")
e15 = harvest()
st = [show(f.post("/sync/push", json=env(e15))).json()["results"][0]["status"] for _ in range(5)]
n15 = sql(f"select count(*) from event_versions where id='{e15['client_id']}'")
n15e = sql(f"select count(*) from events where id='{e15['data']['event_id']}'")
print(f"RESULT BM-15: statuses={st} event_versions={n15} events={n15e}")
bench["BM-15"] = {"server_records": int(n15)}

print("\n== BM-06: an outbox of 3 entries (one with a photo) sent once, then replayed 3x")
img = jpeg()
sha = hashlib.sha256(img).hexdigest()
pid = str(uuid7())
outbox = [harvest(), harvest(photos=[{"client_id": pid, "sha256": sha, "size_bytes": len(img)}]), harvest()]
first = show(f.post("/sync/push", json=env(*outbox))).json()["results"]
up = first[1]["photo_uploads"][0]
pr = httpx.put(up["url"], content=img, headers=up["headers"], timeout=120)
print(f"$ PUT <presigned evidence URL> -> HTTP {pr.status_code}")
show(f.post("/sync/photos/confirm", json={"photos": [{"client_id": pid}]}))
wait_sql(f"select status from evidence_photos where id='{pid}'", lambda r: r not in ("pending", "uploaded", ""))
before = sql(count_q)
ph_before = sql(f"select sha256_client||'|'||coalesce(sha256_server,'') from evidence_photos where id='{pid}'")
ph_rows_before = sql(f"select count(*) from evidence_photos where id='{pid}'")
for i in range(3):
    res = show(f.post("/sync/push", json=env(*outbox))).json()["results"]
    print(f"  replay {i + 1}: {[x['status'] for x in res]}; photo_uploads on replay: {[len(x['photo_uploads']) for x in res]}")
after = sql(count_q)
ph_after = sql(f"select sha256_client||'|'||coalesce(sha256_server,'') from evidence_photos where id='{pid}'")
ph_rows_after = sql(f"select count(*) from evidence_photos where id='{pid}'")
print(f"RESULT BM-06: version rows before={before} after={after}; photo rows {ph_rows_before}->{ph_rows_after}; "
      f"checksum before={ph_before} after={ph_after}")
bench["BM-06"] = {"row_count_delta": int(after) - int(before), "photo_checksum_changes": int(ph_before != ph_after)}
sql(f"select status, variants is not null from evidence_photos where id='{pid}'")

print("\n== 2. foreign-owned id -> client_id_conflict (field officer resends the farmer's client_id)")
with client(OFFICER) as o:
    r = show(o.post("/sync/push", json=env(e1))).json()["results"][0]
print(f"RESULT line2: status={r['status']} code={(r.get('error') or {}).get('code')}")

print("\n== 3. 51 entries -> 422")
r = show(f.post("/sync/push", json=env(*[harvest() for _ in range(51)])))
print(f"RESULT line3: HTTP {r.status_code} code={r.json()['error']['code']}")

print("\n== 4. mixed batch: #1,#3 accepted, #2 rejected (#2 names plot 2 on lot 1: not the lot's plot)")
bad = harvest(plot=W["plots"][1])
res = show(f.post("/sync/push", json=env(harvest(), bad, harvest()))).json()["results"]
print(f"RESULT line4: {[(x['status'], (x.get('error') or {}).get('code')) for x in res]}")
sql(f"select count(*) from event_versions where id='{bad['client_id']}'")

print("\n== 5. wrong checksum -> checksum_mismatch + flag (object written around the presigned URL)")
pid5 = str(uuid7())
e5 = harvest(photos=[{"client_id": pid5, "sha256": hashlib.sha256(b"promised").hexdigest(), "size_bytes": 8}])
show(f.post("/sync/push", json=env(e5)))
key = sql(f"select object_key from evidence_photos where id='{pid5}'")
s3 = boto3.client("s3", endpoint_url="http://localhost:4566", region_name="ap-south-1",
                  aws_access_key_id="test", aws_secret_access_key="test")
s3.put_object(Bucket="evidence", Key=key, Body=b"tampered", ChecksumAlgorithm="SHA256")
print(f"$ s3 put_object evidence/{key} (8 bytes 'tampered')")
show(f.post("/sync/photos/confirm", json={"photos": [{"client_id": pid5}]}))
st5 = wait_sql(f"select status from evidence_photos where id='{pid5}'", lambda r: r not in ("pending", "uploaded", ""))
fl5 = wait_sql(f"select rule_code||'|'||severity||'|'||status from flags where subject_id='{e5['data']['event_id']}' "
               f"or details::text like '%{pid5}%' order by 1", lambda r: "checksum" in r)
print(f"RESULT line5: photo status={st5}; flags={fl5!r}")

print("\n== 6. undo after 24 h -> 409 (own entry captured 25 h ago)")
e6 = harvest(device_time=datetime.now(UTC) - timedelta(hours=25))
show(f.post("/sync/push", json=env(e6)))
r = show(f.post(f"/events/{e6['data']['event_id']}/undo", json={"client_id": str(uuid7()), "version_no": 2}))
print(f"RESULT line6: HTTP {r.status_code} code={r.json().get('error', {}).get('code')}")

print("\n== 7. farmer correction -> 403")
e7 = harvest()
show(f.post("/sync/push", json=env(e7)))
data = {**e7["data"], "version_no": 2, "change_kind": "correct", "reason_code": "wrong_quantity",
        "payload": {"quantity": {"value": 185, "unit": "kg"}}}
r = show(f.post(f"/events/{e7['data']['event_id']}/versions", json={"client_id": str(uuid7()), "data": data}))
print(f"RESULT line7: HTTP {r.status_code} code={r.json().get('error', {}).get('code')}")

print("\n== 8. device clock +3 d -> stored + clock_skew flag (rules run by the real worker)")
e8 = harvest(device_time=datetime.now(UTC) + timedelta(days=3))
r = show(f.post("/sync/push", json=env(e8))).json()["results"][0]
sql(f"select device_time - server_received_at from event_versions where id='{e8['client_id']}'")
fl8 = wait_sql(f"select rule_code||'|'||severity||'|'||status from flags where subject_id in "
               f"('{e8['data']['event_id']}','{e8['client_id']}') order by 1", lambda r: "clock_skew" in r)
print(f"RESULT line8: push={r['status']} flags={fl8!r}")

f.close()
json.dump(bench, open(os.environ["QA_BENCH"], "w"))
print("\nbench:", bench)
