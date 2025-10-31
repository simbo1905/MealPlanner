# Flutter Development Playbook (MVP1)

## Mindset
- Senior-level Flutter + Riverpod craft: clean architecture, fast feedback loops.
- Documentation-first: specs define outcomes before code. Update `specs/MVP1.md` and supporting guides prior to implementation.
- MVP1 constraint: everything serves the dual-mode calendar, Firestore-backed meals, recipe selector, and favorites. Defer non-MVP work.

## Core Workflow
1. **Plan** – confirm scope against `specs/MVP1.md` and capture tasks in TODOs.
2. **Document** – refine feature notes in `specs/MVP1.md` or component docs before editing Dart.
3. **Test-first** – create or update the smallest failing widget/unit test for the calendar, selector, or persistence behavior.
4. **Implement** – make focused code changes, keeping files small and composable.
5. **Verify** – run `flutter analyze` and targeted `flutter test` after each file. Complete flow ends with integration tests once Firestore wiring lands.
6. **Review** – ensure code reads cleanly, respects Riverpod patterns, and references repositories rather than direct Firebase APIs in widgets.

## Tooling Checklist
```bash
flutter pub get
flutter analyze
flutter test path/to/test.dart
flutter test                # before PR when scope touched multiple areas
flutter test integration_test # once Firestore-backed flows exist
```
- Regenerate Freezed/Riverpod code when models/providers change:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

## Architecture Principles
- **Repository pattern** isolates Firestore; widgets consume providers only.
- **Providers** stay pure and side-effect free; imperative work belongs in notifiers or services.
- **Slots + dates** are first-class: model breakfast/lunch/dinner/other explicitly.
- **Drag-and-drop** logic confined to calendar widgets backed by repository methods.
- **Authentication context** injected at repository level; UI responds to signed-in user state.

## Testing Discipline
- Widget tests simulate meal add/edit/delete, slot conflicts, and drag swaps using fakes.
- Provider tests validate derived state (week sections, planned counts) with deterministic clocks.
- Integration tests (post-Firestore) cover portrait add flow, landscape swap, and persistence across restart.
- Keep all tests deterministic; seed fakes rather than relying on `DateTime.now()`.

## Code Review Ready Definition
- Documentation updated and cited.
- Analyzer + relevant tests passing locally.
- No TODOs or commented-out blocks left behind.
- Clear commit history using Conventional Commits.
- Screenshots or short clips for meaningful UI changes (portrait + landscape where applicable).

## Guardrails Against Scope Creep
- Reject additions that hint at shopping list, AI onboarding, preferences, or other MVP2 ideas.
- Remove or gate legacy UI/routes that distract from MVP1 path.
- When in doubt, trim features to protect calendar + recipe selector quality.

Stay disciplined, ship fast, and keep the calendar experience crisp.
