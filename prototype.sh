#!/bin/sh

# Prototype management script for Next.js prototype
# Usage: ./prototype.sh <id> <start|stop|reload>
# Safety: Use timeout 20 ./prototype.sh <id> start to prevent hanging on slow systems

set -e

PROTOTYPE_ID="$1"
ACTION="$2"
PROTOTYPE_DIR="prototype/$PROTOTYPE_ID"
PID_FILE="$PROTOTYPE_DIR/.pid"

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

# Function to check if Next.js is ready by polling health endpoint
check_nextjs_ready() {
    max_attempts=20
    attempt=1
    
    echo "Waiting for Next.js to be ready..."
    
    while [ $attempt -le $max_attempts ]; do
        # Try to connect to the development server
        if command -v curl >/dev/null 2>&1; then
            # Use curl if available
            if curl -s -f "http://localhost:3000" >/dev/null 2>&1; then
                return 0
            fi
        elif command -v nc >/dev/null 2>&1; then
            # Use netcat as fallback to check if port is open
            if nc -z localhost 3000 2>/dev/null; then
                return 0
            fi
        elif command -v telnet >/dev/null 2>&1; then
            # Use telnet as last resort
            if echo "" | telnet localhost 3000 2>/dev/null | grep -q "Connected"; then
                return 0
            fi
        else
            # If no tools available, just wait and check process
            if [ $attempt -eq 10 ] && check_process "$1"; then
                return 0
            fi
        fi
        
        echo "Attempt $attempt/$max_attempts - Next.js not ready yet..."
        sleep 1
        attempt=$((attempt + 1))
    done
    
    return 1
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
        echo "Are you sure this is a Next.js prototype?"
        exit 1
    fi
    
    echo "Starting prototype $PROTOTYPE_ID..."
    cd "$PROTOTYPE_DIR"
    
    # Check if node is available
    if ! command -v node >/dev/null 2>&1; then
        echo "Error: Node.js is not installed or not in PATH"
        exit 1
    fi
    
    # Install dependencies if node_modules doesn't exist
    if [ ! -d "node_modules" ]; then
        echo "Installing dependencies..."
        npm install
    fi
    
    # Start Next.js in background and capture PID
    npm run dev &
    new_pid=$!
    
    # Wait for Next.js to be ready with health check polling
    if check_nextjs_ready "$new_pid"; then
        # Ensure the directory exists for PID file
        mkdir -p "$(dirname "$PID_FILE")"
        echo "$new_pid" > "$PID_FILE"
        echo "Prototype $PROTOTYPE_ID started successfully (PID: $new_pid)"
        echo "Next.js development server is running on http://localhost:3000"
    else
        echo "Error: Failed to start prototype $PROTOTYPE_ID - server not responding after 20 seconds"
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