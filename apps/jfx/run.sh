#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "Using Java version:"
java --version
echo

echo "Building & running JavaFX 25 app..."
./gradlew --no-daemon clean run
