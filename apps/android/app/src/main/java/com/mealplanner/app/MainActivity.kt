package com.mealplanner.app

import android.annotation.SuppressLint
import android.os.Bundle
import android.util.Log
import android.webkit.ConsoleMessage
import android.webkit.WebChromeClient
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity
import androidx.webkit.WebResourceErrorCompat
import androidx.webkit.WebViewClientCompat

class MainActivity : AppCompatActivity() {
    companion object {
        private const val TAG = "MealPlannerWebView"
    }

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        Log.d(TAG, "Activity created")

        val webView = findViewById<WebView>(R.id.webView)

        WebView.setWebContentsDebuggingEnabled(true)

        webView.webViewClient = object : WebViewClientCompat() {
            override fun shouldInterceptRequest(
                view: WebView,
                request: WebResourceRequest
            ): WebResourceResponse? {
                val localResponse = serveBundledAsset(request)
                return localResponse ?: super.shouldInterceptRequest(view, request)
            }

            override fun onReceivedError(
                view: WebView,
                request: WebResourceRequest,
                error: WebResourceErrorCompat
            ) {
                Log.e(
                    TAG,
                    "WebView error for ${request.url}: ${error.errorCode} ${error.description}"
                )
                super.onReceivedError(view, request, error)
            }
        }

        webView.webChromeClient = object : WebChromeClient() {
            override fun onConsoleMessage(consoleMessage: ConsoleMessage): Boolean {
                val msg = "[JS] ${consoleMessage.message()} @ ${consoleMessage.sourceId()}:${consoleMessage.lineNumber()}"
                when (consoleMessage.messageLevel()) {
                    ConsoleMessage.MessageLevel.ERROR -> Log.e(TAG, msg)
                    ConsoleMessage.MessageLevel.WARNING -> Log.w(TAG, msg)
                    else -> Log.d(TAG, msg)
                }
                return true
            }
        }

        webView.settings.javaScriptEnabled = true
        webView.settings.domStorageEnabled = true
        webView.settings.databaseEnabled = true

        val baseUrl = "https://appassets.androidplatform.net/webapp/"
        val htmlPath = "webapp/index.html"
        try {
            assets.open(htmlPath).use { input ->
                val html = input.bufferedReader().use { it.readText() }
                Log.d(TAG, "Loading HTML via loadDataWithBaseURL from $htmlPath")
                webView.loadDataWithBaseURL(baseUrl, html, "text/html", "UTF-8", null)
            }
        } catch (ex: Exception) {
            Log.e(TAG, "Failed to load bundled webapp HTML at $htmlPath", ex)
        }
    }

    private fun serveBundledAsset(request: WebResourceRequest): WebResourceResponse? {
        val url = request.url
        if (url.scheme != "https" || url.host != "appassets.androidplatform.net") {
            return null
        }

        val path = url.encodedPath ?: return null
        if (!path.startsWith("/webapp/")) {
            return null
        }

        val assetPath = path.removePrefix("/webapp/")
        if (assetPath.isEmpty()) {
            return null
        }

        return try {
            val stream = assets.open("webapp/$assetPath")
            val mimeType = when {
                assetPath.endsWith(".js") -> "application/javascript"
                assetPath.endsWith(".css") -> "text/css"
                assetPath.endsWith(".svg") -> "image/svg+xml"
                assetPath.endsWith(".json") || assetPath.endsWith(".map") -> "application/json"
                assetPath.endsWith(".html") -> "text/html"
                else -> "application/octet-stream"
            }

            val response = WebResourceResponse(mimeType, "UTF-8", stream)
            response.responseHeaders = mapOf(
                "Access-Control-Allow-Origin" to "*",
                "Access-Control-Allow-Credentials" to "true"
            )
            Log.d(TAG, "Serving $assetPath from bundled assets")
            response
        } catch (ex: Exception) {
            Log.e(TAG, "Asset load failed for $assetPath", ex)
            null
        }
    }

    override fun onStart() {
        super.onStart()
        Log.d(TAG, "Activity started")
    }

    override fun onResume() {
        super.onResume()
        Log.d(TAG, "Activity resumed")
    }
}
