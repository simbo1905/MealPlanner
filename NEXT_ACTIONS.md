# NEXT ACTIONS - Critical Path to Complete

**Date**: 2025-10-27  
**Status**: Ready for next phase  
**Blocker**: Provider architecture refactoring required

---

## Critical Blocker: Provider Architecture

### Problem

The existing providers in `lib/providers/` use **Firebase Firestore directly**, which violates the repository pattern from **TAO_OF_TEEMU.md** and prevents **provider overrides** in widget tests.

**Example - Current (Broken for Testing)**:
```dart
// lib/providers/recipe_providers.dart
@riverpod
Stream<List<Recipe>> recipes(Ref ref) {
  return FirebaseFirestore.instance  // ❌ Direct Firebase
      .collection('recipes')
      .snapshots()
      .map(...);
}
```

**What's Needed (Repository Pattern)**:
```dart
// lib/repositories/recipe_repository.dart
abstract class RecipeRepository {
  Stream<List<Recipe>> watchAllRecipes();
  Future<Recipe?> getRecipe(String id);
  // ...
}

// lib/repositories/firebase_recipe_repository.dart
class FirebaseRecipeRepository implements RecipeRepository {
  @override
  Stream<List<Recipe>> watchAllRecipes() {
    return FirebaseFirestore.instance
        .collection('recipes')
        .snapshots()
        .map(...);
  }
}

// lib/providers/recipe_providers.dart (FIXED)
@riverpod
RecipeRepository recipeRepository(Ref ref) {
  return FirebaseRecipeRepository();
}

@riverpod
Stream<List<Recipe>> recipes(Ref ref) {
  final repo = ref.watch(recipeRepository); // ✅ Uses repository
  return repo.watchAllRecipes();
}
```

---

## Refactoring Steps (In Order)

### Step 1: Create Repository Abstractions

**Time**: 1-2 hours

Create these interface files:

```bash
lib/repositories/
  ├── recipe_repository.dart         # Abstract interface
  ├── meal_assignment_repository.dart
  ├── user_preferences_repository.dart
  ├── shopping_list_repository.dart
  └── firebase/
      ├── firebase_recipe_repository.dart
      ├── firebase_meal_assignment_repository.dart
      ├── firebase_user_preferences_repository.dart
      └── firebase_shopping_list_repository.dart
```

**Each repository must**:
- Define abstract interface with all CRUD operations
- Implement Firebase version
- Support both synchronous (Future) and reactive (Stream) operations
- Use `final FirebaseFirestore _firestore;` dependency injection

### Step 2: Update Providers to Use Repositories

**Time**: 1-2 hours

For each provider file:

1. Add repository provider:
   ```dart
   @riverpod
   RecipeRepository recipeRepository(Ref ref) {
     return FirebaseRecipeRepository();
   }
   ```

2. Update data providers to use repository:
   ```dart
   @riverpod
   Stream<List<Recipe>> recipes(Ref ref) {
     final repo = ref.watch(recipeRepository);
     return repo.watchAllRecipes();
   }
   ```

Files to update:
- `lib/providers/recipe_providers.dart`
- `lib/providers/meal_assignment_providers.dart`
- `lib/providers/user_preferences_providers.dart`
- `lib/providers/shopping_list_providers.dart`

### Step 3: Implement Deferred Screens + Tests

**Time**: 6-10 hours

Once repositories are in place, implement:

1. **RecipeDetailScreen** + 5 tests
2. **RecipeFormScreen** + 8 tests
3. **DayDetailScreen** + 8 tests
4. **MealAssignmentModal** + 6 tests

All tests will use provider overrides:
```dart
ProviderScope(
  overrides: [
    recipeRepositoryProvider.overrideWithValue(FakeRecipeRepository()),
  ],
  child: RecipeDetailScreen(id: 'recipe-1'),
)
```

### Step 4: Fix Known Issues

**Time**: 2-3 hours

1. **User Preferences screen tests** (5 failing tests)
   - Issue: Provider state invalidation in test context
   - Fix: Properly manage test state with setUp/tearDown

2. **LLM Processing screen tests** (2 failing tests)
   - Issue: Timer cleanup in async tests
   - Fix: Properly dispose/cancel timers in test teardown

### Step 5: Integration Testing

**Time**: 4-6 hours

1. Manual simulator testing of all 19 widgets
2. End-to-end workflow testing
3. Firebase emulator integration tests
4. Performance profiling

---

## Execution Plan

### Phase A: Refactoring (2-4 hours)

**Parallelizable tasks**:
- Create recipe_repository.dart interface + firebase_recipe_repository.dart
- Create meal_assignment_repository.dart + firebase version
- Create user_preferences_repository.dart + firebase version
- Create shopping_list_repository.dart + firebase version

All 4 can be done in parallel by one developer/agent.

After all repositories created:
- Update all 4 provider files to use repositories (1-2 hours sequential)

