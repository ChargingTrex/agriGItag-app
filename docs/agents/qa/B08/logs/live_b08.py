"""Verifier live check of the B08 acceptance lines on the compose stack (real API + Celery worker + PostGIS).

Purpose: (A) read the flags `make seed` left on the reference batch FGP8T4033HM7 through `GET /v1/flags` and psql;
(B) as the private QA farmer 2 (live_setup2.py, $QA_WORLD), push real entries so the worker runs the rules, and
resolve flags as officer and admin. Two more QA plots/lots with declared practice tags are created here. Rules run
asynchronously, so every check polls the DB. Caller: the Verifier.
"""

import json
import os
import subprocess
import sys
import time
import uuid
from datetime import UTC, datetime

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "../../B06/logs"))
from live_common import ADMIN, OFFICER, client, show  # noqa: E402

from agritrace.core.ids import uuid7  # noqa: E402

W = json.load(open(os.environ["QA_WORLD"]))
ORGANIC = "01a197e0-9a63-7d18-ba21-c78f64e0ebe7"  # seeded input "Organic Fertilizer Gold", organic_fertilizer


def sql(q: str, quiet: bool = False) -> str:
    """Run one SQL query on the compose DB; print it with its result unless quiet."""
    out = subprocess.run(["psql", "-h", "localhost", "-p", "5433", "-U", "agritrace", "agritrace", "-Atc", q],
                         env={**os.environ, "PGPASSWORD": "agritrace"}, capture_output=True, text=True, check=True)
    if not quiet:
        print(f"  sql> {q}\n  =>  {out.stdout.strip()!r}")
    return out.stdout.strip()


def wait(q: str, want, secs: int = 120) -> str:
    """Poll a query until want(result) holds or secs pass; print the final result."""
    t0 = time.time()
    while True:
        r = sql(q, quiet=True)
        if want(r) or time.time() - t0 > secs:
            print(f"  sql (after {time.time() - t0:.0f}s)> {q}\n  =>  {r!r}")
            return r
        time.sleep(3)


def entry(lot: str, plot: dict, etype: str, on: str, payload: dict | None = None, lat: float | None = None) -> dict:
    """A version-1 farm event on a QA lot, GPS on the plot pin unless lat is given."""
    return {"client_id": str(uuid7()), "kind": "event_version", "data": {
        "event_id": str(uuid7()), "version_no": 1, "subject_type": "lot", "lot_id": lot, "plot_id": plot["id"],
        "event_type": etype, "instance_no": 1, "occurred_on": on, "payload": payload or {},
        "clocks": {"device_time": datetime.now(UTC).isoformat()},
        "gps": {"lat": lat or plot["lat"], "lon": plot["lon"], "accuracy_m": 5.0}}}


def push(c, *entries) -> list:
    """Push entries from one device and print the statuses."""
    body = {"device_id": str(uuid.uuid4()), "app_version": "1.0.3", "device_time": datetime.now(UTC).isoformat(),
            "entries": list(entries)}
    res = show(c.post("/sync/push", json=body), body_limit=400).json()["results"]
    print(f"  push statuses: {[(x['status'], (x.get('error') or {}).get('code')) for x in res]}")
    return res


def flags_of(subject: str) -> str:
    """Query text for rule|severity|status of a subject's flags."""
    return f"select string_agg(rule_code||'|'||severity||'|'||status, ', ' order by rule_code) from flags where subject_id='{subject}'"


