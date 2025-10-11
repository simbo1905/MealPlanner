#!/usr/bin/env bash
set -euo pipefail

# Wrapper for invoking pnpm with a healthy environment.
# - Forces PNPM_HOME away from the repo to avoid corrupting node_modules
# - Falls back to plain pnpm if mise isn't available

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEFAULT_PNPM_HOME="${HOME}/Library/pnpm"

# Guard against PNPM_HOME pointing inside the repository (breaks pnpm installs)
if [[ "${PNPM_HOME:-}" == "$ROOT_DIR"* ]]; then
  echo "[run-pnpm] Detected PNPM_HOME inside repository. Using $DEFAULT_PNPM_HOME instead."
  export PNPM_HOME="$DEFAULT_PNPM_HOME"
fi

mkdir -p "$DEFAULT_PNPM_HOME"

if command -v mise >/dev/null 2>&1; then
  mise exec -- pnpm "$@"
else
  pnpm "$@"
fi
