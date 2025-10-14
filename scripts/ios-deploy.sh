#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
WEBAPP_DIST="$ROOT_DIR/apps/web/build"
IOS_WEBAPP="$ROOT_DIR/apps/ios/Resources/webapp"

log() {
    echo "[ios-deploy] $1"
}

if [ ! -d "$WEBAPP_DIST" ]; then
    log "❌ Web app build directory not found at $WEBAPP_DIST"
    log "Please run 'just web-bundle' first."
    exit 1
fi

log "Deploying web bundle to iOS project..."
rm -rf "$IOS_WEBAPP"
mkdir -p "$IOS_WEBAPP"
cp -r "$WEBAPP_DIST/"* "$IOS_WEBAPP/"

log "✅ Web bundle deployed to iOS project."
