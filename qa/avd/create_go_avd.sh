#!/usr/bin/env bash
# Create the AgriTrace test emulators: the Android Go-class AVD (API 27) and the standard API 34 AVD.
#
# Serves: plan §7.5 Q00 (Go AVD profile: API 27, 2 GB RAM, 2 cores, 720x1280) and Q01 (API 34 AVD);
#         gate G3 ("offline/online matrix passes on Android Go emulator profile"), BM-01/02/11-14.
# Callers: Verifiers and the QA Lead by hand; later the mobile CI job (M00/Q01).
#
# Usage:
#   qa/avd/create_go_avd.sh            # Go-class API 27 AVD  -> agritrace_go_api27
#   qa/avd/create_go_avd.sh api34      # standard API 34 AVD  -> agritrace_std_api34
#
# Environment:
#   ANDROID_HOME / ANDROID_SDK_ROOT  SDK location (default ~/Library/Android/sdk on macOS, ~/Android/Sdk on Linux)
#   AVD_ABI                          override the image ABI (default x86_64 or arm64-v8a by host; API 27 uses x86 on Intel)
#   ANDROID_AVD_HOME                 AVD folder (default ~/.android/avd)
#
# Exit codes: 0 created (or manual steps printed when the SDK command-line tools are missing); 2 usage error.
# Side effects: downloads a system image with sdkmanager, creates or overwrites the AVD, edits its config.ini.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
if [[ -z "$SDK" ]]; then
  if [[ "$(uname)" == Darwin ]]; then SDK="$HOME/Library/Android/sdk"; else SDK="$HOME/Android/Sdk"; fi
fi
AVD_HOME="${ANDROID_AVD_HOME:-$HOME/.android/avd}"
if [[ "$(uname -m)" == arm64 || "$(uname -m)" == aarch64 ]]; then HOST_ABI=arm64-v8a; else HOST_ABI=x86_64; fi

case "${1:-go}" in
  go)
    NAME=agritrace_go_api27
    # API 27 Google APIs images ship x86 (not x86_64) for Intel hosts.
    ABI="${AVD_ABI:-$([[ $HOST_ABI == x86_64 ]] && echo x86 || echo arm64-v8a)}"
    IMAGE="system-images;android-27;google_apis;$ABI"
    DEVICE="Galaxy Nexus"   # 720x1280 xhdpi base device; the profile overrides the hardware anyway
    INI="$HERE/go_profile.ini" ;;
  api34)
    NAME=agritrace_std_api34
    ABI="${AVD_ABI:-$HOST_ABI}"
    IMAGE="system-images;android-34;google_apis;$ABI"
    DEVICE="pixel_6"
    INI="$HERE/api34_profile.ini" ;;
  *) echo "usage: $0 [go|api34]" >&2; exit 2 ;;
esac

# Find an Android command-line tool on PATH or in the SDK's cmdline-tools folder.
# Args: $1 tool name (sdkmanager or avdmanager). Returns: prints the path, exit 1 if not found.
find_tool() {
  command -v "$1" 2>/dev/null && return 0
  local candidate
  for candidate in "$SDK"/cmdline-tools/latest/bin/"$1" "$SDK"/cmdline-tools/*/bin/"$1" "$SDK"/tools/bin/"$1"; do
    [[ -x "$candidate" ]] && { echo "$candidate"; return 0; }
  done
  return 1
}

if ! SDKMANAGER="$(find_tool sdkmanager)" || ! AVDMANAGER="$(find_tool avdmanager)"; then
  cat <<EOF
sdkmanager/avdmanager not found (looked on PATH and in $SDK/cmdline-tools). Manual steps:

1. Android Studio > Settings > Languages & Frameworks > Android SDK > SDK Tools:
   tick "Android SDK Command-line Tools (latest)" and "Android Emulator", Apply.
   (Or download "Command line tools only" from https://developer.android.com/studio and unzip to
   $SDK/cmdline-tools/latest .)
2. $SDK/cmdline-tools/latest/bin/sdkmanager --install "$IMAGE" "platform-tools" "emulator"
3. echo no | $SDK/cmdline-tools/latest/bin/avdmanager create avd --force -n $NAME -k "$IMAGE" --device "$DEVICE"
4. In $AVD_HOME/$NAME.avd/config.ini set every key listed in
   $INI to the profile's value (edit the existing line, or add it when absent).
5. Start it: $SDK/emulator/emulator -avd $NAME -no-snapshot-load
6. Check: adb shell getprop ro.build.version.sdk   and   adb shell cat /proc/meminfo | head -1

Or re-run this script once step 1 is done.
EOF
  exit 0
fi

yes | "$SDKMANAGER" --licenses >/dev/null || true
"$SDKMANAGER" --install "$IMAGE" platform-tools emulator
echo no | "$AVDMANAGER" create avd --force -n "$NAME" -k "$IMAGE" --device "$DEVICE"

CFG="$AVD_HOME/$NAME.avd/config.ini"
KEYS="$(grep -E '^[a-z]' "$INI" | cut -d= -f1 | sed 's/$/=/')"
# Drop avdmanager's values for the keys the profile sets, then append the profile's values.
{ grep -v -F "$KEYS" "$CFG" || true; grep -E '^[a-z]' "$INI"; } >"$CFG.new"
mv "$CFG.new" "$CFG"

echo "Created AVD $NAME from $IMAGE with $(basename "$INI")."
echo "Start: $SDK/emulator/emulator -avd $NAME -no-snapshot-load"
