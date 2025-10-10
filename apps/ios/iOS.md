Here is a detailed coding spec / architecture design for a “Hello WebView” hybrid iOS + Svelte + Vite/TypeScript app. The goal is that the iOS app embeds a WebView, loads bundled web UI (built via Svelte + Vite), and the web UI can display/edit a small list of “recipes” stored in-memory (or persisted) via JSON, supporting add / edit / delete.

I’ll break it down into:
	1.	High-level architecture
	2.	iOS side: structure, WebView integration, JS ↔ Swift bridge
	3.	Web side (Svelte + Vite + TypeScript): structure, API interface, bundling for embedding
	4.	Data model & UI behavior
	5.	Build & bundling / deployment considerations
	6.	Example code skeletons & integration points
	7.	What to watch out for, pitfalls & references to official docs

⸻

1. High-level architecture
	•	The iOS app is essentially a thin wrapper around a WebView (using WKWebView) that loads a local web bundle (HTML/JS/CSS) that was compiled from Vite.
	•	The web UI inside the WebView hosts a small single-page-ish app in Svelte (TypeScript) that displays a list of “recipes” (fake JSON), and allows operations: list, add, edit, delete.
	•	The communication between Swift (iOS) and JavaScript (web) is done via a message bridge (e.g. WKScriptMessageHandler) or direct evaluateJavaScript.
	•	Optionally, you may persist the recipe list on the iOS side (e.g. in a file, UserDefaults, or local DB) so the list survives between launches; or keep it entirely in the web side local storage (but embedded web has constrained file access).
	•	On app launch, iOS loads the local web bundle into the WebView, optionally injecting initial JSON (or request) so the web UI sees the current recipe list.
	•	When user does add/edit/delete in web UI, it sends a message to the iOS side, which updates the stored JSON, and optionally returns the updated list to the web UI. Or, the web UI maintains its own local copy and does not rely on iOS for persistence.

Vite builds static files by default, making it perfect for WebView embedding.

⸻

2. iOS Side: WebView integration & bridging

2.1. Platform, deployment target
	•	Use Swift and either UIKit or SwiftUI (depending on your familiarity).
	•	iOS version target should support WKWebView (iOS 8+), and consider newer SwiftUI WebView support (iOS 26) in future.
	•	Use WebKit framework.

2.2. Embedding the WebView

If using UIKit:
	•	Create a UIViewController (say WebViewController) which hosts a WKWebView.
	•	In loadView() or in viewDidLoad(), instantiate the WKWebView with a custom WKWebViewConfiguration.
	•	Set up its navigation delegate and script message handlers.

If using SwiftUI (pre-iOS 26):
	•	Use UIViewRepresentable to wrap WKWebView (common pattern).
	•	Or, if targeting iOS 26+, you may use the new native WebView in SwiftUI (Apple’s WebKit for SwiftUI) + WebPage interface.  ￼

2.3. Loading local bundled HTML/JS/CSS
	•	You include the built web UI (static output) in the iOS app bundle (e.g. in Resources/webapp folder).
	•	Use Bundle.main.url(forResource:withExtension:subdirectory:) to get the URL of index.html (or entry HTML).
	•	Use webView.loadFileURL(_:allowingReadAccessTo:) to load the HTML, granting access to the folder containing all resources (JS, CSS, assets). This is required so relative references to CSS / JS within the web app can load.  ￼
	•	Example:

let htmlURL = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "webapp")!
webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())


	•	Alternatively, you could load HTML as a string via loadHTMLString(_:baseURL:) if your bundle is simple, but then resource links may break.  ￼

2.4. JavaScript ↔ Swift communication

