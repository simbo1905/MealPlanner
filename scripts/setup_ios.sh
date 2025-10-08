#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() {
  printf "[setup-ios] %s\n" "$*"
}

log "Step 1/3: Building Next.js webapp..."
bash "$ROOT_DIR/scripts/build_ios_webapp.sh"

log "Step 2/3: Copying webapp to iOS Resources..."
bash "$ROOT_DIR/scripts/copy_ios_webapp.sh"

log "Step 3/3: Generating Xcode project..."
bash "$ROOT_DIR/scripts/generate_ios_xcode.sh"

log ""
log "Setup complete! Next steps:"
log "1. Open apps/ios/MealPlanner.xcodeproj in Xcode"
log "2. Select a simulator or device"
log "3. Build and run (Cmd+R)"
