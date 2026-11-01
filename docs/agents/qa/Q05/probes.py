"""Targeted /v1/sync/push probes after B21: the Q04 5xx reproductions R1-R9 plus deep nesting (Q05 Verifier evidence).

Purpose: show that every input that gave a 500 in Q04 (docs/agents/qa/Q04/logs/05-sync-push-5xx-repro.txt) now gets
a 4xx or a per-entry `rejected`, that the clean entries around a bad one still land, and that `data` nested 5,000
lists deep (B21-r1 P2-1) does not raise. Not product code. Serves: PLAN §7.5 Q05 (re-verify Q04-1/Q04-2), issues
Q04-1, Q04-2. Caller: the Q05 Verifier, `python3 docs/agents/qa/Q05/probes.py <tokens.json>`; prints one line per probe
and exits 1 when any probe gets a 5xx or an unexpected status.
Side effects: writes `problem` events (description "Q05 probe ...") on QA lot 45d6230a of farmer +919000000091 and
up to 3 `sync_metrics` rows for the field officer's device on the shared stack.
"""

import datetime
import json
import sys
import time
import urllib.error
import urllib.request
import uuid

BASE = "http://localhost:8000"
FARMER, OFFICER = "+919000000091", "+919000000002"
LOT, PLOT, LAT, LON = "45d6230a-20e8-4c1b-a578-c496127d802e", "4c50d79a-c871-4ded-8a27-17a65358c4cb", 9.585, 78.105
INT32_OVER = 3_000_000_000


def uuid7() -> str:
    """Return a UUIDv7 string, the client-id form the app generates."""
    ms, rnd = int(time.time() * 1000), uuid.uuid4().int
    return str(uuid.UUID(int=(ms << 80) | (0x7 << 76) | ((rnd >> 64) & 0xFFF) << 64 | (0b10 << 62) | (rnd & (2**62 - 1))))


def push(token: str, raw: str) -> tuple[int, dict]:
    """POST a raw JSON body to /v1/sync/push.

    Args:
        token: bearer access token.
        raw: the request body, already serialised (deep nesting is built as text).

    Returns:
        (HTTP status, decoded body or {"raw": text} when it is not JSON).
    """
    req = urllib.request.Request(BASE + "/v1/sync/push", raw.encode(), {"Content-Type": "application/json",
                                                                        "Authorization": f"Bearer {token}"})
    try:
        with urllib.request.urlopen(req, timeout=60) as r:  # noqa: S310 - local dev stack only
            status, text = r.status, r.read().decode()
    except urllib.error.HTTPError as e:
        status, text = e.code, e.read().decode()
    try:
        return status, json.loads(text)
    except ValueError:
        return status, {"raw": text[:200]}


def event(desc: str, instance_no: int = 1, payload_extra: str = "") -> tuple[str, str]:
    """Build one farmer `problem` event entry as JSON text.

    Args:
        desc: payload description (may hold a NUL escape `\\u0000`).
        instance_no: the event's instance number (int32 overflow probe).
        payload_extra: extra raw JSON members for the payload (deep nesting probe), starting with a comma.

    Returns:
        (event id, entry JSON text).
    """
    eid, now = uuid7(), datetime.datetime.now(datetime.UTC).isoformat()
    data = ('{"event_id": "%s", "version_no": 1, "subject_type": "lot", "lot_id": "%s", "plot_id": "%s", '
            '"event_type": "problem", "instance_no": %d, "occurred_on": "%s", '
            '"payload": {"problem_type": "pest", "description": "%s"%s}, "clocks": {"device_time": "%s"}, '
            '"gps": {"lat": %s, "lon": %s, "accuracy_m": 6}}') % (
        eid, LOT, PLOT, instance_no, datetime.date.today().isoformat(), desc, payload_extra, now, LAT, LON)
    return eid, '{"client_id": "%s", "kind": "event_version", "data": %s}' % (uuid7(), data)


def envelope(entries: list[str], app_version: str = "1.0.3", metrics: str = "") -> str:
    """Wrap entry texts (and optional metrics JSON text) in a push body."""
    now = datetime.datetime.now(datetime.UTC).isoformat()
    m = f', "metrics": [{metrics}]' if metrics else ""
    return ('{"device_id": "%s", "app_version": "%s", "device_time": "%s", "entries": [%s]%s}'
            % (uuid.uuid4(), app_version, now, ", ".join(entries), m))


