#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
WEBAPP_DIST="$ROOT_DIR/apps/web/build"
PORT=3333
PID_FILE="$ROOT_DIR/.tmp/web-serve.pid"
LOG_FILE="$ROOT_DIR/.tmp/web-serve.log"

# Ensure .tmp directory exists
mkdir -p "$ROOT_DIR/.tmp"

log() {
    echo "[web-serve] $1"
}

# Function to check if a process is running
check_process() {
    pid="$1"
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to stop a running server
stop_server() {
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        if check_process "$pid"; then
            log "Stopping server (PID: $pid)..."
            kill "$pid"
            rm -f "$PID_FILE"
            log "Server stopped."
        else
            log "PID file exists but process is not running. Cleaning up..."
            rm -f "$PID_FILE"
        fi
    else
        log "No PID file found."
    fi
}

# Function to start a server
start_server() {
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        if check_process "$pid"; then
            log "Server is already running (PID: $pid)."
            return 0
        else
            log "Cleaning up stale PID file..."
            rm -f "$PID_FILE"
        fi
    fi

    if [ ! -d "$WEBAPP_DIST" ]; then
        log "❌ Web app build directory not found at $WEBAPP_DIST"
        log "Please run 'just web bundle' first."
        exit 1
    fi

    log "Starting server on http://localhost:$PORT"
    cd "$WEBAPP_DIST"
    python3 -m http.server "$PORT" > "$LOG_FILE" 2>&1 &
    new_pid=$!
    echo "$new_pid" > "$PID_FILE"
    log "Server started with PID: $new_pid"
    log "✅ Bundle server ready at: http://localhost:$PORT"
    log "Logs available at: $LOG_FILE"
}

case "${1-start}" in
    start)
        start_server
        ;;
    stop)
        stop_server
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac