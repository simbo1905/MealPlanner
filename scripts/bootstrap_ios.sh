#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IOS_DIR="$ROOT_DIR/apps/ios"

log() {
  printf "[bootstrap:ios] %s\n" "$*"
}

warn() {
  printf "[bootstrap:ios][warn] %s\n" "$*" >&2
}

if [ -d "$IOS_DIR" ] && [ -n "$(find "$IOS_DIR" -mindepth 1 -maxdepth 1 2>/dev/null)" ]; then
  warn "iOS scaffold already exists in apps/ios; skipping creation."
  exit 0
fi

log "Creating iOS scaffold under apps/ios"
mkdir -p "$IOS_DIR/Sources" "$IOS_DIR/Resources/webapp" "$IOS_DIR/Assets.xcassets/AppIcon.appiconset"

cat <<'YAML' > "$IOS_DIR/project.yml"
name: MealPlanner
options:
  bundleIdPrefix: com.mealplanner
configs:
  Debug: debug
  Release: release
settings:
  base:
    IPHONEOS_DEPLOYMENT_TARGET: 16.0
    SWIFT_VERSION: 5.9
packages: {}
targets:
  MealPlanner:
    type: application
    platform: iOS
    deploymentTarget: "16.0"
    sources:
      - path: Sources
      - path: Resources
        type: resources
      - path: Assets.xcassets
        type: assets
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: com.mealplanner.app
      INFOPLIST_FILE: Resources/Info.plist
YAML

cat <<'SWIFT' > "$IOS_DIR/Sources/MealPlannerApp.swift"
import SwiftUI

@main
struct MealPlannerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
SWIFT

cat <<'SWIFT' > "$IOS_DIR/Sources/ContentView.swift"
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Hello, Recipe!")
                .font(.title)
                .fontWeight(.semibold)
            Text("Placeholder native container. Replace with WKWebView + shared module integration.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
SWIFT

cat <<'PLIST' > "$IOS_DIR/Resources/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>MealPlanner</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>UILaunchStoryboardName</key>
    <string></string>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
PLIST

cat <<'JSON' > "$IOS_DIR/Assets.xcassets/AppIcon.appiconset/Contents.json"
{
  "images" : [
    { "idiom" : "iphone", "size" : "60x60", "scale" : "2x" },
    { "idiom" : "iphone", "size" : "60x60", "scale" : "3x" },
    { "idiom" : "ipad", "size" : "76x76", "scale" : "2x" },
    { "idiom" : "ipad", "size" : "83.5x83.5", "scale" : "2x" },
    { "idiom" : "ios-marketing", "size" : "1024x1024", "scale" : "1x" }
  ],
  "info" : { "version" : 1, "author" : "xcode" }
}
JSON

cat <<'HTML' > "$IOS_DIR/Resources/webapp/index.html"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>MealPlanner Web Placeholder</title>
</head>
<body>
  <main>
    <h1>MealPlanner Web Placeholder</h1>
    <p>Swap this bundle with the MealPlanner Vite export once ready.</p>
  </main>
</body>
</html>
HTML

if command -v xcodegen >/dev/null 2>&1; then
  log "xcodegen detected – generating Xcode project via project.yml"
  (cd "$IOS_DIR" && xcodegen generate)
else
  warn "xcodegen not found. Install with 'brew install xcodegen' then run 'cd apps/ios && xcodegen generate'."
fi

log "iOS bootstrap complete."
