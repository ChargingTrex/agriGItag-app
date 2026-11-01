"""Verifier live check of the B13 acceptance lines on the compose stack.

Purpose: read `/v1/config/fields` and `/v1/config/features` as the seeded FPO admin, hit the flag-gated
`POST /v1/farmers/{id}/id-documents` on the compose API (flag off) and on a second container of the same image with a
scratch config where the flag is on ($QA_ON_URL), and import a CSV with 2 bad rows into the input master (dry run, then
commit, then psql). Caller: the Verifier, with live_common.py from docs/agents/qa/B06/logs.
"""

import json
import os
import subprocess
import sys
import uuid

import httpx

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "../../B06/logs"))
from live_common import ADMIN, client, session, show  # noqa: E402

W = json.load(open(os.environ["QA_WORLD"]))


def sql(q: str) -> str:
    """Run one SQL query on the compose DB and print it with its result."""
    out = subprocess.run(["psql", "-h", "localhost", "-p", "5433", "-U", "agritrace", "agritrace", "-Atc", q],
                         env={**os.environ, "PGPASSWORD": "agritrace"}, capture_output=True, text=True, check=True)
    print(f"  sql> {q}\n  =>  {out.stdout.strip()!r}")
    return out.stdout.strip()


with client(ADMIN) as a:
    print("== 1. /v1/config/fields for the demo FPO: plot.soil_type")
    r = show(a.get("/config/fields"), body_limit=300)
    body = r.json()
    plot = body.get("entities", body).get("plot") if isinstance(body, dict) else None
    soil = [f for f in (plot["fields"] if isinstance(plot, dict) and "fields" in plot else plot or []) if f.get("name") == "soil_type"]
    print("  plot fields:", [f.get("name") for f in (plot["fields"] if isinstance(plot, dict) and "fields" in plot else plot or [])])
    print("RESULT line1 (demo FPO): soil_type entries in /config/fields plot:", soil)
    r2 = a.get("/config/fields", headers={"If-None-Match": r.headers["etag"]})
    print(f"  If-None-Match with that ETag -> HTTP {r2.status_code}")

    print("\n== 2a. flag off (compose API, repo config): POST /farmers/{id}/id-documents -> 404")
    show(a.get("/config/features"))
    doc = {"doc_type": "aadhaar", "content_type": "image/jpeg", "sha256": "0" * 64, "size_bytes": 1000}
    r = show(a.post(f"/farmers/{W['farmer']}/id-documents", json=doc))
    print(f"RESULT line2 off: HTTP {r.status_code} code={r.json().get('error', {}).get('code')}")

    print(f"\n== 2b. flag on (second container {os.environ['QA_ON_URL']}, same image, tenant file with id_document_capture: true)")
    with httpx.Client(base_url=os.environ["QA_ON_URL"], timeout=60,
                      headers={"Authorization": f"Bearer {session(ADMIN)['access_token']}"}) as on:
        show(on.get("/config/features"))
        r = show(on.post(f"/farmers/{W['farmer']}/id-documents", json=doc))
        print(f"RESULT line2 on: HTTP {r.status_code} code={r.json().get('error', {}).get('code')} (not 404: route exposed)")

    print("\n== 3. CSV with 2 bad rows -> 200, accepted n-2, rejected [{row, code}], no partial writes")
    csv_body = (b"name_en,manufacturer,category,unit,pack_size\n"
                b"QA Verifier Urea,IFFCO,chemical_fertilizer,kg,50\n"
                b"QA Verifier Neem cake,,organic_fertilizer,,25\n"
                b"QA Verifier Trichoderma,,bio_pesticide,kg,1\n"
                b"QA Verifier Mystery,,magic_dust,kg,1\n"
                b"QA Verifier Vermicompost,,organic_fertilizer,kg,40\n")
    q = "select count(*) from inputs_master where name_en like 'QA Verifier%'"
    before = sql(q)
    for dry in ("true", "false"):
        r = a.post("/imports/inputs", params={"dry_run": dry}, files={"file": ("inputs.csv", csv_body, "text/csv")})
        print(f"$ POST {r.request.url} (multipart file inputs.csv, 5 data rows)\n-> HTTP {r.status_code}\n  {r.text}")
        print(f"RESULT line3 dry_run={dry}: HTTP {r.status_code} accepted={r.json().get('accepted')} "
              f"rejected={[(x['row'], x['code']) for x in r.json().get('rejected', [])]}")
        sql(q)
    sql("select name_en from inputs_master where name_en like 'QA Verifier%' order by 1")
    print(f"  rows before={before}")
