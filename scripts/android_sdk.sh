#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$ROOT_DIR/meal_planner/android"
DEFAULT_AVD_NAME="${ANDROID_AVD_NAME:-MealPlanner_API_34}"
DEFAULT_AVD_DEVICE="${ANDROID_AVD_DEVICE:-pixel_6}"
DEFAULT_SYSTEM_IMAGE="${ANDROID_SYSTEM_IMAGE:-system-images;android-34;google_apis_playstore;arm64-v8a}"
REQUIRED_PACKAGES=(
  "platform-tools"
  "platforms;android-34"
  "build-tools;34.0.0"
  "emulator"
  "$DEFAULT_SYSTEM_IMAGE"
)

log() {
  printf "[android-sdk] %s\n" "$*"
}

warn() {
  printf "[android-sdk][warn] %s\n" "$*" >&2
}

error() {
  printf "[android-sdk][error] %s\n" "$*" >&2
  exit 1
}

detect_sdk_root() {
  if [ -n "${ANDROID_SDK_ROOT:-}" ]; then
    SDK_ROOT="${ANDROID_SDK_ROOT}"
  elif [ -n "${ANDROID_HOME:-}" ]; then
    SDK_ROOT="${ANDROID_HOME}"
  elif [ -d "$HOME/Library/Android/sdk" ]; then
    SDK_ROOT="$HOME/Library/Android/sdk"
  elif [ -d "$HOME/Android/Sdk" ]; then
    SDK_ROOT="$HOME/Android/Sdk"
  else
    error "Android SDK not found. Set ANDROID_SDK_ROOT or install Android Studio."
  fi

  if [ ! -d "$SDK_ROOT" ]; then
    error "Detected SDK path '$SDK_ROOT' does not exist."
  fi
}

