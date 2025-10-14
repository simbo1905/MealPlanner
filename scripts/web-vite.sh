#!/bin/bash
# Manages the Vite development server for the web app.

# Set project root relative to the script location
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_FILE="$PROJECT_ROOT/.tmp/web-vite.pid"
LOG_FILE="$PROJECT_ROOT/.tmp/web-vite.log"

# Ensure .tmp directory exists
mkdir -p "$PROJECT_ROOT/.tmp"

# Ensure we are in the project root
cd "$PROJECT_ROOT" || exit 1

start() {
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null; then
            echo "Vite server is already running (PID: $pid)."
            # Try to extract URL from existing log
            if [ -f "$LOG_FILE" ]; then
                url=$(grep -a "Local:" "$LOG_FILE" | grep -o "http://localhost:[0-9]*" | tail -1)
                if [ -n "$url" ]; then
                    echo "Server available at: $url"
                fi
            fi
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
    
    # Wait for server to start and extract the URL
    echo "Waiting for server to start..."
    for i in {1..30}; do
        if [ -f "$LOG_FILE" ]; then
            # Use grep -a to treat as text and extract URL
            url=$(grep -a "Local:" "$LOG_FILE" | grep -o "http://localhost:[0-9]*" | tail -1)
            if [ -n "$url" ]; then
                echo "✅ Vite dev server ready at: $url"
                echo "Run 'just web dev stop' to stop it."
                break
            fi
        fi
        sleep 0.5
    done
    
    if [ -z "$url" ]; then
        echo "⚠️  Server started but URL not detected. Check logs at: $LOG_FILE"
        echo "Run 'just web dev stop' to stop it."
    fi
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
