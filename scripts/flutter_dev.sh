#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="flutter_dev"
PID_FILE="/tmp/${SCRIPT_NAME}.pid"
LOG_FILE="/tmp/${SCRIPT_NAME}.log"

PLATFORM="${1:-web}"

if [ "$PLATFORM" = "stop" ]; then
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
      kill "$PID"
      echo "Stopped Flutter dev server (PID: $PID)"
    else
      echo "Flutter dev server not running"
    fi
    rm -f "$PID_FILE"
  else
    echo "No PID file found"
  fi
  exit 0
fi

if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo "Flutter dev server already running (PID: $(cat "$PID_FILE"))"
  echo "Use 'just flutter dev stop' to stop it first"
  exit 1
fi

cd "$(dirname "$0")/../meal_planner" || exit 1

DEVICE_FLAG=""
case "$PLATFORM" in
  web|chrome)
    DEVICE_FLAG="-d chrome"
    ;;
  ios)
    DEVICE_FLAG="-d ios"
    ;;
  macos)
    DEVICE_FLAG="-d macos"
    ;;
  android)
    DEVICE_FLAG="-d android"
    ;;
  windows)
    DEVICE_FLAG="-d windows"
    ;;
  linux)
    DEVICE_FLAG="-d linux"
    ;;
  *)
    echo "Unknown platform: $PLATFORM"
    echo "Usage: $0 {web|ios|macos|android|windows|linux|stop}"
    exit 1
    ;;
esac

flutter run $DEVICE_FLAG > "$LOG_FILE" 2>&1 &
PID=$!
echo $PID > "$PID_FILE"

echo "Started Flutter dev server on $PLATFORM (PID: $PID)"
echo "Log: $LOG_FILE"
echo "Stop with: just flutter dev stop"
