#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------
# 1️⃣ Environment (Homebrew, Java, Android SDK)
# -------------------------------------------------
export ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools

# -------------------------------------------------
# 2️⃣ Flutter preparation
# -------------------------------------------------
cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)
echo "📂 Project root: $PROJECT_ROOT"
flutter --version || true

cd "$PROJECT_ROOT"
flutter clean
flutter pub get

# -------------------------------------------------
# 3️⃣ Verify device is present (started from Android Studio)
# -------------------------------------------------
DEVICE_ID=$(adb devices | awk '/\tdevice$/ && !/List/ {print $1; exit}')
if [[ -z "${DEVICE_ID:-}" ]]; then
  echo "❌ No Android device (emulator or phone) detected. Start one from Android Studio first."
  exit 1
fi
echo "📱 Using device $DEVICE_ID"

# -------------------------------------------------
# 4️⃣ Run integration tests with logging
# -------------------------------------------------
mkdir -p ./tmp
dart run tool/run_android_integration_tests.dart

# -------------------------------------------------
# 5️⃣ Append quick how-to to AGENTS.md (idempotent-ish)
# -------------------------------------------------
if ! grep -q "Android‑Only Integration‑Test Execution" AGENTS.md; then
  cat <<'EOF' >> AGENTS.md

## 📋 Android‑Only Integration‑Test Execution (Android Studio, M1/macOS)

```bash
# 1️⃣ Start an Android Virtual Device from Android Studio → AVD Manager
# 2️⃣ Run all integration tests:
dart run tool/run_android_integration_tests.dart
```

- Logs are stored in `./tmp/` (`test_*.log` + `logcat.log`).
EOF
fi

echo "✅ Android‑Studio pipeline finished successfully."

