"""AgriTrace Robot Framework keyword library for the mobile and network suites.

Purpose: load the emulator network profiles, switch the emulator network, and read
Flutter integration-test results so Robot suites can assert on them.
Serves: plan §9.1 (Robot suites drive Flutter integration tests and adb), §13 (BM-11..BM-16),
§7.5 Q01 (offline/online matrix).
Callers: qa/robot/resources/common.resource (imported as a library), qa/robot/mobile/*.robot.
Each public function is a keyword: `load_network_profiles` is `Load Network Profiles` in Robot.
"""

import json
import os
import pathlib
import subprocess

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


def parse_flutter_results(path: str) -> dict:
    """Summarise a Flutter test run written with ``flutter test --machine`` (JSON lines).

    Args:
        path: file holding the JSON-lines output of ``flutter test integration_test --machine``.

    Returns:
        dict with ``passed``, ``failed``, ``skipped`` (int counts) and ``failures``
        (list of failing test names). Hidden tests (Flutter's setUp/tearDown wrappers) are ignored.

    Raises:
        FileNotFoundError: the file does not exist.
        json.JSONDecodeError: a line starting with ``{`` is not valid JSON.
    """
    names: dict[int, str] = {}
    summary = {"passed": 0, "failed": 0, "skipped": 0, "failures": []}
    with open(path, encoding="utf-8") as handle:
        # Flutter mixes plain build output into --machine logs; only JSON objects are events.
        events = [json.loads(line) for line in handle if line.lstrip().startswith("{")]
    for event in events:
        if event.get("type") == "testStart":
            names[event["test"]["id"]] = event["test"]["name"]
        elif event.get("type") == "testDone" and not event.get("hidden"):
            if event.get("skipped"):
                summary["skipped"] += 1
            elif event.get("result") == "success":
                summary["passed"] += 1
            else:
                summary["failed"] += 1
                summary["failures"].append(names.get(event["testID"], str(event["testID"])))
    return summary
