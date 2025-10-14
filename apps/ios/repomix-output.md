This file is a merged representation of a subset of the codebase, containing specifically included files, combined into a single document by Repomix.

# File Summary

## Purpose
This file contains a packed representation of a subset of the repository's contents that is considered the most important context.
It is designed to be easily consumable by AI systems for analysis, code review,
or other automated processes.

## File Format
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Repository files (if enabled)
5. Multiple file entries, each consisting of:
  a. A header with the file path (## File: path/to/file)
  b. The full contents of the file in a code block

## Usage Guidelines
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.

## Notes
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Only files matching these patterns are included: **/*.swift, **/*.xcodeproj/**, **/*.md, **/*.plist, **/*.pbxproj, **/*.sh, **/*.js, **/*.css, **/*.ts, **/tsconfig.json, **/app.html
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Files are sorted by Git change count (files with more changes are at the bottom)

# Directory Structure
```
MealPlanner.xcodeproj/
  project.xcworkspace/
    xcuserdata/
      consensussolutions.xcuserdatad/
        UserInterfaceState.xcuserstate
    contents.xcworkspacedata
  xcuserdata/
    consensussolutions.xcuserdatad/
      xcschemes/
        xcschememanagement.plist
  project.pbxproj
Resources/
  Info.plist
Sources/
  ContentView.swift
  MealPlannerApp.swift
  WebViewCoordinator.swift
iOS.md
README.md
```

# Files

## File: MealPlanner.xcodeproj/project.xcworkspace/contents.xcworkspacedata
````
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
````

## File: MealPlanner.xcodeproj/xcuserdata/consensussolutions.xcuserdatad/xcschemes/xcschememanagement.plist
````
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>SchemeUserState</key>
	<dict>
		<key>MealPlanner.xcscheme_^#shared#^_</key>
		<dict>
			<key>orderHint</key>
			<integer>0</integer>
		</dict>
	</dict>
</dict>
</plist>
````

## File: MealPlanner.xcodeproj/project.pbxproj
````
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 77;
	objects = {

/* Begin PBXBuildFile section */
		12CE2C0FDB57B7401CB2AAE6 /* webapp in Resources */ = {isa = PBXBuildFile; fileRef = BB05ECC433C448BD4AA772F8 /* webapp */; };
		72BD8293050BCD0F8DDDDE92 /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = 9588231C8D45C6B405C025AF /* Assets.xcassets */; };
		901907E7AA09AC491C7E47DA /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A73E911DAA541CFDFBA090E3 /* ContentView.swift */; };
		A1360EF2663895D417BC4FAD /* MealPlannerApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = 82B3D97C85549D919FADD440 /* MealPlannerApp.swift */; };
		AA1DB9EAF44CD6E72D8FE03A /* WebViewCoordinator.swift in Sources */ = {isa = PBXBuildFile; fileRef = 765DA3FC7C7A6B92BE3B657D /* WebViewCoordinator.swift */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		132A732BD9970049430725ED /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist; path = Info.plist; sourceTree = "<group>"; };
		38ECCCD49A24C73137FA2EDB /* MealPlanner.app */ = {isa = PBXFileReference; includeInIndex = 0; lastKnownFileType = wrapper.application; path = MealPlanner.app; sourceTree = BUILT_PRODUCTS_DIR; };
		765DA3FC7C7A6B92BE3B657D /* WebViewCoordinator.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = WebViewCoordinator.swift; sourceTree = "<group>"; };
		7AC1E1CB33AECC63093107FC /* .gitignore */ = {isa = PBXFileReference; path = .gitignore; sourceTree = "<group>"; };
		82B3D97C85549D919FADD440 /* MealPlannerApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MealPlannerApp.swift; sourceTree = "<group>"; };
		9588231C8D45C6B405C025AF /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
		A73E911DAA541CFDFBA090E3 /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		BB05ECC433C448BD4AA772F8 /* webapp */ = {isa = PBXFileReference; lastKnownFileType = folder; name = webapp; path = Resources/webapp; sourceTree = SOURCE_ROOT; };
/* End PBXFileReference section */

