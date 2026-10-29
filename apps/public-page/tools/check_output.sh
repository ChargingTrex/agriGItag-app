#!/usr/bin/env bash
# Privacy-lint a built public page folder with the W02 canary strings.
#
# Purpose: run the project's single privacy linter (infra/scripts/privacy-lint.py, Q00) over built
#   output (index.html, data.json) and add every `value` in fixtures/canaries.json as --canary, so a
#   template or builder that prints a planted phone, Aadhaar, survey number, 6-dp pin or temp path fails.
# Requirements: BM-09 (privacy lint 0 hits), FR-16, plan §7.4 W02 ("canary fixture passes",
#   "injected phone fails CI"), CLAUDE.md §6.
# Callers: the public-page CI job, qa/robot/public/page.robot, apps/public-page/tests/test_render.py.
#
# Usage: tools/check_output.sh <out_dir>
# Exit codes: the linter's own: 0 no hits; 1 hits (path:line:col: rule: excerpt, leaks redacted);
#   2 bad arguments, missing folder or nothing to scan.
# Environment: PYTHON (default python3); the linter and this script need the standard library only.
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: $0 <out_dir>" >&2
  exit 2
fi
here="$(cd "$(dirname "$0")/.." && pwd)"
python="${PYTHON:-python3}"
args=()
# One canary per line; canary values never contain a newline.
while IFS= read -r value; do
  args+=(--canary "$value")
done < <("$python" -c 'import json, sys; print("\n".join(c["value"] for c in json.load(open(sys.argv[1], encoding="utf-8"))["canaries"]))' "$here/fixtures/canaries.json")
exec "$python" "$here/../../infra/scripts/privacy-lint.py" "$1" "${args[@]}"