To allow the web UI to request operations (add / edit / delete) and receive responses, you need a message bridge:
	•	Use WKUserContentController and WKScriptMessageHandler in the web view configuration.
	•	Register script handlers such as "iosHandler" (or more granular names) so JS code can call window.webkit.messageHandlers.iosHandler.postMessage(...) with a message.
	•	In Swift, implement userContentController(_:didReceive:) to catch messages from JS, parse them (e.g. JSON payload with action + data), and respond accordingly (update local data, then call back JS).
	•	To call JS from Swift, use webView.evaluateJavaScript(_:) to run JS code in the context of the page — e.g. send updated JSON, trigger UI refresh, etc.
	•	In the JS side, define global JS functions or message handlers (e.g. onNativeResponse(data)) that Swift can call via evaluateJavaScript("onNativeResponse(\(jsonString))").

Example:

let config = WKWebViewConfiguration()
config.userContentController.add(self, name: "recipeHandler")
webView = WKWebView(frame: .zero, configuration: config)

Then:

extension WebViewController: WKScriptMessageHandler {
  func userContentController(_ uc: WKUserContentController, didReceive message: WKScriptMessage) {
    if message.name == "recipeHandler", let body = message.body as? [String: Any] {
      // parse action (e.g. "add", "edit", "delete", "list")
      // update local model
      // then send back updated list
      let response = … // JSON dictionary or array
      let json = try! JSONSerialization.data(withJSONObject: response)
      let jsonString = String(data: json, encoding: .utf8)!
      webView.evaluateJavaScript("onNativeRecipesUpdate(\(jsonString));", completionHandler: nil)
    }
  }
}

	•	Also set webView.navigationDelegate = self if you want to observe load events, errors, etc.

2.5. Data persistence (optional)
	•	Maintain a local data store for the recipe list (e.g. write JSON to file in the app’s documents directory, or use UserDefaults or a small local DB).
	•	On app startup, load stored JSON or initialize default recipe list (5 recipes).
	•	When receiving a JS “list” request or on load, inject that JSON to JS side.
	•	On any mutation (add/edit/delete), update storage.

2.6. App flow and lifecycle
	•	On viewDidLoad, set up the web view, load the local HTML, then once the WebView signals that the page loaded (via the navigation delegate), inject initial data (call a JS function e.g. initializeWithRecipes(...)).
	•	On subsequent JS messages (user actions), handle them as above.
	•	Clean up (remove script handlers) in deinit if needed.

⸻

3. Web Side: Svelte + Vite + TypeScript
3.1. Project structure
Vite builds to static files perfect for client-side embedding in WebViews.

3.1. Project structure

my-web-ui/
  pages/
    index.tsx    // main page, but may use only client-side code (no server logic)
  components/
    RecipeList.tsx
    RecipeForm.tsx
  public/
    (static assets)
  next.config.js
  tsconfig.json
  package.json

Vite handles static builds automatically:
	•	Use next export to export a static HTML + JS bundle (i.e. no server).
	•	Or use the /app directory with client-only components.
	•	Ensure that routing is minimal (just the root /).

3.2. Data model & interface with native

Define a TypeScript interface:

interface Recipe {
  id: string;
  title: string;
  ingredients: string;
  instructions: string;
}

Define a front-end “bridge” interface, something like:

declare global {
  interface Window {
    webkit?: {
      messageHandlers: {
        recipeHandler: {
          postMessage: (msg: any) => void;
        }
      }
    };
  }
  function onNativeRecipesUpdate(recipes: Recipe[]): void;
}

In your React app (e.g. in useEffect or on mount):
	•	On mount, send a message to Swift to ask for initial list:

window.webkit?.messageHandlers.recipeHandler.postMessage({ action: "list" });


	•	Implement window.onNativeRecipesUpdate = (recipes) => { setRecipes(recipes) } to receive updates from native side.
	•	On user actions (add / edit / delete), send messages:

window.webkit?.messageHandlers.recipeHandler.postMessage({
  action: "add",
  recipe: { title, ingredients, instructions },
});

Or:

