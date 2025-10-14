#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"

log() {
    echo "[web-bundle] $1"
}

log "Running SvelteKit production build..."
npm --prefix "$ROOT_DIR/apps/web" run build
