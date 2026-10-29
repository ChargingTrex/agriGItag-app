#!/usr/bin/env bash
# App size budget check: builds the release prod arm64 APK and checks its size.
# Requirement: D-002 and plan §13 D1 (100 MB hard ceiling, 30 MB download target), plan §7.2 M00
#   ("arm64 APK < 15 MB at skeleton": run with MAX_MB=15) and M13 (target <= 40 MB).
# Callers: CI mobile job (skipped when no Android SDK); Verifiers. Usage:
#   apps/mobile/tool/size_check.sh                 # fail > 100 MB, warn > 40 MB
#   MAX_MB=15 apps/mobile/tool/size_check.sh       # stricter ceiling, e.g. the M00 skeleton gate
# Exit codes: 0 within budget (or skipped: no Android SDK), 1 over budget or build failed.
# Side effects: writes build/ (run `flutter clean` afterwards on small disks).
set -euo pipefail

MAX_MB="${MAX_MB:-100}"
WARN_MB="${WARN_MB:-40}"
cd "$(dirname "$0")/.."

if [ -z "${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}" ] && [ ! -d "$HOME/Library/Android/sdk" ] && [ ! -d "$HOME/Android/Sdk" ]; then
  echo "size_check: SKIPPED, no Android SDK found (set ANDROID_HOME)."
  exit 0
fi

# DECISION D-002: the per-ABI arm64 APK is the number checked; it is what a pilot phone downloads from an
# APK side-load and is close to the Play per-device download.
#   ADV: one deterministic number per build, no Play account needed.
#   COMPROMISE: the true Play download (AAB device split) is only measured when bundletool is installed.
# API_BASE_URL is required by the prod flavor at run time only; a placeholder is enough for a size build.
# --split-debug-info moves Dart symbols out of libapp.so into build/symbols (kept for crash symbolication);
# release builds must use the same flags, or this number does not describe what ships.
flutter build apk --release --split-per-abi --target-platform android-arm64 -t lib/main_prod.dart \
  --split-debug-info=build/symbols --dart-define=API_BASE_URL=https://api.invalid

APK="build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
BYTES="$(wc -c < "$APK" | tr -d ' ')"
MB="$(awk -v b="$BYTES" 'BEGIN { printf "%.2f", b / 1048576 }')"
echo "size_check: arm64-v8a release APK = $MB MB ($BYTES bytes); ceiling $MAX_MB MB, warning $WARN_MB MB"

if command -v bundletool >/dev/null 2>&1; then
  flutter build appbundle --release -t lib/main_prod.dart --split-debug-info=build/symbols \
    --dart-define=API_BASE_URL=https://api.invalid
  bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab \
    --output=build/size_check.apks --overwrite
  echo "size_check: AAB download size per device config (bytes):"
  bundletool get-size total --apks=build/size_check.apks --dimensions=ABI
else
  echo "size_check: bundletool not on PATH, AAB download size not measured (plan §13 D1 target 30 MB)."
fi

if awk -v m="$MB" -v max="$MAX_MB" 'BEGIN { exit !(m > max) }'; then
  echo "size_check: FAIL, $MB MB exceeds $MAX_MB MB" >&2
  exit 1
fi
if awk -v m="$MB" -v warn="$WARN_MB" 'BEGIN { exit !(m > warn) }'; then
  echo "size_check: WARNING, $MB MB exceeds the $WARN_MB MB target"
fi
echo "size_check: OK"
