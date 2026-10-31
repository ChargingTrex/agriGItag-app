#!/usr/bin/env bash
# Farmer-UI lint: fails when a free-text input widget appears in a farmer feature or the farmer widget kit.
# Requirement: UserFlows §Design rules "Tap, never type" (farmers never see a free-text box); plan §7.2
#   ("no TextField in farmer features (lint script)"); M05 acceptance "no free TextField lint passes".
# Callers: CI mobile job; developers before pushing. Usage: apps/mobile/tool/no_textfield_lint.sh
# Exit codes: 0 clean, 1 farmer UI code uses a free-text field (offending lines are printed),
#   2 the check itself could not run.
set -euo pipefail

LIB="$(cd "$(dirname "$0")/.." && pwd)/lib"

# Farmer-facing feature folders (mobile-design.md §1) and the farmer widget kit in core/widgets (M05), which
# every farmer screen uses. Officer and QC features may use text fields. auth (M06) is here because farmers sign
# in on it too: the phone number, code and PIN come from the on-screen keypad.
FARMER_DIRS=()
for dir in "$LIB"/features/farmer_* "$LIB"/features/{auth,event_log,problem_report,sell,money,history,settings} \
  "$LIB"/core/widgets; do
  [ -d "$dir" ] && FARMER_DIRS+=("$dir")
done

if [ "${#FARMER_DIRS[@]}" -eq 0 ]; then
  echo "no_textfield_lint: no farmer folders under $LIB" >&2
  exit 2
fi

# Every Flutter widget that opens a keyboard for free text, matched as a whole identifier with explicit
# boundary classes (portable to BSD and GNU grep).
WIDGETS='TextField|TextFormField|CupertinoTextField|CupertinoSearchTextField|EditableText|SearchBar|SearchAnchor'
PATTERN="(^|[^A-Za-z0-9_])($WIDGETS)([^A-Za-z0-9_]|\$)"

# grep exits 0 on a match, 1 on none, 2 on an error (an error must not pass as "clean").
set +e
hits="$(grep -rnE --include='*.dart' "$PATTERN" "${FARMER_DIRS[@]}")"
rc=$?
set -e
if [ "$rc" -eq 0 ]; then
  echo "no_textfield_lint: free-text input in farmer UI code (use pictures, steppers or NumberPad):" >&2
  echo "$hits" >&2
  exit 1
elif [ "$rc" -ne 1 ]; then
  echo "no_textfield_lint: grep failed (exit $rc)" >&2
  exit 2
fi
echo "no_textfield_lint: OK (${#FARMER_DIRS[@]} farmer folders checked)"
