"""Verifier live check of the B11 acceptance lines and BM-05 inputs on the compose stack.

Purpose: compare the dashboard completeness with a direct SQL count, send 105 public scans in one minute window,
export the audit CSV of a batch holding an assisted event version and compare it row by row with event_versions,
call the partner and storage-monitoring stubs, and read the reference batch's completeness and flags by name for
BM-05. Writes BM-05 results to $QA_BENCH. Prints every call and SQL read. Caller: the Verifier, once.
"""

import csv
import io
import json
import os
import sys
import time
from datetime import UTC, datetime

import httpx

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "B09", "logs"))
from qa_live import (ADMIN, OFFICER, QC, check, client, days_ago, event, load, moisture, new_lot, push, save,  # noqa: E402
                     section, show, sql, statuses, today, uuid7)

W = load()
API = "http://localhost:8000/v1"
FPO = sql("select id from fpos where code='VIRUDHAI_SCFC_VINOBA_BHAVA_FPO'")
SEED_BATCH = "01900000-0000-7000-8000-0000000b12aa"
# Same test as reporting.service (D-037): every type in the crop's event_schema.mandatory has a live event.
COMPLETE = ("not exists (select 1 from jsonb_array_elements_text(c.event_schema->'mandatory') m(t) where not exists "
            "(select 1 from events e where e.lot_id=l.id and e.event_type=m.t and e.status not in ('undone','superseded')))")