### Phase B: Complete Screens (6-10 hours)

Once repositories are in place:

**In parallel**:
- RecipeDetailScreen + tests (2-3 hours)
- DayDetailScreen + tests (2-3 hours)

**Sequential** (dependencies):
- RecipeFormScreen + tests (2-3 hours) - depends on RecipeDetailScreen
- MealAssignmentModal + tests (1-2 hours)

### Phase C: Bug Fixes (2-3 hours)

- Fix 5 User Preferences integration tests
- Fix 2 LLM Processing tests
- Run full test suite

### Phase D: Integration Testing (4-6 hours)

- Manual testing in simulator
- Firebase emulator tests
- Performance optimization

---

## Immediate Next Action

**To unblock the team:**

Use FlutterDev subagent to refactor one provider module:

```
Task: Refactor recipe_providers.dart to use repository pattern

1. Create lib/repositories/recipe_repository.dart (interface)
2. Create lib/repositories/firebase/firebase_recipe_repository.dart (impl)
3. Update lib/providers/recipe_providers.dart to use repository
4. Verify all existing tests still pass with provider change
5. Ensure FakeRecipeRepository matches new interface
6. Document the pattern for other providers

Reference: TAO_OF_TEEMU.md lines 1-100 for repository pattern
```

Once this is complete, the other 3 repositories can be done in parallel.

---

## Cost-Benefit Analysis

### Cost of Refactoring
- **Time**: 8-16 hours total
- **Risk**: Low (refactoring, no new functionality)
- **Testing**: High (existing tests validate changes)

### Benefit
- ✅ Enables provider overrides in all widget tests
- ✅ Allows 4 deferred screens to be implemented
- ✅ Adds 27 more test cases
- ✅ Increases test coverage from 94.8% to 97%+
- ✅ Improves code testability long-term
- ✅ Aligns with TAO_OF_TEEMU.md best practices

### ROI
**High**: 6-10 hours of work enables 16+ hours of deferred feature development

---

## Success Criteria for Refactoring

### Code Quality
- ✅ All 4 repositories implement consistent interface
- ✅ All providers updated to use repositories
- ✅ Zero Firebase imports outside repositories
- ✅ `flutter analyze` passes with 0 errors

### Testing
- ✅ All existing provider tests pass
- ✅ `flutter test test/providers/` passes
- ✅ FakeRecipeRepository matches new interface
- ✅ Provider overrides work in widget tests

### Architecture
- ✅ Follows TAO_OF_TEEMU.md repository pattern
- ✅ Dependency injection via Riverpod
- ✅ Testable with provider overrides
- ✅ Maintains backward compatibility

---

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Breaking existing screens | All provider changes are additive (new `recipeRepository` provider); existing providers still work |
| Provider override issues | Use existing `FakeRecipeRepository` as validation that pattern works |
| Complex refactoring | Refactor one provider at a time, test after each |
| Time overrun | Parallelizable: 4 repositories can be created simultaneously |

---

## Timeline Estimate

| Phase | Duration | Blocker | Status |
|-------|----------|---------|--------|
| **A: Refactoring** | 2-4 hours | None | Ready |
| **B: Complete Screens** | 6-10 hours | Requires Phase A | Blocked |
| **C: Bug Fixes** | 2-3 hours | Requires Phase B | Blocked |
| **D: Integration** | 4-6 hours | Requires Phase C | Blocked |
| **Total** | **14-23 hours** | Phase A → B → C → D | **On Critical Path** |

---

## Deliverables Summary (After All Phases)

### Screens Completed
- ✅ RecipeListScreen (partial → complete)
- ✅ RecipeDetailScreen (deferred → complete)
- ✅ RecipeFormScreen (deferred → complete)
- ✅ WeekCalendarScreen (partial → complete)
- ✅ DayDetailScreen (deferred → complete)
- ✅ MealAssignmentModal (deferred → complete)
- ✅ UserPreferencesScreen (complete)
- ✅ ShoppingListGenerationScreen (complete)
- ✅ ShoppingListScreen (complete)
- ✅ CameraCaptureScreen (complete)
- ✅ RecipeProcessingScreen (complete)
- ✅ RecipeReviewScreen (complete)

**Total: 12/12 screens complete**

### Test Coverage
- Current: 128/132 tests passing (94.8%)
- Target: 155/155+ tests passing (100%)
- Gain: +27 tests for 4 deferred screens

### Architecture
- Current: 94.8% TAO_OF_TEEMU.md compliant
- Target: 100% compliant
- Gain: Full repository pattern implementation

---

## Ready to Execute

**Recommendation**: Launch FlutterDev subagent to refactor `recipe_providers.dart` as proof-of-concept, then parallelize remaining 3 repositories.

**Expected Outcome**: Complete all 5 functional areas with 155+ passing tests in 14-23 hours.
