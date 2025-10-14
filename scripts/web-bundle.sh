#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"

log() {
    echo "[web-bundle] $1"
}

log "Preparing web bundle..."
node "$ROOT_DIR/scripts/prepare-web-bundle.mjs"
