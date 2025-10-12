#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEBAPP_DIST="$ROOT_DIR/apps/web/dist"
IOS_WEBAPP="$ROOT_DIR/apps/ios/Resources/webapp"

log() {
  printf "[deploy-ios] %s\n" "$*"
}

if [ ! -d "$WEBAPP_DIST" ]; then
  echo "Error: webapp build output not found at $WEBAPP_DIST"
  echo "Run 'just build-bundle' or 'pnpm build:web' first"
  exit 1
fi

log "Removing old webapp resources..."
rm -rf "$IOS_WEBAPP"

log "Copying built webapp to Resources/webapp..."
mkdir -p "$IOS_WEBAPP"
cp -r "$WEBAPP_DIST"/. "$IOS_WEBAPP"/

log "✅ Webapp deployed to iOS Resources at $IOS_WEBAPP"
