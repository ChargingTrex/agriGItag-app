"""Verifier live check of the B10 acceptance lines and BM-09 on the compose stack (real worker, LocalStack).

Purpose: batch X (B09 live run, QA lots of 100/200/20 kg, published, build 1) is rebuilt after its page-required
fields are filled through the API; then the objects in `public-pages/batches/<code>/` are listed and downloaded,
the HTML/JSON are searched for the phone, survey reference, PIN and temp paths, the QR is decoded, events are
checked for date order, an event is corrected and the page rebuilt to show the older S3 versions are kept.
The downloaded files are written to $QA_PAGES for privacy-lint (BM-09). Caller: the Verifier, once.
"""

import json
import os
import subprocess
import sys
import time
from io import BytesIO

import boto3
import zxingcpp
from PIL import Image

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "B09", "logs"))
from qa_live import ADMIN, OFFICER, QA_FARMER_PHONE, check, client, load, save, section, show, sql, uuid7  # noqa: E402

W = load()
X, CODE = W["batch_x"], W["batch_x_code"]
BASE = "http://localhost:4566/public-pages"  # PUBLIC_BASE_URL of the compose api service (docker compose exec api env)
s3 = boto3.client("s3", endpoint_url="http://localhost:4566", aws_access_key_id="test",
                  aws_secret_access_key="test", region_name="ap-south-1")
PREFIX = f"batches/{CODE}/"


def wait_build(a, build_no: int) -> dict:
    """Poll GET /batches/{X}/builds until build `build_no` leaves `queued` (max 180 s); return it."""
    for _ in range(90):
        items = a.get(f"/batches/{X}/builds").json()["items"]
        b = next((i for i in items if i["build_no"] == build_no), None)
        if b and b["status"] != "queued":
            show(a.get(f"/batches/{X}/builds"), 2500)
            return b
        time.sleep(2)
    raise SystemExit(f"build {build_no} still queued after 180 s")


def ls() -> None:
    """List the batch's objects with the LocalStack CLI inside the s3 container (evidence of the listing)."""
    cmd = ["docker", "compose", "-f", "../../infra/docker-compose.yml", "exec", "-T", "s3",
           "awslocal", "s3", "ls", f"s3://public-pages/{PREFIX}"]
    print("$", " ".join(cmd))
    print(subprocess.run(cmd, capture_output=True, text=True).stdout)


