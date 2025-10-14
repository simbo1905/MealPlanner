#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
IOS_WEBAPP="$ROOT_DIR/apps/ios/Resources/webapp"
TEST_HTML="$ROOT_DIR/scripts/test.html"

log() {
  printf "[deploy-test-ios] %s\n" "$*"
}

if [ ! -f "$TEST_HTML" ]; then
  echo "Error: test.html not found at $TEST_HTML"
  exit 1
fi

log "Removing old webapp resources..."
rm -rf "$IOS_WEBAPP"

log "Copying test wrapper to Resources/webapp..."
mkdir -p "$IOS_WEBAPP"
cp "$TEST_HTML" "$IOS_WEBAPP/index.html"

log "✅ Test wrapper deployed to iOS Resources at $IOS_WEBAPP"

