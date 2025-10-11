#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"
"$SCRIPT_DIR/run_pnpm.sh" clean:web
"$SCRIPT_DIR/run_pnpm.sh" build:web
