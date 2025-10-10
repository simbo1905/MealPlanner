# iOS WebView Integration for MealPlanner

Detailed architecture for embedding the MealPlanner Svelte + Vite webapp into an iOS native app using WKWebView.

## High-Level Architecture

- **iOS app**: Thin wrapper around WKWebView that loads bundled Vite static output
- **Web UI**: Svelte 5 + Vite 6 app built to static HTML/JS/CSS bundle
- **Communication**: Swift ↔ JavaScript bridge via WKScriptMessageHandler
- **Bundle location**: Static Vite output copied to iOS app Resources/webapp/

The Vite build produces static files, making it perfect for WebView embedding.

---

## iOS Side: WebView Integration

### Platform Requirements
- Swift (UIKit or SwiftUI)
- iOS deployment target supporting WKWebView (iOS 8+)
- WebKit framework

### Embedding WKWebView

**UIKit approach:**
```swift
import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
  var webView: WKWebView!
  
  override func loadView() {
    let contentController = WKUserContentController()
    contentController.add(self, name: "recipeHandler")
    
    let config = WKWebViewConfiguration()
    config.userContentController = contentController
    
    webView = WKWebView(frame: .zero, configuration: config)
    webView.navigationDelegate = self
    view = webView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadBundledWebApp()
  }
  
  func loadBundledWebApp() {
    guard let htmlURL = Bundle.main.url(
      forResource: "index", 
      withExtension: "html", 
      subdirectory: "webapp"
    ) else {
      print("Error: webapp bundle not found")
      return
    }
    
    // Allow read access to entire webapp directory
    let webappDir = htmlURL.deletingLastPathComponent()
    webView.loadFileURL(htmlURL, allowingReadAccessTo: webappDir)
  }
  
  // MARK: - WKNavigationDelegate
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    print("Webapp loaded successfully")
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    print("Failed to load webapp: \(error.localizedDescription)")
  }
}
```

**SwiftUI approach (iOS 14+) using UIViewRepresentable:**
```swift
import SwiftUI
import WebKit

struct WebViewRepresentable: UIViewRepresentable {
  func makeUIView(context: Context) -> WKWebView {
    let config = WKWebViewConfiguration()
    config.userContentController.add(context.coordinator, name: "recipeHandler")
    
    let webView = WKWebView(frame: .zero, configuration: config)
    webView.navigationDelegate = context.coordinator
    
    if let htmlURL = Bundle.main.url(
      forResource: "index",
      withExtension: "html",
      subdirectory: "webapp"
    ) {
      let webappDir = htmlURL.deletingLastPathComponent()
      webView.loadFileURL(htmlURL, allowingReadAccessTo: webappDir)
    }
    
    return webView
  }
  
  func updateUIView(_ uiView: WKWebView, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    func userContentController(
      _ userContentController: WKUserContentController,
      didReceive message: WKScriptMessage
    ) {
      // Handle messages from webapp
      if message.name == "recipeHandler",
         let body = message.body as? [String: Any] {
        print("Received message from webapp: \(body)")
      }
    }
    
    // IMPORTANT: Remove message handler to prevent retain cycles
    deinit {
      // Note: In production, store reference to WKUserContentController
      // and call removeScriptMessageHandler(forName:) here
    }
  }
}
```

### JavaScript ↔ Swift Bridge

**Swift side (receiving from JS):**
```swift
extension WebViewController: WKScriptMessageHandler {
  func userContentController(
    _ userContentController: WKUserContentController,
    didReceive message: WKScriptMessage
  ) {
    guard message.name == "recipeHandler",
          let body = message.body as? [String: Any],
          let action = body["action"] as? String else {
      return
    }
    
    switch action {
    case "saveRecipe":
      if let recipe = body["recipe"] as? [String: Any] {
        handleSaveRecipe(recipe)
      }
    case "getRecipes":
      sendRecipesToWebApp()
    default:
      break
    }
  }
  
  func sendRecipesToWebApp() {
    let recipes = loadRecipes() // Your data source
    if let jsonData = try? JSONSerialization.data(withJSONObject: recipes),
       let jsonString = String(data: jsonData, encoding: .utf8) {
      let js = "window.receiveRecipes(\(jsonString));"
      webView.evaluateJavaScript(js, completionHandler: nil)
    }
  }
}
```

---

## Web Side: Svelte + Vite

### Project Structure

```
apps/web/
  src/
    lib/
      components/
        RecipeList.svelte
        RecipeForm.svelte
      stores/
        recipes.ts
      types/
        bridge.ts
    App.svelte
    main.ts
  index.html
  vite.config.ts
  package.json
```

### TypeScript Bridge Interface

**src/lib/types/bridge.ts:**
```typescript
export interface Recipe {
  id: string;
  title: string;
  ingredients: string[];
  instructions: string;
}

declare global {
  interface Window {
    webkit?: {
      messageHandlers: {
        recipeHandler: {
          postMessage: (msg: any) => void;
        }
      }
    };
    receiveRecipes?: (recipes: Recipe[]) => void;
  }
}

export const sendToNative = (action: string, data?: any) => {
  if (window.webkit?.messageHandlers.recipeHandler) {
    window.webkit.messageHandlers.recipeHandler.postMessage({
      action,
      ...data
    });
  } else {
    console.warn('Native bridge not available');
  }
};
```

