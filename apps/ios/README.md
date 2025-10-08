# iOS Hello WebView App

Minimal iOS app with embedded Next.js WebView showing recipe list with add/delete functionality.

## Setup & Build

Run these commands from the repository root:

```bash
# Complete setup (all-in-one)
bash scripts/setup_ios.sh

# Or run steps individually:
bash scripts/build_ios_webapp.sh      # Build Next.js app
bash scripts/copy_ios_webapp.sh       # Copy to iOS Resources
bash scripts/generate_ios_xcode.sh    # Generate Xcode project
```

## Open in Xcode

```bash
open apps/ios/MealPlanner.xcodeproj
```

Then select a simulator and press Cmd+R to build and run.

## Architecture

- **Swift Side**: `Sources/ContentView.swift` + `Sources/WebViewCoordinator.swift`
  - WKWebView wrapper
  - JS-Swift bridge via message handlers
  - In-memory recipe storage (5 default recipes)
  
- **Web Side**: `webapp/src/app/page.tsx`
  - Next.js static export
  - TypeScript + React
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
├── webapp/ (new Next.js project)
│   ├── src/app/
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── package.json
│   ├── tsconfig.json
│   └── next.config.js
└── project.yml (modified - added webapp resources)
```

## Troubleshooting

**No recipes showing?**
- Check Xcode console for "Error: Could not find webapp/index.html"
- Verify `Resources/webapp/index.html` exists after running copy script

**Build fails?**
- Ensure xcodegen is installed: `brew install xcodegen`
- Ensure Node.js is installed for Next.js build

**WebView blank?**
- Check Safari Web Inspector (Develop menu → Simulator → index.html)
- Verify console for JavaScript errors
