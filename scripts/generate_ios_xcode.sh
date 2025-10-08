#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IOS_DIR="$ROOT_DIR/apps/ios"

log() {
  printf "[generate-xcode] %s\n" "$*"
}

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "Error: xcodegen not found"
  echo "Install with: brew install xcodegen"
  exit 1
fi

cd "$IOS_DIR"

log "Generating Xcode project from project.yml..."
xcodegen generate

log "Xcode project generated successfully at $IOS_DIR/MealPlanner.xcodeproj"
