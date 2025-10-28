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
  - One‑off: `dart run build_runner build --delete-conflicting-outputs`
  - Watch: `dart run build_runner watch --delete-conflicting-outputs`
- Analyze: `flutter analyze`
- Run app: `flutter run -d chrome` (or your target device)
- Tests:
  - Unit/Widget: `flutter test`
  - Integration: `flutter test integration_test`

## Coding Style & Naming
- Follow `flutter_lints` (see `analysis_options.yaml`). Run `flutter analyze` before pushing.
- Dart style: 2‑space indent, single quotes preferred, avoid `dynamic`.
- Naming: files `lower_snake_case.dart`; classes `UpperCamelCase`; variables/methods `lowerCamelCase`.
- Riverpod: prefer `ref.read(...)` inside notifiers’ imperative methods; keep providers pure.

## Testing Guidelines
- Frameworks: `flutter_test`, `integration_test`, `mockito`.
- Place tests under `test/` mirroring source paths (e.g., `test/widgets/...`, `test/unit/...`).
- Name tests `*_test.dart`. Run locally with `flutter test` (add `--coverage` if needed).

## Commit & Pull Request Guidelines
- Use Conventional Commits: `feat:`, `fix:`, `chore:`, etc. (history shows this pattern).
- PRs must include: concise description, linked issue, screenshots for UI changes, and a checklist confirming analyzer/tests pass and codegen is updated.

## Security & Configuration Tips
- Firebase: in debug, Firestore uses the local emulator (`localhost:8080`). Ensure your emulator is running when developing.
- Do not commit secrets. Keep configuration in environment‑safe locations; `firebase_options.dart` is generated.

