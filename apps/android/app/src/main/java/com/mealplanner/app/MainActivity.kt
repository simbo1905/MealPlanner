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
import androidx.webkit.WebViewAssetLoader

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

        val assetLoader = WebViewAssetLoader.Builder()
            .addPathHandler("/webapp/", WebViewAssetLoader.AssetsPathHandler(this))
            .build()

        webView.webViewClient = object : WebViewClient() {
            override fun shouldInterceptRequest(
                view: WebView,
                request: WebResourceRequest
            ): WebResourceResponse? {
                val response = assetLoader.shouldInterceptRequest(request.url)
                return response ?: super.shouldInterceptRequest(view, request)
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

        val startUrl = "https://appassets.androidplatform.net/webapp/index.html"
        Log.d(TAG, "Loading: $startUrl")
        webView.loadUrl(startUrl)
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
