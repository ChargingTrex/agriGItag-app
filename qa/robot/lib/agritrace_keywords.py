"""AgriTrace Robot Framework keyword library for the API, mobile, network and public-page suites.

Purpose: load the emulator network profiles, switch the emulator network, read
Flutter integration-test results, and pull checkable facts out of a built public page so
Robot suites can assert on them. For the API suites: sign in with the dev OTP (+ office PIN), call the
live `/v1` API, build the request bodies and the QA farmer/plot/lot/batch fixtures the acceptance lines
need, wait for the Celery worker's flags and page builds, and reach the stack's containers (LocalStack
S3, the api image) through `docker compose`. The request sequences are the Verifiers' live procedures
(docs/agents/qa/B0x.md evidence, B06/logs/live_common.py, B09/logs/qa_live.py), not a second copy of the
pytest integration suites.
Serves: plan §9.1 (Robot suites drive Flutter integration tests and adb; API suites per acceptance line),
§13 (BM-11..BM-16), §7.5 Q01 (offline/online matrix), §7.5 Q06 (Robot API suites), §7.4 W01/W02
(public page FR-58, FR-61, FR-63).
Callers: qa/robot/resources/common.resource (imported as a library), qa/robot/api/*.robot,
qa/robot/mobile/*.robot, qa/robot/public/page.robot.
Each public function is a keyword: `load_network_profiles` is `Load Network Profiles` in Robot.
"""

import json
import os
import pathlib
import random
import shlex
import subprocess
import time
import uuid
from datetime import UTC, date, datetime, timedelta
from html.parser import HTMLParser

import yaml
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError

ROBOT_LIBRARY_SCOPE = "GLOBAL"

QA_DIR = pathlib.Path(__file__).resolve().parents[2]
PROFILES_PATH = QA_DIR / "robot" / "profiles.yaml"
NETWORK_SCRIPT = QA_DIR / "scripts" / "network.sh"


def load_network_profiles(path: str | None = None) -> dict:
    """Return the network profiles keyed by name.

    Args:
        path: profiles YAML file; defaults to qa/robot/profiles.yaml.

    Returns:
        dict mapping profile name (e.g. ``normal_4g``) to its settings
        (``down_kbps``, ``up_kbps`` in kbit/s, ``delay_min_ms``, ``delay_max_ms`` in ms, ``data`` bool).

    Raises:
        FileNotFoundError: the file does not exist.
        KeyError: the file has no top-level ``profiles`` key.
        yaml.YAMLError: the file is not valid YAML.
    """
    with open(path or PROFILES_PATH, encoding="utf-8") as handle:
        return yaml.safe_load(handle)["profiles"]


def set_emulator_network(profile: str) -> str:
    """Apply a named network profile to the running emulator via qa/scripts/network.sh.

    Args:
        profile: profile name from profiles.yaml (``normal_4g``, ``weak_4g``, ``edge``, ``offline``).

    Returns:
        The script's stdout (the adb commands when ``DRY_RUN`` is set in the environment).

    Raises:
        RuntimeError: the script exited non-zero (unknown profile, no emulator, adb error);
            the message carries its stderr.

    Side effects:
        Changes the emulator's network speed, delay, mobile data and Wi-Fi state.
    """
    done = subprocess.run(
        ["bash", str(NETWORK_SCRIPT), "profile", profile],
        capture_output=True,
        text=True,
        env=os.environ.copy(),
        check=False,
    )
    if done.returncode != 0:
        raise RuntimeError(f"network.sh profile {profile} failed: {done.stderr.strip()}")
    return done.stdout


