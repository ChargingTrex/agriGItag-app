"""Schemathesis auth hook for the Q04 fuzz runs: a staff bearer token that is refreshed before it expires.

Purpose: access tokens live 900 s and a 200-example run takes longer, so the hook swaps the refresh token for a new
access token every 600 s (POST /v1/auth/refresh) instead of letting late requests turn into 401s.
Serves: PLAN §7.5 Q04 (Schemathesis fuzz on /sync/push). Not product code. Caller: schemathesis, loaded with
`SCHEMATHESIS_HOOKS=st_auth` (PYTHONPATH=docs/agents/qa/Q04). Inputs: $Q04_TOKENS (token cache JSON, scratch only)
and $Q04_PHONE (whose session to use). Side effects: rewrites the token cache with the rotated refresh token.
"""

import json
import os

import requests
import schemathesis


@schemathesis.auth(refresh_interval=600)
class StaffToken:
    """Bearer token of the $Q04_PHONE session, refreshed every 600 s."""

    def get(self, case, ctx) -> str:
        """Rotate the cached refresh token and return the new access token.

        Raises:
            requests.HTTPError: the refresh call is rejected (the run cannot continue authenticated).
        Side effects: writes the rotated tokens back to $Q04_TOKENS.
        """
        path, phone = os.environ["Q04_TOKENS"], os.environ["Q04_PHONE"]
        cache = json.load(open(path))
        r = requests.post("http://localhost:8000/v1/auth/refresh", json={"refresh_token": cache[phone]["refresh_token"]}, timeout=30)
        r.raise_for_status()
        cache[phone].update(access_token=r.json()["access_token"], refresh_token=r.json()["refresh_token"])
        json.dump(cache, open(path, "w"))
        return cache[phone]["access_token"]

    def set(self, case, data: str, ctx) -> None:
        """Put the token in the Authorization header of the case."""
        case.headers = {**(case.headers or {}), "Authorization": f"Bearer {data}"}
