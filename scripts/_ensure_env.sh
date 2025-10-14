#!/usr/bin/env bash
set -Eeuo pipefail

# This script ensures that the environment is correctly configured using mise.
# It checks for the presence of mise and then verifies that all specified
# tools are installed and available in the environment.

if ! command -v mise &> /dev/null; then
    echo "Error: mise is not installed. Please install it to continue." >&2
    echo "See: https://mise.jdx.dev/getting-started.html" >&2
    exit 1
fi

# Activate the mise environment for the current shell.
# This exports the necessary environment variables (e.g., PATH).
eval "$(mise env -s bash)"

# Check if the required tools specified as arguments are available.
for tool_spec in "$@"; do
    tool_name=$(echo "$tool_spec" | cut -d'@' -f1 | xargs)
    if ! mise which "$tool_name" &>/dev/null; then
        echo "Error: Required tool '$tool_name' (from spec '$tool_spec') is not available via mise." >&2
        echo "Please ensure it is in your .mise.toml file and run 'mise install'." >&2
        exit 1
    fi
done
