# Testing TAO - MealPlanner Testing Architecture

This file extends **TAO_OF_TEEMU.md** with project-specific patterns for MealPlanner.

## Repository Pattern Implementation

### Core Principles
- Widgets never import Firebase packages
- Widgets only know Riverpod providers
- Tests override providers with in-memory fake repositories
- All fakes are synchronous and deterministic

### Three Repository Tiers

| Tier | Implementation | Use Case | Speed |
|------|----------------|----------|-------|
| **Fake Repositories** | In-memory, synchronous | Widget tests | ⚡ Instant |
| **Firebase Repository** | Cloud Firestore + Auth | App production | 🔵 Network-dependent |
| **Integration Tests** | Firestore emulator | Critical E2E flows | 🐌 5-7s startup |

---

## MealPlanner Fake Repositories

### 1. FakeRecipeRepository
```dart
// test/repositories/fake_recipe_repository.dart
class FakeRecipeRepository implements RecipeRepository {
  final Map<String, Recipe> _recipes = {};
  final Map<String, StreamController<List<Recipe>>> _controllers = {};
  
  void seed(String recipeId, Recipe recipe) {
    _recipes[recipeId] = recipe;
    _notifyListeners();
  }
  
  void clear() {
    _recipes.clear();
    for (var controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
  
  @override
  Stream<List<Recipe>> watchAllRecipes() {
    _controllers['all'] ??= StreamController<List<Recipe>>.broadcast();
    Future.microtask(() {
      if (!_controllers['all']!.isClosed) {
        _controllers['all']!.add(_recipes.values.toList());
      }
    });
    return _controllers['all']!.stream;
  }
  
  @override
  Future<Recipe?> getRecipe(String recipeId) async {
    return _recipes[recipeId];
  }
  
  @override
  Future<String> save(Recipe recipe) async {
    _recipes[recipe.id] = recipe;
    _notifyListeners();
    return recipe.id;
  }
  
  @override
  Future<void> delete(String recipeId) async {
    _recipes.remove(recipeId);
    _notifyListeners();
  }
  
  void _notifyListeners() {
    if (_controllers.containsKey('all') && !_controllers['all']!.isClosed) {
      _controllers['all']!.add(_recipes.values.toList());
    }
  }
}
```

### 2. FakeMealAssignmentRepository
```dart
class FakeMealAssignmentRepository implements MealAssignmentRepository {
  final Map<String, MealAssignment> _assignments = {};
  final Map<String, StreamController<List<MealAssignment>>> _controllers = {};
  
  void seed(String assignmentId, MealAssignment assignment) {
    _assignments[assignmentId] = assignment;
    _notifyListeners(assignment.dayIsoDate);
  }
  
  void clear() {
    _assignments.clear();
    for (var controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
  
  @override
  Stream<List<MealAssignment>> watchAssignmentsForDay(String isoDate) {
    _controllers[isoDate] ??= StreamController<List<MealAssignment>>.broadcast();
    Future.microtask(() {
      if (!_controllers[isoDate]!.isClosed) {
        final dayAssignments = _assignments.values
            .where((a) => a.dayIsoDate == isoDate)
            .toList();
        _controllers[isoDate]!.add(dayAssignments);
      }
    });
    return _controllers[isoDate]!.stream;
  }
  
  @override
  Future<String> assign(MealAssignment assignment) async {
    _assignments[assignment.id] = assignment;
    _notifyListeners(assignment.dayIsoDate);
    return assignment.id;
  }
  
  @override
  Future<void> unassign(String assignmentId) async {
    final assignment = _assignments.remove(assignmentId);
    if (assignment != null) {
      _notifyListeners(assignment.dayIsoDate);
    }
  }
  
  void _notifyListeners(String isoDate) {
    if (_controllers.containsKey(isoDate) && !_controllers[isoDate]!.isClosed) {
      final dayAssignments = _assignments.values
          .where((a) => a.dayIsoDate == isoDate)
          .toList();
      _controllers[isoDate]!.add(dayAssignments);
    }
  }
}
```

### 3. FakeUserPreferencesRepository
```dart
class FakeUserPreferencesRepository implements UserPreferencesRepository {
  final Map<String, UserPreferences> _prefs = {};
  
  void seed(String userId, UserPreferences prefs) {
    _prefs[userId] = prefs;
  }
  
  void clear() {
    _prefs.clear();
  }
  
  @override
  Future<UserPreferences?> getUserPreferences(String userId) async {
    return _prefs[userId];
  }
  
  @override
  Future<void> save(UserPreferences prefs) async {
    _prefs[prefs.userId] = prefs;
  }
}
```

