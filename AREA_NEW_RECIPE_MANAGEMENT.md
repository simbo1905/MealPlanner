# AREA_NEW_RECIPE_MANAGEMENT.md

## Functional Area: Recipe Management (Spec 003)

**Status**: Models & providers exist. Screens, widgets, and tests need to be built.

**Models** (reuse from `./meal_planner/lib/models`):
- `recipe.freezed_model.dart` - Core recipe entity
- `ingredient.freezed_model.dart` - Recipe ingredients
- `search_models.freezed_model.dart` - Search/filter types

**Providers** (reuse from `./meal_planner/lib/providers`):
- `recipe_providers.dart` - `recipesProvider`, `recipeProvider(id)`, `RecipeSaveNotifier`, `RecipeSearchNotifier`

**Services**:
- `uuid_generator.dart` - Generate recipe IDs

---

## Screens to Build

### 1. RecipeListScreen
**Path**: `lib/screens/recipe/recipe_list_screen.dart`

**Purpose**: Display searchable, filterable list of recipes

**Widgets Used**:
- RecipeSearchBar
- RecipeFilterChips
- RecipeCard (in ListView)
- FloatingActionButton (create new recipe)

**Provider Watches**:
- `recipesProvider` - All recipes
- `RecipeSearchNotifier` - Search results
- User interactions trigger search/filter updates

**UI States**:
- Loading: Show CircularProgressIndicator
- Empty: Show "No recipes found" message
- Loaded: Show RecipeCard list
- Error: Show error message with retry button

**User Interactions**:
- Tap RecipeCard → Navigate to RecipeDetailScreen
- Tap FloatingActionButton → Navigate to RecipeFormScreen
- Search box typing → Filter recipes in real-time
- Filter chips → Apply allergen/time/ingredient filters

---

### 2. RecipeDetailScreen
**Path**: `lib/screens/recipe/recipe_detail_screen.dart`

**Purpose**: Display full recipe details with edit/delete options

**Widgets Used**:
- Recipe header (image, title, time)
- Ingredient list with quantities
- Cooking steps
- Edit button → RecipeFormScreen
- Delete button → Confirmation dialog

**Provider Watches**:
- `recipeProvider(recipeId)` - Single recipe data
- `userPreferencesProvider` - Portion scaling

**UI States**:
- Loading: Show skeleton/shimmer
- Loaded: Show all details
- Error: Show error message

**User Interactions**:
- Tap Edit → Navigate to RecipeFormScreen with pre-populated recipe
- Tap Delete → Show confirmation, call `RecipeSaveNotifier.delete()`
- Scale portions (from UserPreferences) → Recalculate ingredient quantities
- Tap ingredient → Show substitution options (future)

---

### 3. RecipeFormScreen
**Path**: `lib/screens/recipe/recipe_form_screen.dart`

**Purpose**: Create new or edit existing recipe

**Widgets Used**:
- Text fields: Title, description, notes, pre-requisites, total time
- Image upload button (future: camera)
- Ingredient list builder
- Steps list builder
- Save button (calls `RecipeSaveNotifier.save()`)
- Cancel button

**Provider Watches**:
- `recipeProvider(recipeId)` - Pre-populate form if editing
- `RecipeSaveNotifier` - Handle save state (loading/error/success)

**UI States**:
- New recipe: Empty form with placeholder text
- Edit recipe: Form pre-filled with existing data
- Saving: Show loading indicator on button
- Success: Pop screen, show snackbar "Recipe saved"
- Error: Show error message, allow retry

**User Interactions**:
- Add/remove ingredients (dynamic list)
- Add/remove steps (dynamic list)
- Validate title is not empty
- Call `RecipeSaveNotifier.save(Recipe)` with form data
- Call `UuidGenerator.next()` for new recipe ID

**Validation**:
- Title required, min 3 chars
- At least one ingredient required
- At least one step required

---

## Widgets to Build

### 1. RecipeCard
**Path**: `lib/widgets/recipe/recipe_card.dart`

**Props**:
- `recipe: Recipe`
- `onTap: VoidCallback`

**Displays**:
- Recipe image (or placeholder icon)
- Title
- Total cook time
- Ingredient count
- Allergen badges (if applicable)

**UI**:
- Material Card with shadow
- Clickable with Material ripple effect

---

### 2. RecipeSearchBar
**Path**: `lib/widgets/recipe/recipe_search_bar.dart`

**Props**:
- `onChanged: Function(String query)` - Called on text change
- `onSearchTriggered: Function(String query)?` - Optional: called on search button
- `hintText: String?`

**Displays**:
- TextField with search icon
- Clear button (appears when text entered)

**UI**:
- Rounded corners, subtle shadow
- Keyboard type: text
- Auto-focus optional

**Behavior**:
- Call `onChanged` on every keystroke (debounced in parent if needed)

---

### 3. RecipeFilterChips
**Path**: `lib/widgets/recipe/recipe_filter_chips.dart`

**Props**:
- `onAllergenChanged: Function(List<String> allergens)` - Selected allergens to exclude
- `onMaxTimeChanged: Function(int? maxMinutes)` - Max cook time
- `onIngredientsChanged: Function(List<String> ingredients)` - Must-have ingredients
- `selectedAllergens: List<String>` - Current selection
- `selectedMaxTime: int?` - Current selection
- `selectedIngredients: List<String>` - Current selection

