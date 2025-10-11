#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"
"$SCRIPT_DIR/run_pnpm.sh" clean

rm -rf "$ROOT_DIR/node_modules"
rm -rf "$ROOT_DIR"/apps/*/node_modules
rm -rf "$ROOT_DIR"/packages/*/node_modules
