#!/usr/bin/env bash
# App size budget check: builds the release prod arm64 APK and checks its size; checks the per-device AAB
# download size too when bundletool is installed.
# Requirement: D-002 and plan §13 D1 (100 MB hard ceiling, 30 MB download target), M13 (target <= 40 MB).
# Callers: CI mobile job (skipped when no Android SDK); Verifiers. Usage: apps/mobile/tool/size_check.sh
#   Overrides: MAX_MB (fail, default 100), WARN_MB (warn, default 40), AAB_MAX_MB (fail, default 30).
# Units: all sizes are MiB (1 MiB = 1,048,576 bytes) and printed as "MiB".
# Exit codes: 0 within budget (or skipped: no Android SDK), 1 over budget or build failed.
# Side effects: writes build/ (run `flutter clean` afterwards on small disks).
set -euo pipefail

MAX_MB="${MAX_MB:-100}"
WARN_MB="${WARN_MB:-40}"
AAB_MAX_MB="${AAB_MAX_MB:-30}"
cd "$(dirname "$0")/.."

if [ -z "${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}" ] && [ ! -d "$HOME/Library/Android/sdk" ] && [ ! -d "$HOME/Android/Sdk" ]; then
  echo "size_check: SKIPPED, no Android SDK found (set ANDROID_HOME)."
  exit 0
fi

# Prints bytes as MiB with two decimals. $1: byte count.
mib() { awk -v b="$1" 'BEGIN { printf "%.2f", b / 1048576 }'; }
# Exit status 0 when $1 > $2 (decimal compare).
gt() { awk -v a="$1" -v b="$2" 'BEGIN { exit !(a > b) }'; }

# DECISION D-002: the per-ABI arm64 APK is the number checked, in MiB; it is what a pilot phone downloads from
# an APK side-load. The AAB device download (what Play sends) is checked when bundletool is installed.
#   ADV: one deterministic number per build, no Play account needed; one unit everywhere (MiB).
#   COMPROMISE: without bundletool the 30 MB download target is reported as unmeasured, not checked.
# API_BASE_URL is required by the prod flavor at run time only; a placeholder is enough for a size build.
# --split-debug-info moves Dart symbols out of libapp.so into build/symbols (kept for crash symbolication);
# release builds must use the same flags, or this number does not describe what ships.
flutter build apk --release --split-per-abi --target-platform android-arm64 -t lib/main_prod.dart \
  --split-debug-info=build/symbols --dart-define=API_BASE_URL=https://api.invalid

APK="build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
BYTES="$(wc -c < "$APK" | tr -d ' ')"
MB="$(mib "$BYTES")"
echo "size_check: arm64-v8a release APK = $MB MiB ($BYTES bytes); fail > $MAX_MB MiB, warn > $WARN_MB MiB"

FAIL=0
if gt "$MB" "$MAX_MB"; then
  echo "size_check: FAIL, APK $MB MiB exceeds $MAX_MB MiB" >&2
  FAIL=1
elif gt "$MB" "$WARN_MB"; then
  echo "size_check: WARNING, APK $MB MiB exceeds the $WARN_MB MiB target"
fi

if command -v bundletool >/dev/null 2>&1; then
  flutter build appbundle --release -t lib/main_prod.dart --split-debug-info=build/symbols \
    --dart-define=API_BASE_URL=https://api.invalid
  bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab \
    --output=build/size_check.apks --overwrite
  # CSV "ABI,MIN,MAX" (bytes); the largest MAX is the worst-case device download.
  AAB_BYTES="$(bundletool get-size total --apks=build/size_check.apks --dimensions=ABI \
    | awk -F, 'NR > 1 && $NF > max { max = $NF } END { print max + 0 }')"
  AAB_MB="$(mib "$AAB_BYTES")"
  echo "size_check: AAB largest per-device download = $AAB_MB MiB ($AAB_BYTES bytes); fail > $AAB_MAX_MB MiB"
  if gt "$AAB_MB" "$AAB_MAX_MB"; then
    echo "size_check: FAIL, AAB download $AAB_MB MiB exceeds $AAB_MAX_MB MiB" >&2
    FAIL=1
  fi
else
  echo "size_check: AAB download size unmeasured (bundletool not on PATH; target $AAB_MAX_MB MiB, plan §13 D1)."
fi

[ "$FAIL" -eq 0 ] && echo "size_check: OK"
exit "$FAIL"
