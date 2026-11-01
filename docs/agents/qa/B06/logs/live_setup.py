"""Verifier live setup: a QA farmer, three 1-acre plots and three lots in the seeded FPO (B06/B08 live checks).

Purpose: give the live sync and rules checks their own farmer so the seeded reference batch FGP8T4033HM7 is never
written to. Prints every call; writes the ids to $QA_WORLD (scratchpad). Caller: the Verifier, once.
"""

import json
import os
import sys
import uuid
from datetime import UTC, datetime

sys.path.insert(0, os.path.dirname(__file__))
from live_common import ADMIN, client, show  # noqa: E402

PHONE = "+919000000091"
WORLD = os.environ["QA_WORLD"]
# Inside the Virudhunagar GI region, ~3 km from the seeded plots; 3 plots ~2 km apart.
PINS = [(9.585, 78.105), (9.585, 78.125), (9.585, 78.145)]

with client(ADMIN) as a:
    crops = show(a.get("/crops")).json()
    crop = next(c for c in crops if c["code"] == "SAMBA_VATHAL")
    f = show(a.post("/farmers", json={"name": "QA Verifier Farmer", "phone": PHONE, "lang": "en",
                                         "client_id": str(uuid.uuid4())})).json()
    show(a.post(f"/farmers/{f['id']}/approve"))
    show(a.post("/consents", json={"client_id": str(uuid.uuid4()), "farmer_id": f["id"],
                                   "consent_type": "data_collection", "consent_version": "v1",
                                   "given_at": datetime.now(UTC).isoformat()}))
    plots, lots = [], []
    for i, (lat, lon) in enumerate(PINS):
        p = show(a.post("/plots", json={
            "client_id": str(uuid.uuid4()), "farmer_id": f["id"], "pin": {"lat": lat, "lon": lon, "accuracy_m": 5},
            "pin_method": "live_gps", "device_time": datetime.now(UTC).isoformat(),
            "declared_area": {"value": "1", "unit": "acre"}, "code": f"QA-P{i + 1}"})).json()
        lot = show(a.post("/lots", json={"client_id": str(uuid.uuid4()), "plot_id": p["id"], "crop_id": crop["id"],
                                         "season_label": "QA 2026"})).json()
        plots.append({"id": p["id"], "lat": lat, "lon": lon})
        lots.append(lot["id"])
json.dump({"farmer": f["id"], "phone": PHONE, "crop": crop["id"], "plots": plots, "lots": lots}, open(WORLD, "w"))
print("world:", json.load(open(WORLD)))
