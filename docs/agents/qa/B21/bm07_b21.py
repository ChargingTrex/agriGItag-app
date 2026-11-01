"""BM-07 load profile of Q04, unchanged, pointed at the lots of another stack (B21 evidence).

Purpose: rerun `docs/agents/qa/Q04/locustfile.py` (30 farmer sync + 20 staff batch-read users) on the B21
isolated compose project, whose seeded lot ids differ from the shared stack's. Not product code.
Serves: PLAN §8 BM-07, B21 item 3. Caller: the B21 Worker,
`Q04_TOKENS=<tokens.json> B21_LOTS=<lots.json> uvx --from locust==2.47.0 locust -f docs/agents/qa/B21/bm07_b21.py ...`.
Input: $B21_LOTS, a JSON file {farmer phone: [[lot_id, plot_id, lat, lon], ...]} (psql on that stack's DB).
"""

import json
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "Q04"))
import locustfile as q04  # noqa: E402

q04.LOTS.clear()
q04.LOTS.update({phone: [tuple(lot) for lot in lots] for phone, lots in json.load(open(os.environ["B21_LOTS"])).items()})
FarmerSync, StaffBatches = q04.FarmerSync, q04.StaffBatches
