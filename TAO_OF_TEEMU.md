# Tao of Teemu (MealPlanner Edition)

Teemu’s philosophy keeps development calm, deliberate, and test-first—even under MVP pressure. Apply these kernels relentlessly.

## 1. Clarity Before Code
- No code without narrative. Align on desired UX/behavior in `specs/MVP1.md` first.
- Ask "what problem, for whom, and how do we know it works?" before opening an editor.
- Simplify scope ruthlessly: calendar weeks, meal swaps, recipe selection. Nothing else.

## 2. Flow of Work
1. Capture the change in docs/specs.
2. Write the smallest failing test.
3. Implement minimal code to pass.
4. Refactor for readability.
5. Re-run analyzer and tests.
6. Demo, gather feedback, iterate.

## 3. Testing Pyramid Discipline
- Widget tests are the heartbeat—fast feedback for slot conflicts, drag/drop, and Firestore fakes.
- Provider/model tests ensure deterministic state (use fixed clocks, seeded repos).
- Integration tests run only for critical flows (portrait add, landscape swap, persistence).
- never skip: `flutter analyze` `flutter test` (targeted) `flutter test integration_test` (when Firestore path turns on).

## 4. Riverpod + Repository Harmony
- Widgets depend on providers, not Firestore.
- Repositories expose async methods/streams for meals, recipes, favorites.
- Tests override providers with fakes—no emulator for unit/widget tests.
- Keep providers pure; mutations go through notifiers/services.

## 5. Calm Execution Rhythm
- Work in focused slices (one widget, one state change).
- Name things precisely (slot vs template, selectedDate vs stickyDate).
- Avoid urgency—quality beats speed when planning meals for families.

## 6. Guardrails Against Drift
- Revisit this file and `FLUTTER_DEV.md` when unsure.
- Reject "just one more feature" thinking. MVP1 lives or dies on calendar clarity.
- Archive legacy screens/modules until post-MVP revival.

## 7. Celebrate Passing Tests
- Treat green test runs as a team heartbeat.
- Share learnings from failures; analyze root causes, not symptoms.

Practice these habits and MealPlanner lands polished, predictable, and ready for real families.
