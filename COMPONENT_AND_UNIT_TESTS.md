# COMPONENT_AND_UNIT_TESTS.md

**Status**: Plan created. Implementation in progress via FlutterDev subagents.

**Last Updated**: 2025-10-27

---

## Overview

This document tracks all screens, widgets, and unit tests to be built for MealPlanner. All work follows the architecture and testing patterns defined in:

- **TAO_OF_TEEMU.md** - Decoupling, repository pattern, provider overrides
- **FLUTTER_DEV.md** - Development workflow, quality gates
- **TESTING_TAO.md** - MealPlanner-specific fake repositories and test patterns

---

## Functional Areas

### Area 1: Recipe Management (Spec 003)
**Specification**: `AREA_NEW_RECIPE_MANAGEMENT.md`

**Models** (reuse):
- `recipe.freezed_model.dart`
- `ingredient.freezed_model.dart`
- `search_models.freezed_model.dart`

**Providers** (reuse):
- `recipe_providers.dart`

| Component | Type | Status | Test Count | Notes |
|-----------|------|--------|------------|-------|
| RecipeListScreen | Screen | Pending | 8 | Search, filter, sort recipes |
| RecipeDetailScreen | Screen | Pending | 5 | View, edit, delete recipe |
| RecipeFormScreen | Screen | Pending | 8 | Create/edit with validation |
| RecipeCard | Widget | Pending | 4 | Display recipe summary |
| RecipeSearchBar | Widget | Pending | 3 | Text input with clear |
| RecipeFilterChips | Widget | Pending | 5 | Allergen/time/ingredient filters |
| FakeRecipeRepository | Test | Pending | — | In-memory test double |

**Total**: 6 screens/widgets, 33 test cases

---

### Area 2: Calendar & Meal Planning (Spec 002)
**Specification**: `AREA_NEW_CALENDAR_PLANNING.md`

**Models** (reuse):
- `meal_assignment.freezed_model.dart`
- `meal_plan.freezed_model.dart`

**Providers** (reuse):
- `meal_assignment_providers.dart`
- `calendar_providers.dart`

| Component | Type | Status | Test Count | Notes |
|-----------|------|--------|------------|-------|
| WeekCalendarScreen | Screen | Pending | 8 | Week view with nav |
| DayDetailScreen | Screen | Pending | 8 | Day view with assignments |
| MealAssignmentModal | Screen | Pending | 6 | Recipe picker modal |
| CalendarDayCell | Widget | Pending | 5 | Day cell with meal count |
| MealAssignmentWidget | Widget | Pending | 4 | Meal card with unassign |
| WeeklySummary | Widget | Pending | 4 | Stats: meals, time |
| FakeMealAssignmentRepository | Test | Pending | — | In-memory test double |

**Total**: 6 screens/widgets, 35 test cases

---

### Area 3: User Preferences (Spec 001)
**Specification**: `AREA_NEW_USER_PREFERENCES.md`

**Models** (reuse):
- `user_preferences.freezed_model.dart`

**Providers** (reuse):
- `user_preferences_providers.dart`

| Component | Type | Status | Test Count | Notes |
|-----------|------|--------|------------|-------|
| UserPreferencesScreen | Screen | Pending | 10 | Edit portions, restrictions, etc. |
| PortionsSelector | Widget | Pending | 5 | Slider/spinner 1-12 |
| DietaryRestrictionsSelector | Widget | Pending | 6 | Multi-select chips |
| DislikedIngredientsInput | Widget | Pending | 6 | Add/remove with autocomplete |
| PreferredSupermarketsSelector | Widget | Pending | 6 | Searchable multi-select |
| FakeUserPreferencesRepository | Test | Pending | — | In-memory test double |

**Total**: 5 screens/widgets, 33 test cases

---

### Area 4: Shopping List (Spec 001)
**Specification**: `AREA_NEW_SHOPPING_LIST.md`

**Models** (reuse):
- `shopping_list.freezed_model.dart`
- `ingredient.freezed_model.dart`

**Providers** (reuse):
- `shopping_list_providers.dart`

| Component | Type | Status | Test Count | Notes |
|-----------|------|--------|------------|-------|
| ShoppingListGenerationScreen | Screen | Pending | 9 | Select assignments, generate |
| ShoppingListScreen | Screen | Pending | 10 | View, check off, manage items |
| ShoppingListItem | Widget | Pending | 5 | Checkbox, name, qty, delete |
| CostSummary | Widget | Pending | 5 | Total cost, item count, progress |
| ShoppingListSection | Widget | Pending | 5 | Collapsible section (Produce, etc) |
| FakeShoppingListRepository | Test | Pending | — | In-memory test double |

**Total**: 5 screens/widgets, 34 test cases

---

### Area 5: LLM Recipe Onboarding (Spec 004)
**Specification**: `AREA_NEW_LLM_ONBOARDING.md`