/* Begin PBXGroup section */
		134BD7755EEC90076BF4DD8E /* Resources */ = {
			isa = PBXGroup;
			children = (
				7AC1E1CB33AECC63093107FC /* .gitignore */,
				132A732BD9970049430725ED /* Info.plist */,
			);
			path = Resources;
			sourceTree = "<group>";
		};
		64F39675F1172FA47A6368CB = {
			isa = PBXGroup;
			children = (
				9588231C8D45C6B405C025AF /* Assets.xcassets */,
				BB05ECC433C448BD4AA772F8 /* webapp */,
				134BD7755EEC90076BF4DD8E /* Resources */,
				D2E3C118F0342F579EEEB462 /* Sources */,
				C3DD0896B3E521327766B279 /* Products */,
			);
			sourceTree = "<group>";
		};
		C3DD0896B3E521327766B279 /* Products */ = {
			isa = PBXGroup;
			children = (
				38ECCCD49A24C73137FA2EDB /* MealPlanner.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		D2E3C118F0342F579EEEB462 /* Sources */ = {
			isa = PBXGroup;
			children = (
				A73E911DAA541CFDFBA090E3 /* ContentView.swift */,
				82B3D97C85549D919FADD440 /* MealPlannerApp.swift */,
				765DA3FC7C7A6B92BE3B657D /* WebViewCoordinator.swift */,
			);
			path = Sources;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		6DFF75702F8AA7F4CE31554E /* MealPlanner */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 818BA5CE0F4B605EF5A101F4 /* Build configuration list for PBXNativeTarget "MealPlanner" */;
			buildPhases = (
				B838F03CE911CFC6D200BA75 /* Sources */,
				1875E04848DC264DD58F443E /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = MealPlanner;
			packageProductDependencies = (
			);
			productName = MealPlanner;
			productReference = 38ECCCD49A24C73137FA2EDB /* MealPlanner.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		153CBAD90565AEE864DF4F46 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = YES;
				LastUpgradeCheck = 1430;
			};
			buildConfigurationList = 4AD4CE0F9F30F553F4722450 /* Build configuration list for PBXProject "MealPlanner" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				Base,
				en,
			);
			mainGroup = 64F39675F1172FA47A6368CB;
			minimizedProjectReferenceProxies = 1;
			preferredProjectObjectVersion = 77;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				6DFF75702F8AA7F4CE31554E /* MealPlanner */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		1875E04848DC264DD58F443E /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				72BD8293050BCD0F8DDDDE92 /* Assets.xcassets in Resources */,
				12CE2C0FDB57B7401CB2AAE6 /* webapp in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		B838F03CE911CFC6D200BA75 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				901907E7AA09AC491C7E47DA /* ContentView.swift in Sources */,
				A1360EF2663895D417BC4FAD /* MealPlannerApp.swift in Sources */,
				AA1DB9EAF44CD6E72D8FE03A /* WebViewCoordinator.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		25B2311705E811CE881F1B52 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
				CLANG_CXX_LIBRARY = "libc++";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"$(inherited)",
					"DEBUG=1",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_VERSION = 5.9;
			};
			name = Debug;
		};
		2C4EEBEF6AB26116485248CC /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_IDENTITY = "iPhone Developer";
				INFOPLIST_FILE = Resources/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				PRODUCT_BUNDLE_IDENTIFIER = com.mealplanner.app;
				SDKROOT = iphoneos;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
		324293B219269605D66F64E5 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
				CLANG_CXX_LIBRARY = "libc++";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				SWIFT_VERSION = 5.9;
			};
			name = Release;
		};
		BEDD6490986061C674B8F04A /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				CODE_SIGN_IDENTITY = "iPhone Developer";
				INFOPLIST_FILE = Resources/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				PRODUCT_BUNDLE_IDENTIFIER = com.mealplanner.app;
				SDKROOT = iphoneos;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		4AD4CE0F9F30F553F4722450 /* Build configuration list for PBXProject "MealPlanner" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				25B2311705E811CE881F1B52 /* Debug */,
				324293B219269605D66F64E5 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
		818BA5CE0F4B605EF5A101F4 /* Build configuration list for PBXNativeTarget "MealPlanner" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				BEDD6490986061C674B8F04A /* Debug */,
				2C4EEBEF6AB26116485248CC /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Debug;
		};
/* End XCConfigurationList section */
	};
	rootObject = 153CBAD90565AEE864DF4F46 /* Project object */;
}
````

## File: Resources/Info.plist
````
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
````

## File: Sources/ContentView.swift
````swift
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
````

## File: Sources/MealPlannerApp.swift
````swift
import SwiftUI

@main
struct MealPlannerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
````

## File: Sources/WebViewCoordinator.swift
````swift
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
````

## File: iOS.md
````markdown
# iOS WebView Integration for MealPlanner

Detailed architecture for embedding the MealPlanner Svelte + Vite webapp into an iOS native app using WKWebView.

## High-Level Architecture

> ⚙️ **Automation commands**
>
> - `just build-ios` – build the Svelte bundle, copy it into `Resources/webapp`, and run `xcodebuild` for a simulator target.
> - `just deploy-ios` – refresh only the embedded web assets without running Xcode.
> - `bash scripts/setup_ios.sh` – rebuild the bundle and regenerate `MealPlanner.xcodeproj` (no simulator build).

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
````

## File: README.md
````markdown
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
````
