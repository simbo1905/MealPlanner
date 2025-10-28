# MealPlanner - Flutter App Build Automation
# App location: ./meal_planner
# Use `just` to list all available commands
#
# Pass-through: Use `just flutter <args>` to run Flutter CLI in the app directory
# Example: just flutter run, just flutter build apk, just flutter analyze

# Default recipe: list all available commands
default:
    @just --list

# --- Flutter App --- #

# Pass through Flutter CLI commands
# Usage: just flutter <flutter-args>
# Examples:
#   just flutter run
#   just flutter build apk
#   just flutter analyze
#   just flutter pub get
flutter +args='--help':
    cd meal_planner && flutter {{args}}

# --- Firebase Backend --- #

# (Removed) PocketBase Dart setup script
# Previous target `pocketbase-setup` referenced a non-existent Dart script.

# Manage Firebase dev server
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

# --- Tooling --- #

# Run repomix to generate code context
# Usage: just repomix [platform]
# Default: flutter
repomix platform='flutter':
    sh ./scripts/repomix.sh {{platform}}

# Manage Android SDK / launch Android Studio
# Usage: just android-sdk [studio|ensure|avd|emulator|doctor]
android-sdk action='studio':
    sh ./scripts/android_sdk.sh {{action}}

# --- Promptfoo Testing --- #

# Run promptfoo commands via Bun
# Usage: just promptfoo test, just promptfoo eval, etc.
promptfoo +args='--help':
    sh ./scripts/promptfoo.sh {{args}}
