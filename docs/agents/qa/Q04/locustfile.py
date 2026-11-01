"""BM-07 load profile: 50 users on POST /v1/sync/push and the batch read endpoints (Q04 Verifier evidence).

Purpose: measure p50/p95/p99 latency of the sync and batch endpoints on the compose stack (PLAN §8 BM-07,
§7.5 Q04). Not product code. Caller: the Q04 Verifier, via
`uv run --with locust locust -f docs/agents/qa/Q04/locustfile.py --headless -u 50 -r 5 -t 3m ...`.
Input: $Q04_TOKENS, a JSON file {phone: {"access_token": ...}} with fresh sessions (never committed).
Farmers push `problem` events on their own open lots: each push sends 1-3 new entries (fresh client ids), and
every second push replays the user's previous batch, which must come back `duplicate` (idempotent path).
Staff (field officer, QC officer) read the batch list, one batch, its builds and its grade.
"""

import datetime
import json
import os
import random
import time
import uuid

from locust import HttpUser, between, task

TOKENS = json.load(open(os.environ["Q04_TOKENS"]))
# Open lots of the two QA farmers with their plot pins (psql on the compose DB, 2026-11-02).
LOTS = {
    "+919000000091": [("45d6230a-20e8-4c1b-a578-c496127d802e", "4c50d79a-c871-4ded-8a27-17a65358c4cb", 9.585, 78.105),
                      ("f8004b84-2cf3-45f8-918d-343def8588e6", "72b065f5-3555-4486-82bf-ae7e862ac49a", 9.585, 78.125),
                      ("8d9f4a1e-0ccc-4b0f-90a0-c75caa0a683a", "852b5d9d-d80b-495d-89cc-e6787354c2dc", 9.585, 78.145)],
    "+919000000092": [("c147bc72-992e-46bb-bf79-5a866ece5c23", "d682f54a-db70-479a-ad36-42f81f8dc8a7", 9.575, 78.105),
                      ("befb2098-5cd5-4e95-a80a-8297b47faf81", "22487e81-a229-4e6e-ac49-58b3022bbf17", 9.575, 78.125),
                      ("dde6a35c-ab6d-40a2-956d-7e3b101e2451", "175e8fac-4c17-4b75-895c-c5bb60f17ca8", 9.575, 78.145)],
}
STAFF = ["+919000000002", "+919000000003"]


def uuid7() -> str:
    """Return a UUIDv7 string (ms timestamp prefix), the id form the app generates for client ids."""
    ms, rnd = int(time.time() * 1000), uuid.uuid4().int
    return str(uuid.UUID(int=(ms << 80) | (0x7 << 76) | ((rnd >> 64) & 0xFFF) << 64 | (0b10 << 62) | (rnd & (2**62 - 1))))


class FarmerSync(HttpUser):
    """A farmer phone draining its outbox: small pushes, new entries and replays."""

    weight = 3
    wait_time = between(0.5, 2)

    def on_start(self) -> None:
        """Pick a farmer and set the bearer token; no request is sent."""
        self.phone = random.choice(list(LOTS))
        self.client.headers["Authorization"] = "Bearer " + TOKENS[self.phone]["access_token"]
        self.device = str(uuid.uuid4())
        self.last = None

    def _push(self, body: dict, name: str, want: str) -> None:
        """POST /v1/sync/push; mark the request failed unless HTTP 200 and every entry has status `want`."""
        with self.client.post("/v1/sync/push", json=body, name=name, catch_response=True) as r:
            if r.status_code != 200:
                r.failure(f"HTTP {r.status_code}: {r.text[:200]}")
            elif any(x["status"] != want for x in r.json()["results"]):
                r.failure("statuses " + ",".join(x["status"] for x in r.json()["results"]))

    @task
    def push(self) -> None:
        """Send 1-3 fresh `problem` events, or replay the previous batch (expected `duplicate`)."""
        if self.last and random.random() < 0.5:
            self._push(self.last, "POST /v1/sync/push (replay)", "duplicate")
            self.last = None
            return
        now = datetime.datetime.now(datetime.UTC).isoformat()
        entries = []
        for _ in range(random.randint(1, 3)):
            lot, plot, lat, lon = random.choice(LOTS[self.phone])
            entries.append({"client_id": uuid7(), "kind": "event_version", "data": {
                "event_id": uuid7(), "version_no": 1, "subject_type": "lot", "lot_id": lot, "plot_id": plot,
                "event_type": "problem", "instance_no": 1, "occurred_on": datetime.date.today().isoformat(),
                "payload": {"problem_type": "pest", "description": "Q04 BM-07 load"},
                "clocks": {"device_time": now}, "gps": {"lat": lat, "lon": lon, "accuracy_m": 6}}})
        self.last = {"device_id": self.device, "app_version": "1.0.3", "device_time": now, "entries": entries}
        self._push(self.last, "POST /v1/sync/push (new)", "accepted")


class StaffBatches(HttpUser):
    """A field/QC officer browsing batches in the portal."""

    weight = 2
    wait_time = between(0.5, 2)

    def on_start(self) -> None:
        """Set a staff token and load batch ids from GET /v1/batches."""
        self.client.headers["Authorization"] = "Bearer " + TOKENS[random.choice(STAFF)]["access_token"]
        items = self.client.get("/v1/batches?limit=50", name="GET /v1/batches").json()["items"]
        self.ids = [b["id"] for b in items] or ["01a19822-94cf-7100-bedc-ecf49185f598"]

    @task(2)
    def list_batches(self) -> None:
        """GET /v1/batches (first page)."""
        self.client.get("/v1/batches?limit=20", name="GET /v1/batches")

    @task(2)
    def one_batch(self) -> None:
        """GET /v1/batches/{id}."""
        self.client.get(f"/v1/batches/{random.choice(self.ids)}", name="GET /v1/batches/{id}")

    @task(1)
    def builds(self) -> None:
        """GET /v1/batches/{id}/builds."""
        self.client.get(f"/v1/batches/{random.choice(self.ids)}/builds", name="GET /v1/batches/{id}/builds")

    @task(1)
    def grade(self) -> None:
        """GET /v1/batches/{id}/grade (404 for a batch without grading is not a failure)."""
        with self.client.get(f"/v1/batches/{random.choice(self.ids)}/grade", name="GET /v1/batches/{id}/grade",
                             catch_response=True) as r:
            if r.status_code in (200, 404):
                r.success()
