"""Verifier helpers for the B09/B15/B16/B10/B11/B12 live checks on the compose stack.

Purpose: reuse B06's sign-in helper (docs/agents/qa/B06/logs/live_common.py: dev OTP 123456, office PIN 2468) and
add psql reads, sync pushes and builders for the bodies these WPs need, so each live_*.py stays short. Every call
and every SQL read is printed: the log is the evidence. Callers: live_b09.py, ../../B15/logs/live_b15.py,
../../B16/logs/live_b16.py, ../../B10/logs/live_b10.py, ../../B11/logs/live_b11.py. Ids shared between scripts are
kept in $QA_WORLD (session scratchpad, never the repo).
"""

import json
import os
import subprocess
import sys
import uuid
from datetime import UTC, date, datetime, timedelta

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "B06", "logs"))
from live_common import ADMIN, OFFICER, QC, client, show  # noqa: E402,F401

from agritrace.core.ids import uuid7  # noqa: E402

QA_FARMER_PHONE = "+919000000091"  # B06 Verifier's QA farmer (active, plots QA-P1..3)
WORLD = os.environ["QA_WORLD"]


def section(title: str) -> None:
    """Print a section header."""
    print(f"\n## {title}")


def sql(q: str) -> str:
    """Run one SQL query on the compose DB (host port 5433) and return the unaligned output."""
    out = subprocess.run(["psql", "-h", "localhost", "-p", "5433", "-U", "agritrace", "agritrace", "-Atc", q],
                         env={**os.environ, "PGPASSWORD": "agritrace"}, capture_output=True, text=True, check=True)
    print(f"  sql> {q}\n  =>  {out.stdout.strip()!r}")
    return out.stdout.strip()


def load() -> dict:
    """Read the shared world ids."""
    try:
        return json.load(open(WORLD))
    except FileNotFoundError:
        return {}


def save(w: dict) -> None:
    """Write the shared world ids."""
    json.dump(w, open(WORLD, "w"), indent=1)


def push(h, *entries: dict, headers: dict | None = None, expect_http: int = 200) -> list[dict]:
    """POST /v1/sync/push and return the per-entry results (prints `status[:code]` per entry)."""
    body = {"device_id": str(uuid.uuid4()), "app_version": "1.0.3", "device_time": datetime.now(UTC).isoformat(),
            "entries": list(entries)}
    r = show(h.post("/sync/push", json=body, headers=headers or {}), 2500)
    assert r.status_code == expect_http, r.text
    if r.status_code != 200:
        return []
    res = r.json()["results"]
    print("  statuses:", [x["status"] + (":" + x["error"]["code"] if x["status"] == "rejected" else "") for x in res])
    return res


def statuses(res: list[dict]) -> list[str]:
    """Statuses with the error code appended for rejections."""
    return [x["status"] + (":" + x["error"]["code"] if x["status"] == "rejected" else "") for x in res]


def check(label: str, cond: bool) -> None:
    """Print a PASS/FAIL line for one assertion (the run continues so the log shows every line)."""
    print(f"  CHECK {'PASS' if cond else 'FAIL'}: {label}")


def moisture(instrument: str, value: str, stage: str = "drying_end", **subject: str) -> dict:
    """An instrument moisture reading body (`QualityReadingIn`)."""
    return {"client_id": str(uuid7()), "stage": stage, "parameter_code": "moisture",
            "measurement": {"value": value, "unit": "%"}, "source": "instrument", "instrument_id": instrument,
            "measured_at": datetime.now(UTC).isoformat(), **subject}


def event(lot: str, plot: dict, kind: str, on: str, payload: dict | None = None, **extra) -> dict:
    """An `event_version` entry (version 1) on a lot."""
    data = {"event_id": str(uuid7()), "version_no": 1, "subject_type": "lot", "lot_id": lot, "plot_id": plot["id"],
            "event_type": kind, "instance_no": 1, "occurred_on": on, "payload": payload or {},
            "clocks": {"device_time": datetime.now(UTC).isoformat()},
            "gps": {"lat": plot["lat"], "lon": plot["lon"], "accuracy_m": 6.2}}
    return {"client_id": str(uuid7()), "kind": "event_version", "data": data, **extra}


def new_plot(a, farmer: str, code: str, lat: float, lon: float, **extra) -> dict:
    """Create a 1-acre live-GPS plot through POST /v1/plots (FPO admin)."""
    p = show(a.post("/plots", json={"client_id": str(uuid7()), "farmer_id": farmer,
                                    "pin": {"lat": lat, "lon": lon, "accuracy_m": 5}, "pin_method": "live_gps",
                                    "device_time": datetime.now(UTC).isoformat(),
                                    "declared_area": {"value": "1", "unit": "acre"}, "code": code, **extra})).json()
    return {"id": p["id"], "lat": lat, "lon": lon}


def new_lot(a, plot: dict, crop: str, season: str) -> str:
    """Open a lot through POST /v1/lots and return its id."""
    r = show(a.post("/lots", json={"client_id": str(uuid7()), "plot_id": plot["id"], "crop_id": crop,
                                   "season_label": season}))
    assert r.status_code == 201, r.text
    return r.json()["id"]


def today() -> str:
    """Today's date, ISO."""
    return date.today().isoformat()


def days_ago(n: int) -> str:
    """A past date, ISO."""
    return (date.today() - timedelta(days=n)).isoformat()


def codes(r) -> list[str]:
    """Reason codes of a 409 `gate_not_met` answer (empty list otherwise)."""
    try:
        return [x["code"] for x in r.json()["error"]["details"]["reasons"]]
    except Exception:
        return []
