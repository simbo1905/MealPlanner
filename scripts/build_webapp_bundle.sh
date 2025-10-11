#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_PNPM="$ROOT_DIR/scripts/run_pnpm.sh"
WEBAPP_DIR="$ROOT_DIR/apps/web"
DIST_DIR="$WEBAPP_DIR/dist"

log() {
  printf "[build-webapp-bundle] %s\n" "$*"
}

if [ ! -d "$WEBAPP_DIR" ]; then
  echo "Error: webapp directory not found at $WEBAPP_DIR"
  exit 1
fi

log "Building Vite webapp bundle..."
cd "$ROOT_DIR"
"$RUN_PNPM" build:web

if [ ! -d "$DIST_DIR" ]; then
  echo "Error: build output not found at $DIST_DIR"
  exit 1
fi

log "✅ Webapp bundle built successfully at $DIST_DIR"
