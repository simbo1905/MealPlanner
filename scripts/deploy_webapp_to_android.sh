#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEBAPP_DIST="$ROOT_DIR/apps/web/dist"
ANDROID_WEBAPP="$ROOT_DIR/apps/android/app/src/main/assets/web"

log() {
  printf "[deploy-android] %s\n" "$*"
}

if [ ! -d "$WEBAPP_DIST" ]; then
  echo "Error: webapp build output not found at $WEBAPP_DIST"
  echo "Run 'just build-bundle' or 'pnpm build:web' first"
  exit 1
fi

log "Removing old webapp assets..."
rm -rf "$ANDROID_WEBAPP"

log "Copying built webapp to assets/web..."
mkdir -p "$ANDROID_WEBAPP"
cp -r "$WEBAPP_DIST"/. "$ANDROID_WEBAPP"/

log "✅ Webapp deployed to Android assets at $ANDROID_WEBAPP"
log ""
log "Note: Assumes Android module path 'app/src/main/assets/web'"
log "Adjust ANDROID_WEBAPP variable if your module structure differs"
