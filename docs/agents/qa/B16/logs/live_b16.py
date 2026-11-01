"""Verifier live check of B16 (D-040 `lot_intake` push kind, D-041 non-GI holds, D-042 assist scope) on the stack.

Purpose: the G5 condition (rulings 2026-10-31b §1): the seeded QC officer +919000000003 pushes
[quality_reading R, lot_intake I] for a ready, packed QA lot through POST /v1/sync/push; then the processor
default, open-lot gate, roles, REST intake, GI-only holds in a non-GI batch and the assist-scope lines. All lots
are the B06 QA farmer's; the seeded batch is not touched. Prints every call and SQL read. Caller: the Verifier.
"""

import os
import sys
import time
from datetime import UTC, datetime

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "B09", "logs"))
from qa_live import (ADMIN, OFFICER, QA_FARMER_PHONE, QC, check, client, codes, days_ago, event, load, moisture,  # noqa: E402
                     new_lot, new_plot, push, save, section, show, sql, statuses, today, uuid7)

W = load()
inst, crop, proc, pm = W["instrument"], W["crop"], W["processor"], W["plot_main"]


def intake_e(lot: str, kg: str = "230", cid=None, **data) -> dict:
    """A `lot_intake` entry (no processor_id unless given)."""
    return {"client_id": str(cid or uuid7()), "kind": "lot_intake",
            "data": {"lot_id": lot, "sale_date": today(), "received": {"value": kg, "unit": "kg"}, **data}}


def reading_e(reading: dict, sid=None) -> dict:
    """Wrap a reading body as a `quality_reading` entry."""
    cid = reading.pop("client_id")
    return {"client_id": cid, "kind": "quality_reading", "data": reading, "assist_session_id": sid and str(sid)}


def wait_flags(lot: str, code: str) -> str:
    """Wait (max 60 s) for the worker's rules run to store an open flag of `code` on a subject; return the list."""
    for _ in range(30):
        got = sql(f"select string_agg(rule_code||':'||severity, ',' order by rule_code) from flags "
                  f"where subject_id='{lot}' and status='open'")
        if code in got:
            return got
        time.sleep(2)
    return got


