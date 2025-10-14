# iOS Hello WebView App

Minimal iOS app with embedded Svelte + Vite WebView showing recipe list with add/delete functionality.

## Setup & Build

Run these commands from the repository root:

```bash
# Build the Svelte bundle, copy into the iOS resources, and compile for the simulator
just build-ios

# Regenerate the bundle without triggering xcodebuild
just deploy-ios

# Optional: only scaffold Xcode project (no build)
bash scripts/setup_ios.sh
```

`just build-ios` accepts the following overrides:

- `IOS_DESTINATION="platform=iOS Simulator,name=iPhone 15 Pro" just build-ios`
- `IOS_CONFIGURATION=Release just build-ios`

After the build succeeds you can open the project in Xcode if you want to run or debug manually:

```bash
open apps/ios/MealPlanner.xcodeproj
```

## Architecture

- **Swift Side**: `Sources/ContentView.swift` + `Sources/WebViewCoordinator.swift`
  - WKWebView wrapper
  - JS-Swift bridge via message handlers
  - In-memory recipe storage (5 default recipes)
  
- **Web Side**: `webapp/src/App.svelte`
  - Vite static export
  - TypeScript + Svelte
  - Communicates via `window.webkit.messageHandlers.recipeHandler`

## How It Works

1. iOS loads `Resources/webapp/index.html` into WKWebView
2. Web UI requests recipe list on mount
3. Swift responds with 5 hardcoded recipes
4. User can add (via prompt) or delete recipes
5. Changes update in Swift memory and sync back to UI

## Files Created

```
apps/ios/
├── Sources/
│   ├── MealPlannerApp.swift
│   ├── ContentView.swift (modified - now WebView wrapper)
│   └── WebViewCoordinator.swift (new - bridge logic)
├── Resources/
│   ├── Info.plist
│   └── webapp/ (copied from webapp/out/)
├── webapp/ (Svelte + Vite project)
│   ├── src/
│   │   ├── App.svelte
│   │   ├── main.ts
│   │   └── lib/
│   ├── package.json
│   ├── tsconfig.json
│   └── vite.config.ts
└── project.yml (modified - added webapp resources)
```

## Troubleshooting

**No recipes showing?**
- Check Xcode console for "Error: Could not find webapp/index.html"
- Verify `Resources/webapp/index.html` exists after running copy script

**Build fails?**
- Ensure xcodegen is installed: `brew install xcodegen`
- Ensure Node.js is installed for Vite build

**WebView blank?**
- Check Safari Web Inspector (Develop menu → Simulator → index.html)
- Verify console for JavaScript errors
end
