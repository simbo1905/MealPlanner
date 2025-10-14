import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        WebViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct WebViewContainer: UIViewRepresentable {
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator()
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webpagePreferences = WKWebpagePreferences()
        webpagePreferences.allowsContentJavaScript = true

        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = webpagePreferences
        
        config.userContentController.add(context.coordinator, name: "recipeHandler")
        config.userContentController.add(context.coordinator, name: "consoleHandler")
        
        // Inject console bridge script that captures ALL console methods
        let consoleOverrideJS = """
        (function() {
          console.log("[DEBUG] Injected console override script is running.");
          const methods = ['log', 'warn', 'error', 'info'];
          methods.forEach(function(method) {
            const orig = console[method];
            console[method] = function(...args) {
              try {
                window.webkit.messageHandlers.consoleHandler.postMessage({ method: method, args: args });
              } catch (err) {
                // ignore
              }
              orig.apply(console, args);
            };
          });
        })();
        """
        let script = WKUserScript(source: consoleOverrideJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        config.userContentController.addUserScript(script)
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView
        
        if let htmlURL = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "webapp") {
            print("[DEBUG] Loading htmlURL: \(htmlURL)")
            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
        } else {
            print("[DEBUG] Error: Could not find webapp/index.html in bundle")
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}

#Preview {
    ContentView()
}
