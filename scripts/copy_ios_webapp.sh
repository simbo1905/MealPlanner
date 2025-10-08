#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEBAPP_OUT="$ROOT_DIR/apps/ios/webapp/out"
RESOURCES_WEBAPP="$ROOT_DIR/apps/ios/Resources/webapp"

log() {
  printf "[copy-webapp] %s\n" "$*"
}

if [ ! -d "$WEBAPP_OUT" ]; then
  echo "Error: webapp build output not found at $WEBAPP_OUT"
  echo "Run ./scripts/build_ios_webapp.sh first"
  exit 1
fi

log "Removing old webapp resources..."
rm -rf "$RESOURCES_WEBAPP"

log "Copying built webapp to Resources/webapp..."
mkdir -p "$RESOURCES_WEBAPP"
cp -r "$WEBAPP_OUT"/* "$RESOURCES_WEBAPP/"

log "Webapp copied successfully to $RESOURCES_WEBAPP"
