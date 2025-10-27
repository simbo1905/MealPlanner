# MealPlanner Build Automation
# Use `just` to list all available commands

# Default recipe: list all available commands
default:
    @just --list

# --- iOS --- #

# Deploy to the iOS project
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

# --- Tooling --- #

# Run repomix to generate code context for a specific platform
# Usage: just repomix <platform> (e.g., web, ios, android, jfx)
repomix platform:
    sh ./scripts/repomix.sh {{platform}}

# --- Global --- #

# Clean all build artifacts
all-clean:
    just ios-clean
    just clean-android

# --- PocketBase Backend --- #

# Setup PocketBase local development environment (Dart-based, probes for free port)
# Requirements: .env file with PB_ADMIN_USER and PB_ADMIN_PASSWORD
pocketbase-setup:
    dart scripts/setup_pocketbase.dart

# Manage PocketBase dev server
# Usage: just pocketbase {stop|status|logs|test}
pocketbase action:
    sh ./scripts/pocketbase_dev.sh {{action}}

# --- Testing --- #

# Run all unit tests for event store
test-event-store:
    cd meal_planner && flutter test test/unit/services/entity_handle_test.dart test/unit/services/local_buffer_test.dart test/unit/services/merge_arbitrator_test.dart test/unit/services/uuid_generator_test.dart test/unit/models/store_event_test.dart

# Run integration tests for offline sync
test-offline-sync:
    cd meal_planner && flutter test integration_test/offline_sync_test.dart

# Run all unit tests
test-all-unit:
    cd meal_planner && flutter test test/unit/
