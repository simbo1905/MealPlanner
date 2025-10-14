#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
WEBAPP_DIR="$ROOT_DIR/apps/web"
WEBAPP_DIST="$WEBAPP_DIR/build"
IOS_WEBAPP="$ROOT_DIR/apps/ios/Resources/webapp"

log() {
    echo "[build-and-deploy-ios] $1"
}

log "🛠 Building webapp..."
# The node script needs to be run from the root of the project
cd "$ROOT_DIR"
npm --prefix "$WEBAPP_DIR" run build

# Check if build succeeded
if [ ! -f "$WEBAPP_DIST/index.html" ]; then
    log "❌ Build failed - index.html not found"
    exit 1
fi

log "Injecting JS bundle into wrapper..."
node "$ROOT_DIR/scripts/inject-bundle.mjs"

log "📦 Copying webapp into iOS bundle..."
rm -rf "$IOS_WEBAPP"
mkdir -p "$IOS_WEBAPP"
cp -r "$WEBAPP_DIST/"* "$IOS_WEBAPP/"

log "✅ Build and deploy complete!"