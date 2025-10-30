#!/usr/bin/env bash
set -euo pipefail

# Minimal per-worktree setup without downloads.
# - Names the Android Studio workspace after the worktree folder
# - Ensures android/local.properties points at existing SDK path

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORKTREE_NAME="$(basename "$(dirname "$PROJECT_ROOT")")"
IDEA_DIR="$PROJECT_ROOT/.idea"
ANDROID_DIR="$PROJECT_ROOT/android"
LP_FILE="$ANDROID_DIR/local.properties"

echo "[worktree] Project: $PROJECT_ROOT"
echo "[worktree] Worktree name: $WORKTREE_NAME"

# 1) Create/update Android Studio workspace name (not checked in)
mkdir -p "$IDEA_DIR"
echo "$WORKTREE_NAME" > "$IDEA_DIR/.name"
echo "[worktree] Wrote $IDEA_DIR/.name"

# 2) Reuse existing SDK paths
if [[ -f "$LP_FILE" ]]; then
  echo "[worktree] Using existing $LP_FILE"
else
  # Try to reuse SDK from default install; do NOT download anything
  if [[ "$(uname -s)" == "Darwin" ]]; then
    SDK_PATH_DEFAULT="$HOME/Library/Android/sdk"
  else
    SDK_PATH_DEFAULT="$HOME/Android/Sdk"
  fi
  {
    echo "sdk.dir=$SDK_PATH_DEFAULT"
    # If flutter.sdk is already set globally in your previous worktree, Android Studio will pick it up from env/plugins
    # You can uncomment and set a custom path if needed:
    # echo "flutter.sdk=/opt/homebrew/share/flutter"
  } > "$LP_FILE"
  echo "[worktree] Created $LP_FILE with sdk.dir=$SDK_PATH_DEFAULT"
fi

echo "[worktree] Done. Open the project in Android Studio:"
echo "           $PROJECT_ROOT"
echo "           and select an emulator in Device Manager, then Run."

