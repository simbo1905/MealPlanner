# Repository Guidelines

## Project Structure & Modules
- App code: `meal_planner/lib/` (providers, screens, widgets, services).
  - Providers: `lib/providers/` (Riverpod + codegen `*.g.dart`)
  - UI: `lib/screens/`, `lib/widgets/`
  - Services: `lib/services/` (e.g., `uuid_generator.dart`)
- Tests: `meal_planner/test/` (unit/widget) and `meal_planner/integration_test/`.
- Assets: `meal_planner/assets/`
- Config: `meal_planner/pubspec.yaml`, Firebase options in `lib/firebase_options.dart`.

## Build, Test, and Development
- Install deps: `flutter pub get`
- Generate code (Freezed/Riverpod):
  - One-off: `dart run build_runner build --delete-conflicting-outputs`
  - Watch: `dart run build_runner watch --delete-conflicting-outputs`
- Analyze: `flutter analyze`
- Run app: `flutter run -d chrome` (or your target device)
- Tests (MVP1 scope):
  - Unit/Widget: `flutter test` (focus on meal calendar, recipe selector, favorites)
  - Integration: `flutter test integration_test` (only for MVP1 calendar flows once Firestore-backed)

## Coding Style & Naming
- Follow `flutter_lints` (see `analysis_options.yaml`). Run `flutter analyze` before pushing.
- Dart style: 2-space indent, single quotes preferred, avoid `dynamic`.
- Naming: files `lower_snake_case.dart`; classes `UpperCamelCase`; variables/methods `lowerCamelCase`.
- Riverpod: prefer `ref.read(...)` inside notifiers’ imperative methods; keep providers pure.

## Testing Guidelines (MVP1 Alignment)
- Testing pyramid stays intact: widget tests cover portrait/landscape calendars and selector flows; integration tests validate Firestore persistence and drag-drop swaps.
- Place tests under `test/` mirroring source paths (e.g., `test/widgets/calendar/...`).
- Name tests `*_test.dart`. Run locally with `flutter test` before pushing.
- Prioritize deterministic fakes for Firestore until true backend is wired.

## Commit & Pull Request Guidelines
- Use Conventional Commits: `feat:`, `fix:`, `chore:`, etc. (history shows this pattern).
- PRs must include: concise description, linked issue, screenshots for UI changes, and a checklist confirming analyzer/tests pass and codegen is updated.

## Firebase & Firestore Architecture
- Firebase CLI tools installed: `firebase-tools@14.22.0`
- Project: `planmise` (Project Number: `1001077707255`)
- Command: `firebase use planmise`
- See `memory/FIREBASE.md` for setup details and `spec/FIREBASE.md` for detailed architecture.

### Versioning & A/B Testing Strategy
**All resources MUST include a version number** such as `recipesv1`, `usersv2` at the outermost container that establishes logical namespace. This allows the app to pivot to new data structures while maintaining old versions simultaneously.

Key principles:
- Resource version in container name: `recipesv1/`, `recipesv2/`, etc.
- Sub-resources (collections within version) do NOT need version numbers: `recipesv1/recipes`, `recipesv1/ingredients`
- Generated code uses matching version: `RecipesV1Repository`, `recipesV1Provider`, `recipes_v1_provider.dart`
- Firebase Auth custom claims enable per-user version assignment (e.g., `recipe_version: "v1"` or `recipe_version: "v2"`)
- Enables A/B testing, gradual rollouts, and live debugging without code changes

This architecture allows coexistent versioned code and unit tests, enabling zero-downtime version switching via Firebase console by mapping users to versions using custom auth attributes.

See `spec/FIREBASE.md` for complete architecture, use cases (A/B testing, feature flags, gradual rollout, live debugging), and implementation patterns.

## Security & Configuration Tips
- Firebase: in debug, Firestore uses the local emulator (`localhost:8080`). Ensure your emulator is running when developing.
- Do not commit secrets. Keep configuration in environment-safe locations; `firebase_options.dart` is generated.

## MVP1 Delivery Guardrails
- Documentation-first: `specs/MVP1.md` and this guide stay accurate before code merges.
- Architecture discipline: repository pattern + Riverpod overrides to keep UI Firestore-agnostic.
- TDD discipline: smallest failing test for calendar slot swap, recipe search, and persistence before implementation.
- Scope enforcement: defer non-MVP features (shopping list, AI onboarding, preferences) even if referenced historically.
