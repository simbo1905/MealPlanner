#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_ensure_env.sh" "bun @1.3"

SCRIPT_NAME="repomix_swift"
PID_FILE="/tmp/${SCRIPT_NAME}.pid"
LOG_FILE="/tmp/${SCRIPT_NAME}.log"
OUTPUT_FILE="repomix-swift.md"

ACTION="${1:-run}"
shift || true

cleanup() {
  [[ "${ACTION}" == "run" ]] && rm -f "${PID_FILE}"
}
trap cleanup EXIT

if ! command -v bunx >/dev/null 2>&1; then
  echo "Error: bunx not found. Install via 'mise install bun @1.3'" >&2
  exit 1
fi

command_args=(
  bunx --bun repomix
  --style markdown
  --output "${OUTPUT_FILE}"
  --include "AlphaNotes/**/*.swift,*.xcodeproj,*.xcworkspace,*.xcconfig,*.plist"
  --ignore "build/**,DerivedData/**,*.xcarchive/**"
  "$@"
)

case "${ACTION}" in
  run)
    mkdir -p "$(dirname "${LOG_FILE}")"
    echo "Generating Swift repomix → ${OUTPUT_FILE}"
    "${command_args[@]}" &> "${LOG_FILE}" &
    pid=$!
    echo "${pid}" > "${PID_FILE}"
    if wait "${pid}"; then
      echo "✓ Created ${OUTPUT_FILE}"
    else
      echo "✗ Failed. See ${LOG_FILE}" >&2
      exit 1
    fi
    ;;
  status)
    [[ -f "${PID_FILE}" ]] && pid=$(<"${PID_FILE}") && kill -0 "${pid}" 2>/dev/null && \
      echo "${SCRIPT_NAME} running (PID ${pid})" && exit 0
    echo "${SCRIPT_NAME} not running"
    exit 1
    ;;
  stop)
    if [[ -f "${PID_FILE}" ]]; then
      pid=$(<"${PID_FILE}")
      kill "${pid}" 2>/dev/null && wait "${pid}" 2>/dev/null || true
      rm -f "${PID_FILE}"
      echo "Stopped ${SCRIPT_NAME}"
    fi
    ;;
  tail)
    [[ -f "${LOG_FILE}" ]] && tail -100 "${LOG_FILE}" || { echo "No log file" >&2; exit 1; }
    ;;
  *)
    echo "Usage: $0 [run|status|stop|tail] [repomix flags...]" >&2
    exit 2
    ;;
esac
