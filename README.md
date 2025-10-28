# MealPlanner

A Flutter-based meal planning application with offline-first architecture and event sourcing.

## Quick Start

The Flutter app is located in `./meal_planner`. All build, test, and development commands go through the `just` task runner.

### Usage Examples

```bash
just flutter run                 # Run the Flutter app
just flutter build apk          # Build Android APK
just flutter analyze            # Analyze the code
just flutter pub get            # Update dependencies
just flutter test               # Run tests
just android-sdk studio         # Open Android Studio
just pocketbase status          # Check PocketBase status
just repomix flutter            # Generate code context
```

## Development

### Prerequisites
- Flutter (managed via `mise`)
- Java 17 (for Android builds)
- Android SDK (via Android Studio or `just android-sdk ensure`)

### Available Commands

See all available commands with:
```bash
just
```

### Testing

Run unit tests:
```bash
just test-all-unit
```

Run event store tests:
```bash
just test-event-store
```

Run integration tests:
```bash
just test-offline-sync
```

### PocketBase Backend

Setup local PocketBase development environment:
```bash
just pocketbase-setup
```

Manage the PocketBase dev server:
```bash
just pocketbase status
just pocketbase stop
just pocketbase logs
```

## Project Structure

- `meal_planner/` - Flutter application source code
  - `lib/` - Dart source code
  - `test/` - Unit and widget tests
  - `integration_test/` - Integration tests
  - `pubspec.yaml` - Flutter dependencies
- `scripts/` - Build and development scripts
- `specs/` - Feature specifications
- `memory/` - Project documentation
