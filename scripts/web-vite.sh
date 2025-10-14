#!/bin/bash
# Manages the Vite development server for the web app.

# Set project root relative to the script location
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_FILE="/tmp/web-vite.pid"
LOG_FILE="/tmp/web-vite.log"

# Ensure we are in the project root
cd "$PROJECT_ROOT" || exit 1

start() {
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null; then
            echo "Vite server is already running (PID: $pid)."
            exit 0
        else
            echo "Found stale PID file. Removing it."
            rm "$PID_FILE"
        fi
    fi

    echo "Starting Vite server in background..."
    echo "Logs will be available at: $LOG_FILE"

    # Start the server in the background, redirecting output
    pnpm --filter @mealplanner/web run dev > "$LOG_FILE" 2>&1 &
    pid=$!

    # Save the PID
    echo "$pid" > "$PID_FILE"

    echo "Vite server started with PID: $pid."
    echo "Run 'just web-vite-stop' to stop it."
}

stop() {
    if [ ! -f "$PID_FILE" ]; then
        echo "Vite server is not running (no PID file found)."
        exit 0
    fi

    pid=$(cat "$PID_FILE")
    echo "Stopping Vite server (PID: $pid)..."

    if ps -p "$pid" > /dev/null; then
        # Terminate the process group to ensure child processes (like Vite) are also killed
        kill -- -"$pid"
        sleep 1
        if ps -p "$pid" > /dev/null; then
            echo "Process $pid did not terminate gracefully. Sending SIGKILL."
            kill -9 "$pid"
        fi
    else
        echo "Process with PID $pid not found. It might have already stopped."
    fi

    rm "$PID_FILE"
    echo "Vite server stopped."
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
