#!/usr/bin/env bash
set -euo pipefail

# Android SDK/AVD bootstrapper for MealPlanner worktrees
# - Idempotent: safe to run multiple times
# - Does NOT check in machine-specific settings
# - Updates android/local.properties for the current host
#
# Usage examples:
#   scripts/android_sdk.sh doctor
#   scripts/android_sdk.sh configure-local-properties
#   scripts/android_sdk.sh install-sdk
#   scripts/android_sdk.sh create-avd
#   scripts/android_sdk.sh start-avd [--headless]
#   scripts/android_sdk.sh wait-for-boot
#   scripts/android_sdk.sh stop-avd

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_DIR="$PROJECT_ROOT/android"

# Defaults per host OS
OS_NAME="$(uname -s)"
if [[ "${ANDROID_SDK_ROOT:-}" == "" ]]; then
  if [[ "$OS_NAME" == "Darwin" ]]; then
    export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
  else
    export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
  fi
fi

# Prefer latest cmdline-tools layout
SDKMANAGER="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager"
AVDMANAGER="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/avdmanager"
if [[ ! -x "$SDKMANAGER" ]]; then
  # Fallback to legacy path if a dev has older tools
  SDKMANAGER="$ANDROID_SDK_ROOT/tools/bin/sdkmanager"
  AVDMANAGER="$ANDROID_SDK_ROOT/tools/bin/avdmanager"
fi

EMULATOR_BIN="$ANDROID_SDK_ROOT/emulator/emulator"
ADB_BIN="$ANDROID_SDK_ROOT/platform-tools/adb"

# Sensible defaults for Apple Silicon / modern Android
ANDROID_API="${ANDROID_API:-36}"
ABI="${ABI:-arm64-v8a}"
IMG_FLAVOR="${IMG_FLAVOR:-google_apis}"
AVD_NAME="${AVD_NAME:-mp_phone_api_${ANDROID_API}}"
SYS_IMAGE="system-images;android-${ANDROID_API};${IMG_FLAVOR};${ABI}"

log() { echo "[android-sdk] $*"; }
err() { echo "[android-sdk][ERROR] $*" >&2; }

require_bin() {
  if ! command -v "$1" >/dev/null 2>&1; then
    err "Missing binary: $1. Ensure Flutter/Android Studio is installed and in PATH."; exit 1;
  fi
}

doctor() {
  log "OS: $OS_NAME"
  log "PROJECT_ROOT: $PROJECT_ROOT"
  log "ANDROID_SDK_ROOT: $ANDROID_SDK_ROOT"
  log "AVD_NAME: $AVD_NAME  (API $ANDROID_API, $IMG_FLAVOR, $ABI)"
  command -v flutter >/dev/null && flutter --version || true
  command -v java >/dev/null && java -version || true
  [[ -x "$SDKMANAGER" ]] && "$SDKMANAGER" --list | head -n 5 || err "sdkmanager not found at $SDKMANAGER"
  [[ -x "$EMULATOR_BIN" ]] && "$EMULATOR_BIN" -version | head -n 1 || err "emulator not found at $EMULATOR_BIN"
  [[ -x "$ADB_BIN" ]] && "$ADB_BIN" version || err "adb not found at $ADB_BIN"
}

configure_local_properties() {
  mkdir -p "$ANDROID_DIR"
  local lp="$ANDROID_DIR/local.properties"
  # Preserve flutter.* keys if present; update only sdk.dir
  local tmp
  tmp="$(mktemp)"
  if [[ -f "$lp" ]]; then
    # Replace or append sdk.dir
    if grep -q '^sdk.dir=' "$lp"; then
      sed -E "s|^sdk.dir=.*$|sdk.dir=${ANDROID_SDK_ROOT//\/\\/}|" "$lp" > "$tmp"
    else
      cat "$lp" > "$tmp"
      echo "sdk.dir=$ANDROID_SDK_ROOT" >> "$tmp"
    fi
  else
    cat > "$tmp" <<EOF
sdk.dir=$ANDROID_SDK_ROOT
flutter.buildMode=debug
EOF
  fi
  mv "$tmp" "$lp"
  log "Updated $lp with sdk.dir=$ANDROID_SDK_ROOT"
}

accept_licenses() {
  require_bin yes || true
  if [[ -x "$SDKMANAGER" ]]; then
    yes | "$SDKMANAGER" --licenses >/dev/null || true
  else
    err "sdkmanager not found; skipping license acceptance"
  fi
}

