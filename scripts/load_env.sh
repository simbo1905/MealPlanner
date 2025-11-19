#!/bin/sh

# This script loads environment variables from a .env file in the project root.
# It's designed to be sourced by other scripts.

set -a # automatically export all variables
if [ -f "$(dirname "$0")/../.env" ]; then
  . "$(dirname "$0")/../.env"
fi
set +a