**Displays**:
- FilterChip widgets for common allergens (peanuts, dairy, gluten, etc.)
- Slider or dropdown for max cook time (0-120 min)
- Input field for ingredient inclusion

**UI**:
- Horizontally scrollable list of allergen chips
- Filter reset button (clears all)

**Behavior**:
- Tapping allergen chip toggles selection
- Moving time slider updates max time
- Calls callbacks to update parent state

---

## Unit Tests to Build

### Test Repositories

**FakeRecipeRepository**  
`test/repositories/fake_recipe_repository.dart`
- Implements same interface as Firebase repository
- In-memory storage with StreamController for watches
- Methods: `watchAllRecipes()`, `getRecipe(id)`, `save(recipe)`, `delete(id)`
- Seed/clear methods for test setup

---

### Widget Tests

**RecipeListScreen Tests**  
`test/widgets/recipe/recipe_list_screen_test.dart`
- Test: Display empty state when no recipes
- Test: Display list of recipes when loaded
- Test: Navigate to detail on recipe tap
- Test: Navigate to form on FAB tap
- Test: Filter recipes by search query
- Test: Filter recipes by allergens
- Test: Filter recipes by max cook time

**RecipeDetailScreen Tests**  
`test/widgets/recipe/recipe_detail_screen_test.dart`
- Test: Display recipe data (title, time, ingredients, steps)
- Test: Show scaled ingredients based on portion preference
- Test: Navigate to form on Edit tap
- Test: Delete recipe on confirmation
- Test: Show error state if recipe not found

**RecipeFormScreen Tests**  
`test/widgets/recipe/recipe_form_screen_test.dart`
- Test: Create new recipe with valid data
- Test: Edit existing recipe
- Test: Validate required fields (title, ingredients, steps)
- Test: Add/remove ingredients in dynamic list
- Test: Add/remove steps in dynamic list
- Test: Show loading state while saving
- Test: Show error state on save failure
- Test: Generate UUID for new recipe

**RecipeCard Tests**  
`test/widgets/recipe/recipe_card_test.dart`
- Test: Display recipe title and time
- Test: Show allergen badges
- Test: Call onTap callback when tapped
- Test: Show placeholder image if imageUrl is empty

**RecipeSearchBar Tests**  
`test/widgets/recipe/recipe_search_bar_test.dart`
- Test: Call onChanged on text input
- Test: Show clear button when text entered
- Test: Clear text on clear button tap
- Test: Update hint text if provided

**RecipeFilterChips Tests**  
`test/widgets/recipe/recipe_filter_chips_test.dart`
- Test: Display allergen chips
- Test: Toggle allergen selection
- Test: Update max cook time slider
- Test: Call callbacks on selection changes
- Test: Reset all filters

---

## Architecture Notes

### State Management Flow

1. **RecipeListScreen watches `recipesProvider`**
   - Displays all recipes from Firestore
   - User searches → Updates local state in `RecipeSearchNotifier`
   - SearchNotifier filters locally and returns `SearchResult`

2. **RecipeDetailScreen watches `recipeProvider(id)`**
   - Displays single recipe by ID
   - Edit button → Pass recipe to RecipeFormScreen
   - Delete button → Call `RecipeSaveNotifier.delete()`

3. **RecipeFormScreen watches `recipeProvider(id)` for editing**
   - New recipe: Create with empty form
   - Edit recipe: Pre-populate form from provider
   - Save → Call `RecipeSaveNotifier.save(Recipe)`
   - Generate ID with `UuidGenerator.next()`

### Provider Override in Tests

```dart
// In test setup
final fakeRecipeRepo = FakeRecipeRepository();
fakeRecipeRepo.seed('recipe-1', Recipe(...));

// In ProviderScope
ProviderScope(
  overrides: [
    recipeRepositoryProvider.overrideWithValue(fakeRecipeRepo),
  ],
  child: RecipeListScreen(),
)
```

---

## Implementation Checklist

### Screens
- [ ] RecipeListScreen
- [ ] RecipeDetailScreen
- [ ] RecipeFormScreen

### Widgets
- [ ] RecipeCard
- [ ] RecipeSearchBar
- [ ] RecipeFilterChips

### Fake Repository
- [ ] FakeRecipeRepository

### Tests
- [ ] recipe_list_screen_test.dart (8+ test cases)
- [ ] recipe_detail_screen_test.dart (5+ test cases)
- [ ] recipe_form_screen_test.dart (8+ test cases)
- [ ] recipe_card_test.dart (4+ test cases)
- [ ] recipe_search_bar_test.dart (3+ test cases)
- [ ] recipe_filter_chips_test.dart (5+ test cases)

### Code Generation
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Verify all .g.dart files generated

### Quality Checks
- [ ] `flutter analyze` passes
- [ ] `flutter test test/widgets/recipe/` passes
- [ ] All test files run <5s total
- [ ] No Firebase imports in tests

---

## References

- **Models**: `./meal_planner/lib/models/recipe.freezed_model.dart`, `ingredient.freezed_model.dart`, `search_models.freezed_model.dart`
- **Providers**: `./meal_planner/lib/providers/recipe_providers.dart`
- **Testing**: `TESTING_TAO.md` (fake repositories, provider overrides)
- **Development**: `FLUTTER_DEV.md` (workflow, quality gates)
- **Architecture**: `TAO_OF_TEEMU.md` (decoupling principles)
- **ID Generation**: `./meal_planner/lib/services/uuid_generator.dart`
