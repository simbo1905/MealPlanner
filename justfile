# MealPlanner Build Automation
# Use `just` to list all available commands

# Default recipe: list all available commands
default:
    @just --list

# Build and manage prototype servers
# Usage: just prototype <num> <action>
# Actions: start, stop, reload
prototype num action:
    sh ./scripts/prototype.sh {{num}} {{action}}

# Build webapp with pnpm
build-webapp:
    sh ./scripts/build_webapp.sh

# Build webapp with clean cache
clean-build-webapp:
    sh ./scripts/clean_build_webapp.sh

# Start webapp dev mode
dev-webapp:
    sh ./scripts/webapp.sh start

# Start webapp production server
webapp action:
    sh ./scripts/webapp.sh {{action}}

# Clean all build artifacts
clean:
    sh ./scripts/clean.sh

# Clean everything including node_modules
clean-all:
    sh ./scripts/clean_all.sh

# Full repair of web environment (clear pnpm cache and reinstall)
nuke-web:
    sh ./scripts/nuke_web.sh

# Build webapp to static bundle for deployment
build-bundle:
    sh ./scripts/build_webapp_bundle.sh

# Build the iOS wrapper with the latest web bundle
build-ios:
    sh ./scripts/build_ios.sh

# Build the Android wrapper with the latest web bundle
build-android:
    sh ./scripts/build_android.sh

# Manage Android SDK / launch Android Studio
android-sdk action='studio':
    sh ./scripts/android_sdk.sh {{action}}

# Deploy Android app (rebuild web bundle, copy assets, build, install, launch)
deploy-android:
    sh ./scripts/build_webapp_bundle.sh
    sh ./scripts/deploy_webapp_to_android.sh
    sh ./scripts/build_android.sh
    sh ./scripts/launch_android.sh

# Clean Android build artifacts (web bundle untouched)
clean-android:
    sh ./scripts/clean_android.sh

# Deploy webapp bundle to iOS Resources
deploy-ios:
    sh ./scripts/build_webapp_bundle.sh
    sh ./scripts/deploy_webapp_to_ios.sh
