"""Verifier live check of B09 sections 6 and 7, rerun after a Verifier scripting error in live_b09.py.

Purpose: part 1 sent the grading readings without `batch_id` (422 `set exactly one of lot_id and batch_id`), so
grading, approval, packing and publish never ran. This part reruns sections 6 and 7 on the same batches Y and X,
with `batch_id` set as tests/integration/test_lots_batches.py does. Caller: the Verifier, once.
"""

import os
import sys
from datetime import UTC, datetime

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from qa_live import ADMIN, check, client, codes, days_ago, load, moisture, save, section, show, sql, today  # noqa: E402

W = load()
inst = W["instrument"]
with client(ADMIN) as a:
    section("6 approve on declared_above_computed -> 409 (batch Y from part 1, one 100 kg lot)")
    y = {"id": W["batch_y"]}
    r = show(a.post(f"/batches/{y['id']}/grading", json={"declared_grade": "Special", "readings": [
        moisture(inst, "10.5", stage="grading", batch_id=y["id"])]}), 1500)
    print("  computed:", r.json().get("computed_grade"))
    r = show(a.post(f"/batches/{y['id']}/grading/approve", json={"graded": {"value": 90, "unit": "kg"}}))
    check("approve -> 409 [declared_above_computed]", r.status_code == 409 and codes(r) == ["declared_above_computed"])
    W["batch_y"] = y["id"]

    section("7 publish before approval -> 409 listing reasons; pack 25 on 20 graded -> 409; after gates -> 202 + page_builds")
    xb = W["batch_x"]
    r = show(a.post(f"/batches/{xb}/grading", json={"declared_grade": "Standard", "readings": [
        moisture(inst, "10.5", stage="grading", batch_id=xb)]}), 1500)
    check("grading Standard on 10.5 % -> 201", r.status_code == 201)
    r = show(a.post(f"/batches/{xb}/publish"))
    check("publish before approval -> 409 [grading_not_approved, final_packing_missing]",
          r.status_code == 409 and codes(r) == ["grading_not_approved", "final_packing_missing"])
    r = show(a.post(f"/batches/{xb}/grading/approve", json={"graded": {"value": 20, "unit": "kg"}}), 2500)
    check("approve 20 kg -> 200 graded, computed Standard",
          r.status_code == 200 and r.json()["status"] == "graded" and r.json()["computed_grade"] == "Standard")
    pack = {"packed": {"value": 25, "unit": "kg"}, "pack_date": today(), "best_before_date": days_ago(-365)}
    r = show(a.post(f"/batches/{xb}/final-packing", json=pack))
    check("pack 25 on 20 graded -> 409 [packed_above_graded]", r.status_code == 409 and codes(r) == ["packed_above_graded"])
    pack["packed"] = {"value": 20, "unit": "kg"}
    r = show(a.post(f"/batches/{xb}/final-packing", json=pack), 600)
    check("pack 20 -> 200 packed", r.status_code == 200 and r.json()["status"] == "packed")
    r = show(a.post(f"/batches/{xb}/publish"))
    check("publish -> 202 build_no 1 queued", r.status_code == 202 and r.json()["build_no"] == 1
          and r.json()["status"] == "queued")
    W["published_at"] = datetime.now(UTC).isoformat()
    sql(f"select build_no, generation, trigger, status from page_builds where batch_id='{xb}'")
    r = show(a.post(f"/batches/{xb}/publish"))
    check("second publish -> 409 [already_published]", codes(r) == ["already_published"])
    save(W)

print('\nworld:', W)
