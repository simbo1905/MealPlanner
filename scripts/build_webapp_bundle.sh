#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
WEBAPP_DIR="$ROOT_DIR/apps/web"
WEBAPP_DIST="$WEBAPP_DIR/build"
IOS_WEBAPP="$ROOT_DIR/apps/ios/Resources/webapp"

log() {
    echo "[build-webapp-bundle] $1"
}

log "🛠 Building webapp..."
cd "$WEBAPP_DIR"
npm run build

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

log "✅ Build complete!"