with client(QC) as q, client(ADMIN) as a, client(OFFICER) as o, client(QA_FARMER_PHONE) as fm:
    qc_id = sql(f"select id from users where phone='{QC}'")
    section("1 G5: QC push [quality_reading R (intake 10.5 %), lot_intake I (230 kg)] on lot L ready_for_sale packed 200 kg")
    lot = new_lot(a, pm, crop, "QA-B16 L")
    push(o, event(lot, pm, "packing", days_ago(3), {"quantity": {"value": 200, "unit": "kg"}, "bags": 8}))
    show(a.post("/quality-readings", json=moisture(inst, "10.0", lot_id=lot)))
    show(a.post(f"/lots/{lot}/ready"))
    r_e = reading_e(moisture(inst, "10.5", stage="intake", lot_id=lot))
    i_e = intake_e(lot, intake_moisture_reading_id=r_e["client_id"])
    res = push(q, r_e, i_e)
    check("2 x accepted, intake server_id == I", statuses(res) == ["accepted", "accepted"]
          and res[1]["server_id"] == i_e["client_id"])
    row = sql(f"select id, processor_id, accepted_by_user_id, received_kg from lot_intakes where lot_id='{lot}'")
    check("one lot_intakes row: id I, processor P (the FPO's only own one), accepted_by = QC user, 230 kg",
          row == f"{i_e['client_id']}|{proc}|{qc_id}|230.000")
    check("lot L received", sql(f"select status from lots where id='{lot}'") == "received")
    got = wait_flags(lot, "quantity_mismatch")
    check("L's open flags include quantity_mismatch", "quantity_mismatch" in got)
    res = push(q, r_e, i_e)
    check("same push again -> 2 x duplicate", statuses(res) == ["duplicate", "duplicate"])
    check("still one intake row", sql(f"select count(*) from lot_intakes where lot_id='{lot}'") == "1")
    W["b16_lot_l"] = lot

    section("2 processor: explicit own -> accepted with it; another FPO's -> not_found (zero/two own: integration test)")
    lot2 = new_lot(a, pm, crop, "QA-B16 explicit processor")
    show(a.post("/quality-readings", json=moisture(inst, "10.0", lot_id=lot2)))
    res = push(q, intake_e(lot2, "50", processor_id=proc))
    check("explicit own processor -> accepted (open lot passes the gate at intake)", statuses(res) == ["accepted"])
    check("stored with that processor", sql(f"select processor_id from lot_intakes where lot_id='{lot2}'") == proc)
    lot3 = new_lot(a, pm, crop, "QA-B16 foreign processor")
    show(a.post("/quality-readings", json=moisture(inst, "10.0", lot_id=lot3)))
    res = push(q, intake_e(lot3, "50", processor_id=str(uuid7())))
    check("unknown/foreign processor -> rejected not_found", statuses(res) == ["rejected:not_found"])

    section("3 open lot: drying-end 10.9 -> accepted, received, ready_at set; 11.5 or none -> gate_not_met moisture_gate_failed")
    lo = new_lot(a, pm, crop, "QA-B16 open 10.9")
    show(a.post("/quality-readings", json=moisture(inst, "10.9", lot_id=lo)))
    res = push(q, intake_e(lo, "60"))
    check("10.9 % -> accepted", statuses(res) == ["accepted"])
    check("L received with ready_at", sql(f"select status, ready_at is not null from lots where id='{lo}'") == "received|t")
    W["b16_lot_open"], W["b16_intake_open"] = lo, res[0]["server_id"]
    for label, val in (("11.5 %", "11.5"), ("no reading", None)):
        lx = new_lot(a, pm, crop, f"QA-B16 open {label}")
        if val:
            show(a.post("/quality-readings", json=moisture(inst, val, lot_id=lx)))
        res = push(q, intake_e(lx, "60"))
        reasons = [x["code"] for x in ((res[0].get("error") or {}).get("details") or {}).get("reasons", [])]
        print("  reasons:", reasons)
        check(f"{label} -> rejected gate_not_met [moisture_gate_failed]; lot unchanged; no intake row",
              statuses(res) == ["rejected:gate_not_met"] and reasons == ["moisture_gate_failed"]
              and sql(f"select status, ready_at is null from lots where id='{lx}'") == "open|t"
              and sql(f"select count(*) from lot_intakes where lot_id='{lx}'") == "0")

    section("4 roles: farmer / field officer token -> forbidden; correction by QC -> forbidden, by FPO admin -> accepted")
    lr = new_lot(a, pm, crop, "QA-B16 roles")
    show(a.post("/quality-readings", json=moisture(inst, "10.0", lot_id=lr)))
    for who, h in (("farmer", fm), ("field officer", o)):
        res = push(h, intake_e(lr, "40"))
        check(f"lot_intake by {who} -> rejected forbidden", statuses(res) == ["rejected:forbidden"])
    print("  (no viewer user exists in the seeded FPO; the viewer case is tests/unit/test_b16_logic.py::test_intake_refused_for_other_roles)")
    fix = {"supersedes_intake_id": W["b16_intake_open"], "correction_reason": "scale misread"}
    res = push(q, intake_e(lo, "58", **fix))
    check("correction by QC officer -> rejected forbidden", statuses(res) == ["rejected:forbidden"])
    res = push(a, intake_e(lo, "58", **fix))
    check("correction by FPO admin -> accepted", statuses(res) == ["accepted"])
    print("  ", sql(f"select received_kg, supersedes_intake_id from lot_intakes where lot_id='{lo}' order by created_at"))

    section("5 POST /v1/intakes by a QC officer -> 201; by a field officer -> 403")
    body = {"client_id": str(uuid7()), "lot_id": lr, "sale_date": today(), "received": {"value": "40", "unit": "kg"}}
    r = show(o.post("/intakes", json=body))
    check("field officer -> 403 forbidden", r.status_code == 403)
    r = show(q.post("/intakes", json=body), 600)
    check("QC officer -> 201 (processor defaulted)", r.status_code == 201 and r.json()["processor_id"] == proc)

    section("6 non-GI batch over GI-only holds (plot_outside_gi_region + yield_over_ceiling) -> gates pass, publish 202")
    p_out = new_plot(a, W["farmer"], "QA-P8-OUT", 9.9252, 78.1198)  # Madurai: outside the GI region
    print("  ", sql(f"select location_status from plots where id='{p_out['id']}'"))
    k = new_lot(a, p_out, crop, "QA-B16 outside region")
    hy = new_lot(a, W["plot_yield"], crop, "QA-B16 yield hold")
    push(o, event(hy, W["plot_yield"], "harvest", days_ago(10), {"quantity": {"value": 2000, "unit": "kg"}, "bags": 80}))
    for lx in (k, hy):
        show(a.post("/quality-readings", json=moisture(inst, "10.0", lot_id=lx)))
        push(q, intake_e(lx, "50"))
    plot_hold = wait_flags(p_out["id"], "plot_outside_gi_region")
    yield_hold = wait_flags(hy, "yield_over_ceiling")
    check("open holds: plot_outside_gi_region on the plot, yield_over_ceiling on the lot",
          "plot_outside_gi_region:hold" in plot_hold and "yield_over_ceiling:hold" in yield_hold)
    nb = show(a.post("/batches", json={"client_id": str(uuid7()), "processor_id": proc, "gi_label_requested": False,
                                       "lot_ids": [k, hy]}), 3000).json()
    show(a.post(f"/batches/{nb['id']}/grading", json={"declared_grade": "Standard", "readings": [
        moisture(inst, "10.5", stage="grading", batch_id=nb["id"])]}), 600)
    r1 = show(a.post(f"/batches/{nb['id']}/grading/approve", json={"graded": {"value": 95, "unit": "kg"}}), 1500)
    r2 = show(a.post(f"/batches/{nb['id']}/final-packing", json={"packed": {"value": 95, "unit": "kg"},
                                                                 "pack_date": today(), "best_before_date": days_ago(-365)}), 1500)
    r3 = show(a.post(f"/batches/{nb['id']}/publish"))
    check("approve 200, final packing 200, publish 202", (r1.status_code, r2.status_code, r3.status_code) == (200, 200, 202))
    print("  ", sql(f"select build_no, status from page_builds where batch_id='{nb['id']}'"))
    g = show(a.get(f"/batches/{nb['id']}"), 600).json()
    check("gi_verified=false, gi_block_reasons=[]", g["gi_verified"] is False and g["gi_block_reasons"] == [])
    br = sql(f"select stage, blocked_reasons::text from batch_approvals where batch_id='{nb['id']}' order by created_at")
    check("each new batch_approvals.blocked_reasons lists both codes",
          all("plot_outside_gi_region" in ln and "yield_over_ceiling" in ln for ln in br.splitlines()[1:]))
    check("both flags still open", "plot_outside_gi_region" in wait_flags(p_out["id"], "plot_outside_gi_region")
          and "yield_over_ceiling" in wait_flags(hy, "yield_over_ceiling"))
    W["b16_nongi_batch"] = nb["id"]

    section("7 GI-requested batch with a GI-only hold -> publish 409 with open_hold_flag, gi_verified=false with reasons")
    r = show(a.post(f"/batches/{W['batch_gi']}/publish"), 2500)
    hold = [x for x in r.json()["error"]["details"]["reasons"] if x["code"] == "open_hold_flag"]
    check("409 with an open_hold_flag reason naming yield_over_ceiling (batch of lot F from the B09 run)",
          r.status_code == 409 and any(x["rule_code"] == "yield_over_ceiling" for x in hold))
    g = show(a.get(f"/batches/{W['batch_gi']}"), 300).json()
    check("gi_verified=false with reasons", g["gi_verified"] is False and len(g["gi_block_reasons"]) > 0)

    section("8 assist scope: session S2 for the QA farmer; reading on their lot ok, on another farmer's lot / batch -> forbidden")
    s2 = uuid7()
    res = push(o, {"client_id": str(s2), "kind": "assist_session",
                   "data": {"farmer_id": W["farmer"], "started_at": datetime.now(UTC).isoformat(), "started_gps": None}})
    check("assist_session S2 accepted", statuses(res) == ["accepted"])
    la = new_lot(a, pm, crop, "QA-B16 assisted reading")
    e = reading_e(moisture(inst, "10.2", lot_id=la), s2)
    res = push(o, e)
    check("drying-end reading on the QA farmer's lot with S2 -> accepted", statuses(res) == ["accepted"])
    off = sql(f"select id from users where phone='{OFFICER}'")
    check("its audit_log row carries S2 and the QA farmer",
          sql(f"select actor_user_id, assist_session_id, on_behalf_of_farmer_id from audit_log where "
              f"entity_type='quality_readings' and entity_id='{e['client_id']}'") == f"{off}|{s2}|{W['farmer']}")
    other_lot = new_lot(a, {"id": W["b15_plot"]}, crop, "QA-B16 other farmer")
    res = push(o, reading_e(moisture(inst, "10.2", lot_id=other_lot), s2))
    check("same on the B15 farmer F's lot -> rejected forbidden", statuses(res) == ["rejected:forbidden"])
    res = push(o, reading_e(moisture(inst, "10.5", stage="storage", batch_id=W["batch_y"]), s2))
    check("batch quality_reading with S2 -> rejected forbidden", statuses(res) == ["rejected:forbidden"])
    be = {"client_id": str(uuid7()), "kind": "event_version", "assist_session_id": str(s2),
          "data": {"event_id": str(uuid7()), "version_no": 1, "subject_type": "batch", "batch_id": W["batch_y"],
                   "event_type": "grading", "instance_no": 1, "occurred_on": today(), "payload": {},
                   "clocks": {"device_time": datetime.now(UTC).isoformat()}}}
    res = push(o, be)
    check("batch event_version with S2 -> rejected forbidden", statuses(res) == ["rejected:forbidden"])

    section("9 flag_resolution with S2 and with an unknown session -> accepted, audit row without assist fields")
    flags = sql(f"select id from flags where subject_id in ('{W['lot_b']}','{lot}') and rule_code='quantity_mismatch' "
                f"and status='open' order by subject_id").splitlines()
    for fid, sid in zip(flags[:2], (s2, uuid7()), strict=False):
        res = push(o, {"client_id": str(uuid7()), "kind": "flag_resolution", "assist_session_id": str(sid),
                       "data": {"flag_id": fid, "resolution": "looks_fine", "reason_code": "field_visit",
                                "note": "QA verifier B16 line 10"}})
        check(f"flag_resolution with session {'S2' if sid == s2 else 'unknown'} -> accepted",
              statuses(res) == ["accepted"])
        check("its audit_log row has no on_behalf_of_farmer_id / assist_session_id",
              sql(f"select count(*) filter (where on_behalf_of_farmer_id is not null or assist_session_id is not null), "
                  f"count(*) from audit_log where entity_id='{fid}'").split("|")[0] == "0")
    save(W)
