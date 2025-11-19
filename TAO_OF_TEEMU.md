# Tao of Teemu – Testing Discipline

Test-first habits keep MealPlanner calm, predictable, and shippable. Apply these principles relentlessly.

## 1. Clarity Before Code
- Align on behavior in `specs/MVP1.md` prior to implementation.
- Ask "what problem, for whom, and how will we verify it?" before writing code.

## 2. Flow of Work
1. Capture the change in docs/specs.
2. Write the smallest failing test.
3. Implement the minimal code to pass.
4. Refactor for clarity.
5. Re-run analyzer and tests.
6. Demo, gather feedback, iterate.

## 3. Testing Pyramid
| Layer | Purpose | Tooling | cadence |
| --- | --- | --- | --- |
| Widget/Provider | Validate UI + state (add, swap, delete meals) | `flutter_test`, Riverpod overrides | every change |
| Repository | Verify Firestore adapters + serialization | fakes, `fake_cloud_firestore` | when persistence code changes |
| Integration | Golden path (add/swap/persist) | `integration_test`, Firestore emulator | before PR merge |

## 4. Golden Rules
- Fast feedback first: targeted widget/provider tests before integration suites.
- Deterministic data: fixed clocks, seeded repos; avoid `DateTime.now()` in tests.
- One behavior per test: add meal, replace slot, drag swap, recipe search, auth gating.
- Analyzer non-negotiable: `flutter analyze` must be clean before running tests.

## 5. Riverpod + Repository Harmony
- Widgets depend on providers, not Firestore.
- Repositories expose async methods/streams for meals, recipes, favorites.
- Tests override providers with fakes; no emulator for unit/widget tests.
- Keep providers pure; mutations go through notifiers/services.

## 6. Execution Rhythm
- Work in focused slices (one widget, one state change).
- Name things precisely (`slot` vs `template`, `selectedDate` vs `stickyDate`).
- Avoid urgency—quality beats speed when planning meals for families.

## 7. Guardrails Against Drift
- Revisit this file and `FLUTTER_DEV.md` when unsure.
- Reject "just one more feature" thinking; MVP1 lives or dies on calendar clarity.
- Archive legacy modules until after MVP.

## 8. Celebrate Passing Tests
- Treat green test runs as the team heartbeat.
- Share learning from failures; analyze root causes, not symptoms.

## 9. Integration Test Guidance
- Never use `flutter drive` / ChromeDriver; it was removed from the SDK.
- Use the `integration_test` package, initialize the binding, write widget-style interactions.
- Run via `flutter test integration_test` for Firestore-backed flows.