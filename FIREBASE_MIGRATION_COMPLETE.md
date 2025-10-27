# Firebase + Riverpod Migration - Complete

**Date**: 2025-10-27  
**Branch**: `firebase`  
**Status**: ✅ COMPLETE - Ready for Testing

---

## Overview

MealPlanner has been successfully migrated from PocketBase event-sourcing to **Firebase Firestore** with **Riverpod** reactive state management. The new architecture is simpler, more maintainable, and directly aligned with specs 001-004.

---

## What Changed

### ❌ Removed (Event-Sourcing Architecture)
- **PocketBase backend** → Replaced by Firebase Firestore
- **Event sourcing** (`edits`, `snapshots` collections) → Direct document persistence
- **Event-sourced services**:
  - `entity_handle.dart` - ORM-style state management
  - `local_buffer.dart` - Event queuing
  - `merge_arbitrator.dart` - Conflict resolution
  - `sync_isolate.dart` - Background sync worker
  - `uuid_generator.dart` - Custom UUID generation
  - `recipe_handle_provider.dart` - Entity wrapper
- **Old models**:
  - `recipe.dart`, `ingredient.dart` → Replaced by freezed versions
  - `day_event.dart`, `day_log.dart`, `event_type.dart` → Replaced by `meal_assignment.freezed_model.dart`
  - `meal_entry.dart` → Logic moved to computed providers
- **PocketBase documentation**:
  - `EVENT_STORE_ARCHITECTURE.md` - Event store concepts
  - `POCKETBASE_MIGRATION_SUMMARY.md` - PocketBase setup
  - `POCKETBASE_DART_MIGRATION.md` - Dart integration notes
  - `BUG_FIXES_APPLIED.md` - Event store fixes

### ✅ Added (Firebase + Riverpod)

#### Dependencies
```yaml
firebase_core: ^3.12.0
cloud_firestore: ^5.8.0
firebase_auth: ^5.6.0
flutter_riverpod: ^2.6.1
freezed_annotation: ^2.4.1
json_annotation: ^4.9.0
```

#### Data Models (Freezed)
All models are **immutable**, auto-generate **JSON serialization**, and support **copyWith()** for creating modified copies:

1. **Core Entities** (Specs 001-004):
   - `Recipe` - JDT RFC 8927 compliant recipes
   - `Ingredient` - UCUM + metric units, allergen codes
   - `MealAssignment` - Links recipes to calendar days
   - `UserPreferences` - Portions, dietary restrictions, supermarkets
   - `ShoppingList` - Aggregated ingredients by section
   - `MealPlan` - Collection of meal assignments

2. **Supporting Entities** (Spec 004):
   - `WorkspaceRecipe` - Draft recipes for LLM onboarding
   - `SearchModels` - SearchOptions, SearchResult for querying

#### State Management (Riverpod)

**5 provider files** implementing the cafe demo pattern:

1. **`recipe_providers.dart`**
   - `recipesProvider` - Stream of all recipes from Firestore
   - `recipeProvider(id)` - Single recipe by ID
   - `RecipeSaveNotifier` - Save/delete operations
   - `RecipeSearchNotifier` - Full-text + filtered search (max time, allergens, ingredients, sorting)

2. **`meal_assignment_providers.dart`**
   - `mealAssignmentsForDayProvider(isoDate)` - Day's assignments
   - `weekMealAssignmentsProvider(startIsoDate)` - Week's assignments
   - `MealAssignmentNotifier` - Assign/unassign meals

3. **`user_preferences_providers.dart`**
   - `userPreferencesProvider(userId)` - Load user settings
   - `UserPreferencesNotifier` - Update portions, restrictions, save

4. **`calendar_providers.dart`** (Computed)
   - `recipesForDayProvider(isoDate)` - Recipes for a day
   - `weekMealCountsProvider(startIsoDate)` - Meals per day
   - `weekTotalTimeProvider(startIsoDate)` - Weekly cook time sum

5. **`shopping_list_providers.dart`** (Computed)
   - `generateShoppingListProvider(assignmentIds)` - Aggregate ingredients
   - `ShoppingListNotifier` - Save/update operations