ensure_cmdline_tools() {
  if [ -x "$SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" ]; then
    current_version="$("$SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" --version 2>/dev/null | head -n1)"
    if [[ "$current_version" =~ ^([0-9]+) ]]; then
      if [ "${BASH_REMATCH[1]}" -ge 13 ]; then
        return
      fi
      log "Existing cmdline-tools version ${BASH_REMATCH[1]} is outdated. Upgrading..."
    else
      return
    fi
  fi

  case "$(uname -s)" in
    Darwin)
      CT_URL="https://dl.google.com/android/repository/commandlinetools-mac-13114758_latest.zip"
      ;;
    Linux)
      CT_URL="https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip"
      ;;
    *)
      error "Unsupported OS for automatic commandline-tools installation"
      ;;
  esac

  if ! command -v curl >/dev/null 2>&1; then
    error "curl is required to download Android commandline-tools"
  fi
  if ! command -v unzip >/dev/null 2>&1; then
    error "unzip is required to extract Android commandline-tools"
  fi

  log "Downloading Android SDK commandline-tools..."
  TMP_DIR="$(mktemp -d)"
  ARCHIVE="$TMP_DIR/cmdline-tools.zip"
  curl -fsSL "$CT_URL" -o "$ARCHIVE"

  log "Extracting commandline-tools to $SDK_ROOT/cmdline-tools/latest"
  mkdir -p "$SDK_ROOT/cmdline-tools"
  unzip -q -o "$ARCHIVE" -d "$TMP_DIR"
  rm -rf "$SDK_ROOT/cmdline-tools/latest"
  if [ -d "$TMP_DIR/cmdline-tools" ]; then
    mv "$TMP_DIR/cmdline-tools" "$SDK_ROOT/cmdline-tools/latest"
  else
    mv "$TMP_DIR"/* "$SDK_ROOT/cmdline-tools/latest"
  fi
  rm -rf "$TMP_DIR"
}

search_within() {
  local base="$1" name="$2"
  if [ -d "$base" ]; then
    if command -v rg >/dev/null 2>&1; then
      rg --files -g "$name" "$base" 2>/dev/null | head -n 1
    else
      find "$base" -maxdepth 5 -type f -name "$name" 2>/dev/null | head -n 1
    fi
  fi
}

find_tool() {
  local tool="$1"
  if command -v "$tool" >/dev/null 2>&1; then
    command -v "$tool"
    return 0
  fi

  local candidate
  case "$tool" in
    emulator)
      candidate="$SDK_ROOT/emulator/emulator"
      if [ -x "$candidate" ]; then
        printf '%s\n' "$candidate"
        return 0
      fi
      ;;
    *)
      for candidate in \
        "$SDK_ROOT/cmdline-tools/latest/bin/$tool" \
        "$SDK_ROOT/cmdline-tools/bin/$tool" \
        "$SDK_ROOT/tools/bin/$tool" \
        "$SDK_ROOT/tools/$tool"; do
        if [ -x "$candidate" ]; then
          printf '%s\n' "$candidate"
          return 0
        fi
      done

      local platform="$(uname -s)"
      local fallback=""
      case "$platform" in
        Darwin)
          fallback=$(search_within "/Applications/Android Studio.app" "$tool")
          ;;
        Linux)
          fallback=$(search_within "/opt/android-studio" "$tool")
          ;;
      esac
      if [ -z "$fallback" ]; then
        fallback=$(search_within "$SDK_ROOT" "$tool")
      fi
      if [ -n "$fallback" ] && [ -x "$fallback" ]; then
        printf '%s\n' "$fallback"
        return 0
      fi
      ;;
  esac

  return 1
}

ensure_local_properties() {
  local properties="$ANDROID_DIR/local.properties"
  if [ ! -d "$ANDROID_DIR" ]; then
    error "Android project not found at $ANDROID_DIR"
  fi

  if [ ! -f "$properties" ]; then
    log "Creating local.properties with sdk.dir=$SDK_ROOT"
    printf 'sdk.dir=%s\n' "$SDK_ROOT" > "$properties"
  fi
}

accept_licenses() {
  local sdkmanager
  ensure_cmdline_tools
  sdkmanager="$(find_tool sdkmanager)" || error "sdkmanager not found even after installing commandline-tools"
  "$sdkmanager" --sdk_root="$SDK_ROOT" --licenses >/dev/null 2>&1 <<<'y' || true
}

ensure_packages() {
  local sdkmanager
  ensure_cmdline_tools
  sdkmanager="$(find_tool sdkmanager)" || error "sdkmanager not found even after installing commandline-tools"

  log "Ensuring required SDK packages are installed..."
  "$sdkmanager" --sdk_root="$SDK_ROOT" --install "${REQUIRED_PACKAGES[@]}" >/dev/null <<<'y' || true
}

ensure_avd() {
  local avdmanager
  ensure_cmdline_tools
  avdmanager="$(find_tool avdmanager)" || error "avdmanager not found even after installing commandline-tools"

  if "$avdmanager" list avd | grep -q "$DEFAULT_AVD_NAME"; then
    log "AVD '$DEFAULT_AVD_NAME' already exists."
    return
  fi

  log "Creating Android Virtual Device '$DEFAULT_AVD_NAME'..."
  yes | "$avdmanager" create avd \
    --force \
    --name "$DEFAULT_AVD_NAME" \
    --device "$DEFAULT_AVD_DEVICE" \
    --package "$DEFAULT_SYSTEM_IMAGE" \
    --abi "arm64-v8a"
}

launch_emulator() {
  local emulator_bin
  emulator_bin="$(find_tool emulator)" || error "emulator binary not found. Ensure the Android Emulator package is installed."

  ensure_avd
  log "Launching emulator '$DEFAULT_AVD_NAME'..."
  "$emulator_bin" -avd "$DEFAULT_AVD_NAME" "$@" &
  disown || true
}

launch_studio() {
  if open -Ra "Android Studio"; then
    log "Opening Android Studio with project at $ANDROID_DIR"
    open -a "Android Studio" "$ANDROID_DIR"
  elif command -v studio >/dev/null 2>&1; then
    log "Launching Android Studio via 'studio' command..."
    studio "$ANDROID_DIR" >/dev/null 2>&1 &
    disown || true
  else
    error "Android Studio not found. Install it from https://developer.android.com/studio."
  fi
}

doctor() {
  log "Android SDK root: $SDK_ROOT"
  log "Required packages:"
  for pkg in "${REQUIRED_PACKAGES[@]}"; do
    log "  - $pkg"
  done

  log ""
  log "Installed SDK packages:"
  local sdkmanager
  if sdkmanager="$(find_tool sdkmanager)"; then
    "$sdkmanager" --sdk_root="$SDK_ROOT" --list | sed -n '/Installed packages:/,/Available Packages:/p' | sed 's/^/    /'
  else
    warn "sdkmanager not available; cannot list installed packages."
  fi

  log ""
  log "Available AVDs:"
  local avdmanager
  if avdmanager="$(find_tool avdmanager)"; then
    "$avdmanager" list avd | sed 's/^/    /'
  else
    warn "avdmanager not available; cannot list AVDs."
  fi
}

usage() {
  cat <<'EOF'
Usage: android_sdk.sh [command]

Commands:
  studio         Ensure tooling and open Android Studio (default)
  ensure         Install required SDK packages
  avd            Create the default MealPlanner AVD if missing
  emulator       Launch the default MealPlanner AVD
  doctor         Print SDK / AVD diagnostics
  help           Show this help message

Environment overrides:
  ANDROID_SDK_ROOT     Android SDK location (auto-detected if unset)
  ANDROID_AVD_NAME     Default: MealPlanner_API_34
  ANDROID_AVD_DEVICE   Default: pixel_6
  ANDROID_SYSTEM_IMAGE Default: system-images;android-34;google_apis_playstore;arm64-v8a
EOF
}

main() {
  detect_sdk_root
  ensure_local_properties

  local cmd="${1:-studio}"
  shift || true

  case "$cmd" in
    studio)
      ensure_packages
      launch_studio
      ;;
    ensure)
      accept_licenses
      ensure_packages
      ;;
    avd)
      ensure_packages
      ensure_avd
      ;;
    emulator)
      ensure_packages
      launch_emulator "$@"
      ;;
    doctor)
      doctor
      ;;
    help|-h|--help)
      usage
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
