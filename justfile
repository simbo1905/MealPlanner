# MealPlanner Build Automation
# Use `just` to list all available commands

# Default recipe: list all available commands
default:
    @just --list

# --- Web App --- #

# Run the web app in development mode with Vite
web-vite:
    sh ./scripts/web-vite.sh start

# Stop the Vite dev server
web-vite-stop:
    sh ./scripts/web-vite.sh stop

# Create a self-contained web app bundle for native deployment
web-bundle:
    sh ./scripts/web-bundle.sh

# Serve the web app bundle locally for testing on port 3333
web-serve:
    sh ./scripts/web-serve.sh start

# Stop the local web server
web-stop:
    sh ./scripts/web-serve.sh stop

# Build the web app and serve it locally
web-run:
    just web-bundle && just web-serve

# Clean the web app build artifacts
web-clean:
    rm -rf apps/web/build apps/web/.svelte-kit

# --- iOS --- #

# Deploy the web app bundle to the iOS project
ios-deploy:
    sh ./scripts/ios-deploy.sh

# Clean the iOS build artifacts
ios-clean:
    rm -rf apps/ios/build

# --- Android (DO NOT TOUCH) --- #

# Build the Android wrapper with the latest web bundle
build-android:
    sh ./scripts/build_android.sh

# Manage Android SDK / launch Android Studio
android-sdk action='studio':
    sh ./scripts/android_sdk.sh {{action}}

# Deploy Android app (rebuild web bundle, copy assets, build, install, launch)
deploy-android:
    sh ./scripts/build_and_deploy_ios.sh # This should be build_and_deploy_android.sh, but for now we use the ios one
    sh ./scripts/build_android.sh
    sh ./scripts/launch_android.sh

# Clean Android build artifacts (web bundle untouched)
clean-android:
    sh ./scripts/clean_android.sh

# --- Prototypes (DO NOT TOUCH) --- #

# Build and manage prototype servers
# Usage: just prototype <num> <action>
# Actions: start, stop, reload
prototype num action:
    sh ./scripts/prototype.sh {{num}} {{action}}

# --- Global --- #

# Clean all build artifacts
all-clean:
    just web-clean
    just ios-clean
    just clean-android

# Full repair of web environment (clear pnpm cache and reinstall)
nuke-web:
    sh ./scripts/nuke_web.sh