#### Firebase Setup
- **`firebase_options.dart`** - Platform-specific Firebase config
- **`firebase.json`** - Emulator configuration (port 8080)
- **`firestore.rules`** - Security rules (dev: allow all reads/writes)
- **Updated `main.dart`** - Firebase init + ProviderScope wrapping

---

## Firestore Schema

```
/recipes/{recipeId}
├── id: string
├── title: string
├── imageUrl: string
├── description: string
├── notes: string
├── preReqs: string[]
├── totalTime: number
├── ingredients: { name, ucumUnit, ucumAmount, metricUnit, metricAmount, notes, allergenCode }[]
└── steps: string[]

/meal_assignments/{assignmentId}
├── id: string
├── recipeId: string (FK → /recipes)
├── dayIsoDate: string (YYYY-MM-DD)
└── assignedAt: timestamp

/user_preferences/{userId}
├── userId: string
├── portions: number (default 4)
├── maxCookTime: number?
├── dietaryRestrictions: string[]
├── dislikedIngredients: string[]
└── preferredSupermarkets: string[]

/shopping_lists/{listId}
├── id: string
├── items: { name, quantity, unit, section, alternatives }[]
├── totalEstimatedCost: number
└── createdAt: timestamp
```

---

## Key Architectural Changes

### 1. Immutability by Default
- All models are `@freezed` classes
- No mutable state in models
- `copyWith()` creates new instances
- Equality and hashCode auto-generated

### 2. Reactive State Management
- **Riverpod** watches provider changes
- UI auto-updates when data changes
- No manual setState or listeners
- Computed providers derive state from other providers

### 3. Direct Firebase Access
- No ORM, no session management
- Firestore queries directly in providers
- Firebase SDK handles offline queuing automatically
- Real-time listeners update UI instantly

### 4. Simplified Offline Support
- `await firestore.set()` works online or offline
- Firebase SDK queues writes locally
- Automatic sync when network returns
- No complex conflict resolution needed

### 5. Search Implementation
- Full-text search across title/description/ingredients
- Filter by max cook time
- Filter by allergen exclusion
- Filter by ingredient inclusion
- Relevance scoring + sorting
- All in `RecipeSearchNotifier` (no backend API needed)

---

## Migration Path: Old → New

| Old | New | Purpose |
|-----|-----|---------|
| EntityHandle<T> | Riverpod providers | Mutable state management |
| LocalBuffer | Firebase SDK (local cache) | Offline queuing |
| MergeArbitrator | Firestore (server-side) | Conflict resolution |
| StoreEvent/Snapshot | Direct JSON serialization | Data persistence |
| PocketBase SDK | Cloud Firestore SDK | Backend |
| Recipe (old) | Recipe (freezed) | Immutable data model |
| @immutable + equatable | @freezed | Auto-generated machinery |

---

## How to Test

### 1. Start Firestore Emulator
```bash
cd /Users/Shared/MealPlanner
firebase emulators:start --only firestore,auth
```

### 2. Run App
```bash
cd meal_planner
flutter run
```

### 3. Test Workflows
**Add Recipe:**
- App creates recipe in Firestore `/recipes` collection
- UI re-renders automatically

**Assign Meal to Day:**
- App creates assignment in Firestore `/meal_assignments` collection
- `recipesForDayProvider` watchers update
- Calendar displays new meal

**Search Recipes:**
- Type in search box
- `RecipeSearchNotifier.search()` filters locally from `recipesProvider`
- Results ranked by relevance

**Go Offline:**
- Disable network
- Try saving a recipe
- Firebase SDK queues locally
- Go online
- Data syncs automatically

---

## Code Generation

Run this when models or providers change:
```bash
cd meal_planner
flutter pub run build_runner build --delete-conflicting-outputs
```

Generated files:
- `lib/models/*.freezed.dart` - Immutability machinery (equality, copyWith, etc)
- `lib/models/*.g.dart` - JSON serialization (toJson/fromJson)
- `lib/providers/*.g.dart` - Riverpod wiring

---

## Compilation Status

**Main app:** ✅ Compiles successfully
- `main.dart` has only 2 minor info warnings (not errors)
- Firebase packages properly integrated
- All providers and models generate successfully

**Test files:** ⚠️ Need updating
- Old event-sourcing tests reference deleted files
- Will be rewritten in next phase
- Not blocking app compilation

