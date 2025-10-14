import SwiftUI
import WebKit

class WebViewCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    var webView: WKWebView?
    
    private var recipes: [[String: Any]] = [
        [
            "id": "1",
            "title": "Spaghetti Bolognese",
            "image_url": "https://example.com/images/spaghetti-bolognese.jpg",
            "description": "Classic spaghetti with rich, savory meat sauce simmered with herbs and tomato.",
            "notes": "Best served with grated cheese and fresh basil.",
            "total_time": 45
        ],
        [
            "id": "2",
            "title": "Chicken Stir-Fry",
            "image_url": "https://example.com/images/chicken-stirfry.jpg",
            "description": "Quick and colorful chicken stir-fry with vegetables and savory soy sauce.",
            "notes": "Serve immediately to keep vegetables crisp.",
            "total_time": 30
        ],
        [
            "id": "3",
            "title": "Fish and Chips",
            "image_url": "https://example.com/images/fish-and-chips.jpg",
            "description": "Crispy battered fish with golden fries, a classic comfort meal.",
            "notes": "Serve with tartar sauce or malt vinegar.",
            "total_time": 40
        ],
        [
            "id": "4",
            "title": "Vegetable Curry",
            "image_url": "https://example.com/images/vegetable-curry.jpg",
            "description": "A fragrant curry packed with mixed vegetables in a rich coconut sauce.",
            "notes": "Adjust spice level to taste.",
            "total_time": 35
        ],
        [
            "id": "5",
            "title": "Roasted Chicken",
            "image_url": "https://example.com/images/roast-chicken.jpg",
            "description": "A perfectly seasoned, juicy roasted chicken with buttery flavor and tender meat.",
            "notes": "Some people prefer to roast a whole chicken at 425°F (220°C) for 50–60 minutes to get crispier skin.",
            "total_time": 90
        ]
    ]
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("[WebView] Page loaded successfully")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("!!!!!!!!!! [WebView] Navigation failed !!!!!!!!!!")
        print("\(error.localizedDescription)")
        print("\(error)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("!!!!!!!!!! [WebView] Provisional navigation failed !!!!!!!!!!")
        print("\(error.localizedDescription)")
        print("\(error)")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("[WebView] Navigation request: \(navigationAction.request.url?.absoluteString ?? "unknown")")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let httpResponse = navigationResponse.response as? HTTPURLResponse {
            print("[WebView] Response: \(httpResponse.statusCode) for \(navigationResponse.response.url?.absoluteString ?? "unknown")")
        } else {
            let response = navigationResponse.response
            print("[WebView] File response: \(response.url?.absoluteString ?? "unknown")")
        }
        decisionHandler(.allow)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "consoleHandler", let body = message.body as? [String: Any] {
            // e.g. { method: "log", args: [...] }
            print("[JS][\(body["method"] ?? "")] \(body["args"] ?? "")")
            return
        }

        if message.name == "consoleLog" {
            print("[JS Console] \(message.body)")
            return
        }
        
        guard message.name == "recipeHandler",
              let body = message.body as? [String: Any],
              let action = body["action"] as? String else {
            print("[Bridge] Received unknown message: \(message.name)")
            return
        }
        
        print("[Bridge] Received action: \(action)")
        
        switch action {
        case "list":
            print("[Bridge] Handling 'list' action, sending \(recipes.count) recipes")
            sendRecipesToJS()
            
        case "add":
            if let recipeData = body["recipe"] as? [String: Any],
               let title = recipeData["title"] as? String {
                let newId = String(recipes.count + 1)
                let newRecipe: [String: Any] = [
                    "id": newId,
                    "title": title,
                    "image_url": recipeData["image_url"] ?? "",
                    "description": recipeData["description"] ?? "",
                    "notes": recipeData["notes"] ?? "",
                    "total_time": recipeData["total_time"] ?? 0
                ]
                recipes.append(newRecipe)
                sendRecipesToJS()
            }
            
        case "delete":
            if let recipeId = body["recipeId"] as? String {
                recipes.removeAll { ($0["id"] as? String) == recipeId }
                sendRecipesToJS()
            }
            
        default:
            break
        }
    }
    
    private func sendRecipesToJS() {
        guard let webView = webView else {
            print("[Bridge] Error: webView is nil")
            return
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: recipes),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            let js = "if (window.onNativeRecipesUpdate) { window.onNativeRecipesUpdate(\(jsonString)); } else { console.log('onNativeRecipesUpdate not defined'); }"
            print("[Bridge] Sending recipes to JS: \(recipes.count) recipes")
            webView.evaluateJavaScript(js) { result, error in
                if let error = error {
                    print("[Bridge] Error sending recipes to JS: \(error)")
                } else {
                    print("[Bridge] Successfully sent recipes to JS")
                }
            }
        }
    }
}
