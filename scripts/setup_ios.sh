#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() {
  printf "[setup-ios] %s\n" "$*"
}

log "Step 1/3: Building Svelte webapp bundle..."
"$ROOT_DIR/scripts/build_webapp_bundle.sh"

log "Step 2/3: Copying bundle into iOS resources..."
"$ROOT_DIR/scripts/deploy_webapp_to_ios.sh"

log "Step 3/3: Generating Xcode project..."
"$ROOT_DIR/scripts/generate_ios_xcode.sh"

log ""
log "Setup complete! Next steps:"
log "1. (Optional) Run 'just build-ios' to compile and launch the simulator build"
log "2. Or open apps/ios/MealPlanner.xcodeproj in Xcode"
log "3. Select a simulator/device and build with Cmd+R"
