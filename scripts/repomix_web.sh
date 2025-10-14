#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/_ensure_env.sh" "bun @1.3"

SCRIPT_NAME="repomix_web"
PID_FILE="/tmp/${SCRIPT_NAME}.pid"
LOG_FILE="/tmp/${SCRIPT_NAME}.log"

ACTION="${1:-run}"
shift || true

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

# Includes root configs, the web app, shared packages, and relevant tooling configs.
# Excludes other apps, prototypes, and all build/dependency artifacts.
command_args=(
  bunx
  --bun
  repomix
  --style
  markdown
  --include "package.json,pnpm-workspace.yaml,justfile,AGENTS.md,apps/web/**,packages/**,tooling/typescript-config/base.json,tooling/eslint-config/**,tooling/prettier-config/**"
  --ignore "**/node_modules/**,**/.git/**,**/build/**,**/dist/**,**/.svelte-kit/**,prototype/**,apps/android/**,apps/ios/**,apps/jfx/**,*.log,*.pid"
  "$@"
)

if ! command -v bunx >/dev/null 2>&1; then
    cat >&2 <<'EOF'
bunx (from bun) is required to run repomix. Install via `mise install bun @1.3` or `brew install bun`.
EOF
    exit 1
fi

case "${ACTION}" in
  run)
    ensure_log_files
    echo "Launching ${command_args[*]} (log: ${LOG_FILE})"
    "${command_args[@]}" &> "${LOG_FILE}" &
    pid=$!
    echo "${pid}" > "${PID_FILE}"
    if ! wait "${pid}"; then
      status=$?
      echo "repomix export failed, inspect ${LOG_FILE}" >&2
      exit "${status}"
    fi
    cat "${LOG_FILE}"
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
