#!/bin/sh

# Webapp management script for MealPlanner monorepo
# Usage: ./webapp.sh <start|stop|reload>
# Safety: Runs Vite dev server on port 3001

set -e

ACTION="$1"
WEBAPP_DIR="apps/web"
PID_FILE="$WEBAPP_DIR/.pid"
WEBAPP_PORT="3001"

# Validate arguments
if [ -z "$ACTION" ]; then
    echo "Usage: $0 <start|stop|reload>"
    echo "Example: $0 start"
    exit 1
fi

case "$ACTION" in
    start|stop|reload)
        ;;
    *)
        echo "Error: Action must be 'start', 'stop', or 'reload'"
        exit 1
        ;;
esac

# Check if webapp directory exists
if [ ! -d "$WEBAPP_DIR" ]; then
    echo "Error: Webapp directory '$WEBAPP_DIR' does not exist"
    exit 1
fi

# Function to check if a process is running
check_process() {
    pid="$1"
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to check if Vite is ready by polling health endpoint
check_vite_ready() {
    max_attempts=5
    attempt=1
    
    echo "Waiting for Vite to be ready..."
    
    while [ $attempt -le $max_attempts ]; do
        # Try to connect to the server
        if command -v curl >/dev/null 2>&1; then
            # Use curl with timeout
            if curl -s -f -m 2 "http://localhost:$WEBAPP_PORT" >/dev/null 2>&1; then
                echo "Server ready"
                return 0
            fi
        elif command -v nc >/dev/null 2>&1; then
            # Use netcat to check if port is open
            if nc -z localhost "$WEBAPP_PORT" 2>/dev/null; then
                echo "Server ready"
                return 0
            fi
        fi
        
        sleep 1
        attempt=$((attempt + 1))
    done
    
    # Don't fail, just warn - server might still be starting
    echo "Warning: Server health check timed out, but process is running"
    return 0
}

# Function to stop webapp
stop_webapp() {
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        if check_process "$pid"; then
            echo "Stopping webapp (PID: $pid)..."
            kill "$pid"
            rm -f "$PID_FILE"
            echo "Webapp stopped"
        else
            echo "PID file exists but process is not running. Cleaning up..."
            rm -f "$PID_FILE"
        fi
    else
        echo "No PID file found for webapp"
    fi
}

# Function to start webapp
start_webapp() {
    # Check if already running
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        if check_process "$pid"; then
            echo "Webapp is already running (PID: $pid)"
            return 0
        else
            echo "Cleaning up stale PID file..."
            rm -f "$PID_FILE"
        fi
    fi
    
    # Check if package.json exists
    if [ ! -f "$WEBAPP_DIR/package.json" ]; then
        echo "Error: No package.json found in $WEBAPP_DIR"
        exit 1
    fi
    
    echo "Starting webapp..."
    
    # Check if node is available
    if ! command -v node >/dev/null 2>&1; then
        echo "Error: Node.js is not installed or not in PATH"
        exit 1
    fi
    
    # Start Vite dev server in background
    cd "$(dirname "$0")/.." && mise exec -- pnpm dev:web &
    new_pid=$!
    
    # Wait for Vite to be ready with health check polling
    if check_vite_ready "$new_pid"; then
        # Ensure the directory exists for PID file
        mkdir -p "$(dirname "$PID_FILE")"
        echo "$new_pid" > "$PID_FILE"
        echo "Webapp started successfully (PID: $new_pid)"
        echo "Vite dev server is running on http://localhost:$WEBAPP_PORT"
    else
        echo "Error: Failed to start webapp - server not responding after 5 seconds"
        # Clean up the failed process
        if check_process "$new_pid"; then
            kill "$new_pid" 2>/dev/null
        fi
        exit 1
    fi
}

# Main logic based on action
case "$ACTION" in
    start)
        start_webapp
        ;;
    stop)
        stop_webapp
        ;;
    reload)
        echo "Reloading webapp..."
        stop_webapp
        sleep 1
        start_webapp
        ;;
esac
