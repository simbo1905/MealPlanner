#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🩺 Running MealPlanner web environment doctor..."

# Remove workspace node_modules and lockfile
rm -rf "$ROOT_DIR/node_modules" "$ROOT_DIR/pnpm-lock.yaml"
rm -rf "$ROOT_DIR/node_modules/.pnpm/store" 2>/dev/null || true

# Prune pnpm store safely
"$SCRIPT_DIR/run_pnpm.sh" store prune --force || true

STORE_PATH="$("$SCRIPT_DIR/run_pnpm.sh" store path 2>/dev/null || echo "${HOME}/Library/pnpm/store")"
rm -rf "$STORE_PATH"

cd "$ROOT_DIR"
"$SCRIPT_DIR/run_pnpm.sh" install