**Models** (reuse):
- `workspace_recipe.freezed_model.dart`
- `recipe.freezed_model.dart`

**Providers** (reuse):
- `recipe_providers.dart`

| Component | Type | Status | Test Count | Notes |
|-----------|------|--------|------------|-------|
| CameraCaptureScreen | Screen | Pending | 8 | Camera/gallery, photo capture |
| RecipeProcessingScreen | Screen | Pending | 8 | Mock OCR, show progress |
| RecipeReviewScreen | Screen | Pending | 9 | Edit workspace, convert to Recipe |
| RecipeWorkspaceWidget | Widget | Pending | 10 | Editable recipe form |
| WorkspaceIngredientField | Widget | Pending | 6 | Edit single ingredient |

**Total**: 5 screens/widgets, 41 test cases

---

## Summary Statistics

| Category | Count |
|----------|-------|
| **Screens** | 10 |
| **Widgets** | 19 |
| **Test Doubles** | 5 fake repositories |
| **Test Cases** | 176 total |
| **Est. Lines of Code** | ~15,000 (screens + widgets + tests) |

---

## Implementation Order

### Parallel Batch 1: Foundations (Week 1)
1. **Recipe Management** (AREA_NEW_RECIPE_MANAGEMENT.md)
   - Subagent: FlutterDev
   - Time: ~2-3 days
   - Blocker: None
   - Tests: 33 cases

2. **Calendar Planning** (AREA_NEW_CALENDAR_PLANNING.md)
   - Subagent: FlutterDev
   - Time: ~2-3 days
   - Blocker: None (uses recipe data, but can mock)
   - Tests: 35 cases

### Parallel Batch 2: Features (Week 2)
3. **User Preferences** (AREA_NEW_USER_PREFERENCES.md)
   - Subagent: FlutterDev
   - Time: ~1-2 days
   - Blocker: None (independent feature)
   - Tests: 33 cases

4. **Shopping List** (AREA_NEW_SHOPPING_LIST.md)
   - Subagent: FlutterDev
   - Time: ~2-3 days
   - Blocker: None (depends on recipes/assignments, but mocks available)
   - Tests: 34 cases

### Batch 3: Advanced (Week 3)
5. **LLM Onboarding** (AREA_NEW_LLM_ONBOARDING.md)
   - Subagent: FlutterDev
   - Time: ~2-3 days
   - Blocker: None (mock processing for now)
   - Tests: 41 cases

---

## Testing Strategy

### Test Pyramid

```
                    ┌─────────────────┐
                    │  Integration    │  5-7 tests
                    │  (Emulator E2E) │  ~5-10s each
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ Repository Unit │  ~30 tests
                    │  (fake_cloud)   │  ~10-50ms each
                    └────────┬────────┘
                             │
            ┌────────────────▼────────────────┐
            │  Widget/Component Tests (Fast)  │  176 tests
            │       (Provider Overrides)      │  ~50-200ms each
            └────────────────┬────────────────┘
```

### Test Execution

```bash
# All widget tests (fastest)
flutter test test/widgets/ --exclude integration_test/
# Expected: ~30-40 seconds total

# All tests including repository unit tests
flutter test test/
# Expected: ~45-60 seconds total

# Integration tests (optional, slow)
flutter test integration_test/ --dart-define=DEV_MODE=true
# Expected: ~2-3 minutes
```

---

## Architecture Compliance Checklist

### ✅ Decoupling (TAO_OF_TEEMU.md)

- [ ] All widgets use Riverpod providers only
- [ ] No Firebase imports in widgets
- [ ] No Firebase imports in tests
- [ ] Repository pattern implemented for each domain
- [ ] Fake repositories used for widget tests
- [ ] Provider overrides in all test ProviderScopes

### ✅ State Management (TAO_OF_TEEMU.md)

- [ ] `recipe_providers.dart` patterns followed
- [ ] `meal_assignment_providers.dart` patterns followed
- [ ] Computed providers for derived state
- [ ] StreamProvider for real-time updates
- [ ] FutureProvider for async operations
- [ ] StateNotifier/AsyncNotifier for mutations

### ✅ Testing (FLUTTER_DEV.md)

- [ ] `flutter analyze` passes all files
- [ ] `flutter test` passes all files
- [ ] Tests run <5s total for each area
- [ ] No flaky/sleep-based tests
- [ ] Test data seeding in setUp()
- [ ] Provider overrides in each test

### ✅ ID Generation (uuid_generator.dart)

- [ ] All entity IDs use `UuidGenerator.next()`
- [ ] Format: `${timestamp}:${counter}:${deviceHash}`
- [ ] Sortable by creation time
- [ ] Cross-device collision-safe

### ✅ Models (Existing, Reused)

