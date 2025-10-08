#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

printf "[bootstrap][warn] 'bootstrap_native.sh' is deprecated. Use 'bootstrap_ios.sh' or 'bootstrap_android.sh' instead.\n"

"$ROOT_DIR/scripts/bootstrap_ios.sh" || true
"$ROOT_DIR/scripts/bootstrap_android.sh" || true

printf "[bootstrap] Combined bootstrap complete.\n"