install_sdk() {
  if [[ ! -x "$SDKMANAGER" ]]; then
    err "sdkmanager not found. Install Android Studio or the commandline-tools first."; exit 1
  fi
  log "Installing platform-tools, emulator, platform and build-tools..."
  "$SDKMANAGER" \
    "platform-tools" \
    "emulator" \
    "platforms;android-${ANDROID_API}" \
    "build-tools;35.0.0" || true

  log "Installing system image: $SYS_IMAGE"
  "$SDKMANAGER" "$SYS_IMAGE" || true

  accept_licenses
}

create_avd() {
  if "$AVDMANAGER" list avd | grep -q "Name: ${AVD_NAME}"; then
    log "AVD ${AVD_NAME} already exists."
    return
  fi
  log "Creating AVD ${AVD_NAME} with ${SYS_IMAGE}"
  echo "no" | "$AVDMANAGER" create avd -n "$AVD_NAME" -k "$SYS_IMAGE" -d pixel_6 || true
}

start_avd() {
  local headless=0
  [[ "${1:-}" == "--headless" ]] && headless=1
  local args=(-avd "$AVD_NAME" -no-snapshot -netdelay none -netspeed full)
  if [[ $headless -eq 1 ]]; then
    args+=(-no-boot-anim -no-audio -no-window)
  fi
  log "Starting emulator ${AVD_NAME} (headless=$headless)"
  "$EMULATOR_BIN" "${args[@]}" >/tmp/emulator_${AVD_NAME}.log 2>&1 & echo $! > /tmp/emulator_${AVD_NAME}.pid
  log "Emulator PID $(cat /tmp/emulator_${AVD_NAME}.pid)"
}

wait_for_boot() {
  require_bin "$ADB_BIN"
  log "Waiting for emulator to appear in adb..."
  "$ADB_BIN" wait-for-device
  log "Waiting for sys.boot_completed=1 and bootanim=stopped..."
  for i in {1..60}; do
    local booted anim
    booted=$("$ADB_BIN" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r') || true
    anim=$("$ADB_BIN" shell getprop init.svc.bootanim 2>/dev/null | tr -d '\r') || true
    log "probe $i: boot_completed='${booted:-?}' bootanim='${anim:-?}'"
    if [[ "$booted" == "1" && "$anim" == "stopped" ]]; then
      log "Emulator boot complete"
      return
    fi
    sleep 5
  done
  err "Timeout waiting for emulator boot"
  exit 1
}

stop_avd() {
  if [[ -f /tmp/emulator_${AVD_NAME}.pid ]]; then
    local pid
    pid="$(cat /tmp/emulator_${AVD_NAME}.pid)"
    log "Stopping emulator PID $pid"
    kill "$pid" 2>/dev/null || true
    rm -f /tmp/emulator_${AVD_NAME}.pid || true
  fi
  # Also try graceful adb shutdown
  "$ADB_BIN" emu kill 2>/dev/null || true
}

case "${1:-}" in
  doctor) doctor ;;
  configure-local-properties) configure_local_properties ;;
  install-sdk) install_sdk ;;
  accept-licenses) accept_licenses ;;
  create-avd) create_avd ;;
  start-avd) shift || true; start_avd "${1:-}" ;;
  wait-for-boot) wait_for_boot ;;
  stop-avd) stop_avd ;;
  *)
    cat <<EOF
Android SDK/AVD helper

Commands:
  doctor                      Print tool versions and quick status
  configure-local-properties  Update android/local.properties with current SDK path
  install-sdk                 Install platform-tools, emulator, platforms, build-tools, system image
  accept-licenses             Accept all Android SDK licenses
  create-avd                  Create default AVD (
                              name=
                                ${AVD_NAME}, image=${SYS_IMAGE})
  start-avd [--headless]      Start the AVD (writes /tmp/emulator_${AVD_NAME}.pid)
  wait-for-boot               Wait until sys.boot_completed=1 and bootanim=stopped
  stop-avd                    Kill emulator process and adb instance

Environment overrides:
  ANDROID_SDK_ROOT   Path to Android SDK (default macOS: ~/Library/Android/sdk)
  ANDROID_API        Android API level (default: ${ANDROID_API})
  ABI                CPU ABI (default: ${ABI})
  IMG_FLAVOR         Image flavor: google_apis or default (default: ${IMG_FLAVOR})
  AVD_NAME           Emulator name (default: ${AVD_NAME})
EOF
    ;;
esac

