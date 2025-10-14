#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$ROOT_DIR/apps/android"
GRADLEW="$ANDROID_DIR/gradlew"
GRADLE_TASK="${ANDROID_GRADLE_TASK:-assembleDebug}"
DERIVED_OUTPUT="$ANDROID_DIR/app/build/outputs/apk"

log() {
  printf "[build-android] %s\n" "$*"
}

error() {
  printf "[build-android][error] %s\n" "$*" >&2
  exit 1
}

ensure_android_project() {
  if [ ! -d "$ANDROID_DIR" ]; then
    error "Android project not found at $ANDROID_DIR"
  fi
  if [ ! -f "$ANDROID_DIR/settings.gradle.kts" ]; then
    error "Android project appears incomplete. Run scripts/bootstrap_android.sh or restore the project scaffolding."
  fi
}

ensure_gradle_wrapper() {
  if [ -x "$GRADLEW" ]; then
    return
  fi

  log "Gradle wrapper not found – ensuring Gradle 8.9 via mise (or system gradle)"

  if command -v mise >/dev/null 2>&1; then
    if ! mise list gradle 2>/dev/null | grep -q gradle; then
      log "Installing gradle@8.9 via mise"
      (cd "$ROOT_DIR" && mise install gradle@8.9)
    fi
    (cd "$ROOT_DIR" && mise exec -- gradle wrapper --gradle-version 8.9 --project-dir "$ANDROID_DIR")
  elif command -v gradle >/dev/null 2>&1; then
    (cd "$ANDROID_DIR" && gradle wrapper --gradle-version 8.9)
  else
    error "Gradle wrapper missing and no gradle executable found. Install Gradle or mise."
  fi

  chmod +x "$GRADLEW"
}

ensure_sdk_location() {
  local sdk_path=""

  if [ -n "${ANDROID_HOME:-}" ]; then
    sdk_path="$ANDROID_HOME"
  elif [ -n "${ANDROID_SDK_ROOT:-}" ]; then
    sdk_path="$ANDROID_SDK_ROOT"
  elif [ -d "$HOME/Library/Android/sdk" ]; then
    sdk_path="$HOME/Library/Android/sdk"
  elif [ -d "$HOME/Android/Sdk" ]; then
    sdk_path="$HOME/Android/Sdk"
  fi

  if [ -z "$sdk_path" ]; then
    error "Android SDK path not found. Set ANDROID_HOME or ANDROID_SDK_ROOT."
  fi

  if [ ! -f "$ANDROID_DIR/local.properties" ]; then
    log "Writing local.properties with SDK path"
    echo "sdk.dir=${sdk_path}" > "$ANDROID_DIR/local.properties"
  fi
}

ensure_java() {
  local required_major=17
  local current=""

  if command -v java >/dev/null 2>&1; then
    current=$(java -version 2>&1 | head -n1 | sed 's/.*version \"\([0-9]*\).*/\1/')
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

ensure_android_project

log "Step 1/2: Ensuring toolchain (Java, SDK, Gradle wrapper)"
ensure_java
ensure_gradle_wrapper
ensure_sdk_location

ASSET_INDEX="$ANDROID_DIR/app/src/main/assets/webapp/index.html"
if [ ! -f "$ASSET_INDEX" ]; then
  warn "Web bundle not found at $ASSET_INDEX"
  warn "Run 'just deploy-android' to rebuild and copy the web assets before building again."
fi

log "Step 2/2: Gradle task $GRADLE_TASK"
(cd "$ROOT_DIR" && "$GRADLEW" -p "$ANDROID_DIR" "$GRADLE_TASK")

log "✅ Android build complete."
if [ -d "$DERIVED_OUTPUT" ]; then
  log "Artifacts in: $DERIVED_OUTPUT"
fi
