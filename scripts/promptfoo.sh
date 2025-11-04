#!/usr/bin/env sh
set -eu

# Change to the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source environment setup to ensure bun and node are available
. "${SCRIPT_DIR}/_ensure_env.sh" "bun@1.1.0" "node@20"

# Load environment variables from .env if present
ENV_FILE="${PROJECT_ROOT}/.env"
if [ -f "${ENV_FILE}" ]; then
  # shellcheck disable=SC1090
  set -a
  . "${ENV_FILE}"
  set +a
else
  echo "Error: ${ENV_FILE} not found. Create it (copy .env.example) with MISTRAL_API_KEY and GROQ_API_KEY." >&2
  exit 1
fi

# Validate required environment variables
if [ -z "${MISTRAL_API_KEY:-}" ]; then
  echo "Error: MISTRAL_API_KEY is not set. Please add it to ${ENV_FILE}." >&2
  exit 1
fi

if [ -z "${GROQ_API_KEY:-}" ]; then
  echo "Error: GROQ_API_KEY is not set. Please add it to ${ENV_FILE}." >&2
  exit 1
fi

# Change to promptfoo directory
cd "${PROJECT_ROOT}/promptfoo"

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo "Installing promptfoo dependencies..."
  bun install
fi

# Run promptfoo with all passed arguments
export MISTRAL_API_KEY
export GROQ_API_KEY
exec bun run promptfoo "$@"
