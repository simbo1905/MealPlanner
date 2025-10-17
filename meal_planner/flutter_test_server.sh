#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SCRIPT_NAME="$(basename "$0")"
TMP_DIR="$ROOT_DIR/.tmp"
LOG_FILE="$TMP_DIR/$SCRIPT_NAME.log"
PID_FILE="$TMP_DIR/$SCRIPT_NAME.pid"
PROJECT_DIR="$SCRIPT_DIR"
CHROMEDRIVER_PORT=4444

mkdir -p "$TMP_DIR"
touch "$LOG_FILE"
: > "$LOG_FILE"

timestamp() {
  date +"%Y-%m-%dT%H:%M:%S%z"
}

log() {
  echo "$(timestamp) $*"
}

tests_passed() {
  grep -q "All tests passed!" "$LOG_FILE"
}

kill_with_retries() {
  local pid=$1
  local label=$2
  local attempts=0
  local max_attempts=5

  if ! kill -0 "$pid" 2>/dev/null; then
    log "$label (pid $pid) already exited."
    return 0
  fi

  log "Stopping $label (pid $pid)."
  kill "$pid" 2>/dev/null || true

  while kill -0 "$pid" 2>/dev/null && (( attempts < max_attempts )); do
    attempts=$((attempts + 1))
    sleep 1
    log "$label still running after ${attempts}s; waiting..."
  done

  if kill -0 "$pid" 2>/dev/null; then
    log "$label unresponsive; sending SIGKILL."
    kill -9 "$pid" 2>/dev/null || true
  else
    log "$label stopped cleanly."
  fi
}

kill_children() {
  local parent=$1
  local label=$2
  local child_pids

  child_pids=$(pgrep -P "$parent" || true)
  if [[ -z "$child_pids" ]]; then
    return
  fi

  log "Terminating ${label} child processes: $child_pids"
  while read -r child; do
    [[ -z "$child" ]] && continue
    kill_with_retries "$child" "$label child"
  done <<< "$child_pids"
}

cleanup_remote_debugging_chrome() {
  local chrome_pids
  chrome_pids=$(pgrep -f "flutter_tools_chrome_device" || pgrep -f ".org.chromium.Chromium." || true)

  if [[ -z "$chrome_pids" ]]; then
    log "No lingering Chrome remote-debugging processes detected."
    return
  fi

  log "Terminating Chrome remote-debugging processes: $chrome_pids"
  while read -r pid; do
    [[ -z "$pid" ]] && continue
    kill_with_retries "$pid" "chrome (remote-debugging)"
  done <<< "$chrome_pids"
}

wait_for_chromedriver() {
  local attempt=0
  local max_attempts=20

  while (( attempt < max_attempts )); do
    if curl --silent --show-error --max-time 2 "http://127.0.0.1:${CHROMEDRIVER_PORT}/status" | grep -qi '"ready"[[:space:]]*:[[:space:]]*true'; then
      log "Chromedriver reported ready after $((attempt * 2))s."
      return 0
    fi
    attempt=$((attempt + 1))
    log "Waiting for chromedriver readiness (attempt ${attempt}/${max_attempts})."
    sleep 2
  done

  log "ERROR: Chromedriver failed to signal readiness within $((max_attempts * 2))s."
  return 1
}

cleanup() {
  local exit_code=$1

  if [[ -n "${CHROMEDRIVER_PID:-}" ]]; then
    kill_with_retries "$CHROMEDRIVER_PID" "chromedriver"
  fi

  if [[ -n "${FLUTTER_PID:-}" ]]; then
    kill_with_retries "$FLUTTER_PID" "flutter drive"
  fi

  cleanup_remote_debugging_chrome

  rm -f "$PID_FILE"

  log "--- Test Run Finished (exit ${exit_code}) ---"
}

run_tests() {
  trap 'cleanup $?' EXIT

  log "--- Starting Test Run (runner pid $$) ---"

  if ! command -v chromedriver >/dev/null 2>&1; then
    log "ERROR: chromedriver not found in PATH."
    return 1
  fi

  if pgrep chromedriver >/dev/null 2>&1; then
    log "Previous chromedriver processes detected; terminating."
    pkill chromedriver || true
    sleep 1
  else
    log "No pre-existing chromedriver processes detected."
  fi

  if lsof -ti tcp:"$CHROMEDRIVER_PORT" >/dev/null 2>&1; then
    log "Port $CHROMEDRIVER_PORT currently in use; attempting to free it."
    lsof -ti tcp:"$CHROMEDRIVER_PORT" | while read -r pid; do
      [[ -z "$pid" ]] && continue
      kill_with_retries "$pid" "process on port $CHROMEDRIVER_PORT"
    done
  fi

  chromedriver --port="$CHROMEDRIVER_PORT" >> "$LOG_FILE" 2>&1 &
  CHROMEDRIVER_PID=$!
  log "Chromedriver started with pid $CHROMEDRIVER_PID on port $CHROMEDRIVER_PORT."

  if ! wait_for_chromedriver; then
    return 1
  fi
  log "Chromedriver readiness confirmed."

  local start_ts
  start_ts=$(date +%s)
  log "Launching flutter drive at $(timestamp)."

  pushd "$PROJECT_DIR" >/dev/null 2>&1

  flutter drive \
    --driver=test_driver/integration_test_driver.dart \
    --target=integration_test/calendar_web_test.dart \
    -d chrome &
  local flutter_pid=$!
  FLUTTER_PID=$flutter_pid
  log "flutter drive running with pid $flutter_pid."

  local forced_exit_code=""

  while kill -0 "$flutter_pid" 2>/dev/null; do
    sleep 5
    local elapsed
    elapsed=$(( $(date +%s) - start_ts ))
    log "flutter drive still running (elapsed ${elapsed}s)."
    if tests_passed; then
      log "Detected \"All tests passed!\"; terminating flutter drive and Chrome."
      if [[ -n "${CHROMEDRIVER_PID:-}" ]]; then
        kill_children "$CHROMEDRIVER_PID" "chromedriver"
      fi
      kill_children "$flutter_pid" "flutter drive"
      kill_with_retries "$flutter_pid" "flutter drive after pass"
      if [[ -n "${CHROMEDRIVER_PID:-}" ]]; then
        kill_with_retries "$CHROMEDRIVER_PID" "chromedriver after pass"
      fi
      forced_exit_code=0
      break
    fi
  done

  local flutter_exit_code
  if [[ -n "$forced_exit_code" ]]; then
    wait "$flutter_pid" 2>/dev/null || true
    flutter_exit_code=$forced_exit_code
  else
    wait "$flutter_pid"
    flutter_exit_code=$?
  fi
  popd >/dev/null 2>&1
  local end_ts
  end_ts=$(date +%s)
  local duration
  duration=$(( end_ts - start_ts ))

  log "flutter drive completed with exit code ${flutter_exit_code} after ${duration}s."
  return $flutter_exit_code
}

{
  printf "\n%s === Invocation started (script pid %s) ===\n" "$(timestamp)" "$$"
} >> "$LOG_FILE"

run_tests >> "$LOG_FILE" 2>&1 &
TEST_RUNNER_PID=$!
echo "$TEST_RUNNER_PID" > "$PID_FILE"

echo "Test runner started in background."
echo "PID: $TEST_RUNNER_PID"
echo "Log: $LOG_FILE"
