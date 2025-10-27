#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SCRIPT_NAME="pocketbase_dev"
CURRENT_LINK="$PROJECT_ROOT/.tmp/pb_current"

log() {
    echo "[$(date '+%Y-%m-%dT%H:%M:%S%z')] $*"
}

error() {
    echo "[$(date '+%Y-%m-%dT%H:%M:%S%z')] ERROR: $*" >&2
}

get_current_workdir() {
    if [ ! -L "$CURRENT_LINK" ]; then
        error "No current PocketBase instance found"
        error "Run: dart scripts/setup_pocketbase.dart"
        exit 1
    fi
    
    readlink "$CURRENT_LINK"
}

load_run_info() {
    local workdir="$(get_current_workdir)"
    local run_info="$workdir/run_info.json"
    
    if [ ! -f "$run_info" ]; then
        error "Run info not found: $run_info"
        exit 1
    fi
    
    # Parse JSON using grep (simple approach for single values)
    PORT=$(grep -o '"port"[[:space:]]*:[[:space:]]*[0-9]*' "$run_info" | grep -o '[0-9]*$')
    URL=$(grep -o '"url"[[:space:]]*:[[:space:]]*"[^"]*"' "$run_info" | cut -d'"' -f4)
    
    if [ -z "$PORT" ] || [ -z "$URL" ]; then
        error "Could not parse run info"
        exit 1
    fi
}

get_pid_file() {
    local workdir="$(get_current_workdir)"
    echo "$workdir/pocketbase.pid"
}

get_log_file() {
    local workdir="$(get_current_workdir)"
    echo "$workdir/pocketbase.log"
}

get_running_pid() {
    local pid_file="$(get_pid_file)"
    
    if [ ! -f "$pid_file" ]; then
        return 1
    fi
    
    local pid
    pid=$(cat "$pid_file")
    
    if kill -0 "$pid" 2>/dev/null; then
        echo "$pid"
        return 0
    else
        # Stale PID file
        rm -f "$pid_file"
        return 1
    fi
}

cmd_start() {
    error "Use 'dart scripts/setup_pocketbase.dart' to start a new instance"
    error "This command only works for stopping/checking existing instances"
    exit 1
}

cmd_stop() {
    if ! pid=$(get_running_pid); then
        log "PocketBase is not running"
        return 0
    fi
    
    log "Stopping PocketBase (PID: $pid)..."
    
    # Try graceful shutdown first
    if kill "$pid" 2>/dev/null; then
        local attempts=0
        local max_attempts=10
        
        while kill -0 "$pid" 2>/dev/null && [ $attempts -lt $max_attempts ]; do
            sleep 1
            attempts=$((attempts + 1))
            log "Waiting for shutdown... ($attempts/$max_attempts)"
        done
        
        # Force kill if still running
        if kill -0 "$pid" 2>/dev/null; then
            log "Graceful shutdown failed, forcing..."
            kill -9 "$pid" 2>/dev/null || true
            sleep 1
        fi
    fi
    
    # Clean up PID file
    local pid_file="$(get_pid_file)"
    rm -f "$pid_file"
    
    log "PocketBase stopped"
}

cmd_status() {
    if ! load_run_info 2>/dev/null; then
        log "No PocketBase instance configured"
        log "Run: dart scripts/setup_pocketbase.dart"
        return 0
    fi
    
    if pid=$(get_running_pid); then
        local workdir="$(get_current_workdir)"
        local log_file="$(get_log_file)"
        
        log "PocketBase is RUNNING"
        log "  PID: $pid"
        log "  Port: $PORT"
        log "  URL: $URL"
        log "  Admin UI: $URL/_/"
        log "  Working directory: $workdir"
        log "  Log file: $log_file"
        log ""
        log "Recent log tail:"
        tail -n 10 "$log_file" 2>/dev/null | sed 's/^/  /' || echo "  (log file not available)"
    else
        log "PocketBase is NOT RUNNING"
        log ""
        log "Start with: dart scripts/setup_pocketbase.dart"
    fi
}

cmd_reset() {
    log "Resetting PocketBase (creating fresh instance)..."
    
    # Stop if running
    if get_running_pid >/dev/null 2>&1; then
        cmd_stop
    fi
    
    log "Run: dart scripts/setup_pocketbase.dart"
}

cmd_logs() {
    local log_file="$(get_log_file)"
    
    if [ ! -f "$log_file" ]; then
        error "Log file not found: $log_file"
        exit 1
    fi
    
    tail -f "$log_file"
}

cmd_test() {
    log "Running integration tests..."
    cd "$PROJECT_ROOT"
    dart scripts/test_pocketbase.dart
}

usage() {
    cat << EOF
Usage: $0 {stop|status|logs|test}

Commands:
  stop    - Stop PocketBase server
  status  - Check server status and show recent logs  
  logs    - Tail log file (follow mode)
  test    - Run integration tests

Setup:
  dart scripts/setup_pocketbase.dart   - Start new instance

Examples:
  $0 status
  $0 logs
  $0 test
EOF
    exit 1
}

# Main command dispatch
case "${1:-}" in
    stop)
        cmd_stop
        ;;
    status)
        cmd_status
        ;;
    logs)
        cmd_logs
        ;;
    test)
        cmd_test
        ;;
    start|reset)
        error "This command is deprecated"
        error "Use: dart scripts/setup_pocketbase.dart"
        exit 1
        ;;
    *)
        usage
        ;;
esac
