#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$ROOT_DIR/apps/android"
REQUIRED_JAVA_VERSION=17

log() {
  printf "[deploy-android] %s\n" "$*"
}

find_adb() {
  if command -v adb >/dev/null 2>&1; then
    command -v adb
    return 0
  fi

  for candidate in \
    "$ANDROID_SDK_ROOT/platform-tools/adb" \
    "$ANDROID_SDK_ROOT/platform-tools/adb.exe" \
    "$ANDROID_SDK_ROOT/platform-tools/adb.sh"; do
    if [ -x "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

error() {
  printf "[deploy-android][error] %s\n" "$*" >&2
  exit 1
}

if [ ! -d "$ANDROID_DIR" ]; then
  error "Android app not found at $ANDROID_DIR. Run scripts/bootstrap_android.sh first."
fi

if ! command -v mise >/dev/null 2>&1; then
  error "mise not found. Install mise from https://mise.jdx.dev/"
fi

log "Checking Java version..."
CURRENT_JAVA_VERSION=""
if command -v java >/dev/null 2>&1; then
  CURRENT_JAVA_VERSION=$(java -version 2>&1 | head -n 1 | sed 's/.*version "\?\([0-9]*\).*/\1/')
fi

if [ "$CURRENT_JAVA_VERSION" != "$REQUIRED_JAVA_VERSION" ]; then
  log "Java $REQUIRED_JAVA_VERSION required (found: ${CURRENT_JAVA_VERSION:-none}). Setting up via mise..."
  
  if ! mise list java 2>/dev/null | grep -q "java.*$REQUIRED_JAVA_VERSION"; then
    log "Installing Java $REQUIRED_JAVA_VERSION via mise..."
    cd "$ROOT_DIR"
    mise install java@$REQUIRED_JAVA_VERSION
    cd "$ANDROID_DIR"
  fi
  
  log "Java $REQUIRED_JAVA_VERSION configured via mise"
fi

cd "$ANDROID_DIR"

if [ ! -f "./gradlew" ]; then
  log "Gradle wrapper not found. Generating wrapper..."
  
  if ! mise list gradle 2>/dev/null | grep -q gradle; then
    log "Installing gradle via mise..."
    cd "$ROOT_DIR"
    mise install gradle@8.9
    cd "$ANDROID_DIR"
  fi
  
  log "Using mise to generate gradle wrapper..."
  cd "$ROOT_DIR"
  mise exec -- gradle wrapper --gradle-version 8.9 --project-dir "$ANDROID_DIR"
  cd "$ANDROID_DIR"
fi

log "Checking Android SDK location..."
ANDROID_SDK_ROOT=""

if [ -n "${ANDROID_HOME:-}" ]; then
  ANDROID_SDK_ROOT="$ANDROID_HOME"
elif [ -n "${ANDROID_SDK_ROOT:-}" ]; then
  ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
elif [ -d "$HOME/Library/Android/sdk" ]; then
  ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
elif [ -d "$HOME/Android/Sdk" ]; then
  ANDROID_SDK_ROOT="$HOME/Android/Sdk"
else
  error "Android SDK not found. Install Android Studio or set ANDROID_HOME environment variable."
fi

log "Using Android SDK at: $ANDROID_SDK_ROOT"

if [ ! -f "$ANDROID_DIR/local.properties" ]; then
log "Creating local.properties with SDK location..."
  echo "sdk.dir=$ANDROID_SDK_ROOT" > "$ANDROID_DIR/local.properties"
fi

log "Checking for connected devices/emulators..."
ADB_BIN="$(find_adb)" || error "adb not found. Install Android SDK Platform Tools."

DEVICE_COUNT=$("$ADB_BIN" devices | grep -v "List of devices" | grep -v "^$" | wc -l | tr -d ' ')
if [ "$DEVICE_COUNT" -eq 0 ]; then
  error "No Android devices or emulators connected. Start an emulator or connect a device."
fi

log "Installing app on device/emulator..."
mise exec -- "$ANDROID_DIR/gradlew" -p "$ANDROID_DIR" installDebug --info

log "Launching app..."
"$ADB_BIN" shell am start -n com.mealplanner.app/.MainActivity

log "App launched successfully. Check your device/emulator."
log "To view logs, run: $ADB_BIN logcat | grep -i mealplanner"