def parse_flutter_results(path: str, exit_code: int | str | None = None) -> dict:
    """Summarise a Flutter test run written with ``flutter test --machine`` (JSON lines).

    A crashed or truncated run is a failure: tests that started but never finished count as failed,
    and a missing final ``{"type": "done"}`` event or a non-zero exit code makes ``success`` False and
    adds a failure, so a suite asserting ``failed == 0`` cannot pass on a run that died (emulator crash,
    out of memory on the 2 GB Go AVD).

    Args:
        path: file holding the JSON-lines output of ``flutter test integration_test --machine``.
        exit_code: the ``flutter test`` process exit code, when the caller has it (Robot passes ``${rc}``).

    Returns:
        dict with ``passed``, ``failed``, ``skipped`` (int counts), ``failures`` (list of failing or
        unfinished test names, plus a run-level reason) and ``success`` (bool). Hidden tests (Flutter's
        setUp/tearDown wrappers) are ignored once they finish.

    Raises:
        FileNotFoundError: the file does not exist.
        json.JSONDecodeError: a line starting with ``{`` is not valid JSON.
        ValueError: ``exit_code`` is not an integer.
    """
    names: dict[int, str] = {}
    summary = {"passed": 0, "failed": 0, "skipped": 0, "failures": [], "success": False}
    done = None
    with open(path, encoding="utf-8") as handle:
        # Flutter mixes plain build output into --machine logs; only JSON objects are events.
        events = [json.loads(line) for line in handle if line.lstrip().startswith("{")]
    for event in events:
        if event.get("type") == "testStart":
            names[event["test"]["id"]] = event["test"]["name"]
        elif event.get("type") == "testDone":
            name = names.pop(event["testID"], str(event["testID"]))
            if event.get("hidden"):
                continue
            if event.get("skipped"):
                summary["skipped"] += 1
            elif event.get("result") == "success":
                summary["passed"] += 1
            else:
                summary["failed"] += 1
                summary["failures"].append(name)
        elif event.get("type") == "done":
            done = event
    for name in names.values():
        summary["failed"] += 1
        summary["failures"].append(f"{name} (did not finish)")
    reasons = []
    if done is None:
        reasons.append("run did not finish (no done event)")
    if exit_code not in (None, "") and int(exit_code) != 0:
        reasons.append(f"flutter test exited {exit_code}")
    if reasons and summary["failed"] == 0:
        summary["failed"] = 1
    summary["failures"] += reasons
    summary["success"] = bool(done and done.get("success")) and not reasons and summary["failed"] == 0
    return summary


class _PageFacts(HTMLParser):
    """Collect event dates per timeline, quantity texts and photo URLs from a built public page."""

    def __init__(self) -> None:
        """Start with empty lists; see read_public_page for their meaning."""
        super().__init__()
        self.timelines, self.quantities, self.photo_urls = [], [], []
        self._want_date = False
        self._quantity = None

    def handle_starttag(self, tag: str, attrs: list) -> None:
        """Record what an opening tag tells us.

        Args:
            tag: lower-case tag name.
            attrs: (name, value) pairs.

        Side effects:
            Appends to timelines, quantities and photo_urls; tracks parser state.
        """
        a = dict(attrs)
        classes = (a.get("class") or "").split()
        if tag == "ol" and "tl" in classes:
            self.timelines.append([])
        elif tag == "li" and "ev" in classes:
            self._want_date = True  # the first <time> in an event is its start date
        elif tag == "time" and self._want_date and self.timelines:
            self.timelines[-1].append(a.get("datetime", ""))
            self._want_date = False
        elif tag == "data" and "q" in classes:
            self._quantity = ""
        if tag == "img" and a.get("src"):
            self.photo_urls.append(a["src"])
        elif tag == "source" and a.get("srcset"):
            self.photo_urls.append(a["srcset"])
        elif tag == "a" and "ph" in classes and a.get("href"):
            self.photo_urls.append(a["href"])

    def handle_endtag(self, tag: str) -> None:
        """Close a quantity when its <data> element ends.

        Args:
            tag: lower-case tag name.

        Side effects:
            Appends the collected quantity text to quantities.
        """
        if tag == "data" and self._quantity is not None:
            self.quantities.append(" ".join(self._quantity.split()))
            self._quantity = None

    def handle_data(self, data: str) -> None:
        """Collect the text inside an open quantity <data> element.

        Args:
            data: text between tags.

        Side effects:
            Extends the open quantity text.
        """
        if self._quantity is not None:
            self._quantity += data


def read_public_page(path: str) -> dict:
    """Read a built public page (W01 `index.html`) into the facts the public suite asserts on.

    Args:
        path: the built ``index.html``.

    Returns:
        dict with ``timelines`` (one list of ISO start dates per ``<ol class="tl">``, in page order),
        ``quantities`` (the text of every ``<data class="q">``, e.g. ``"1,20,000 kg"``) and
        ``photo_urls`` (every ``img src``, ``source srcset`` and photo link ``href``).

    Raises:
        FileNotFoundError: the page does not exist.
    """
    parser = _PageFacts()
    parser.feed(pathlib.Path(path).read_text(encoding="utf-8"))
    return {"timelines": parser.timelines, "quantities": parser.quantities, "photo_urls": parser.photo_urls}


