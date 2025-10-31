# Testing Tao – MVP1 Discipline

Testing is the spine of MealPlanner. Keep it lean, fast, and centered on the calendar + recipe selector.

## 1. Three-Layer Strategy
| Layer | Purpose | Tech | Runs |
| --- | --- | --- | --- |
| Widget/Provider tests | Validate UI + state changes (add, swap, delete meals) | `flutter_test`, Riverpod overrides, in-memory fakes | every edit |
| Repository tests | Verify Firestore adapters + serialization | `fake_cloud_firestore`, custom fakes | when persistence code changes |
| Integration tests | Golden path for calendar add/swap/persist | `integration_test`, Firestore emulator | before PR merge |

## 2. Golden Rules
- **Fast feedback first**: Targeted widget/provider tests before touching integration suite.
- **Deterministic data**: Seed fakes with fixed dates/recipes; avoid `DateTime.now()` inside tests.
- **One behavior per test**: Add meal, replace slot, drag swap, recipe search, authentication gating.
- **Analyzer is non-negotiable**: `flutter analyze` must return clean before running tests.

## 3. Recommended Commands
```bash
flutter analyze
flutter test test/widgets/calendar/infinite_calendar_screen_test.dart
flutter test test/widgets/... # other focused suites
flutter test test/providers/... # when state logic changes
flutter test integration_test # only when Firestore-backed flow is touched
```

## 4. Test Data Patterns
- **Fixed clock**: Provide deterministic `DateTime(2025, 10, 28)` when generating week sections.
- **Template seed**: Use canonical breakfast/lunch/dinner titles for slot assertions.
- **Favorites**: Preload with few entries to verify autocomplete suggestions.
- **Firestore**: Use fake or emulator depending on layer—never mix in the same test.

## 5. Coverage Focus Areas
- Portrait infinite scroll: rendering, slot counts, sticky selected date.
- Landscape drag-drop: swap logic, conflict dialogs, visual cues.
- Recipe selector: search debounce, top-10 results, custom recipe, favorites update.
- Firestore repos: CRUD, user scoping, persistence restoration.
- Auth states: signed-in requirement for calendar access.

## 6. Continuous Improvement
- Refactor tests when scenarios overlap; keep fixtures tidy in `test/support/`.
- Capture flaky behavior immediately; diagnose before moving on.
- Update this guide if the pyramid or tooling shifts.

Stay disciplined and tests will accelerate delivery, not slow it down.
