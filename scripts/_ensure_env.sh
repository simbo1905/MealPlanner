#!/usr/bin/env sh
set -eu

# Ensure mise is installed and configured.
# Parses mise.toml, activates the environment, and auto-installs missing tools.
# Fast validation using version checks to warm disk cache.

if ! command -v mise >/dev/null 2>&1; then
    echo "Error: mise is not installed. Please install it to continue." >&2
    echo "See: https://mise.jdx.dev/getting-started.html" >&2
    exit 1
fi

# Get the repository root (directory containing mise.toml)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MISE_TOML="$REPO_ROOT/mise.toml"

if [ ! -f "$MISE_TOML" ]; then
    echo "Error: mise.toml not found at $MISE_TOML" >&2
    exit 1
fi

# Activate the mise environment for the current shell.
# Detect the calling shell or use bash as fallback.
CALLING_SHELL="${SHELL##*/}"
case "$CALLING_SHELL" in
    bash|zsh|fish|elvish|xonsh|nu|pwsh) ;;
    *) CALLING_SHELL="bash" ;;
esac
eval "$(mise env -s "$CALLING_SHELL")"

# Parse tools from mise.toml and validate installations
# Only extract lines from [tools] section like: bun = "1.1.0", node = "20"
TOOLS_TO_CHECK=""
IN_TOOLS_SECTION=0
while IFS= read -r line; do
    # Check for section headers
    case "$line" in
        "[tools]")
            IN_TOOLS_SECTION=1
            continue
            ;;
        "["*"]")
            IN_TOOLS_SECTION=0
            continue
            ;;
    esac
    
    # Only process lines if we're in [tools] section
    if [ "$IN_TOOLS_SECTION" -eq 1 ]; then
        case "$line" in
            *"="*)
                # Extract tool name (e.g., bun from 'bun = "1.1.0"')
                tool_name=$(echo "$line" | sed -n 's/^[ \t]*\([a-zA-Z_][a-zA-Z0-9_]*\)[ \t]*=.*/\1/p')
                if [ -n "$tool_name" ]; then
                    TOOLS_TO_CHECK="$TOOLS_TO_CHECK $tool_name"
                fi
                ;;
        esac
    fi
done < "$MISE_TOML"

# Check each tool and install if missing
NEEDS_INSTALL=0
for tool_name in $TOOLS_TO_CHECK; do
    if ! command -v "$tool_name" >/dev/null 2>&1; then
        NEEDS_INSTALL=1
        break
    fi
done

# If any tool is missing, run mise install
if [ "$NEEDS_INSTALL" -eq 1 ]; then
    echo "Installing mise tools from $MISE_TOML..." >&2
    mise install
    # Re-activate environment after install
    eval "$(mise env -s "$CALLING_SHELL")"
fi

# Quick validation: check tool versions to ensure they're properly installed
for tool_name in $TOOLS_TO_CHECK; do
    if ! mise which "$tool_name" >/dev/null 2>&1; then
        echo "Error: Required tool '$tool_name' is not available after mise install." >&2
        exit 1
    fi
done
