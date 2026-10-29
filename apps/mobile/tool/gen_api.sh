#!/usr/bin/env bash
# Regenerates the Dart API client packages/agritrace_api from packages/openapi/openapi.json.
# Requirement: D-003 (clients generated from one OpenAPI contract), plan §7.2 M00 "gen_api.sh zero manual edits".
# Callers: developers after `make openapi`; the CI mobile job (followed by `git diff --exit-code`).
#
# GENERATED OUTPUT, NEVER EDIT BY HAND: everything under apps/mobile/packages/agritrace_api is deleted and
# rewritten by this script. To change the client, change the API (Pydantic models, route docstrings),
# run `make openapi`, then run this script and commit the result.
#
# Needs: Node (npx) and Java 11+ (openapi-generator is a Java tool; set JAVA_HOME if `java` on PATH is older,
# e.g. Android Studio's bundled JBR at "/Applications/Android Studio.app/Contents/jbr/Contents/Home").
# Usage: apps/mobile/tool/gen_api.sh   (from any working directory). Exit code non-zero on any failure.
set -euo pipefail

MOBILE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SPEC="$MOBILE_DIR/../../packages/openapi/openapi.json"
OUT="$MOBILE_DIR/packages/agritrace_api"
# Version of the npm wrapper; the generator jar version is pinned in apps/mobile/openapitools.json.
CLI_VERSION="2.42.0"

if [ -n "${JAVA_HOME:-}" ]; then
  export PATH="$JAVA_HOME/bin:$PATH"
fi
JAVA_MAJOR="$(java -version 2>&1 | awk -F'"' '/version/ {split($2, v, "."); print (v[1] == "1") ? v[2] : v[1]; exit}')"
if [ -z "$JAVA_MAJOR" ] || [ "$JAVA_MAJOR" -lt 11 ]; then
  echo "gen_api.sh: openapi-generator needs Java 11+, found '${JAVA_MAJOR:-none}'. Set JAVA_HOME." >&2
  exit 1
fi

# Start from an empty directory so operations removed from the spec also disappear from the client.
# The generator keeps an existing .openapi-generator-ignore, so seeding it is how the skip list takes effect
# (--ignore-file-override is not passed through reliably by the npm wrapper).
rm -rf "$OUT"
mkdir -p "$OUT"
cp "$MOBILE_DIR/tool/openapi-generator-ignore" "$OUT/.openapi-generator-ignore"

cd "$MOBILE_DIR"
npx --yes "@openapitools/openapi-generator-cli@$CLI_VERSION" generate \
  --input-spec "$SPEC" \
  --generator-name dart-dio \
  --output "$OUT" \
  --config "$MOBILE_DIR/tool/openapi-generator-config.yaml"

# built_value_generator writes the *.g.dart halves of the models; format so reruns produce identical bytes.
cd "$OUT"
dart pub get
dart run build_runner build
dart format . >/dev/null
echo "gen_api.sh: client written to $OUT"
