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
        let config = WKWebViewConfiguration()
        config.userContentController.add(context.coordinator, name: "recipeHandler")
        config.userContentController.add(context.coordinator, name: "consoleLog")
        
        // Inject console bridge script that captures ALL console methods
        let consoleBridgeJS = """
        (function() {
          const methods = ['log', 'warn', 'error', 'info'];
          methods.forEach(function(method) {
            const orig = console[method];
            console[method] = function(...args) {
              try {
                window.webkit.messageHandlers.consoleLog.postMessage(
                  '[' + method.toUpperCase() + '] ' + args.join(' ')
                );
              } catch (err) {
                orig('Console bridge failed', err);
              }
              orig.apply(console, args);
            };
          });
          // Test all console methods
          console.log('TESTING: console.log bridge working');
          console.info('TESTING: console.info bridge working');
          console.warn('TESTING: console.warn bridge working');
          console.error('TESTING: console.error bridge working');
        })();
        """
        let script = WKUserScript(source: consoleBridgeJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        config.userContentController.addUserScript(script)
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView
        
        if let htmlURL = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "webapp") {
            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
        } else {
            print("Error: Could not find webapp/index.html in bundle")
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}

#Preview {
    ContentView()
}
