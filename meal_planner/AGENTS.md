Agent Working Guide

Scope: This file applies to the entire repository.

General Principles
- Be concise, surgical, and follow flutter_lints.
- Keep providers pure; prefer ref.read(...) inside notifiers’ imperative methods.
- Tests must be deterministic locally (use fakes by default; opt-in to Firebase via flags).

Build & Codegen
- Install deps: `flutter pub get`
- Generate code: `dart run build_runner build --delete-conflicting-outputs`
- Analyze: `flutter analyze` must return 0 issues before pushing.

Running Tests
- Unit/Widget tests: `flutter test -r expanded -j 1`
- Integration tests: Android‑Studio‑Only workflow below (Android only; no Chrome).

## Android‑Studio‑Only Workflow (M‑Series Mac)
Goal: Build the Meal‑Planner Flutter app for Android, run the Flutter integration tests, and capture logs without ever invoking the `emulator` CLI. Let Android Studio launch the virtual device (or attach a physical device) and then drive the tests from the terminal/Android Studio’s built‑in terminal.

### 1️⃣ Prerequisites – ARM‑native tools only

| Tool | Install / set‑up (run once) |
|------|-----------------------------|
| Homebrew (arm64) | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |
| OpenJDK 17 | `brew install openjdk@17` then add to shell profile: `export JAVA_HOME=$(brew --prefix openjdk@17); export PATH=$JAVA_HOME/bin:$PATH` |
| Android Studio (Apple Silicon) | Download “Mac with Apple Silicon” DMG from https://developer.android.com/studio and drag to /Applications |
| Flutter (stable, arm64) | `git clone https://github.com/flutter/flutter.git -b stable && export PATH="$PATH:$HOME/flutter/bin" && flutter upgrade` |
| Android SDK / Platform‑Tools | In Android Studio: Preferences → System Settings → Android SDK → install Android 14 (or latest), Platform‑Tools, Build‑Tools 34.x (or latest) |

Run once: `flutter doctor -v` and ensure Android toolchain, SDK, Java, and Android Studio are green.

### 2️⃣ Open the Project in Android Studio
File → Open… → select the repository folder (the one containing `pubspec.yaml`). Android Studio will detect the Flutter module.

### 3️⃣ Launch an Android Emulator from Android Studio
Use Tools → AVD Manager to create a device (e.g., Pixel 5, Arm 64‑v8a image) and click Play to launch it. You can also plug in a physical device with USB‑debugging.

### 4️⃣ Verify the Device Is Visible to `adb`
Run `adb devices` and ensure an emulator or phone shows as `device`.

### 5️⃣ Build the Debug APK (sanity check)
`flutter build apk --debug`

### 6️⃣ Run Flutter Integration Tests on the Launched Emulator

6.1 One‑liner (manual):
`flutter test integration_test/dnd_comprehensive_test.dart --device-id <device-id> --timeout 300`

6.2 Automated runner (no emulator CLI):
- Script: `tool/run_android_integration_tests.dart`
- Run: `dart run tool/run_android_integration_tests.dart`
- Produces logs in `./tmp/`: `test_<name>.log` per test and `logcat.log` for the device.

Timeout + Logging policy
- Tests are wrapped with a 300s timeout and console output is written to `tmp/test_<name>.log`.
- If GNU `timeout` is unavailable, the runner falls back to `gtimeout` (coreutils) or a manual kill‑after‑timeout.
- On stall/failure, inspect `tmp/logcat.log` and the corresponding `tmp/test_*.log`.

Notes
- Prefer fake repositories for tests; only switch to Firebase with explicit flags.
- Keep flaky UI animations disabled in tests and avoid infinite scroll growth without user input.

