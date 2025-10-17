# Flutter Integration Test Runner Recovery

**Date**: 2025-10-17  
**Context**: Re-stabilising `meal_planner/flutter_test_server.sh`

---

## Current Pain
- The background runner provides no timing markers between chromedriver launch and `flutter drive`, leaving long idle stretches with no signal of progress or failure.
- Chrome instances linger after nominal success, forcing manual cleanup and preventing repeatable invocations.
- Log truncation (multiple quick restarts) obscures earlier output, so it is impossible to distinguish fresh runs from stuck watcher loops.
- `set -euo pipefail` style defensive flags in wrapper scripts mask partial failures instead of preserving context in logs (per user feedback).

## Recovery Goals
1. Emit structured, timestamped log lines for each phase (`chromedriver` cleanup, launch, wait loop, `flutter drive` start/finish, teardown) to allow quick diagnosis when progress stalls.
2. Guard long-running phases with explicit polling/timeout messaging rather than silent `sleep`. While `flutter drive` itself remains long, the outer script must echo heartbeat markers so tailing logs shows life.
3. Harden teardown to always terminate chromedriver and the Chrome session it spawns by tracking PIDs and verifying shutdown (`kill -0` loops with capped retries).
4. Preserve failure exit codes but avoid brittle `set -euo`—errors should be logged and propagated manually so we retain the full failure transcript.

## Implementation Notes
- Replace bare `sleep` with a wait loop that prints status every few seconds until chromedriver responds to `/status` (using `curl` or `wget`). Bail out with descriptive errors if readiness fails.
- Wrap `flutter drive` with `script`-level timestamp logs (`date +"%Y-%m-%dT%H:%M:%S%z"`) before and after execution; capture duration for diagnostics.
- Introduce explicit PID tracking and repeated `kill -0` checks when stopping chromedriver and Chrome, logging every attempt and final state.
- Ensure `.tmp/flutter_test_server.sh.log` records a single header per invocation and append-only behaviour so previous context survives if the file is tailed mid-run.

## Validation
- Run the updated script once to confirm integration tests still pass.
- After completion, verify via `ps`/`pgrep` that no `chromedriver` or `chrome --remote-debugging-port` processes remain.
- Tail the log to confirm timestamps and heartbeat messages appear throughout the run.

