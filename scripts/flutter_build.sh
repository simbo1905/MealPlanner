#!/usr/bin/env bash
set -euo pipefail

PLATFORM="${1:-all}"

cd "$(dirname "$0")/../meal_planner" || exit 1

echo "Building Flutter app for $PLATFORM..."

case "$PLATFORM" in
  web)
    flutter build web
    ;;
  ios)
    flutter build ios --release
    ;;
  macos)
    flutter build macos --release
    ;;
  android)
    flutter build apk --release
    ;;
  appbundle)
    flutter build appbundle --release
    ;;
  windows)
    flutter build windows --release
    ;;
  linux)
    flutter build linux --release
    ;;
  all)
    echo "Building for all platforms..."
    flutter build web
    flutter build ios --release
    flutter build macos --release
    flutter build apk --release
    ;;
  *)
    echo "Unknown platform: $PLATFORM"
    echo "Usage: $0 {web|ios|macos|android|appbundle|windows|linux|all}"
    exit 1
    ;;
esac

echo "Build complete!"