### Svelte Component Example

**src/lib/components/RecipeList.svelte:**
```svelte
<script lang="ts">
  import { onMount } from 'svelte';
  import type { Recipe } from '$lib/types/bridge';
  import { sendToNative } from '$lib/types/bridge';
  
  let recipes = $state<Recipe[]>([]);
  
  onMount(() => {
    // Set up receiver for native messages
    window.receiveRecipes = (newRecipes: Recipe[]) => {
      recipes = newRecipes;
    };
    
    // Request initial data from native
    sendToNative('getRecipes');
  });
  
  const saveRecipe = (recipe: Recipe) => {
    sendToNative('saveRecipe', { recipe });
  };
</script>

<div class="recipe-list">
  {#each recipes as recipe (recipe.id)}
    <article class="recipe-card">
      <h3>{recipe.title}</h3>
      <p>{recipe.instructions}</p>
    </article>
  {/each}
</div>
```

### Vite Configuration

**vite.config.ts:**
```typescript
import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import path from 'path'

export default defineConfig({
  plugins: [svelte()],
  resolve: {
    alias: {
      '$lib': path.resolve('./src/lib')
    }
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    // Ensure assets use relative paths for iOS bundle
    assetsDir: 'assets',
    rollupOptions: {
      output: {
        manualChunks: undefined
      }
    }
  },
  base: './' // Critical for iOS file:// loading
})
```

---

## Build & Bundle Process

### 1. Build Vite Static Bundle

```bash
# From repository root
cd apps/web
pnpm build
# Output: apps/web/dist/
```

### 2. Copy to iOS Resources

```bash
# Clear old bundle
rm -rf apps/ios/Resources/webapp

# Copy new bundle
mkdir -p apps/ios/Resources/webapp
cp -r apps/web/dist/* apps/ios/Resources/webapp/
```

### 3. Xcode Integration

1. Add `Resources/webapp` folder to Xcode project as **folder reference** (blue folder, not group)
2. Ensure target membership includes main app target
3. Verify `Info.plist` settings if needed

### 4. Automated Script

**scripts/deploy_webapp_to_ios.sh:**
```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEBAPP_DIST="$ROOT_DIR/apps/web/dist"
IOS_WEBAPP="$ROOT_DIR/apps/ios/Resources/webapp"

echo "Building webapp..."
cd "$ROOT_DIR" && pnpm build:web

echo "Deploying to iOS..."
rm -rf "$IOS_WEBAPP"
mkdir -p "$IOS_WEBAPP"
cp -r "$WEBAPP_DIST"/* "$IOS_WEBAPP/"

echo "✅ Webapp deployed to iOS Resources"
```

**Important notes:**
- Deployment scripts expect pre-built bundle in `apps/web/dist/` (run `just build-bundle` first)
- Scripts copy entire dist directory including dotfiles for completeness
- For safer JSON bridging, consider base64 encoding or structured message passing to avoid injection issues

---

## Testing & Debugging

### Safari Web Inspector
1. Build and run iOS app in Simulator or device
2. Open Safari on Mac
3. Navigate to Develop → [Device Name] → [App Name]
4. Inspect WebView content just like a browser

### Console Logging
```typescript
// In Svelte app
console.log('Message from webapp:', data);

// Will appear in Safari Web Inspector console
```

### Bridge Testing
```swift
// In Swift
webView.evaluateJavaScript("console.log('Hello from Swift')") { result, error in
  if let error = error {
    print("JS error: \(error)")
  }
}
```

---

## Security Considerations

1. **Local file access:** Use `loadFileURL(_:allowingReadAccessTo:)` to grant directory access
2. **Content Security Policy:** Consider adding CSP meta tag in index.html
3. **Message validation:** Always validate messages from JavaScript
4. **HTTPS only:** If loading remote content, enforce HTTPS

---

## Common Pitfalls

### Resource Loading Failures
**Problem:** Assets (CSS, JS) fail to load with 404 errors

**Solution:** 
- Ensure `vite.config.ts` has `base: './'`
- Use `loadFileURL` with directory access grant
- Verify folder reference in Xcode (not group)

### Bridge Communication Issues
**Problem:** Messages not received from JavaScript

**Solution:**
- Verify script message handler is registered before page load
- Check message name matches exactly
- Ensure page has fully loaded before sending messages

### State Synchronization
**Problem:** Swift and JS states get out of sync

**Solution:**
- Designate Swift as single source of truth
- JS sends mutations to Swift, receives updates back
- Use callbacks to confirm state changes

---

## References

- [WKWebView Apple Documentation](https://developer.apple.com/documentation/webkit/wkwebview)
- [WKScriptMessageHandler](https://developer.apple.com/documentation/webkit/wkscriptmessagehandler)
- [Loading Local Content](https://developer.apple.com/documentation/webkit/wkwebview/1414973-loadfileurl)
- [Vite Static Build](https://vitejs.dev/guide/static-deploy.html)
- [Svelte Documentation](https://svelte.dev/docs)
