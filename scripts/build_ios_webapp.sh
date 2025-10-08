#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEBAPP_DIR="$ROOT_DIR/apps/ios/webapp"

log() {
  printf "[build-ios-webapp] %s\n" "$*"
}

if [ ! -d "$WEBAPP_DIR" ]; then
  echo "Error: webapp directory not found at $WEBAPP_DIR"
  exit 1
fi

cd "$WEBAPP_DIR"

log "Installing webapp dependencies..."
npm install

log "Building Next.js webapp..."
npm run build

log "Webapp build complete. Output in $WEBAPP_DIR/out/"
