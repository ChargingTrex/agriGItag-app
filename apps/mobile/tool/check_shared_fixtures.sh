#!/usr/bin/env bash
# Shared-fixture identity check: the Dart preview rules are tested with byte-identical copies of the server's
# fixtures, so the Python engine and its Dart port answer the same cases (D-006 contract test).
# Requirement: plan §7.2 M03 "Contract test: same JSON fixtures produce identical outcomes in Dart and Python";
#   backend-design.md §4. Callers: CI mobile job; developers after changing a server fixture.
# Usage: apps/mobile/tool/check_shared_fixtures.sh
# Exit codes: 0 identical, 1 a copy differs or is missing (fix: copy the server file over the mobile one).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
MOBILE="$ROOT/apps/mobile/test/fixtures"

# server file → mobile copy (same base name)
SHARED=(
  "apps/api/tests/fixtures/grade_cases.json"
  "apps/api/agritrace/modules/quality/profiles/dry_chilli_agmark_v1.json"
  "apps/api/agritrace/seed/fixtures/gi_region_fixture.geojson"
)

status=0
for src in "${SHARED[@]}"; do
  copy="$MOBILE/$(basename "$src")"
  if ! cmp -s "$ROOT/$src" "$copy"; then
    echo "check_shared_fixtures: $copy differs from $src (run: cp $src apps/mobile/test/fixtures/)" >&2
    status=1
  fi
done
[ "$status" -eq 0 ] && echo "check_shared_fixtures: OK (${#SHARED[@]} files identical)"
exit "$status"
