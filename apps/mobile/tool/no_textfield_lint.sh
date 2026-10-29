#!/usr/bin/env bash
# Farmer-UI lint: fails when a free-text input (TextField / TextFormField) appears in a farmer feature.
# Requirement: UserFlows §Design rules "Tap, never type" (farmers never see a free-text box); plan §7.2
#   ("no TextField in farmer features (lint script)"); M05 acceptance "no free TextField lint passes".
# Callers: CI mobile job; developers before pushing. Usage: apps/mobile/tool/no_textfield_lint.sh
# Exit codes: 0 clean, 1 a farmer feature uses a free-text field (offending lines are printed),
#   2 the check itself could not run.
set -euo pipefail

LIB="$(cd "$(dirname "$0")/.." && pwd)/lib"

# Farmer-facing feature folders (mobile-design.md §1). Officer and QC features may use text fields.
FARMER_DIRS=()
for dir in "$LIB"/features/farmer_* "$LIB"/features/{event_log,problem_report,sell,money,history,settings}; do
  [ -d "$dir" ] && FARMER_DIRS+=("$dir")
done

if [ "${#FARMER_DIRS[@]}" -eq 0 ]; then
  echo "no_textfield_lint: no farmer feature folders under $LIB/features" >&2
  exit 2
fi

# grep exits 0 on a match, 1 on none, 2 on an error (an error must not pass as "clean").
set +e
hits="$(grep -rnwE --include='*.dart' 'TextField|TextFormField|CupertinoTextField' "${FARMER_DIRS[@]}")"
rc=$?
set -e
if [ "$rc" -eq 0 ]; then
  echo "no_textfield_lint: free-text input in a farmer feature (use pictures, steppers or NumberPad):" >&2
  echo "$hits" >&2
  exit 1
elif [ "$rc" -ne 1 ]; then
  echo "no_textfield_lint: grep failed (exit $rc)" >&2
  exit 2
fi
echo "no_textfield_lint: OK (${#FARMER_DIRS[@]} farmer feature folders checked)"
