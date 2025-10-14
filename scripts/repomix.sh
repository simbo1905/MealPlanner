#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_ensure_env.sh" "bun @1.3"

PLATFORM="${1:-web}"
shift || true

SCRIPT_NAME="repomix_${PLATFORM}"
PID_FILE="/tmp/${SCRIPT_NAME}.pid"
LOG_FILE="/tmp/${SCRIPT_NAME}.log"
OUTPUT_FILE="repomix-${PLATFORM}.md"

cleanup() {
  if [[ "${ACTION}" == "run" ]]; then
    rm -f "${PID_FILE}"
  fi
}
trap cleanup EXIT

ensure_log_files() {
  mkdir -p "$(dirname "${LOG_FILE}")"
  : > "${LOG_FILE}"
}

# Default includes for all platforms
include_patterns="package.json,pnpm-workspace.yaml,justfile,AGENTS.md,mise.toml,packages/**,tooling/**"
ignore_patterns="**/node_modules/**,**/.git/**,**/build/**,**/dist/**,**/.svelte-kit/**,prototype/**,*.log,*.pid"

case "${PLATFORM}" in
  web)
    include_patterns+=",apps/web/**"
    ignore_patterns+=",apps/ios/**,apps/android/**,apps/jfx/**"
    ;;
  ios)
    include_patterns+=",apps/ios/**,*.xcodeproj/**"
    ignore_patterns+=",apps/web/**,apps/android/**,apps/jfx/**,**/*.app/**,**/build/**"
    ;;
  android)
    include_patterns+=",apps/android/**,*.gradle*,gradle.properties"
    ignore_patterns+=",apps/web/**,apps/ios/**,apps/jfx/**,**/build/**,**/.gradle/**"
    ;;
  jfx)
    include_patterns+=",apps/jfx/**,*.gradle"
    ignore_patterns+=",apps/web/**,apps/ios/**,apps/android/**,**/build/**,**/.gradle/**"
    ;;
  *)
    echo "Usage: $0 [web|ios|android|jfx] [repomix flags...]" >&2
    exit 2
    ;;
esac

command_args=(
  bunx
  --bun
  repomix
  --style
  markdown
  --output "${OUTPUT_FILE}"
  --include "${include_patterns}"
  --ignore "${ignore_patterns}"
  "$@"
)

ACTION="${1:-run}"

if ! command -v bunx >/dev/null 2>&1; then
    cat >&2 <<'EOF'
bunx (from bun) is required to run repomix. Install via `mise install bun @1.3` or `brew install bun`.
EOF
    exit 1
fi

case "${ACTION}" in
  run)
    ensure_log_files
    echo "Launching repomix for ${PLATFORM} (log: ${LOG_FILE}, output: ${OUTPUT_FILE})"
    echo "Command: ${command_args[*]}"
    "${command_args[@]}" &> "${LOG_FILE}" &
    pid=$!
    echo "${pid}" > "${PID_FILE}"
    if ! wait "${pid}"; then
      status=$?
      echo "repomix export failed, inspect ${LOG_FILE}" >&2
      exit "${status}"
    fi
    cat "${LOG_FILE}"
    echo "Repomix context file created at ${OUTPUT_FILE}"
    ;;
  status)
    if [[ -f "${PID_FILE}" ]]; then
      pid=$(<"${PID_FILE}")
      if kill -0 "${pid}" 2>/dev/null; then
        echo "${SCRIPT_NAME} running with PID ${pid}"
        exit 0
      fi
    fi
    echo "${SCRIPT_NAME} is not running"
    exit 1
    ;;
  stop)
    if [[ -f "${PID_FILE}" ]]; then
      pid=$(<"${PID_FILE}")
      if kill -0 "${pid}" 2>/dev/null; then
        kill "${pid}"
        wait "${pid}" || true
        echo "Stopped ${SCRIPT_NAME}"
      else
        echo "Process ${pid} not running"
      fi
      rm -f "${PID_FILE}"
    else
      echo "No PID file found for ${SCRIPT_NAME}"
    fi
    ;;
  tail)
    if [[ -f "${LOG_FILE}" ]]; then
      tail -100 "${LOG_FILE}"
    else
      echo "Log file ${LOG_FILE} not found"
      exit 1
    fi
    ;;
  *)
    echo "Usage: $0 [run|status|stop|tail] [repomix flags...]" >&2
    exit 2
    ;;
esac
