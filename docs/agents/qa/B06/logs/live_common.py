"""Verifier helper for live calls against the compose stack (B06/B13/B14/B07/B08 verification).

Purpose: sign in with the dev OTP flow (OTP_DEV_CODE=123456, office roles add a PIN) and print every request and
response so the log is the evidence. Tokens are cached in the session scratchpad (never in the repo) because the API
allows one OTP per phone per 60 s and 10 per day. Callers: the live_*.py scripts next to this file.
"""

import json
import os
import sys
import time
import uuid

import httpx

API = "http://localhost:8000/v1"
CODE = "123456"
OFFICE_PIN = "2468"  # set on first office sign-in by this Verifier (pin_set was false for every seeded user)
CACHE = os.environ.get("QA_TOKEN_CACHE", "/tmp/qa-tokens.json")
REDACT = ("access_token", "refresh_token", "pin_token")


def _load() -> dict:
    """Return the token cache (phone -> {access_token, refresh_token, device_id, at})."""
    try:
        with open(CACHE) as f:
            return json.load(f)
    except FileNotFoundError:
        return {}


def _save(c: dict) -> None:
    """Write the token cache."""
    with open(CACHE, "w") as f:
        json.dump(c, f)


def show(r: httpx.Response, body_limit: int = 1500) -> httpx.Response:
    """Print request line, status and (redacted, truncated) body; return the response."""
    req = r.request
    print(f"$ {req.method} {req.url}")
    if req.content:
        print(f"  body: {req.content[:600].decode(errors='replace')}{' ...' if len(req.content) > 600 else ''}")
    print(f"-> HTTP {r.status_code}  etag={r.headers.get('etag')}")
    try:
        data = r.json()
        if isinstance(data, dict):
            data = {k: ("<redacted>" if k in REDACT else v) for k, v in data.items()}
        txt = json.dumps(data, default=str)
    except Exception:
        txt = r.text
    print("  " + txt[:body_limit] + (" ..." if len(txt) > body_limit else ""))
    return r


def session(phone: str) -> dict:
    """Return a valid session for a phone: cached, refreshed, or new via OTP (+PIN for office roles)."""
    c = _load()
    s = c.get(phone)
    if s and time.time() - s["at"] < 800:
        return s
    with httpx.Client(timeout=60) as h:
        if s:
            r = h.post(f"{API}/auth/refresh", json={"refresh_token": s["refresh_token"]})
            if r.status_code == 200:
                d = r.json()
                s.update(access_token=d["access_token"], refresh_token=d["refresh_token"], at=time.time())
                c[phone] = s
                _save(c)
                return s
        dev = s["device_id"] if s else str(uuid.uuid4())
        print(f"# sign-in {phone} on device {dev}")
        show(h.post(f"{API}/auth/otp/request", json={"phone": phone}))
        d = show(
            h.post(
                f"{API}/auth/otp/verify",
                json={"phone": phone, "code": CODE, "device_id": dev, "platform": "android"},
            )
        ).json()
        if d.get("kind") == "pin_required":
            d = show(
                h.post(
                    f"{API}/auth/pin/verify",
                    json={"pin": OFFICE_PIN},
                    headers={"Authorization": f"Bearer {d['pin_token']}"},
                )
            ).json()
        if "access_token" not in d:
            sys.exit(f"sign-in failed for {phone}: {d}")
        s = {"access_token": d["access_token"], "refresh_token": d["refresh_token"], "device_id": dev,
             "at": time.time()}
        c[phone] = s
        _save(c)
        return s


def client(phone: str) -> httpx.Client:
    """Return an httpx client authorised as the phone's user."""
    s = session(phone)
    return httpx.Client(base_url=API, timeout=120, headers={"Authorization": f"Bearer {s['access_token']}"})


ADMIN, OFFICER, QC = "+919000000001", "+919000000002", "+919000000003"
