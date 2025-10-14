# Android WebView Integration for MealPlanner

Architecture guide for embedding the MealPlanner Svelte + Vite webapp into an Android native app using WebView.

## High-Level Architecture

> ⚙️ **Automation commands**
>
> - `just build-android` – build the Svelte bundle, copy it into `assets/webapp`, and run the Gradle task defined by `ANDROID_GRADLE_TASK` (defaults to `assembleDebug`).
> - `just deploy-android` – refresh only the embedded web assets without invoking Gradle.
> - `bash scripts/launch_android.sh` – build + install + launch on the currently connected emulator/device.
> - `just android-sdk` – ensure SDK packages exist and open Android Studio with the MealPlanner project.

- **Android app**: Kotlin wrapper with WebView loading bundled Vite static output
- **Web UI**: Svelte 5 + Vite 6 app built to static HTML/JS/CSS bundle
- **Communication**: Kotlin ↔ JavaScript bridge via JavascriptInterface
- **Bundle location**: Static Vite output copied to `app/src/main/assets/webapp/`

The Vite build produces static files served via WebViewAssetLoader under secure origin `https://appassets.androidplatform.net/`.

---

## Android Side: WebView Integration

### Platform Requirements
- Kotlin
- Android API 21+ (required for WebViewAssetLoader)
- AndroidX WebKit library

### Dependencies

**build.gradle.kts (module):**
```kotlin
dependencies {
  implementation("androidx.webkit:webkit:1.12.0")
}
```

### Project Structure

```
app/
  src/main/
    AndroidManifest.xml
    java/com/mealplanner/
      MainActivity.kt
    res/layout/
      activity_main.xml
    assets/webapp/         # Vite bundle copied here
      index.html
      assets/
        *.js
        *.css
```

### WebView Setup

**MainActivity.kt:**
```kotlin
package com.mealplanner

import android.annotation.SuppressLint
import android.os.Bundle
import android.webkit.WebView
import androidx.appcompat.app.AppCompatActivity
import androidx.webkit.WebViewAssetLoader
import androidx.webkit.WebViewClientCompat

class MainActivity : AppCompatActivity() {

  @SuppressLint("SetJavaScriptEnabled")
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.activity_main)

    // Enable web debugging in debug builds only
    if (BuildConfig.DEBUG) {
      WebView.setWebContentsDebuggingEnabled(true)
    }

    val webView = findViewById<WebView>(R.id.webView)

    // Configure WebView for local app bundle
    webView.settings.apply {
      javaScriptEnabled = true
      domStorageEnabled = true
      allowFileAccess = false
      allowContentAccess = false
    }

    // Serve assets via secure origin using WebViewAssetLoader
    val assetLoader = WebViewAssetLoader.Builder()
      .addPathHandler("/webapp/", WebViewAssetLoader.AssetsPathHandler(this))
      .build()

    webView.webViewClient = object : WebViewClientCompat() {
      override fun shouldInterceptRequest(
        view: WebView,
        request: WebResourceRequest
      ): WebResourceResponse? {
        return assetLoader.shouldInterceptRequest(request.url)
      }

      override fun shouldOverrideUrlLoading(
        view: WebView?,
        request: WebResourceRequest?
      ): Boolean = false // Keep navigation inside WebView
    }

    // Optional: Native bridge for persistence
    // webView.addJavascriptInterface(RecipeBridge(this), "AndroidBridge")

    // Load the Vite bundle from assets
    webView.loadUrl("https://appassets.androidplatform.net/webapp/index.html")
  }
}
```

**activity_main.xml:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
  android:layout_width="match_parent"
  android:layout_height="match_parent">
  
  <WebView
    android:id="@+id/webView"
    android:layout_width="match_parent"
    android:layout_height="match_parent" />
</FrameLayout>
```

### JavaScript ↔ Kotlin Bridge (Optional)

**RecipeBridge.kt:**
```kotlin
package com.mealplanner

import android.content.Context
import android.webkit.JavascriptInterface
import org.json.JSONArray

class RecipeBridge(private val context: Context) {
  
  private val prefs = context.getSharedPreferences("recipes", Context.MODE_PRIVATE)

