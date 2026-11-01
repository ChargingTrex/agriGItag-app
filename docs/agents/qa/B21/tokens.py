"""Sign in the BM-07 load-test phones with the dev OTP and write their tokens for the locustfile (B21 evidence).

Purpose: produce the $Q04_TOKENS file `docs/agents/qa/Q04/locustfile.py` reads ({phone: {access_token,
refresh_token}}). Not product code. Serves: PLAN §8 BM-07, B21 item 3. Caller: the B21 Worker,
`python3 docs/agents/qa/B21/tokens.py http://localhost:8000 <out.json> +919000000091 ...`.
Needs a dev stack (`OTP_DEV_CODE=123456`); the output holds live tokens, so write it to a scratch dir only.
"""

import json
import os
import sys
import urllib.request
import uuid


def post(base: str, path: str, body: dict, bearer: str | None = None) -> dict:
    """POST JSON (with an optional bearer token) and return the decoded body ({} for 204)."""
    headers = {"Content-Type": "application/json"} | ({"Authorization": f"Bearer {bearer}"} if bearer else {})
    req = urllib.request.Request(base + path, json.dumps(body).encode(), headers)
    with urllib.request.urlopen(req, timeout=30) as r:  # noqa: S310 - local dev stack only
        raw = r.read()
    return json.loads(raw) if raw else {}


def main() -> None:
    """Request and verify an OTP (and the staff PIN) per phone; write {phone: session} to the output path."""
    base, out, phones = sys.argv[1], sys.argv[2], sys.argv[3:]
    tokens = {}
    for phone in phones:
        post(base, "/v1/auth/otp/request", {"phone": phone})
        body = {"phone": phone, "code": "123456", "device_id": str(uuid.uuid4()), "platform": "android"}
        out_ = post(base, "/v1/auth/otp/verify", body)
        if out_["kind"] == "pin_required":  # staff: PIN step; a first sign-in sets $B21_PIN as the PIN
            out_ = post(base, "/v1/auth/pin/verify", {"pin": os.environ.get("B21_PIN", "2468")}, out_["pin_token"])
        tokens[phone] = out_
    json.dump(tokens, open(out, "w"))
    print(f"{len(tokens)} sessions -> {out}")


if __name__ == "__main__":
    main()
