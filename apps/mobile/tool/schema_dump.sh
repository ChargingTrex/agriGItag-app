#!/usr/bin/env bash
# Regenerates the Drift code and the committed schema dump after a schema change.
# Requirement: mobile-design.md §2 ("Schema dump test from day one"); WP-M01 migrations.
# Callers: developers after editing lib/core/db/tables/** (then bump AppDatabase.schemaVersion first);
#   test/db/schema_test.dart fails until this has been run. Usage: apps/mobile/tool/schema_dump.sh
# Writes: lib/core/db/**/*.g.dart, test/db/drift_schemas/drift_schema_v<N>.json, test/db/generated/*.dart.
set -euo pipefail

cd "$(dirname "$0")/.."

# Use the Flutter SDK's dart: a standalone `dart` on PATH cannot resolve flutter_test.
DART="$(dirname "$(readlink -f "$(command -v flutter)")")/dart"

# --force-jit: the AOT-compiled build script fails on some hosts; JIT is slower to start but always works.
"$DART" run build_runner build --force-jit
"$DART" run drift_dev schema dump lib/core/db/database.dart test/db/drift_schemas/
"$DART" run drift_dev schema generate test/db/drift_schemas/ test/db/generated/
# build_runner writes at width 80; the project formats at 120 (CI runs dart format --set-exit-if-changed).
"$DART" format lib/core/db test/db >/dev/null
echo "schema_dump: done. Commit the .g.dart files, the new dump and test/db/generated/."
