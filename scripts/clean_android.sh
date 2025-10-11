#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$ROOT_DIR/apps/android"
GRADLEW="$ANDROID_DIR/gradlew"

log() {
  printf "[clean-android] %s\n" "$*"
}

error() {
  printf "[clean-android][error] %s\n" "$*" >&2
  exit 1
}

ensure_gradle_wrapper() {
  if [ -x "$GRADLEW" ]; then
    return
  fi

  log "Gradle wrapper not found – generating wrapper (8.9)"
  if command -v mise >/dev/null 2>&1; then
    (cd "$ROOT_DIR" && mise install gradle@8.9 >/dev/null 2>&1 || true)
    (cd "$ROOT_DIR" && mise exec -- gradle wrapper --gradle-version 8.9 --project-dir "$ANDROID_DIR")
  elif command -v gradle >/dev/null 2>&1; then
    (cd "$ANDROID_DIR" && gradle wrapper --gradle-version 8.9)
  else
    error "Gradle wrapper missing and gradle not found. Install Gradle or mise."
  fi

  chmod +x "$GRADLEW"
}

ensure_sdk_location() {
  if [ -f "$ANDROID_DIR/local.properties" ]; then
    return
  fi

  local sdk_path=""
  if [ -n "${ANDROID_HOME:-}" ]; then
    sdk_path="$ANDROID_HOME"
  elif [ -n "${ANDROID_SDK_ROOT:-}" ]; then
    sdk_path="$ANDROID_SDK_ROOT"
  elif [ -d "$HOME/Library/Android/sdk" ]; then
    sdk_path="$HOME/Library/Android/sdk"
  elif [ -d "$HOME/Android/Sdk" ]; then
    sdk_path="$HOME/Android/Sdk"
  else
    error "Android SDK path not found. Set ANDROID_HOME or ANDROID_SDK_ROOT."
  fi

  log "Writing local.properties with sdk.dir"
  echo "sdk.dir=${sdk_path}" > "$ANDROID_DIR/local.properties"
}

ensure_java() {
  local required_major=17
  local current=""

  if command -v java >/dev/null 2>&1; then
    current=$(java -version 2>&1 | head -n1 | sed 's/.*version "\([0-9]*\).*/\1/')
  fi

  if [ "$current" != "$required_major" ]; then
    log "Java $required_major required (found: ${current:-none})."
    if command -v mise >/dev/null 2>&1; then
      if ! mise list java 2>/dev/null | grep -q "java.*$required_major"; then
        log "Installing java@$required_major via mise"
        (cd "$ROOT_DIR" && mise install java@$required_major)
      fi
      export JAVA_HOME="$(mise where java@$required_major)"
      export PATH="$JAVA_HOME/bin:$PATH"
    else
      log "Warning: Install Java $required_major and set JAVA_HOME to avoid Gradle issues."
    fi
  fi
}

log "Cleaning Android build artifacts..."
if [ ! -d "$ANDROID_DIR" ]; then
  error "Android project not found at $ANDROID_DIR"
fi

ensure_gradle_wrapper
ensure_sdk_location
ensure_java

(cd "$ROOT_DIR" && "$GRADLEW" -p "$ANDROID_DIR" clean >/dev/null)

log "✅ Android build artifacts removed (web bundle untouched)."