window.webkit?.messageHandlers.recipeHandler.postMessage({
  action: "delete",
  recipeId: id
});


	•	Optionally, you may also locally update UI state optimistically, but rely on the native side to confirm or respond with the authoritative list.

Your React UI displays the list, shows forms for editing / adding, handles user input.

3.3. Bundling & output
	•	In next.config.js, configure export mode:

module.exports = {
  output: 'export',
  trailingSlash: true,  // optional
};

This will allow you to run next build && next export to produce a static bundle under out/ directory.

	•	Or use next start and host the web UI externally — but since you want it bundled in the iOS app, static export is recommended.
	•	After build, copy the contents of out/ (including index.html, _next/ assets, CSS, etc.) into your iOS app’s bundle (e.g. in Resources/webapp).
	•	Ensure relative resource paths work (e.g. /_next/static/...) — the allowingReadAccessTo: folder passed to loadFileURL must permit access to the whole directory.

⸻

4. Data Model & UI Behavior (Recipes)

4.1. Initial data
	•	On first install, iOS can preset a JSON file with 5 recipes (hardcoded in bundle) which can then be copied into the writable area, or you can embed them in code.
	•	Each recipe has a unique id (UUID string), a title, ingredients (string or array), and instructions (string).

4.2. UI flows
	•	On web UI load, you show a list of recipes: title & maybe a short summary.
	•	Each recipe entry has “Edit” and “Delete” buttons.
	•	At top or bottom, an “Add recipe” button opens a form.
	•	The form allows entering fields, then “Save” or “Cancel”.
	•	On Save, send the add or edit message to native. On success (or after response message), update the UI.
	•	On Delete, confirm (optional) then send delete message.
	•	Optionally, you can show error or feedback if the native side fails.

⸻

5. Build, bundling, and deployment

5.1. Build script
	•	Use an NPM / Yarn / PNPM script that builds the Vite app:

npm run build


	•	After build, you have a dist/ folder. Then a script (shell, Node) copies (or syncs) dist/ to your iOS project folder (e.g. iOSApp/Resources/webapp).
	•	In the Xcode project, include the webapp folder as a “folder reference” (not a group) so that the directory structure is preserved (JS/CSS assets, subfolders).
	•	Make sure target membership includes the app target.

5.2. Xcode setup
	•	Add WebKit.framework to your app.
	•	In Info.plist, you may need to allow local file loading or set NSAllowsLocalNetworking (depending on how you access resources).
	•	In app resources, verify that the webapp folder with HTML/JS files ends up in the app bundle.
	•	Ensure that the file paths in the built HTML (especially JavaScript chunks, dynamic chunks) are relative or correct.

5.3. Testing & debugging
	•	Use Safari’s Web Inspector to inspect the web content inside the WebView (in Simulator or device).
	•	Use console logs in JS, and evaluateJavaScript responses to debug the message bridge.
	•	Watch for resource load errors (404s) if folder access is misconfigured.

⸻

6. Example skeleton code & integration points

6.1. iOS side (UIKit example)

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
    // Load local HTML
    let htmlURL = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "webapp")!
    webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    // Optionally, inject initial data
    let initialRecipes: [[String: Any]] = [
      ["id": "1", "title": "Recipe 1", "ingredients": "A, B", "instructions": "Mix"],
      // etc ...
    ]
    if let data = try? JSONSerialization.data(withJSONObject: initialRecipes),
       let str = String(data: data, encoding: .utf8) {
      let js = "onNativeRecipesUpdate(\(str));"
      webView.evaluateJavaScript(js, completionHandler: nil)
    }
  }
  
  // MARK: - JS → Swift message handler
  func userContentController(_ uc: WKUserContentController, didReceive message: WKScriptMessage) {
    guard message.name == "recipeHandler",
          let body = message.body as? [String: Any],
          let action = body["action"] as? String else {
      return
    }
    // respond based on action
    switch action {
    case "list":
      // read stored JSON, respond
      break
    case "add":
      // parse `recipe` object, append to storage
      break
    case "edit":
      // parse `recipe`, update
      break
    case "delete":
      // parse `recipeId`, remove
      break
    default:
      break
    }
    // After mutation, get latest list and call:
    // webView.evaluateJavaScript("onNativeRecipesUpdate(\(jsonList))", ...)
  }
}