def metric(**over: object) -> str:
    """One sync_metrics row as JSON text; keyword arguments replace fields (raw JSON values)."""
    row = {"entry_client_id": f'"{uuid.uuid4()}"', "saved_at": '"2026-11-02T00:00:00Z"', "acked_at": '"2026-11-02T00:00:05Z"', "network_type": '"4g"',
           "failures": "0", "photo_upload_ms": "1200"} | {k: str(v) for k, v in over.items()}
    return "{" + ", ".join(f'"{k}": {v}' for k, v in row.items()) + "}"


def main() -> int:
    """Run the probes and print one verdict line each.

    Returns:
        0 when every probe got its expected status and no 5xx, else 1.
    """
    tokens = json.load(open(sys.argv[1]))
    farmer, officer = tokens[FARMER]["access_token"], tokens[OFFICER]["access_token"]
    deep_nul = ', "deep": ' + "[" * 5000 + '"x\\u0000"' + "]" * 5000
    deep_clean = ', "deep": ' + "[" * 5000 + '"x"' + "]" * 5000
    ok = True
    probes = []
    # (name, token, body, want HTTP, want per-entry statuses or None)
    probes.append(("R1 NUL in app_version + metrics", officer, envelope([], "1.0\\u0000", metric()), 422, None))
    probes.append(("R2 control: clean, no metrics", officer, envelope([]), 200, []))
    e3, t3 = event("Q05 probe R3 \\u0000 nul")
    probes.append(("R3 NUL in event payload (jsonb)", farmer, envelope([t3]), 200, ["rejected"]))
    probes.append(("R4 NUL in metrics network_type", officer, envelope([], metrics=metric(network_type='"4g\\u0000"')), 422, None))
    e5 = [event("Q05 probe R5 first (clean)"), event("Q05 probe R5 \\u0000"), event("Q05 probe R5 third (clean)")]
    probes.append(("R5 [clean, NUL, clean]", farmer, envelope([t for _, t in e5]), 200, ["accepted", "rejected", "accepted"]))
    probes.append(("R6 failures = 3e9", officer, envelope([], metrics=metric(failures=INT32_OVER)), 422, None))
    probes.append(("R7 photo_upload_ms = 3e9", officer, envelope([], metrics=metric(photo_upload_ms=INT32_OVER)), 422, None))
    probes.append(("R8 control failures = 2147483647", officer, envelope([], metrics=metric(failures=2147483647)), 200, []))
    e9 = [event("Q05 probe R9 first (clean)"), event("Q05 probe R9 overflow", INT32_OVER), event("Q05 probe R9 third (clean)")]
    probes.append(("R9 [clean, instance_no 3e9, clean]", farmer, envelope([t for _, t in e9]), 200, ["accepted", "rejected", "accepted"]))
    e10 = [event("Q05 probe D1 first (clean)"), event("Q05 probe D1 deep nul", payload_extra=deep_nul), event("Q05 probe D1 third (clean)")]
    probes.append(("D1 [clean, data 5000 lists deep + NUL, clean]", farmer, envelope([t for _, t in e10]), 200, ["accepted", "rejected", "accepted"]))
    e11 = [event("Q05 probe D2 deep clean", payload_extra=deep_clean), event("Q05 probe D2 after (clean)")]
    probes.append(("D2 [data 5000 lists deep no NUL, clean]", farmer, envelope([t for _, t in e11]), 200, None))
    for name, token, body, want_http, want_entries in probes:
        status, out = push(token, body)
        got = [r["status"] for r in out.get("results", [])] if status == 200 else None
        good = status < 500 and status == want_http and (want_entries is None or got == want_entries)
        if name.startswith("D2"):  # the deep entry may be accepted or rejected; it must not 500 and must not block the next
            good = good and got is not None and got[1] == "accepted"
        ok &= good
        detail = got if got is not None else out.get("error", {}).get("code", out)
        codes = [r.get("code") for r in out.get("results", []) if r.get("status") == "rejected"] if status == 200 else ""
        print(f"{'PASS' if good else 'FAIL'}  {name}: HTTP {status} {detail} {codes or ''}")
    ids = [e for e, _ in e5 + e9 + e10 + e11] + [e3]
    print("event ids (R5 x3, R9 x3, D1 x3, D2 x2, R3):", json.dumps(ids))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
