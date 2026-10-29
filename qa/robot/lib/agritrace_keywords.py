"""AgriTrace Robot Framework keyword library for the mobile, network and public-page suites.

Purpose: load the emulator network profiles, switch the emulator network, read
Flutter integration-test results, and pull checkable facts out of a built public page so
Robot suites can assert on them.
Serves: plan §9.1 (Robot suites drive Flutter integration tests and adb), §13 (BM-11..BM-16),
§7.5 Q01 (offline/online matrix), §7.4 W01/W02 (public page FR-58, FR-61, FR-63).
Callers: qa/robot/resources/common.resource (imported as a library), qa/robot/mobile/*.robot,
qa/robot/public/page.robot.
Each public function is a keyword: `load_network_profiles` is `Load Network Profiles` in Robot.
"""

import json
import os
import pathlib
import subprocess
from html.parser import HTMLParser

import yaml

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