with client(ADMIN) as a, client(OFFICER) as o, client(QC) as q:
    section("1 completeness = lots with all mandatory events / lots")
    d = show(a.get(f"/dashboard/fpo/{FPO}"), 3000).json()
    print("  dashboard completeness:", d["completeness"])
    num_den = sql(f"select count(*) filter (where {COMPLETE}), count(*) from lots l join crops c on c.id=l.crop_id "
                  f"where l.fpo_id='{FPO}'")
    n, den = map(int, num_den.split("|"))
    print(f"  SQL: {n} complete of {den} lots")
    comp = d["completeness"]
    vals = json.dumps(comp)
    check("dashboard numerator/denominator equal the SQL count", str(n) in vals and str(den) in vals)

    section("2 100 scans/min -> 429 (105 scans from one address in one minute window)")
    while datetime.now(UTC).second > 40:  # start early in a minute so 105 calls fit one window
        time.sleep(1)
    codes_seen = []
    with httpx.Client(timeout=30) as h:
        for i in range(105):
            r = h.post(f"{API}/public/scans", params={"batch_code": W["batch_x_code"]})
            codes_seen.append(r.status_code)
            if r.status_code == 429 and codes_seen.count(429) == 1:
                print(f"  first 429 at scan #{i + 1}: {r.text}")
    print("  status counts:", {c: codes_seen.count(c) for c in set(codes_seen)})
    first = codes_seen.index(429) + 1 if 429 in codes_seen else None
    check("scans 1-100 -> 204, scan 101 onward -> 429 rate_limited", codes_seen[:100] == [204] * 100 and first == 101
          and set(codes_seen[100:]) == {429})
    sql(f"select count(*) from scan_events where batch_code='{W['batch_x_code']}'")

    section("3 CSV row per version with entered_by, assist_session_id (batch Z: an assisted, a plain and a corrected event)")
    pm = W["plot_main"]
    z = new_lot(a, pm, W["crop"], "QA-B11 CSV")
    s3 = uuid7()
    push(o, {"client_id": str(s3), "kind": "assist_session",
             "data": {"farmer_id": W["farmer"], "started_at": datetime.now(UTC).isoformat(), "started_gps": None}})
    assisted = event(z, pm, "land_preparation", days_ago(100), assist_session_id=str(s3))
    plain = event(z, pm, "harvest", days_ago(20), {"quantity": {"value": 52, "unit": "kg"}, "bags": 2})
    res = push(o, assisted, plain)
    check("assisted + plain event accepted", statuses(res) == ["accepted", "accepted"])
    pv = plain["data"]
    corr = {**pv, "version_no": 2, "change_kind": "correct", "reason_code": "entered_by_mistake",
            "payload": {"quantity": {"value": 50, "unit": "kg"}, "bags": 2}}
    corr.pop("gps", None)
    show(o.post(f"/events/{pv['event_id']}/versions", json={"client_id": str(uuid7()), "data": corr}), 400)
    show(a.post("/quality-readings", json=moisture(W["instrument"], "10.0", lot_id=z)))
    push(q, {"client_id": str(uuid7()), "kind": "lot_intake",
             "data": {"lot_id": z, "sale_date": today(), "received": {"value": "50", "unit": "kg"}}})
    zb = show(a.post("/batches", json={"client_id": str(uuid7()), "processor_id": W["processor"],
                                       "gi_label_requested": False, "lot_ids": [z]}), 400).json()
    for bid, label in ((zb["id"], "Z"), (W["batch_x"], "X")):
        r = a.get(f"/batches/{bid}/audit-export.csv")
        print(f"$ GET /v1/batches/{bid}/audit-export.csv -> HTTP {r.status_code} {r.headers.get('content-type')} "
              f"{r.headers.get('content-disposition')}")
        print(r.text)
        rows = list(csv.DictReader(io.StringIO(r.text)))
        db = sql(f"select count(*) from event_versions v join events e on e.id=v.event_id join batch_shares s "
                 f"on s.lot_id=e.lot_id where s.batch_id='{bid}'")
        cols = rows[0].keys() if rows else []
        print(f"  batch {label}: {len(rows)} CSV rows, {db} event_versions; columns: {list(cols)}")
        ok = r.status_code == 200 and len(rows) == int(db) and "entered_by" in " ".join(cols) \
            and "assist_session_id" in cols
        if label == "Z":
            ass = [x for x in rows if x.get("assist_session_id")]
            ok = ok and len(ass) == 1 and ass[0]["assist_session_id"] == str(s3)
            print("  assisted row:", ass)
        check(f"batch {label}: one row per event version, entered_by and assist_session_id columns"
              + (" (S3 on the assisted row only)" if label == "Z" else ""), ok)
    W["batch_z"] = zb["id"]
    save(W)

    section("4 partner -> 501 (and the storage-monitoring stubs)")
    stub = {}
    for m, path in (("GET", f"/partner/batches/{W['batch_x_code']}"), ("POST", "/partner/benefits"),
                    ("POST", "/probes"), ("POST", "/probe-readings")):
        r = show(a.request(m, path, json={} if m == "POST" else None))
        stub[path] = r.text
        check(f"{m} {path} -> 501 not_implemented_pilot", r.status_code == 501
              and r.json()["error"]["code"] == "not_implemented_pilot")
    lint_dir = os.environ["QA_STUBS"]
    os.makedirs(lint_dir, exist_ok=True)
    json.dump(stub, open(os.path.join(lint_dir, "partner-stub-output.json"), "w"), indent=1)

    section("5 BM-05: completeness of the demo (reference) batch's lots and its flags by name")
    seed_lots = sql(f"select string_agg(lot_id::text, ',') from batch_shares where batch_id='{SEED_BATCH}'").split(",")
    inlist = ",".join(f"'{x}'" for x in seed_lots)
    n, den = map(int, sql(f"select count(*) filter (where {COMPLETE}), count(*) from lots l join crops c on "
                          f"c.id=l.crop_id where l.id in ({inlist})").split("|"))
    pct = round(100 * n / den, 2)
    flags = sql(f"select rule_code, count(*) from flags where status in ('open','escalated') and "
                f"(subject_id='{SEED_BATCH}' or subject_id in ({inlist})) group by rule_code order by rule_code")
    by = dict(ln.split("|") for ln in flags.splitlines())
    problems = sum(int(by.get(k, 0)) for k in ("quantity_mismatch", "practice_tag_contradiction", "ipm_without_pest_event"))
    print(f"  demo batch lots complete: {n}/{den} = {pct} %; flags by name: {by}; reference problems flagged: {problems}")
    check("BM-05: completeness 100 % and >= 9 reference problems flagged", pct == 100 and problems >= 9)
    bench = os.environ["QA_BENCH"]
    os.makedirs(bench, exist_ok=True)
    json.dump({"id": "BM-05", "metrics": {"demo_completeness_pct": pct, "reference_problems_flagged": problems},
               "flags_by_name": by, "commit": os.environ.get("QA_COMMIT"), "env": "compose stack, live DB",
               "recorded_at": datetime.now(UTC).isoformat()}, open(os.path.join(bench, "BM-05-B11.json"), "w"), indent=1)
