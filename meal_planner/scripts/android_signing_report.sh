#!/usr/bin/env bash
set -euo pipefail

# Print SHA-1 for debug/release using Gradle signingReport (offline when possible).
# No downloads are performed; relies on existing Gradle caches.

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT/android"

ARGS=("-q" "signingReport" "--offline")

echo "[signing] Running: ./gradlew ${ARGS[*]}"
if ./gradlew "${ARGS[@]}" >/tmp/signing_report.txt 2>&1; then
  :
else
  echo "[signing] Offline run failed, retrying without --offline..." >&2
  ./gradlew -q signingReport >/tmp/signing_report.txt 2>&1 || true
fi

echo "[signing] Parsed SHA1 values:"
awk '/Variant: /{variant=$0} /SHA1:/{print variant"\n"$0"\n"}' /tmp/signing_report.txt | sed -n '1,120p'

echo "[signing] Full report saved to /tmp/signing_report.txt"