with client(ADMIN) as a, client(OFFICER) as o:
    section("0 state found: build 1 of batch X (published by live_b09_part2.py)")
    b1 = wait_build(a, 1)
    print("  build 1 status:", b1["status"], "error code:", (b1.get("error") or {}).get("code"))

    section("1 fill the page-required fields the QA data lacked (farmer address, plot farming_type) via the API")
    show(a.patch(f"/farmers/{W['farmer']}", json={"address": {"village": "QA Thottiyangulam", "block": "Tiruchuli",
                                                              "district": "Virudhunagar", "state": "Tamil Nadu",
                                                              "pin": "626129"}}), 600)
    show(a.post(f"/plots/{W['plot_main']['id']}/correct", json={"farming_type": "rainfed",
                                                                "reason_code": "land_record_checked"}), 600)

    section("2 rebuild -> build 2, worker builds it")
    r = show(a.post(f"/batches/{X}/rebuild"))
    check("rebuild -> 202 build_no 2 trigger rebuild", r.status_code == 202 and r.json()["build_no"] == 2)
    b2 = wait_build(a, 2)
    check("build 2 built", b2["status"] == "built")
    gen = sql(f"select generation from page_builds where batch_id='{X}' and build_no=2")

    section("3 after publish the objects exist and `generation` matches")
    ls()
    objs = {k: s3.get_object(Bucket="public-pages", Key=PREFIX + k) for k in ("index.html", "data.json", "qr.png")}
    body = {k: v["Body"].read() for k, v in objs.items()}
    for k, v in objs.items():
        print(f"  {k}: {len(body[k])} bytes, ContentType={v['ContentType']}, CacheControl={v.get('CacheControl')}, "
              f"VersionId={v.get('VersionId')}")
    data = json.loads(body["data.json"])
    print("  data.json footer:", data["footer"])
    check("index.html, data.json, qr.png exist; data.json footer.generation == page_builds.generation == 2",
          all(body.values()) and str(data["footer"]["generation"]) == gen == "2")
    proxy = show(a.get(f"/public/batches/{CODE}"), 200)
    check("GET /v1/public/batches/<code> serves the same HTML", proxy.content == body["index.html"])

    section("4 HTML (and data.json) have no phone / survey number / temp_uploads")
    staff = sql("select string_agg(phone, ',') from users").split(",")
    leaks = [QA_FARMER_PHONE, QA_FARMER_PHONE[-10:], "QA-SURVEY", "77/3B", "Survey", "survey", "temp_uploads",
             "626129", *staff, *(p[-10:] for p in staff)]
    for k in ("index.html", "data.json"):
        txt = body[k].decode()
        hits = [x for x in leaks if x in txt]
        print(f"  {k}: searched {len(leaks)} strings, hits={hits}")
        check(f"{k}: no phone, survey ref, PIN or temp_uploads", not hits)
    sql(f"select land_record_ref from plots where id='{W['plot_main']['id']}'")
    pages = os.environ["QA_PAGES"]
    os.makedirs(os.path.join(pages, PREFIX), exist_ok=True)
    for k in ("index.html", "data.json", "qr.png"):
        open(os.path.join(pages, PREFIX, k), "wb").write(body[k])
    print("  downloaded to $QA_PAGES/" + PREFIX)

    section("5 QR decodes to {PUBLIC_BASE_URL}/b/<code>")
    want = f"{BASE}/b/{CODE}"
    api_png = show(a.get(f"/batches/{X}/qr.png"), 80).content
    got = [[r.text for r in zxingcpp.read_barcodes(Image.open(BytesIO(png)))] for png in (body["qr.png"], api_png)]
    print("  decoded (S3 qr.png, GET /batches/{id}/qr.png):", got, " expected:", want)
    check("both QR images decode to exactly " + want, got == [[want], [want]])

    section("6 events ascending")
    evs = [(lot["code"] if "code" in lot else None, [(e.get("date") or e.get("occurred_on"), e.get("type") or
            e.get("event_type")) for e in lot.get("events", [])]) for lot in data["lots"]]
    print("  per-lot events:", json.dumps(evs))
    top = data.get("events")
    if top is not None:
        print("  top-level events:", json.dumps(top)[:1500])
    dates = [d for _, e in evs for d, _ in e] if any(e for _, e in evs) else [x.get("date") for x in (top or [])]
    lots_sorted = all([d for d, _ in e] == sorted(d for d, _ in e) for _, e in evs)
    check("event dates ascending (and lot C's 5 events, pushed out of order, are all there)",
          lots_sorted and len(dates) >= 5)

    section("7 correction -> new build_no, old S3 versions kept")
    ev = sql(f"select e.id from events e where e.lot_id='{W['lots_x'][0]}' and e.event_type='harvest'")
    cur = show(a.get(f"/lots/{W['lots_x'][0]}/events"), 3000).json()
    item = next(i for i in cur["items"] if i["id"] == ev) if isinstance(cur, dict) else None
    print("  current harvest version:", json.dumps(item)[:600] if item else None)
    corr = {"event_id": ev, "version_no": 2, "subject_type": "lot", "lot_id": W["lots_x"][0],
            "plot_id": W["plot_main"]["id"], "event_type": "harvest", "instance_no": 1,
            "occurred_on": item["occurred_on"] if item else None, "change_kind": "correct",
            "reason_code": "entered_by_mistake", "payload": {"quantity": {"value": 112, "unit": "kg"}, "bags": 5},
            "clocks": {"device_time": time.strftime("%Y-%m-%dT%H:%M:%S+00:00", time.gmtime())}}
    r = show(o.post(f"/events/{ev}/versions", json={"client_id": str(uuid7()), "data": corr}), 1200)
    check("officer correction of lot C's harvest -> 200 version 2", r.status_code == 200)
    r = show(a.post(f"/batches/{X}/rebuild"))
    check("rebuild -> 202 build_no 3", r.status_code == 202 and r.json()["build_no"] == 3)
    b3 = wait_build(a, 3)
    check("build 3 built", b3["status"] == "built")
    vers = s3.list_object_versions(Bucket="public-pages", Prefix=PREFIX + "data.json")["Versions"]
    print("  data.json versions:", [(v["VersionId"], v["IsLatest"], str(v["LastModified"])) for v in vers])
    gens = []
    for v in vers:
        d = json.loads(s3.get_object(Bucket="public-pages", Key=PREFIX + "data.json", VersionId=v["VersionId"])["Body"].read())
        gens.append((v["IsLatest"], d["footer"]["generation"]))
    print("  (IsLatest, generation) per version:", gens)
    hv = s3.list_object_versions(Bucket="public-pages", Prefix=PREFIX + "index.html")["Versions"]
    print("  index.html versions:", len(hv))
    check("data.json keeps 2 versions: generation 2 (old) and 3 (latest); index.html 2 versions",
          sorted(gens) == [(False, "2"), (True, "3")] and len(hv) == 2)
    sql(f"select build_no, generation, trigger, status from page_builds where batch_id='{X}' order by build_no")
    # Refresh the BM-09 copy with the latest build.
    for k in ("index.html", "data.json"):
        open(os.path.join(pages, PREFIX, k), "wb").write(s3.get_object(Bucket="public-pages", Key=PREFIX + k)["Body"].read())
