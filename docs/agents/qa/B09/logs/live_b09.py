"""Verifier live check of the B09 acceptance lines on the compose stack (plus the setup B10/B11 reuse).

Purpose: read the seeded reference batch's shares, then drive the ready gate, intake reconciliation, batch shares,
GI eligibility, grading approval, final packing and publish gates through the real API on fresh QA lots of the B06
QA farmer (the seeded batch FGP8T4033HM7 is only read). Prints every call; writes ids to $QA_WORLD.
Caller: the Verifier, once (`cd apps/api && QA_WORLD=... QA_TOKEN_CACHE=... uv run python <this file>`).
"""

import os
import sys
from datetime import UTC, datetime

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from qa_live import (ADMIN, OFFICER, QA_FARMER_PHONE, check, client, codes, days_ago, event, load, moisture,  # noqa: E402
                     new_lot, new_plot, push, save, section, show, sql, today, uuid7)

W = load()
with client(ADMIN) as a, client(OFFICER) as o:
    section("0 setup: ids, a calibrated moisture meter, QA plots")
    me = show(a.get("/me")).json()
    crop = next(c for c in show(a.get("/crops")).json() if c["code"] == "SAMBA_VATHAL")["id"]
    procs = show(a.get("/processors")).json()
    own = [p for p in procs if p.get("fpo_id")]
    proc = own[0]["id"]
    farmer = sql(f"select f.id from farmers f join users u on u.id=f.user_id where u.phone='{QA_FARMER_PHONE}'")
    inst = show(a.post("/instruments", json={"kind": "moisture_meter", "make_model": "QA Verifier meter B09",
                                             "serial_no": f"QA-B09-{uuid7().hex[:6]}", "calibrated_on": days_ago(30),
                                             "calibration_due_on": days_ago(-300)})).json()["id"]
    W.update(crop=crop, processor=proc, farmer=farmer, instrument=inst)
    p_main = new_plot(a, farmer, "QA-P5", 9.586, 78.112, land_record_ref="QA-SURVEY-77/3B")
    p_yield = new_plot(a, farmer, "QA-P4", 9.586, 78.132)
    W.update(plot_main=p_main, plot_yield=p_yield)
    save(W)

    section("1 seeded reference batch FGP8T4033HM7: shares 31.250 / 62.500 / 6.250")
    seed = next(b for b in show(a.get("/batches", params={"limit": 50})).json()["items"] if b["code"] == "FGP8T4033HM7")
    full = show(a.get(f"/batches/{seed['id']}"), 4000).json()
    got = sorted((s["share_pct"], s["contributed"]["value"], s["contributed"]["unit"]) for s in full["shares"])
    print("  shares:", got)
    check("seeded shares are 31.250 / 62.500 / 6.250 of 100 / 200 / 20 kg",
          sorted(float(s[0]) for s in got) == [6.25, 31.25, 62.5])
    replay = show(a.post("/batches", json={"client_id": seed["id"], "processor_id": seed["processor_id"],
                                           "gi_label_requested": True,
                                           "lot_ids": [s["lot_id"] for s in full["shares"]]}), 600)
    check("replaying the seed's batch client_id answers 200 with the same shares (D-005, no new row)",
          replay.status_code == 200 and sorted(s["share_pct"] for s in replay.json()["shares"]) ==
          sorted(s[0] for s in got))
    sql(f"select count(*) from batch_shares where batch_id='{seed['id']}'")

    section("2 ready at 11.5 -> 409, at 10.9 -> ready")
    lot_a = new_lot(a, p_main, crop, "QA-B09 ready gate")
    show(a.post("/quality-readings", json=moisture(inst, "11.5", lot_id=lot_a)))
    r = show(a.post(f"/lots/{lot_a}/ready"))
    check("11.5 % -> 409 gate_not_met [moisture_gate_failed]", r.status_code == 409 and codes(r) == ["moisture_gate_failed"])
    show(a.post("/quality-readings", json=moisture(inst, "10.9", lot_id=lot_a)))
    r = show(a.post(f"/lots/{lot_a}/ready"))
    check("10.9 % -> 200 ready_for_sale with ready_at", r.status_code == 200 and r.json()["status"] == "ready_for_sale"
          and r.json()["ready_at"] is not None)

    section("3 intake 100 vs packed 69 -> quantity_mismatch")
    lot_b = new_lot(a, p_main, crop, "QA-B09 packed 69")
    push(o, event(lot_b, p_main, "packing", days_ago(5), {"quantity": {"value": 69, "unit": "kg"}, "bags": 2}))
    show(a.post("/quality-readings", json=moisture(inst, "10.0", lot_id=lot_b)))
    show(a.post(f"/lots/{lot_b}/ready"))
    r = show(a.post("/intakes", json={"client_id": str(uuid7()), "lot_id": lot_b, "processor_id": proc,
                                      "sale_date": today(), "received": {"value": "100", "unit": "kg"}}), 3000)
    body = r.json()
    check("201, reconciliation.in_order false, flags include quantity_mismatch, lot received",
          r.status_code == 201 and body["reconciliation"]["in_order"] is False
          and "quantity_mismatch" in {f["rule_code"] for f in body["flags"]})
    check("lot status received", show(a.get(f"/lots/{lot_b}")).json()["status"] == "received")
    W["lot_b"] = lot_b

    section("4 lots {100,200,20} -> 31.250/62.500/6.250 (batch X, also B10/B11's published batch)")
    lots_x = []
    for kg, label in (("100", "C"), ("200", "D"), ("20", "E")):
        lot = new_lot(a, p_main, crop, f"QA-B09 X-{label}")
        lots_x.append(lot)
    c = lots_x[0]
    # Events on lot C, pushed out of date order, for B10 "events ascending" and B11 CSV rows.
    res = push(o, event(c, p_main, "packing", days_ago(40), {"quantity": {"value": 100, "unit": "kg"}, "bags": 4}),
               event(c, p_main, "land_preparation", days_ago(200)),
               event(c, p_main, "harvest", days_ago(60), {"quantity": {"value": 110, "unit": "kg"}, "bags": 5}),
               event(c, p_main, "sowing", days_ago(150)),
               event(c, p_main, "drying", days_ago(50)))
    W["events_c"] = [x["server_id"] for x in res]
    for lot, kg in zip(lots_x, ("100", "200", "20"), strict=True):
        show(a.post("/quality-readings", json=moisture(inst, "10.0", lot_id=lot)))
        show(a.post(f"/lots/{lot}/ready"))
        show(a.post("/intakes", json={"client_id": str(uuid7()), "lot_id": lot, "processor_id": proc,
                                      "sale_date": today(), "received": {"value": kg, "unit": "kg"}}), 400)
    r = show(a.post("/batches", json={"client_id": str(uuid7()), "processor_id": proc, "gi_label_requested": False,
                                      "lot_ids": lots_x}), 4000)
    x = r.json()
    pct = {s["lot_id"]: s["share_pct"] for s in x["shares"]}
    print("  shares by lot (100, 200, 20 kg):", [pct[i] for i in lots_x])
    check("201, shares 31.250 / 62.500 / 6.250, total 320 kg",
          r.status_code == 201 and [float(pct[i]) for i in lots_x] == [31.25, 62.5, 6.25]
          and float(x["total_received"]["value"]) == 320 and x["total_received"]["unit"] == "kg")
    sql(f"select l.code, s.kg_contributed, s.share_pct from batch_shares s join lots l on l.id=s.lot_id "
        f"where s.batch_id='{x['id']}' order by s.kg_contributed")
    W.update(batch_x=x["id"], batch_x_code=x["code"], lots_x=lots_x)
    save(W)

    section("6 approve on declared_above_computed -> 409 (batch Y, one 100 kg lot)")
    lot_g = new_lot(a, p_main, crop, "QA-B09 Y")
    show(a.post("/quality-readings", json=moisture(inst, "10.0", lot_id=lot_g)))
    show(a.post(f"/lots/{lot_g}/ready"))
    show(a.post("/intakes", json={"client_id": str(uuid7()), "lot_id": lot_g, "processor_id": proc,
                                  "sale_date": today(), "received": {"value": "100", "unit": "kg"}}), 400)
    y = show(a.post("/batches", json={"client_id": str(uuid7()), "processor_id": proc, "gi_label_requested": False,
                                      "lot_ids": [lot_g]}), 600).json()
    r = show(a.post(f"/batches/{y['id']}/grading", json={"declared_grade": "Special", "readings": [
        moisture(inst, "10.5", stage="grading")]}), 1500)
    print("  computed:", r.json().get("computed_grade"))
    r = show(a.post(f"/batches/{y['id']}/grading/approve", json={"graded": {"value": 90, "unit": "kg"}}))
    check("approve -> 409 [declared_above_computed]", r.status_code == 409 and codes(r) == ["declared_above_computed"])
    W["batch_y"] = y["id"]

    section("7 publish before approval -> 409 listing reasons; pack 25 on 20 graded -> 409; after gates -> 202 + page_builds")
    xb = W["batch_x"]
    r = show(a.post(f"/batches/{xb}/grading", json={"declared_grade": "Standard", "readings": [
        moisture(inst, "10.5", stage="grading")]}), 1500)
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

    section("5 ineligible lot + GI requested -> gi_verified=false with reasons (lot F, 2,000 kg on 1 acre)")
    lot_f = new_lot(a, p_yield, crop, "QA-B09 yield hold")
    push(o, event(lot_f, p_yield, "harvest", days_ago(20), {"quantity": {"value": 2000, "unit": "kg"}, "bags": 80}))
    show(a.post("/quality-readings", json=moisture(inst, "10.0", lot_id=lot_f)))
    show(a.post(f"/lots/{lot_f}/ready"))
    r = show(a.post("/intakes", json={"client_id": str(uuid7()), "lot_id": lot_f, "processor_id": proc,
                                      "sale_date": today(), "received": {"value": "50", "unit": "kg"}}), 3000)
    print("  intake flags:", [(f["rule_code"], f["severity"]) for f in r.json().get("flags", [])])
    r = show(a.post("/batches", json={"client_id": str(uuid7()), "processor_id": proc, "gi_label_requested": True,
                                      "lot_ids": [lot_f]}), 3000)
    b = r.json()
    print("  gi_verified:", b.get("gi_verified"), "gi_block_reasons:", b.get("gi_block_reasons"))
    reasons = {(x["lot_id"], x["reason"], x["detail"]) for x in b.get("gi_block_reasons", [])}
    check("201 gi_verified=false; reasons include lot_on_hold for lot F and hold_flag yield_over_ceiling",
          r.status_code == 201 and b["gi_verified"] is False and any(t[:2] == (lot_f, "lot_on_hold") for t in reasons)
          and (None, "hold_flag", "yield_over_ceiling") in reasons)
    W.update(lot_f=lot_f, batch_gi=b["id"])
    save(W)
print("\nworld:", W)