---

## Next Steps

### Phase 1: UI Migration (Separate PR)
- Update existing screens to use new providers
- Replace PocketBase calls with Riverpod watches
- Test calendar view with Firebase data

### Phase 2: Test Rewrite
- Delete old event-sourcing tests
- Write unit tests for new providers
- Write integration tests with Firestore emulator

### Phase 3: Production Firebase
- Set up Firebase project (console.firebase.google.com)
- Generate real `firebase_options.dart` (FlutterFire CLI)
- Update `firestore.rules` with auth-based access control
- Deploy to Firebase Hosting

### Phase 4: LLM Recipe Onboarding (Spec 004)
- Implement camera + OCR for recipe photos
- Integrate MistralAI for recipe structuring
- Pre-populate recipe form from AI output
- Save to `WorkspaceRecipe` collection for review

---

## Breaking Changes

| Old | Impact | Migration |
|-----|--------|-----------|
| `PocketBaseService` | Everywhere | Use Riverpod providers instead |
| `EntityHandle<T>` | Undo/redo logic | Use Riverpod computed providers |
| `LocalBuffer` | Offline buffering | Firebase SDK handles this |
| Custom `Recipe` model | All screens | Use `Recipe.freezed_model.dart` |
| Event-based data updates | Real-time UI | Use `ref.watch()` instead |

---

## File Structure (New)

```
lib/
  main.dart                              ← Firebase init + ProviderScope
  firebase_options.dart                  ← Platform Firebase config
  
  models/
    enums.dart                           ← Keep (UcumUnit, MetricUnit, AllergenCode, DayEventOperation)
    recipe.freezed_model.dart            ← New (with .freezed.dart & .g.dart)
    ingredient.freezed_model.dart        ← New
    meal_assignment.freezed_model.dart   ← New
    user_preferences.freezed_model.dart  ← New
    shopping_list.freezed_model.dart     ← New
    meal_plan.freezed_model.dart         ← New
    workspace_recipe.freezed_model.dart  ← New
    search_models.freezed_model.dart     ← New
  
  providers/
    recipe_providers.dart                ← New (with .g.dart)
    meal_assignment_providers.dart       ← New
    user_preferences_providers.dart      ← New
    calendar_providers.dart              ← New (computed)
    shopping_list_providers.dart         ← New (computed)
  
  screens/
    (empty - to be populated with new Firebase-aware screens)
  
  services/
    (empty - Firebase SDK replaces service layer)

firebase.json                            ← Emulator config
firestore.rules                          ← Dev security rules
```

---

## Alignment with Specs

✅ **Spec 001** (Meal Planning): UserPreferences, ShoppingList, MealPlan models + providers  
✅ **Spec 002** (Calendar View): MealAssignment model + calendar_providers (computed recipes for day/week)  
✅ **Spec 003** (Recipe API): Recipe model + SearchModels + RecipeSearchNotifier (full search, filtering, sorting)  
✅ **Spec 004** (LLM Onboarding): WorkspaceRecipe model (ready for camera + MistralAI integration)

---

## Key Principles Applied

1. **Zero ORM**: Just freezed objects ↔ JSON, no session hydration
2. **Immutability First**: All models `@freezed`, copyWith() for changes
3. **Reactive UI**: Riverpod watches providers, auto-updates on change
4. **Offline Transparent**: Firebase SDK handles queuing, no app logic needed
5. **Computed State**: Derived values auto-recompute (shopping list aggregation, week totals)
6. **Simple Schema**: Flat collections, indexed by document ID, careful ordering on read-side

---

## References

- **Freezed docs**: https://pub.dev/packages/freezed
- **Riverpod docs**: https://riverpod.dev
- **Firebase + Flutter**: https://firebase.google.com/docs/flutter/setup
- **Cloud Firestore docs**: https://firebase.google.com/docs/firestore
- **Emulator suite**: https://firebase.google.com/docs/emulator-suite

---

## Questions?

Refer to the inline comments in:
- `lib/providers/recipe_providers.dart` - Search implementation details
- `lib/main.dart` - Firebase initialization
- `lib/models/*.freezed_model.dart` - Model structure

Code is well-commented and follows the cafe demo pattern from the setup guide.