6.2. Web (React / TypeScript) skeleton in pages/index.tsx

import React, { useEffect, useState } from "react";

interface Recipe {
  id: string;
  title: string;
  ingredients: string;
  instructions: string;
}

export default function Home() {
  const [recipes, setRecipes] = useState<Recipe[]>([]);
  
  // Expose handler to receive updates from native
  useEffect(() => {
    (window as any).onNativeRecipesUpdate = (newRecipes: Recipe[]) => {
      setRecipes(newRecipes);
    };
    // Ask native side for initial list
    window.webkit?.messageHandlers.recipeHandler.postMessage({ action: "list" });
  }, []);
  
  const addRecipe = (r: Omit<Recipe, "id">) => {
    window.webkit?.messageHandlers.recipeHandler.postMessage({
      action: "add",
      recipe: r
    });
  };
  const editRecipe = (r: Recipe) => {
    window.webkit?.messageHandlers.recipeHandler.postMessage({
      action: "edit",
      recipe: r
    });
  };
  const deleteRecipe = (id: string) => {
    window.webkit?.messageHandlers.recipeHandler.postMessage({
      action: "delete",
      recipeId: id
    });
  };
  
  return (
    <div>
      <h1>Recipes</h1>
      <ul>
        {recipes.map(r => (
          <li key={r.id}>
            <strong>{r.title}</strong>
            <button onClick={() => editRecipe(r)}>Edit</button>
            <button onClick={() => deleteRecipe(r.id)}>Delete</button>
          </li>
        ))}
      </ul>
      <button onClick={() => addRecipe({ title: "New", ingredients: "", instructions: "" })}>
        Add Recipe
      </button>
    </div>
  );
}

You’d of course expand that to proper forms, validations, etc.

⸻

7. Pitfalls, gotchas & references to official docs

7.1. File access / resource loading
	•	loadFileURL(_:allowingReadAccessTo:) must allow the directory containing your JS/CSS/asset files, otherwise relative resource loads will be blocked.  ￼
	•	If your JS references absolute paths or unexpected folder structure, paths may break.
	•	If you try to load local files via loadRequest(URLRequest(fileURL: …)), some resources may be blocked or flagged.

7.2. Message size & timing
	•	Be careful about the amount of data sent via message handlers—huge JSON payloads might cause performance issues.
	•	Ensure that the web page’s JS side is ready (i.e. onNativeRecipesUpdate is defined) before native side calls it. You may delay until didFinish navigation callback.
	•	If the web UI does SPA-style routing, be careful that navigation doesn’t break the bridge.

7.3. Synchronization, consistency
	•	If both sides (native and JS) try to mutate state, races or inconsistencies can occur. Better to designate one side as the “source of truth” (e.g. native).
	•	On JS side, you may optimistically update UI, but always override via native’s response.

7.4. Version mismatch
	•	If you update the web UI (new JS chunks, path changes), ensure the iOS bundle is updated, and resource paths remain accessible.

7.5. Official docs & references
	•	Apple’s WKWebView class reference: a WKWebView object is the standard way to embed web content in an app.  ￼
	•	The Apple doc on load(_:) for WKWebView (to load URL or file)  ￼
	•	Apple’s new SwiftUI WebView / WebKit for SwiftUI (in iOS 26) for embedding web content more directly in SwiftUI apps  ￼
	•	The StackOverflow discussion that loadFileURL is the modern way to load local HTML + allow read access, replacing older path-based loads.  ￼
	•	Blog post on bridging JavaScript inside WebViews (JavaScript ↔ Swift communication)  ￼

