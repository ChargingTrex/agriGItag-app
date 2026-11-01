"""Verifier reproduction for B16 line 1's live miss: `quantity_mismatch` raised by the intake, then closed `rule_passed`.

Purpose: run the line-1 sequence (packing 200 kg pushed by the officer, drying-end 10.0 %, ready, QC push
[reading, lot_intake 230 kg]) three times with no pause, and twice with a 20 s pause between the packing push and
the QC push, then push one more event on each lot to show whether a later check re-raises the flag.
Prints the flag rows and the worker's task lines. Caller: the Verifier (issue B16-1).
"""

import os
import sys
import time

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "B09", "logs"))
from qa_live import (ADMIN, OFFICER, QC, client, days_ago, event, load, moisture, new_lot, push, section, show,  # noqa: E402
                     sql, statuses, today, uuid7)

W = load()
inst, crop, pm = W["instrument"], W["crop"], W["plot_main"]
runs = []
with client(QC) as q, client(ADMIN) as a, client(OFFICER) as o:
    for n, pause in enumerate((0, 0, 0, 20, 20), 1):
        section(f"run {n}: pause {pause} s between the packing push and the QC push")
        lot = new_lot(a, pm, crop, f"QA-B16 race {n}")
        push(o, event(lot, pm, "packing", days_ago(3), {"quantity": {"value": 200, "unit": "kg"}, "bags": 8}))
        time.sleep(pause)
        show(a.post("/quality-readings", json=moisture(inst, "10.0", lot_id=lot)))
        show(a.post(f"/lots/{lot}/ready"))
        r = moisture(inst, "10.5", stage="intake", lot_id=lot)
        rid = r.pop("client_id")
        push(q, {"client_id": rid, "kind": "quality_reading", "data": r},
             {"client_id": str(uuid7()), "kind": "lot_intake",
              "data": {"lot_id": lot, "sale_date": today(), "received": {"value": "230", "unit": "kg"},
                       "intake_moisture_reading_id": rid}})
        time.sleep(8)
        st = sql(f"select status||':'||coalesce(resolution_reason_code,'-')||' raised '||raised_at::time||' closed '"
                 f"||coalesce(resolved_at::time::text,'-') from flags where subject_id='{lot}' and rule_code='quantity_mismatch'")
        runs.append((n, pause, lot, st))
    section("a later check on each lot (one `problem` event pushed by the officer): is the flag re-raised?")
    for n, pause, lot, _ in runs:
        push(o, event(lot, pm, "problem", today(), {"problem_type": "pest", "description": "QA recheck"}))
    time.sleep(10)
    for n, pause, lot, st in runs:
        after = sql(f"select status from flags where subject_id='{lot}' and rule_code='quantity_mismatch'")
        print(f"  RESULT run {n} pause {pause:>2} s: after intake: {st} | after a later event check: {after}")