# ---------------------------------------------------------------------------------------------------------
# API suites (Q06): live /v1 calls against a compose stack. Seeded phones and the dev OTP are B12's demo
# seed and apps/api/.env.example; the office PIN is set by the first PIN verify of a fresh seed (B02).
# ---------------------------------------------------------------------------------------------------------

ROOT = QA_DIR.parent
ADMIN, OFFICER, QC = "+919000000001", "+919000000002", "+919000000003"
SURVEY_REF = "QA-SURVEY-77/3B"  # land record on the QA plot: must never reach a public page (B10)
ADDRESS = {"village": "QA Thottiyangulam", "block": "Tiruchuli", "district": "Virudhunagar",
           "state": "Tamil Nadu", "pin": "626129"}
_SESSIONS: dict[str, dict] = {}
_WORLD: dict = {}
_PLOTS = [0]  # plots created this run; spreads the pins on a grid


def _var(name: str, default: str) -> str:
    """Read a setting: the Robot variable ``${name}`` when Robot runs, else the environment, else the default.

    Args:
        name: variable name, e.g. ``API_BASE``.
        default: value when neither is set.

    Returns:
        The value as a string.
    """
    try:
        value = BuiltIn().get_variable_value("${" + name + "}")
    except RobotNotRunningError:
        value = None
    return str(value) if value is not None else os.environ.get(name, default)


def _http():
    """Import requests lazily (installed with robotframework-requests, absent from the bare pytest run).

    Returns:
        The ``requests`` module.

    Raises:
        ImportError: requests is not installed.
    """
    import requests

    return requests


def _sign_in(phone: str) -> dict:
    """Sign in with the dev OTP and, for office roles, the office PIN.

    Args:
        phone: seeded or onboarded phone, E.164.

    Returns:
        The session body (``access_token``, ``refresh_token``, ``roles``...) plus ``device_id`` and ``at``.

    Raises:
        AssertionError: OTP verify or PIN verify did not give a session.

    Side effects:
        Creates an OTP challenge (one per phone per 60 s, 10 a day) and a device row; on a fresh seed the
        first PIN verify sets the office user's PIN to ``${OFFICE_PIN}``.
    """
    http, api, device = _http(), _var("API_BASE", "http://localhost:8000/v1"), str(uuid.uuid4())
    r = http.post(f"{api}/auth/otp/request", json={"phone": phone}, timeout=30)
    wait = ((r.json().get("error") or {}).get("details") or {}).get("retry_after_s", 0) if r.status_code == 429 else 0
    if 0 < wait <= 65:  # one code per phone per 60 s (B02); a longer wait is the daily cap: verify fails below
        time.sleep(wait + 1)
        http.post(f"{api}/auth/otp/request", json={"phone": phone}, timeout=30)
    r = http.post(f"{api}/auth/otp/verify", timeout=30, json={
        "phone": phone, "code": _var("OTP_DEV_CODE", "123456"), "device_id": device, "platform": "android"})
    body = r.json()
    if body.get("kind") == "pin_required":
        r = http.post(f"{api}/auth/pin/verify", json={"pin": _var("OFFICE_PIN", "2468")}, timeout=30,
                      headers={"Authorization": f"Bearer {body['pin_token']}"})
        body = r.json()
    if "access_token" not in body:
        raise AssertionError(f"sign-in of {phone} failed: HTTP {r.status_code} {r.text[:300]}")
    return {**body, "device_id": device, "at": time.time()}


