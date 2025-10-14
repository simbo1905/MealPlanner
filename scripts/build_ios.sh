#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IOS_DIR="$ROOT_DIR/apps/ios"
PROJECT_PATH="$IOS_DIR/MealPlanner.xcodeproj"
SCHEME="${IOS_SCHEME:-MealPlanner}"
CONFIGURATION="${IOS_CONFIGURATION:-Debug}"
DESTINATION="${IOS_DESTINATION:-platform=iOS Simulator,name=iPhone 17 Pro,OS=latest}"
DERIVED_DATA="${IOS_DERIVED_DATA:-$IOS_DIR/build}"

log() {
  printf "[build-ios] %s\n" "$*"
}

error() {
  printf "[build-ios][error] %s\n" "$*" >&2
  exit 1
}

if [ ! -d "$IOS_DIR" ]; then
  error "iOS directory not found at $IOS_DIR"
fi

log "Step 1/4: Building MealPlanner web bundle"
"$ROOT_DIR/scripts/build_webapp_bundle.sh"

log "Step 2/4: Deploying web bundle into iOS resources"
"$ROOT_DIR/scripts/deploy_webapp_to_ios.sh"

if command -v xcodegen >/dev/null 2>&1; then
  log "Step 3/4: Regenerating Xcode project via xcodegen"
  "$ROOT_DIR/scripts/generate_ios_xcode.sh"
else
  log "Step 3/4: xcodegen not found – skipping project regeneration"
fi

if [ ! -d "$PROJECT_PATH" ]; then
  error "Xcode project not found at $PROJECT_PATH. Install xcodegen (brew install xcodegen) or open project.yml in Xcode."
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  error "xcodebuild command not found. Install Xcode command line tools."
fi

log "Step 4/4: Building iOS app with xcodebuild"
mkdir -p "$DERIVED_DATA"

xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -sdk iphonesimulator \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA" \
  build

APP_BUNDLE="$DERIVED_DATA/Build/Products/${CONFIGURATION}-iphonesimulator/${SCHEME}.app"

if [ -d "$APP_BUNDLE" ]; then
  log "✅ Build complete. App bundle available at:"
  log "   $APP_BUNDLE"
else
  log "⚠️ Build finished but app bundle not found at expected path."
fi
