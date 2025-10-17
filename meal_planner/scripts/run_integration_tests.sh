#!/bin/bash

# Ensure chromedriver is installed and in PATH
if ! command -v chromedriver &> /dev/null
then
    echo "chromedriver not found. Please install it (e.g., brew install chromedriver or npx @puppeteer/browsers install chromedriver@stable)."
    exit 1
fi

# Kill any existing chromedriver processes
pkill chromedriver &> /dev/null

# Start chromedriver in the background on port 4444
chromedriver --port=4444 > /tmp/chromedriver.log 2>&1 &
CHROMEDRIVER_PID=$!
echo "Started chromedriver with PID $CHROMEDRIVER_PID on port 4444."

# Give chromedriver a moment to start
sleep 2

# Run the Flutter integration tests
echo "Running Flutter integration tests..."
flutter drive \
  --driver=test_driver/integration_test_driver.dart \
  --target=integration_test/calendar_web_test.dart \
  -d chrome

FLUTTER_DRIVE_EXIT_CODE=$?

# Kill chromedriver process
echo "Stopping chromedriver (PID $CHROMEDRIVER_PID)..."
kill $CHROMEDRIVER_PID

if [ $FLUTTER_DRIVE_EXIT_CODE -eq 0 ]; then
    echo "Flutter integration tests passed successfully."
else
    echo "Flutter integration tests failed with exit code $FLUTTER_DRIVE_EXIT_CODE."
fi

exit $FLUTTER_DRIVE_EXIT_CODE