def login_as(phone: str) -> dict:
    """Return bearer headers for a user, signing in once per run and refreshing before the 15-min expiry.

    Args:
        phone: the user's phone, E.164.

    Returns:
        ``{"Authorization": "Bearer <access_token>"}`` for ``headers=``.

    Raises:
        AssertionError: sign-in failed (see _sign_in).

    Side effects:
        Caches the session in this library (GLOBAL scope) for the whole run.
    """
    s = _SESSIONS.get(phone)
    if s and time.time() - s["at"] > 600:
        r = _http().post(f"{_var('API_BASE', '')}/auth/refresh", json={"refresh_token": s["refresh_token"]},
                         timeout=30)
        s = {**s, **r.json(), "at": time.time()} if r.status_code == 200 else None
    if not s:
        s = _sign_in(phone)
    _SESSIONS[phone] = s
    return {"Authorization": f"Bearer {s['access_token']}"}


def call_api(method: str, path: str, phone: str | None = None, expect: int | str | None = None, **kwargs):
    """Call the live API as a user and optionally assert the status.

    Args:
        method: HTTP method.
        path: path under ``${API_BASE}``, e.g. ``/flags``.
        phone: whose session to use; None calls without a token.
        expect: expected HTTP status; None accepts any.
        **kwargs: passed to ``requests.request`` (``json``, ``params``, ``headers``, ``files``, ``data``).

    Returns:
        The ``requests.Response``.

    Raises:
        AssertionError: the status differs from ``expect``.

    Side effects:
        Whatever the endpoint does.
    """
    headers = {**(login_as(phone) if phone else {}), **(kwargs.pop("headers", None) or {})}
    r = _http().request(method, _var("API_BASE", "http://localhost:8000/v1") + path, headers=headers,
                        timeout=120, **kwargs)
    if expect is not None and r.status_code != int(expect):
        raise AssertionError(f"{method} {path} -> HTTP {r.status_code}, expected {expect}: {r.text[:800]}")
    return r


def days_ago(days: int | str) -> str:
    """Return the ISO date ``days`` before today (negative = in the future).

    Args:
        days: number of days.

    Returns:
        e.g. ``2026-10-20``.
    """
    return (date.today() - timedelta(days=int(days))).isoformat()


def new_phone() -> str:
    """Return a random Indian mobile number nobody in the seed uses (+9197 + 8 digits).

    Returns:
        An E.164 phone string.
    """
    return f"+9197{random.randrange(10**8):08d}"


def new_farmer(name: str = "QA Robot Farmer", phone: str | None = None) -> dict:
    """Onboard, approve and record data consent for a farmer in the demo FPO (as the FPO admin).

    Args:
        name: display name (also the canary the public-page checks search for).
        phone: phone to use; a random one by default.

    Returns:
        ``{"id", "user_id", "phone", "name"}``.

    Raises:
        AssertionError: any call failed.

    Side effects:
        Creates a farmer, its user and a `data_collection` consent.
    """
    phone = phone or new_phone()
    f = call_api("POST", "/farmers", ADMIN, 201, json={"name": name, "phone": phone, "lang": "en",
                                                       "client_id": str(uuid.uuid4()), "address": ADDRESS}).json()
    call_api("POST", f"/farmers/{f['id']}/approve", ADMIN, 200)
    new_consent(f["id"], "data_collection", start_assist(f["id"]))
    return {"id": f["id"], "user_id": f["user_id"], "phone": phone, "name": name}


def start_assist(farmer_id: str) -> str:
    """Start an assist session for a farmer as the seeded field officer (POST /v1/assist/start).

    Args:
        farmer_id: the assisted farmer.

    Returns:
        The assist session id, for the ``X-Assist-Session`` header.

    Raises:
        AssertionError: the session was not started.

    Side effects:
        Creates an assist session.
    """
    return call_api("POST", "/assist/start", OFFICER, 201, json={
        "client_id": str(uuid.uuid4()), "farmer_id": farmer_id}).json()["id"]


def new_consent(farmer_id: str, consent_type: str, assist_session: str | None = None,
                expect: int | str = 201) -> dict:
    """Record a consent for a farmer as the field officer in assist mode (POST /v1/consents).

    Args:
        farmer_id: the farmer.
        consent_type: ``data_collection``, ``public_name`` or ``partner_share``.
        assist_session: assist session id sent as ``X-Assist-Session``; None sends no header.
        expect: expected HTTP status.

    Returns:
        The response body (ConsentOut on 201).

    Raises:
        AssertionError: the status differs from ``expect``.

    Side effects:
        Creates a consent and its audit row.
    """
    headers = {"X-Assist-Session": assist_session} if assist_session else {}
    return call_api("POST", "/consents", OFFICER, expect, headers=headers, json={
        "client_id": str(uuid.uuid4()), "farmer_id": farmer_id, "consent_type": consent_type,
        "consent_version": "v1", "given_at": datetime.now(UTC).isoformat()}).json()


