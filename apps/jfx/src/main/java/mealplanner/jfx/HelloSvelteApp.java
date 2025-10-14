package mealplanner.jfx;

import javafx.application.Application;
import javafx.application.Platform;
import javafx.concurrent.Worker;
import javafx.scene.Scene;
import javafx.scene.web.WebEngine;
import javafx.scene.web.WebView;
import javafx.stage.Stage;
import netscape.javascript.JSObject;

public class HelloSvelteApp extends Application {

    public static class ConsoleBridge {
        public void log(String message) {
            System.out.println("[Browser log] " + message);
        }
    }

    @Override
    public void start(Stage stage) {
        WebView webView = new WebView();
        WebEngine engine = webView.getEngine();

        ConsoleBridge bridge = new ConsoleBridge();

        engine.getLoadWorker().stateProperty().addListener((obs, oldState, newState) -> {
            if (newState == Worker.State.SUCCEEDED) {
                new Thread(() -> {
                    for (int attempt = 1; attempt <= 10; attempt++) {
                        try {
                            Thread.sleep(500);
                        } catch (InterruptedException ignored) {}
                        Platform.runLater(() -> {
                            try {
                                JSObject window = (JSObject) engine.executeScript("window");
                                window.setMember("javaBridge", bridge);
                                engine.executeScript("""
                                    (function() {
                                        const oldLog = window.console.log;
                                        window.console.log = function(msg) {
                                            oldLog(msg);
                                            try { window.javaBridge.log(String(msg)); } catch (e) {}
                                        };
                                        console.log('[Injected] JavaFX console bridge active');
                                    })();
                                """);
                                System.out.println("[JavaFX] Console bridge installed");
                            } catch (Exception e) {
                                System.out.println("[JavaFX] Retry bridge install: " + e.getMessage());
                            }
                        });
                    }
                }).start();
            }
        });

        String indexUrl = new java.io.File("demo/helloworld/build/index.html")
                .toURI().toString();
        System.out.println("[JavaFX] Loading: " + indexUrl);
        engine.load(indexUrl);

        stage.setScene(new Scene(webView, 900, 700));
        stage.setTitle("Hello Svelte in JavaFX 25");
        stage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
