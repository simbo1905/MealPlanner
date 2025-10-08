#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$ROOT_DIR/apps/android"

log() {
  printf "[bootstrap:android] %s\n" "$*"
}

warn() {
  printf "[bootstrap:android][warn] %s\n" "$*" >&2
}

if [ -d "$ANDROID_DIR" ] && [ -n "$(find "$ANDROID_DIR" -mindepth 1 -maxdepth 1 2>/dev/null)" ]; then
  warn "Android scaffold already exists in apps/android; skipping creation."
  exit 0
fi

log "Creating Android scaffold under apps/android"
mkdir -p "$ANDROID_DIR/app/src/main/java/com/mealplanner/app" \
         "$ANDROID_DIR/app/src/main/res/layout" \
         "$ANDROID_DIR/app/src/main/res/values"

cat <<'KTS' > "$ANDROID_DIR/settings.gradle.kts"
rootProject.name = "MealPlannerAndroid"
include(":app")
KTS

cat <<'KTS' > "$ANDROID_DIR/build.gradle.kts"
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.6.0")
        classpath(kotlin("gradle-plugin", version = "1.9.25"))
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
KTS

cat <<'PROPS' > "$ANDROID_DIR/gradle.properties"
org.gradle.jvmargs=-Xmx2g -Dkotlin.daemon.jvm.options=-Xmx2g
android.useAndroidX=true
kotlin.code.style=official
PROPS

cat <<'KTS' > "$ANDROID_DIR/app/build.gradle.kts"
plugins {
    id("com.android.application")
    kotlin("android")
}

android {
    namespace = "com.mealplanner.app"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.mealplanner.app"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "0.1.0"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.activity:activity-ktx:1.9.3")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
}
KTS

cat <<'XML' > "$ANDROID_DIR/app/src/main/AndroidManifest.xml"
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="MealPlanner"
        android:supportsRtl="true"
        android:theme="@style/Theme.MaterialComponents.DayNight.NoActionBar">
        <activity android:name=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
XML

cat <<'KT' > "$ANDROID_DIR/app/src/main/java/com/mealplanner/app/MainActivity.kt"
package com.mealplanner.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                Surface {
                    Text(text = "Hello, Recipe!")
                }
            }
        }
    }
}
KT

cat <<'XML' > "$ANDROID_DIR/app/src/main/res/layout/activity_main.xml"
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity">

    <TextView
        android:id="@+id/helloText"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Hello, Recipe!"
        android:textSize="18sp"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

</androidx.constraintlayout.widget.ConstraintLayout>
XML

cat <<'PRO' > "$ANDROID_DIR/app/proguard-rules.pro"
# Keep file intentionally empty for now.
PRO

if command -v gradle >/dev/null 2>&1; then
  log "Gradle detected – generating wrapper (gradle wrapper --gradle-version 8.9)"
  (cd "$ANDROID_DIR" && gradle wrapper --gradle-version 8.9 >/dev/null)
else
  warn "gradle not found. Install Gradle then run 'cd apps/android && gradle wrapper --gradle-version 8.9'."
fi

log "Android bootstrap complete."
