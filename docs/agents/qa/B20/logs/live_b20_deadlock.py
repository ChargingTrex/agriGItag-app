"""B20 live reproduction of QA issue B08-2: POST /v1/intakes vs the rules worker (deadlock detected?).

Purpose: run the B08-2 sequence 20 times with no pause: officer pushes harvest 220 kg + packing 200 kg on a new lot
(two `rules.check_event` tasks), then at once the admin posts a drying-end moisture reading, POST /lots/{id}/ready
and POST /v1/intakes (200 kg). Prints each intake status; the caller greps api/worker/db logs for
"deadlock detected". Caller: B20 Worker (docs/agents/reports/B20.md).
"""

import os
import sys
from collections import Counter

REPO = os.environ["AGRITRACE_REPO"]
sys.path.insert(0, os.path.join(REPO, "docs", "agents", "qa", "B09", "logs"))
from qa_live import ADMIN, OFFICER, client, days_ago, event, load, moisture, new_lot, push, section, show, today, uuid7  # noqa: E402

W = load()
inst, crop, pm, proc = W["instrument"], W["crop"], W["plot_main"], W["processor"]
RUNS = int(os.environ.get("RUNS", "20"))
seen = Counter()
with client(ADMIN) as a, client(OFFICER) as o:
    for n in range(1, RUNS + 1):
        section(f"run {n}: no pause")
        lot = new_lot(a, pm, crop, f"QA-B20 deadlock {n}")
        push(o, event(lot, pm, "harvest", days_ago(10), {"quantity": {"value": 220, "unit": "kg"}, "bags": 9}),
             event(lot, pm, "packing", days_ago(3), {"quantity": {"value": 200, "unit": "kg"}, "bags": 8}))
        show(a.post("/quality-readings", json=moisture(inst, "10.0", lot_id=lot)))
        show(a.post(f"/lots/{lot}/ready"))
        r = show(a.post("/intakes", json={"client_id": str(uuid7()), "lot_id": lot, "processor_id": proc,
                                          "sale_date": today(), "received": {"value": "200", "unit": "kg"}}))
        seen[r.status_code] += 1
        print(f"  RESULT run {n}: intake HTTP {r.status_code}")
print(f"\nSUMMARY intake statuses over {RUNS} runs: {dict(seen)}")