def new_plot(lat: float | str | None = None, lon: float | str | None = None, pin_method: str = "live_gps",
             farmer_id: str | None = None, expect: int | str = 201, **extra) -> dict:
    """Register a 1-acre plot as the FPO admin (POST /v1/plots).

    Args:
        lat: pin latitude; default the next point of a 0.005° grid inside the GI fixture region.
        lon: pin longitude (same default rule).
        pin_method: ``live_gps`` or ``map_pin``.
        farmer_id: owner; default the QA world's farmer.
        expect: expected HTTP status.
        **extra: more PlotIn fields (``farming_type``, ``land_record_ref``...).

    Returns:
        The PlotOut body (``id``, ``pin``, ``location_status``, ``region_check``...).

    Raises:
        AssertionError: the status differs from ``expect``.

    Side effects:
        Creates a plot; the server runs the GI region check.
    """
    if lat is None:
        n = _PLOTS[0] = _PLOTS[0] + 1
        lat, lon = 9.555 + 0.005 * (n % 7), 78.105 + 0.01 * (n // 7 % 5)
    body = {"client_id": str(uuid.uuid4()), "farmer_id": farmer_id or qa_world()["farmer"]["id"],
            "pin": {"lat": float(lat), "lon": float(lon), "accuracy_m": 5}, "pin_method": pin_method,
            "device_time": datetime.now(UTC).isoformat(), "declared_area": {"value": "1", "unit": "acre"},
            "farming_type": "rainfed", **extra}
    return call_api("POST", "/plots", ADMIN, expect, json=body).json()


def new_lot(plot: dict | None = None, practice_tags: list | None = None) -> str:
    """Open a lot of the QA crop on a plot (POST /v1/lots as the FPO admin).

    Args:
        plot: a PlotOut body; default the QA world's main plot.
        practice_tags: declared practice tags, e.g. ``["inorganic", "ipm"]``.

    Returns:
        The lot id.

    Raises:
        AssertionError: the lot was not created.

    Side effects:
        Creates a lot.
    """
    w = qa_world()
    return call_api("POST", "/lots", ADMIN, 201, json={
        "client_id": str(uuid.uuid4()), "plot_id": (plot or w["plot"])["id"], "crop_id": w["crop"],
        "season_label": "QA Robot", "practice_tags_declared": practice_tags or []}).json()["id"]


def new_instrument(due_in_days: int | str = 300) -> str:
    """Register a moisture meter (POST /v1/instruments as the FPO admin).

    Args:
        due_in_days: days until the calibration falls due; negative gives an expired meter.

    Returns:
        The instrument id.

    Raises:
        AssertionError: the meter was not registered.

    Side effects:
        Creates an instrument.
    """
    return call_api("POST", "/instruments", ADMIN, 201, json={
        "kind": "moisture_meter", "make_model": "QA Robot meter", "serial_no": f"QA-{uuid.uuid4().hex[:8]}",
        "calibrated_on": days_ago(400), "calibration_due_on": days_ago(-int(due_in_days))}).json()["id"]


def qa_world() -> dict:
    """Return this run's QA fixtures, creating them on first use.

    Returns:
        ``fpo``, ``crop``, ``gi_tag``, ``processor``, ``instrument`` (ids), ``farmer`` (see new_farmer) and
        ``plot`` (PlotOut of the main plot, with ``land_record_ref`` = SURVEY_REF).

    Raises:
        AssertionError: a setup call failed.

    Side effects:
        First call: a QA farmer, a calibrated meter and a plot in the demo FPO (the seeded reference batch
        FGP8T4033HM7 is never written to).
    """
    if not _WORLD:
        crop = next(c for c in call_api("GET", "/crops", ADMIN, 200).json() if c["code"] == "SAMBA_VATHAL")
        me = call_api("GET", "/me", ADMIN, 200).json()
        _WORLD.update(fpo=me["memberships"][0]["fpo_id"], crop=crop["id"], gi_tag=crop["gi_tag_id"],
                      processor=call_api("GET", "/processors", ADMIN, 200).json()[0]["id"],
                      instrument=new_instrument(), farmer=new_farmer())
        _WORLD["plot"] = new_plot(9.586, 78.112, land_record_ref=SURVEY_REF)
    return _WORLD


def moisture(value: str, stage: str = "drying_end", lot_id: str | None = None, batch_id: str | None = None,
             **extra) -> dict:
    """Build an instrument moisture reading body (QualityReadingIn) with the QA meter.

    Args:
        value: percent, as a string (``"10.9"``).
        stage: ``drying_end``, ``intake``, ``grading`` or ``storage``.
        lot_id: subject lot (set exactly one of lot_id and batch_id; grading inline readings need neither).
        batch_id: subject batch.
        **extra: overrides (``source``, ``instrument_id``, ``reason_code``...).

    Returns:
        The request body.
    """
    body = {"client_id": str(uuid.uuid4()), "stage": stage, "parameter_code": "moisture",
            "measurement": {"value": str(value), "unit": "%"}, "source": "instrument",
            "instrument_id": qa_world()["instrument"], "measured_at": datetime.now(UTC).isoformat()}
    body.update({k: v for k, v in (("lot_id", lot_id), ("batch_id", batch_id)) if v})
    return {**body, **extra}


def event(lot_id: str, plot: dict, event_type: str, occurred_on: str, payload: dict | None = None,
          lat_shift: float | str = 0, clock_shift_hours: float | str = 0, **extra) -> dict:
    """Build a version-1 farm event entry for POST /v1/sync/push.

    Args:
        lot_id: the lot.
        plot: PlotOut body of the plot the event names (its pin is the GPS fix).
        event_type: e.g. ``harvest``, ``land_preparation``.
        occurred_on: ISO date.
        payload: event payload, e.g. ``{"quantity": {"value": 195, "unit": "kg"}}``.
        lat_shift: degrees added to the fix latitude (0.0054° ≈ 600 m).
        clock_shift_hours: hours added to the device clock (negative = in the past).
        **extra: entry-level fields (``assist_session_id``).

    Returns:
        ``{"client_id", "kind": "event_version", "data": {...}}``.
    """
    data = {"event_id": str(uuid.uuid4()), "version_no": 1, "subject_type": "lot", "lot_id": lot_id,
            "plot_id": plot["id"], "event_type": event_type, "instance_no": 1, "occurred_on": occurred_on,
            "payload": payload or {},
            "clocks": {"device_time": (datetime.now(UTC) + timedelta(hours=float(clock_shift_hours))).isoformat()},
            "gps": {"lat": plot["pin"]["lat"] + float(lat_shift), "lon": plot["pin"]["lon"], "accuracy_m": 5.0}}
    return {"client_id": str(uuid.uuid4()), "kind": "event_version", "data": data, **extra}


def push(phone: str, *entries: dict, expect: int | str = 200, headers: dict | None = None) -> list | dict:
    """POST /v1/sync/push from a new device.

    Args:
        phone: the pushing user.
        *entries: sync entries (see event).
        expect: expected HTTP status.
        headers: extra headers (``X-Assist-Session``).

    Returns:
        The per-entry results on 200, else the error body.

    Raises:
        AssertionError: the status differs from ``expect``.

    Side effects:
        Stores the accepted entries; the worker then runs the rules on them.
    """
    r = call_api("POST", "/sync/push", phone, expect, headers=headers, json={
        "device_id": str(uuid.uuid4()), "app_version": "1.0.3", "device_time": datetime.now(UTC).isoformat(),
        "entries": list(entries)})
    return r.json()["results"] if r.status_code == 200 else r.json()


def received_lot(kg: str, plot: dict | None = None, reading: str = "10.0", stage: str = "drying_end") -> str:
    """Open a lot, record its moisture, mark it ready and receive it at the processor (B09 path).

    Args:
        kg: intake kilograms.
        plot: PlotOut body; default the QA main plot.
        reading: moisture percent recorded before the ready gate.
        stage: stage of that reading.

    Returns:
        The lot id.

    Raises:
        AssertionError: a step failed (e.g. the moisture gate).

    Side effects:
        Creates a lot, a reading and an intake.
    """
    lot = new_lot(plot)
    call_api("POST", "/quality-readings", ADMIN, 201, json=moisture(reading, stage, lot_id=lot))
    call_api("POST", f"/lots/{lot}/ready", ADMIN, 200)
    call_api("POST", "/intakes", ADMIN, 201, json={"client_id": str(uuid.uuid4()), "lot_id": lot,
                                                   "processor_id": qa_world()["processor"], "sale_date": days_ago(0),
                                                   "received": {"value": str(kg), "unit": "kg"}})
    return lot


def new_batch(lot_ids: list, gi: bool | str = False) -> dict:
    """Merge received lots into a batch (POST /v1/batches as the FPO admin).

    Args:
        lot_ids: received lots.
        gi: whether the GI label is requested.

    Returns:
        The batch body (``id``, ``code``, ``shares``, ``gi_verified``...).

    Raises:
        AssertionError: the batch was not created.

    Side effects:
        Creates a batch.
    """
    return call_api("POST", "/batches", ADMIN, 201, json={
        "client_id": str(uuid.uuid4()), "processor_id": qa_world()["processor"],
        "gi_label_requested": str(gi).lower() == "true", "lot_ids": list(lot_ids)}).json()


def flags_of(subject_id: str) -> list:
    """List every flag (any status) on a subject, read page by page from GET /v1/flags as the FPO admin.

    Args:
        subject_id: lot, event, batch, plot or reading id.

    Returns:
        FlagOut bodies whose ``subject_id`` matches.
    """
    found, cursor = [], None
    while True:
        page = call_api("GET", "/flags", ADMIN, 200, params={"limit": 200, **({"cursor": cursor} if cursor else {})}).json()
        found += [f for f in page["items"] if f["subject_id"] == subject_id]
        cursor = page.get("next_cursor")
        if not page.get("has_more"):
            return found


def wait_for_flag(subject_id: str, rule_code: str, timeout: int | str = 120) -> dict:
    """Wait until the worker's rules have raised a flag on a subject.

    Args:
        subject_id: subject id.
        rule_code: e.g. ``event_off_plot``.
        timeout: seconds.

    Returns:
        The FlagOut body.

    Raises:
        AssertionError: no such flag within the timeout.
    """
    end = time.time() + float(timeout)
    while True:
        hit = [f for f in flags_of(subject_id) if f["rule_code"] == rule_code]
        if hit:
            return hit[0]
        if time.time() > end:
            raise AssertionError(f"no {rule_code} flag on {subject_id} after {timeout} s")
        time.sleep(3)


def wait_for_build(batch_id: str, build_no: int | str, timeout: int | str = 180) -> dict:
    """Wait until page build ``build_no`` of a batch leaves ``queued`` (the worker builds it).

    Args:
        batch_id: the batch.
        build_no: build number.
        timeout: seconds.

    Returns:
        The build item from GET /v1/batches/{id}/builds.

    Raises:
        AssertionError: still queued (or absent) after the timeout.
    """
    end = time.time() + float(timeout)
    while time.time() < end:
        items = call_api("GET", f"/batches/{batch_id}/builds", ADMIN, 200).json()["items"]
        build = next((b for b in items if b["build_no"] == int(build_no)), None)
        if build and build["status"] != "queued":
            return build
        time.sleep(2)
    raise AssertionError(f"build {build_no} of {batch_id} still queued after {timeout} s")


def drain_pull(phone: str, cursor: str | None = None) -> dict:
    """Read every page of GET /v1/sync/pull from a cursor.

    Args:
        phone: the pulling user.
        cursor: where to start; None from the beginning.

    Returns:
        ``{"changes": [...], "cursor": <next cursor>}``.

    Side effects:
        The server records the device's pull cursor.
    """
    changes = []
    while True:
        page = call_api("GET", "/sync/pull", phone, 200, params={"cursor": cursor} if cursor else {}).json()
        changes += page["changes"]
        cursor = page["next_cursor"] or cursor
        if not page["has_more"]:
            return {"changes": changes, "cursor": cursor}


def _compose(*args: str, stdin: bytes | None = None) -> subprocess.CompletedProcess:
    """Run ``${COMPOSE} <args>`` (the stack's docker compose command line).

    Args:
        *args: compose arguments, e.g. ``exec -T s3 awslocal s3 ls``.
        stdin: bytes for the process's standard input.

    Returns:
        The completed process with bytes stdout/stderr.

    Raises:
        FileNotFoundError: docker is not installed.
    """
    cmd = shlex.split(_var("COMPOSE", f"docker compose -f {ROOT}/infra/docker-compose.yml")) + list(args)
    return subprocess.run(cmd, input=stdin, capture_output=True, check=False, timeout=600)


def compose(*args: str) -> dict:
    """Run a docker compose command against the stack under test (``${COMPOSE}``, default the repo's file).

    Args:
        *args: compose arguments, e.g. ``run --rm --no-deps api python -c ...``.

    Returns:
        ``{"rc": exit code, "stdout": stdout, "out": stdout + stderr}`` (text).

    Raises:
        FileNotFoundError: docker is not installed.

    Side effects:
        Whatever the command does (one-off containers, exec in running ones).
    """
    done = _compose(*args)
    out = done.stdout.decode(errors="replace")
    return {"rc": done.returncode, "stdout": out, "out": out + done.stderr.decode(errors="replace")}


def s3_get(bucket: str, key: str, version_id: str | None = None) -> bytes:
    """Read an object (or one version of it) from the stack's LocalStack S3 with awslocal in the s3 container.

    Args:
        bucket: bucket, e.g. ``public-pages``.
        key: object key.
        version_id: a version; None for the latest.

    Returns:
        The object bytes.

    Raises:
        AssertionError: the object or version does not exist.
    """
    ver = f"--version-id {shlex.quote(version_id)} " if version_id else ""
    done = _compose("exec", "-T", "s3", "sh", "-c", f"awslocal s3api get-object --bucket {shlex.quote(bucket)} "
                    f"--key {shlex.quote(key)} {ver}/tmp/q06-obj >/dev/null && cat /tmp/q06-obj")
    if done.returncode:
        raise AssertionError(f"s3://{bucket}/{key} {version_id or ''}: {done.stderr.decode()[-400:]}")
    return done.stdout


def s3_versions(bucket: str, key: str) -> list:
    """List the versions of one S3 object (newest first).

    Args:
        bucket: bucket.
        key: exact object key.

    Returns:
        ``[{"VersionId", "IsLatest", ...}]`` for that key only.

    Raises:
        AssertionError: the listing failed.
    """
    out = compose("exec", "-T", "s3", "awslocal", "s3api", "list-object-versions", "--bucket", bucket,
                  "--prefix", key)
    if out["rc"]:
        raise AssertionError(out["out"][-400:])
    return [v for v in json.loads(out["stdout"]).get("Versions", []) if v["Key"] == key]


def s3_put(bucket: str, key: str, data: str | bytes) -> None:
    """Write an object straight into LocalStack S3, bypassing the presigned URL (tampering test, B06).

    Args:
        bucket: bucket.
        key: object key.
        data: the bytes (str is UTF-8 encoded).

    Raises:
        AssertionError: the write failed.

    Side effects:
        Writes the object (with a SHA-256 checksum, which object lock requires).
    """
    raw = data.encode() if isinstance(data, str) else data
    done = _compose("exec", "-T", "s3", "sh", "-c", f"cat > /tmp/q06-put && awslocal s3api put-object --bucket "
                    f"{shlex.quote(bucket)} --key {shlex.quote(key)} --body /tmp/q06-put --checksum-algorithm SHA256",
                    stdin=raw)
    if done.returncode:
        raise AssertionError(done.stderr.decode()[-400:])


def decode_qr(png: bytes) -> list:
    """Decode the QR codes in a PNG with zxing-cpp inside the api container (it ships zxing-cpp and Pillow).

    Args:
        png: PNG bytes.

    Returns:
        The decoded texts, one per QR code found.

    Raises:
        AssertionError: the decoder failed to run.
    """
    code = ("import io,sys,zxingcpp;from PIL import Image;"
            "[print(b.text) for b in zxingcpp.read_barcodes(Image.open(io.BytesIO(sys.stdin.buffer.read())))]")
    done = _compose("exec", "-T", "api", "python", "-c", code, stdin=png)
    if done.returncode:
        raise AssertionError(done.stderr.decode()[-400:])
    return done.stdout.decode().split()
