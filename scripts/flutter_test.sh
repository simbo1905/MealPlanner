#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../meal_planner" || exit 1

echo "Running Flutter tests..."

flutter test

echo ""
echo "All tests passed!"