- [ ] No new models created
- [ ] All Freezed with auto-generated JSON serialization
- [ ] All immutable with copyWith()
- [ ] All models in `./meal_planner/lib/models/`

### ✅ Providers (Existing, Reused)

- [ ] All in `./meal_planner/lib/providers/`
- [ ] Repository pattern injected via providers
- [ ] Overridable for testing

---

## Quality Gates (Per FLUTTER_DEV.md)

### Before Each Test File Completes

- [ ] `flutter analyze lib/` → no errors or critical warnings
- [ ] `flutter analyze test/` → no errors
- [ ] `flutter test [test_file.dart]` → all tests pass
- [ ] Average test execution time <200ms per test
- [ ] No console warnings from Riverpod

### Before Feature Complete

- [ ] All widget tests pass
- [ ] All repository tests pass (if applicable)
- [ ] Zero Firebase imports in test files
- [ ] Provider overrides functional in all tests
- [ ] Integration test passes in dev-mode screen

### Before PR Merge

- [ ] Full test suite passes: `flutter test`
- [ ] Full analysis passes: `flutter analyze`
- [ ] Documentation updated (this file, area specs)
- [ ] Commit message explains changes
- [ ] No breaking changes to existing providers/models

---

## References

### Foundation Documents
- `TAO_OF_TEEMU.md` - Decoupling & testing architecture
- `FLUTTER_DEV.md` - Development workflow
- `TESTING_TAO.md` - MealPlanner testing patterns
- `FIREBASE_MIGRATION_COMPLETE.md` - Schema & providers

### Specification Documents
- `AREA_NEW_RECIPE_MANAGEMENT.md` - Recipe management screens/widgets
- `AREA_NEW_CALENDAR_PLANNING.md` - Calendar & meal planning screens
- `AREA_NEW_USER_PREFERENCES.md` - Preferences settings screens
- `AREA_NEW_SHOPPING_LIST.md` - Shopping list screens
- `AREA_NEW_LLM_ONBOARDING.md` - LLM recipe capture screens

### Code References
- `./meal_planner/lib/models/` - All Freezed models (reuse)
- `./meal_planner/lib/providers/` - All Riverpod providers (reuse)
- `./meal_planner/lib/services/uuid_generator.dart` - ID generation

---

## Implementation Progress

### Batch 1: Recipe Management
- [ ] Screens: RecipeListScreen, RecipeDetailScreen, RecipeFormScreen
- [ ] Widgets: RecipeCard, RecipeSearchBar, RecipeFilterChips
- [ ] Tests: 33 cases across 6 test files
- [ ] Fake Repository: FakeRecipeRepository

### Batch 2: Calendar Planning
- [ ] Screens: WeekCalendarScreen, DayDetailScreen, MealAssignmentModal
- [ ] Widgets: CalendarDayCell, MealAssignmentWidget, WeeklySummary
- [ ] Tests: 35 cases across 6 test files
- [ ] Fake Repository: FakeMealAssignmentRepository

### Batch 3: User Preferences
- [ ] Screen: UserPreferencesScreen
- [ ] Widgets: PortionsSelector, DietaryRestrictionsSelector, DislikedIngredientsInput, PreferredSupermarketsSelector
- [ ] Tests: 33 cases across 5 test files
- [ ] Fake Repository: FakeUserPreferencesRepository

### Batch 4: Shopping List
- [ ] Screens: ShoppingListGenerationScreen, ShoppingListScreen
- [ ] Widgets: ShoppingListItem, CostSummary, ShoppingListSection
- [ ] Tests: 34 cases across 5 test files
- [ ] Fake Repository: FakeShoppingListRepository

### Batch 5: LLM Onboarding
- [ ] Screens: CameraCaptureScreen, RecipeProcessingScreen, RecipeReviewScreen
- [ ] Widgets: RecipeWorkspaceWidget, WorkspaceIngredientField
- [ ] Tests: 41 cases across 5 test files

---

## Success Criteria

### Functional
✅ All 5 functional areas fully implemented with UI  
✅ All user workflows end-to-end functional  
✅ All screens navigate correctly  
✅ All widgets render without crashes  

### Testing
✅ 176+ unit tests all passing  
✅ <5s test execution per area  
✅ Zero Firebase imports in tests  
✅ 100% provider override coverage  

### Architecture
✅ Complete repository pattern implemented  
✅ Fake repositories for all domains  
✅ All models reused from existing  
✅ All providers from existing  
✅ All IDs via UuidGenerator.next()  

### Quality
✅ `flutter analyze` passes  
✅ `flutter test` passes  
✅ No breaking changes  
✅ Documentation up-to-date  

---

## Notes

- All work follows TAO_OF_TEEMU.md strictly
- No external dependencies introduced without approval
- All tests run without Firebase emulator
- All widgets testable in isolation via provider overrides
- Parallel execution of 5 subagents for speed