### 4. FakeShoppingListRepository
```dart
class FakeShoppingListRepository implements ShoppingListRepository {
  final Map<String, ShoppingList> _lists = {};
  
  void seed(String listId, ShoppingList list) {
    _lists[listId] = list;
  }
  
  void clear() {
    _lists.clear();
  }
  
  @override
  Future<ShoppingList?> getShoppingList(String listId) async {
    return _lists[listId];
  }
  
  @override
  Future<String> save(ShoppingList list) async {
    _lists[list.id] = list;
    return list.id;
  }
}
```

---

## Provider Override Pattern

### Setup in Widget Tests
```dart
void main() {
  late FakeRecipeRepository fakeRecipeRepo;
  
  setUp(() {
    fakeRecipeRepo = FakeRecipeRepository();
    // Seed test data
    fakeRecipeRepo.seed('recipe-1', testRecipe1);
    fakeRecipeRepo.seed('recipe-2', testRecipe2);
  });
  
  tearDown(() {
    fakeRecipeRepo.clear();
  });
  
  testWidgets('displays recipes from repository', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recipeRepositoryProvider.overrideWithValue(fakeRecipeRepo),
        ],
        child: const MaterialApp(
          home: RecipeListScreen(),
        ),
      ),
    );
    
    await tester.pump();
    
    expect(find.text('Test Recipe 1'), findsOneWidget);
    expect(find.text('Test Recipe 2'), findsOneWidget);
  });
}
```

---

## Widget Test Checklist

For each widget test file:

- [ ] Import fake repository class
- [ ] Import `flutter_test` and `flutter_riverpod`
- [ ] Create `setUp()` to instantiate fake repo
- [ ] Create `tearDown()` to clean up fake repo
- [ ] Seed test data in each test
- [ ] Override provider with `fakeRepo`
- [ ] Wrap widget in `ProviderScope` + `MaterialApp`
- [ ] Use `await tester.pump()` to let streams emit
- [ ] Assert UI reflects seeded data
- [ ] No Firebase imports in test

---

## ID Generation Pattern

All entity IDs are generated using `UuidGenerator.next()`:

```dart
import 'package:meal_planner/services/uuid_generator.dart';

// In notifier or factory method
final id = await UuidGenerator.next();
final recipe = Recipe(
  id: id,
  title: 'My Recipe',
  // ... other fields
);
```

Format: `${msTimestamp}:${counter}:${deviceHash}`
- Sortable by creation time
- Collision-safe across devices
- Deterministic for testing (mock device hash)

---

## Stream Emission Pattern

For fake repositories that support watches:

```dart
// Correct pattern - emit immediately on first listen
@override
Stream<List<Recipe>> watchAllRecipes() {
  _controllers['all'] ??= StreamController<List<Recipe>>.broadcast();
  
  // Emit current state via microtask (not blocking)
  Future.microtask(() {
    if (!_controllers['all']!.isClosed) {
      _controllers['all']!.add(_recipes.values.toList());
    }
  });
  
  return _controllers['all']!.stream;
}
```

In tests, after creating widget:
```dart
await tester.pump();  // Let microtask run
```

---

## Error Handling in Tests

Use custom exceptions matching Firebase patterns:

```dart
class RecipeNotFoundException implements Exception {
  final String recipeId;
  RecipeNotFoundException(this.recipeId);
  @override
  String toString() => 'Recipe not found: $recipeId';
}

// In tests
testWidgets('handles missing recipe', (tester) async {
  // Don't seed recipe-123
  
  await tester.pumpWidget(...);
  await tester.pump();
  
  expect(find.text('Recipe not found'), findsOneWidget);
});
```

---

## Test File Organization

```
test/
  repositories/
    fake_recipe_repository.dart
    fake_meal_assignment_repository.dart
    fake_user_preferences_repository.dart
    fake_shopping_list_repository.dart
  
  widgets/
    recipe/
      recipe_card_test.dart
      recipe_search_bar_test.dart
      recipe_list_screen_test.dart
    calendar/
      week_calendar_screen_test.dart
      meal_assignment_widget_test.dart
    preferences/
      user_preferences_screen_test.dart
    shopping/
      shopping_list_screen_test.dart
```

---

## Running Tests

```bash
# Single test file
flutter test test/widgets/recipe/recipe_card_test.dart

# All widget tests
flutter test test/widgets/

# All tests including repositories
flutter test

# Watch mode
flutter test --watch
```

---

## Success Criteria Per Test

✅ **All tests must**:
- Use fake repositories (no Firebase imports)
- Run in <500ms per test
- Override providers with `ProviderScope`
- Seed data before widget build
- Pump at least once for streams
- Use `find` queries from `flutter_test`
- Not require network or emulator

❌ **Tests must NOT**:
- Import `cloud_firestore`
- Import `firebase_core`
- Make real HTTP requests
- Require running emulator
- Use `Future.delayed()` for state changes
- Have flaky timeouts or sleep calls

---

## References

- **TAO_OF_TEEMU.md** - Core decoupling principles
- **FLUTTER_DEV.md** - Development workflow
- **FIREBASE_MIGRATION_COMPLETE.md** - Schema and provider design
