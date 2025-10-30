#!/usr/bin/env sh
set -eu

# Ensure Bun and Node.js are available via mise
. "$(dirname "$0")/_ensure_env.sh"

# Navigate to promptfoo directory and run the command
cd "$(dirname "$0")/../promptfoo"
bun run "$@"
