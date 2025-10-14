#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
IOS_WEBAPP="$ROOT_DIR/apps/ios/Resources/webapp"
DIAGNOSTIC_HTML="$ROOT_DIR/scripts/diagnostic.html"

log() {
  printf "[deploy-diag-ios] %s\n" "$*"
}

if [ ! -f "$DIAGNOSTIC_HTML" ]; then
  echo "Error: diagnostic.html not found at $DIAGNOSTIC_HTML"
  exit 1
fi

log "Removing old webapp resources..."
rm -rf "$IOS_WEBAPP"

log "Copying diagnostic wrapper to Resources/webapp..."
mkdir -p "$IOS_WEBAPP"
cp "$DIAGNOSTIC_HTML" "$IOS_WEBAPP/index.html"

log "✅ Diagnostic wrapper deployed to iOS Resources at $IOS_WEBAPP"