with client(ADMIN) as a, client(OFFICER) as o, client(W["phone"]) as f:
    print("== A. flags on the seeded reference batch FGP8T4033HM7 (left by `make seed`), via GET /v1/flags")
    lots = sql("select string_agg(l.id||':'||l.code, ',') from lots l join batch_shares bs on bs.lot_id=l.id "
               "join batches b on b.id=bs.batch_id where b.code='FGP8T4033HM7'").split(",")
    batch = sql("select id from batches where code='FGP8T4033HM7'")
    items, cur = [], None
    while True:
        page = a.get("/flags", params={"limit": 200, **({"cursor": cur} if cur else {})}).json()
        items += page["items"]
        cur = page.get("next_cursor")
        if not page.get("has_more"):
            break
    print(f"  GET /v1/flags (admin, all pages): {len(items)} flags in the FPO")
    for lid_code in lots:
        lid, code = lid_code.split(":")
        mine = sorted((i["rule_code"], i["severity"], i["status"]) for i in items if i["subject_id"] == lid)
        print(f"RESULT A lot {code}: {mine}")
    print(f"RESULT A batch: {sorted((i['rule_code'], i['severity'], i['status']) for i in items if i['subject_id'] == batch)}")
    sql("select l.code, e.event_type, ev.occurred_on from events e join event_versions ev on ev.id=e.current_version_id "
        "join lots l on l.id=e.lot_id where l.code='LOTD02DADB6' order by ev.occurred_on")
    sql("select count(*) from flags f join events e on e.id=f.subject_id join lots l on l.id=e.lot_id "
        "join batch_shares bs on bs.lot_id=l.id join batches b on b.id=bs.batch_id "
        "where b.code='FGP8T4033HM7' and f.rule_code='event_out_of_order'")
    sql("select code, gi_eligible, gi_hold_reason from lots where id in (select lot_id from batch_shares bs join "
        "batches b on b.id=bs.batch_id where b.code='FGP8T4033HM7') order by code")

    print("\n== B0. two more QA plots and lots with declared practice tags (inorganic + ipm)")
    extra = []
    for i, (lat, lon) in enumerate([(9.555, 78.105), (9.555, 78.125)]):
        p = show(a.post("/plots", json={"client_id": str(uuid.uuid4()), "farmer_id": W["farmer"],
                                        "pin": {"lat": lat, "lon": lon, "accuracy_m": 5}, "pin_method": "live_gps",
                                        "device_time": datetime.now(UTC).isoformat(),
                                        "declared_area": {"value": "1", "unit": "acre"}, "code": f"QA2-P{5 + i}"}),
                 body_limit=200).json()
        lot = show(a.post("/lots", json={"client_id": str(uuid.uuid4()), "plot_id": p["id"], "crop_id": W["crop"],
                                         "season_label": "QA 2026", "practice_tags_declared": ["inorganic", "ipm"]}),
                   body_limit=300).json()
        extra.append(({"id": p["id"], "lat": lat, "lon": lon}, lot["id"]))

    print("\n== 1. 600 m off plot -> event_off_plot warn; re-check -> no duplicate")
    plot4, lot4 = W["plots"][3], W["lots"][3]
    e1 = entry(lot4, plot4, "land_preparation", "2026-07-01", lat=plot4["lat"] + 0.0054)  # 0.0054 deg lat ~ 600 m
    push(f, e1)
    ev1 = e1["data"]["event_id"]
    wait(flags_of(ev1), lambda r: "event_off_plot" in r)
    sql(f"select details from flags where subject_id='{ev1}' and rule_code='event_off_plot'")
    out = subprocess.run(["docker", "exec", "agritrace-worker-1", "celery", "-A", "agritrace.worker", "call",
                          "rules.check_event", "--kwargs", json.dumps({"event_id": ev1})], capture_output=True, text=True)
    print(f"$ docker exec agritrace-worker-1 celery -A agritrace.worker call rules.check_event --kwargs '{{\"event_id\": \"{ev1}\"}}'\n  -> task id {out.stdout.strip()} {out.stderr.strip()}")
    time.sleep(15)
    n = sql(f"select count(*) from flags where subject_id='{ev1}' and rule_code='event_off_plot'")
    print(f"RESULT line1: flags {sql(flags_of(ev1), quiet=True)!r}; event_off_plot rows after re-check: {n}")

    print("\n== 2+3+4. lot A (declared inorganic+ipm): nursery 07-01 before ploughing 07-10, organic input only, no pest event")
    plotA, lotA = extra[0]
    nA = entry(lotA, plotA, "nursery", "2026-07-01")
    lA = entry(lotA, plotA, "land_preparation", "2026-07-10")
    iA = entry(lotA, plotA, "input_application", "2026-07-20", {"input_id": ORGANIC, "quantity": {"value": 25, "unit": "kg"}})
    push(f, nA, lA, iA)
    r = wait(flags_of(lotA), lambda r: "practice_tag_contradiction" in r and "ipm_without_pest_event" in r)
    print(f"RESULT line2/3 lot A flags: {r!r}")
    sql(f"select practice_tags from lots where id='{lotA}'")
    time.sleep(5)
    print(f"RESULT line4 nursery flags: {sql(flags_of(nA['data']['event_id']), quiet=True)!r}; "
          f"ploughing flags: {sql(flags_of(lA['data']['event_id']), quiet=True)!r} (expect no event_out_of_order)")

    print("\n== 5. lot B: ploughing 07-01, sowing 07-05, nursery 07-10 (sowing before nursery) -> flag on the sowing")
    plotB, lotB = extra[1]
    lB = entry(lotB, plotB, "land_preparation", "2026-07-01")
    sB = entry(lotB, plotB, "sowing", "2026-07-05")
    nB = entry(lotB, plotB, "nursery", "2026-07-10")
    push(f, lB, sB, nB)
    r = wait(flags_of(sB["data"]["event_id"]), lambda r: "event_out_of_order" in r)
    sql(f"select details from flags where subject_id='{sB['data']['event_id']}' and rule_code='event_out_of_order'")
    print(f"RESULT line5 sowing flags: {r!r}; ploughing: {sql(flags_of(lB['data']['event_id']), quiet=True)!r}; "
          f"nursery: {sql(flags_of(nB['data']['event_id']), quiet=True)!r}")

    print("\n== 6. 1,150 / 1,250 / 1,350 kg harvested on 1 acre -> none / warn / hold + gi_eligible=false")
    hs = []
    for kg, i in ((1150, 0), (1250, 1), (1350, 2)):
        h = entry(W["lots"][i], W["plots"][i], "harvest", "2026-10-20", {"quantity": {"value": kg, "unit": "kg"}})
        hs.append((kg, W["lots"][i], h))
    push(f, *[h for _, _, h in hs])
    for kg, lot, h in hs:
        want = (lambda r: True) if kg == 1150 else (lambda r: "yield_over_ceiling" in (r or ""))
        if kg == 1150:
            time.sleep(20)
        r = wait(flags_of(lot), want)
        g = sql(f"select gi_eligible||'|'||coalesce(gi_hold_reason,'') from lots where id='{lot}'", quiet=True)
        y = [x for x in (r or "").split(", ") if x.startswith("yield_over_ceiling")]
        print(f"RESULT line6 {kg} kg: yield_over_ceiling={y or 'none'}; lot gi_eligible|reason={g}")
    hold_lot = hs[2][1]
    hold = sql(f"select id from flags where subject_id='{hold_lot}' and rule_code='yield_over_ceiling'")
    warn_lot = hs[1][1]
    warn = sql(f"select id from flags where subject_id='{warn_lot}' and rule_code='yield_over_ceiling'")

    print("\n== 7. resolve without reason -> 422")
    r = show(a.post(f"/flags/{warn}/resolve", json={"resolution": "looks_fine"}))
    print(f"RESULT line7 (admin, warn flag, no reason_code): HTTP {r.status_code} {r.json().get('error', {}).get('code')}")
    r = show(o.post(f"/flags/{warn}/resolve", json={"resolution": "looks_fine"}))
    print(f"  same as field officer: HTTP {r.status_code} {r.json().get('error', {}).get('code')}")

    print("\n== 8. officer resolving hold -> 403 (then the admin resolves it: gi_eligible back to true)")
    r = show(o.post(f"/flags/{hold}/resolve", json={"resolution": "looks_fine", "reason_code": "land_record_checked"}))
    print(f"RESULT line8 officer on hold: HTTP {r.status_code} {r.json().get('error', {}).get('code')}")
    sql(f"select status from flags where id='{hold}'")
    r = show(a.post(f"/flags/{hold}/resolve", json={"resolution": "looks_fine", "reason_code": "land_record_checked"}))
    print(f"  admin on hold: HTTP {r.status_code} status={r.json().get('status')}")
    sql(f"select gi_eligible||'|'||coalesce(gi_hold_reason,'') from lots where id='{hold_lot}'")
