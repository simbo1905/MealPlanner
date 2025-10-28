#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PLATFORM="${1:-flutter}"
ACTION="${2:-run}"
shift 2 || shift 1 || true

SCRIPT_NAME="repomix_${PLATFORM}"
PID_FILE="/tmp/${SCRIPT_NAME}.pid"
LOG_FILE="/tmp/${SCRIPT_NAME}.log"
OUTPUT_FILE="repomix-${PLATFORM}.md"

cleanup() {
  [[ "${ACTION}" == "run" ]] && rm -f "${PID_FILE}"
}
trap cleanup EXIT

if ! command -v bunx >/dev/null 2>&1; then
  echo "Error: bunx not found. Please install bun: https://bun.sh" >&2
  exit 1
fi

include_patterns="package.json,justfile,AGENTS.md,mise.toml"
ignore_patterns="**/node_modules/**,**/.git/**,**/build/**,**/dist/**,**/.svelte-kit/**,*.log,*.pid"

case "${PLATFORM}" in
  flutter)
    cd "${SCRIPT_DIR}/../meal_planner"
    include_patterns="**/*.dart,**/*.md,pubspec.yaml,analysis_options.yaml"
    ignore_patterns="build/**,.dart_tool/**,*.g.dart,*.freezed.dart"
    ;;
  *)
    echo "Usage: $0 [flutter] [run|status|stop|tail] [repomix flags...]" >&2
    exit 2
    ;;
esac

command_args=(
  bunx --bun repomix
  --style markdown
  --output "${OUTPUT_FILE}"
  --include "${include_patterns}"
  --ignore "${ignore_patterns}"
  "$@"
)

case "${ACTION}" in
  run)
    mkdir -p "$(dirname "${LOG_FILE}")"
    echo "Generating repomix for ${PLATFORM} → ${OUTPUT_FILE}"
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
    echo "Usage: $0 [flutter] [run|status|stop|tail] [repomix flags...]" >&2
    exit 2
    ;;
esac
