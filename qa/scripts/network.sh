#!/usr/bin/env bash
# Switch the running Android emulator between network conditions through its console.
#
# Serves: plan §13 (4G brief G1-G6, BM-11..BM-16) and §7.5 Q00/Q01 (offline/online matrix).
# Callers: qa/robot/lib/agritrace_keywords.py (`Set Emulator Network`), Verifiers by hand.
#
# Usage:
#   qa/scripts/network.sh off               # mobile data and Wi-Fi off (same as `profile offline`)
#   qa/scripts/network.sh profile <name>    # normal_4g | weak_4g | edge | offline (qa/robot/profiles.yaml)
#
# Environment:
#   ANDROID_SERIAL  pick the emulator when several run (read by adb itself, e.g. emulator-5554)
#   PROFILES        alternative profiles file (default qa/robot/profiles.yaml)
#   QA_PYTHON       Python with PyYAML (default qa/.venv/bin/python, then python3)
#   DRY_RUN=1       print the adb commands instead of running them
#
# Exit codes: 0 ok; 1 adb or profile error; 2 usage error.
# Side effects: changes the emulator's network speed, delay, mobile data and Wi-Fi state.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROFILES="${PROFILES:-$ROOT/qa/robot/profiles.yaml}"
PY="${QA_PYTHON:-$ROOT/qa/.venv/bin/python}"
[[ -x "$PY" ]] || PY=python3

# Run one adb command, or print it when DRY_RUN is set.
# Args: the adb arguments. Returns: adb's exit code. Side effects: talks to the emulator.
run() {
  if [[ -n "${DRY_RUN:-}" ]]; then echo "+ adb $*"; else adb "$@"; fi
}

# Print "<up> <down> <delay_min> <delay_max> <on|off>" for a profile name.
# Args: $1 profile name. Returns: 0, or 1 with a message on stderr if the profile is unknown.
profile_values() {
  "$PY" -c '
import sys, yaml
profiles = yaml.safe_load(open(sys.argv[1]))["profiles"]
p = profiles.get(sys.argv[2])
if p is None:
    sys.exit(f"unknown profile {sys.argv[2]!r}; known: {sorted(profiles)}")
print(p["up_kbps"], p["down_kbps"], p["delay_min_ms"], p["delay_max_ms"], "on" if p["data"] else "off")
' "$PROFILES" "$1"
}

# Apply a named profile to the emulator.
# Args: $1 profile name. Returns: 0 on success. Side effects: Wi-Fi off, data on/off, speed and delay set.
apply_profile() {
  local vals up down dmin dmax data
  vals="$(profile_values "$1")"
  read -r up down dmin dmax data <<<"$vals"
  # Emulator images from API 25 on have a virtual Wi-Fi that would bypass `gsm data off`
  # and make the app see Wi-Fi instead of cellular, so every profile simulates cellular only.
  run shell svc wifi disable
  run emu gsm data "$data"
  if [[ "$data" == on ]]; then
    run emu network speed "$up:$down"
    run emu network delay "$dmin:$dmax"
  fi
  echo "network profile $1 applied (up ${up} kbps, down ${down} kbps, delay ${dmin}-${dmax} ms, data ${data})"
}

case "${1:-}" in
  off) apply_profile offline ;;
  profile)
    [[ -n "${2:-}" ]] || { echo "usage: $0 profile <name>" >&2; exit 2; }
    apply_profile "$2" ;;
  *) echo "usage: $0 off | profile <normal_4g|weak_4g|edge|offline>" >&2; exit 2 ;;
esac
