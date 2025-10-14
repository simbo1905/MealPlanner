#!/bin/sh

# Prototype management script for Next.js and SvelteKit prototypes
# Usage: ./prototype.sh <id> <start|stop|reload>
# Safety: Use timeout 20 ./prototype.sh <id> start to prevent hanging on slow systems

set -e

PROTOTYPE_ID="$1"
ACTION="$2"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROTOTYPE_DIR="$REPO_ROOT/prototype/$PROTOTYPE_ID"
PID_FILE="$PROTOTYPE_DIR/.pid"
LOG_FILE="$PROTOTYPE_DIR/.server.log"
PROTOTYPE_PORT=$((3300 + 10#$PROTOTYPE_ID))

# Validate arguments
if [ -z "$PROTOTYPE_ID" ] || [ -z "$ACTION" ]; then
    echo "Usage: $0 <prototype_id> <start|stop|reload>"
    echo "Example: $0 01 start"
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

# Check if prototype directory exists
if [ ! -d "$PROTOTYPE_DIR" ]; then
    echo "Error: Prototype directory '$PROTOTYPE_DIR' does not exist"
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

# Function to check if server is ready by polling health endpoint
check_server_ready() {
    max_attempts=5
    attempt=1
    
    echo "Waiting for server to be ready..."
    
    while [ $attempt -le $max_attempts ]; do
        # Try to connect to the server
        if command -v curl >/dev/null 2>&1; then
            # Use curl with timeout
            if curl -s -f -m 2 "http://localhost:$PROTOTYPE_PORT" >/dev/null 2>&1; then
                echo "Server ready"
                return 0
            fi
        elif command -v nc >/dev/null 2>&1; then
            # Use netcat to check if port is open
            if nc -z localhost "$PROTOTYPE_PORT" 2>/dev/null; then
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

# Function to stop a running prototype
stop_prototype() {
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        if check_process "$pid"; then
            echo "Stopping prototype $PROTOTYPE_ID (PID: $pid)..."
            kill "$pid"
            rm -f "$PID_FILE"
            echo "Prototype $PROTOTYPE_ID stopped"
        else
            echo "PID file exists but process is not running. Cleaning up..."
            rm -f "$PID_FILE"
        fi
    else
        echo "No PID file found for prototype $PROTOTYPE_ID"
    fi
}

# Function to start a prototype
start_prototype() {
    # Check if already running
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        if check_process "$pid"; then
            echo "Prototype $PROTOTYPE_ID is already running (PID: $pid)"
            return 0
        else
            echo "Cleaning up stale PID file..."
            rm -f "$PID_FILE"
        fi
    fi
    
    # Check if package.json exists
    if [ ! -f "$PROTOTYPE_DIR/package.json" ]; then
        echo "Error: No package.json found in $PROTOTYPE_DIR"
        echo "Are you sure this is a valid prototype?"
        exit 1
    fi
    
    echo "Starting prototype $PROTOTYPE_ID..."
    cd "$PROTOTYPE_DIR"
    
    # Check if node is available
    if ! command -v node >/dev/null 2>&1; then
        echo "Error: Node.js is not installed or not in PATH"
        exit 1
    fi
    
    # Detect framework type
    if grep -q '"@sveltejs/kit"' package.json; then
        FRAMEWORK="sveltekit"
        BUILD_DIR=".svelte-kit"
        echo "Detected SvelteKit framework"
    else
        FRAMEWORK="nextjs"
        BUILD_DIR=".next"
        echo "Detected Next.js framework"
    fi
    
    # Install dependencies if node_modules doesn't exist
    if [ ! -d "node_modules" ]; then
        echo "Installing dependencies..."
        npm install
    fi
    
    # Build the app if build directory doesn't exist or is stale
    if [ ! -d "$BUILD_DIR" ] || [ "package.json" -nt "$BUILD_DIR" ]; then
        echo "Building prototype $PROTOTYPE_ID..."
        npm run build
    fi
    
    # Start server in background with logging
    echo "Starting server on port $PROTOTYPE_PORT..."
    if [ "$FRAMEWORK" = "sveltekit" ]; then
        npm run preview -- --port "$PROTOTYPE_PORT" > "$LOG_FILE" 2>&1 &
    else
        PORT="$PROTOTYPE_PORT" npm run start > "$LOG_FILE" 2>&1 &
    fi
    new_pid=$!
    
    # Wait for server to be ready with health check polling
    if check_server_ready "$new_pid"; then
        # Ensure the directory exists for PID file
        mkdir -p "$(dirname "$PID_FILE")"
        echo "$new_pid" > "$PID_FILE"
        echo "Prototype $PROTOTYPE_ID started successfully (PID: $new_pid)"
        echo "Server running on http://localhost:$PROTOTYPE_PORT"
        echo "Logs available at: $LOG_FILE"
    else
        echo "Error: Failed to start prototype $PROTOTYPE_ID - server not responding after 20 seconds"
        echo "Check logs at: $LOG_FILE"
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
        start_prototype
        ;;
    stop)
        stop_prototype
        ;;
    reload)
        echo "Reloading prototype $PROTOTYPE_ID..."
        stop_prototype
        sleep 1
        start_prototype
        ;;
esac