  @JavascriptInterface
  fun saveRecipes(json: String) {
    prefs.edit().putString("recipes", json).apply()
  }

  @JavascriptInterface
  fun loadRecipes(): String {
    return prefs.getString("recipes", "[]") ?: "[]"
  }
}
```

**Usage in Svelte:**
```typescript
// Check if Android bridge is available
declare global {
  interface Window {
    AndroidBridge?: {
      saveRecipes: (json: string) => void;
      loadRecipes: () => string;
    }
  }
}

// Save to native storage
if (window.AndroidBridge) {
  window.AndroidBridge.saveRecipes(JSON.stringify(recipes));
}

// Load from native storage
if (window.AndroidBridge) {
  const json = window.AndroidBridge.loadRecipes();
  recipes = JSON.parse(json);
}
```

---

## Build & Bundle Process

### 1. Build Vite Static Bundle

```bash
# From repository root
pnpm build:web
# Output: apps/web/dist/
```

### 2. Copy to Android Assets

```bash
# Automated via script
just deploy-android

# Or manually
rm -rf apps/android/app/src/main/assets/web
mkdir -p apps/android/app/src/main/assets/web
cp -r apps/web/dist/. apps/android/app/src/main/assets/web/
```

### 3. Module Path Configuration

**Default assumption:** `app/src/main/assets/web`

If your Android project uses a different module structure, update `scripts/deploy_webapp_to_android.sh`:

```bash
# Adjust this path for custom module layouts
ANDROID_WEBAPP="$ROOT_DIR/apps/android/[your-module]/src/main/assets/web"
```

Common variations:
- Multi-module: `apps/android/mobile/src/main/assets/web`
- Flavors: `apps/android/app/src/[flavor]/assets/web`

---

## Testing & Debugging

### Chrome DevTools Remote Debugging

1. Connect Android device or start emulator
2. Enable USB debugging on device
3. Open Chrome on desktop: `chrome://inspect/#devices`
4. Find your WebView and click "Inspect"
5. Full DevTools available (console, network, elements, etc.)

**Important:** Only enable `WebView.setWebContentsDebuggingEnabled(true)` in debug builds.

### Logging

**JavaScript side:**
```typescript
console.log('Message from webapp:', data);
// Appears in Chrome DevTools and logcat
```

**Kotlin side:**
```kotlin
android.util.Log.d("WebView", "Message from native: $data")
```

---

## Security Considerations

1. **WebViewAssetLoader**: Serves local files under `https://appassets.androidplatform.net/` to avoid `file://` security issues
2. **JavaScript Interface**: Use `@JavascriptInterface` annotation and validate all inputs
3. **Debugging**: Disable `setWebContentsDebuggingEnabled` for production builds
4. **Network Security**: If loading remote content, enforce HTTPS in `network_security_config.xml`

---

## Common Pitfalls

### Asset Loading Failures
**Problem:** CSS/JS files return 404

**Solution:**
- Verify Vite config has `base: './'` (not `'/'`)
- Ensure `WebViewAssetLoader` path matches bundle location
- Check `assets/web/` folder exists in APK (use APK Analyzer)

### Bridge Communication Issues
**Problem:** `AndroidBridge` is undefined

**Solution:**
- Verify `addJavascriptInterface` is called before `loadUrl`
- Check all methods have `@JavascriptInterface` annotation
- Ensure JavaScript calls match exact method names (case-sensitive)

### Blank WebView
**Problem:** WebView shows blank screen

**Solution:**
- Enable remote debugging and check console for errors
- Verify `javaScriptEnabled = true` in settings
- Check `shouldInterceptRequest` returns non-null for asset requests
- Inspect network tab for failed resource loads

---

## References

- [WebViewAssetLoader Documentation](https://developer.android.com/reference/androidx/webkit/WebViewAssetLoader)
- [WebView Best Practices](https://developer.android.com/develop/ui/views/layout/webapps/webview)
- [JavascriptInterface Guide](https://developer.android.com/reference/android/webkit/JavascriptInterface)
- [Chrome DevTools Remote Debugging](https://developer.chrome.com/docs/devtools/remote-debugging/)
- [Vite Static Deploy](https://vitejs.dev/guide/static-deploy.html)
