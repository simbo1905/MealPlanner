# MVP1.0: Recipe Database - IMPLEMENTATION SPEC

## What This Feature Does

Users can search a database of 13,496 recipes from Epicurious by typing in a search box. As they type, they see autocomplete suggestions. They can navigate with keyboard arrows and select with Enter. When they select a recipe, it gets added to their personal favorites and passed to the meal planner. Next time they open the recipe picker, their favorites show up first.

---

## Data Source

- **Location**: `/Users/Shared/MealPlanner/.tmp/recipes.csv` (13,496 recipes)
- **Source**: https://github.com/josephrmartinez/recipe-dataset by Joseph Martinez
- **Original**: Epicurious.com (Condé Nast)
- **License**: CC BY-SA 3.0

Must display attribution in the app.

---

## Firestore Database Structure

### Collection: `recipes_v1`

Single flat collection with 13,496 recipe documents.

```javascript
{
  id: "uuid-here",
  title: "Chicken Parmesan",
  titleLower: "chicken parmesan",                    // for search
  titleTokens: ["chicken", "parmesan"],              // for prefix matching
  ingredients: "raw CSV string...",
  instructions: "raw CSV string...",
  ingredientNamesNormalized: ["chicken", "cheese"],  // for filtering
  createdAt: timestamp,
  version: "v1"
}
```

**Security**: Read-only for everyone. Write-only via admin CLI.

**Indexes Needed**:
1. `titleLower ASC + createdAt DESC` - for title search
2. `ingredientNamesNormalized ARRAY_CONTAINS + createdAt DESC` - for ingredient filter

### Collection: `user_favourites_v1/{userId}/recipes/{recipeId}`

User-specific favorites, nested under their user ID.

```javascript
{
  recipeId: "uuid-from-recipes_v1",
  title: "Chicken Parmesan",  // denormalized for display
  addedAt: timestamp
}
```

**Security**: User can only read/write their own favorites (enforced by `userId == auth.uid` rule).

---

## User Experience

### First Time User
1. Opens meal planner, clicks "Add Recipe"
2. See search box: "Type to search for recipes..."
3. Types "chick"
4. Sees dropdown with matching recipes
5. Arrows down, presses Enter on "Chicken Parmesan"
6. Recipe added to favorites (background)
7. Recipe passed to meal planner
8. Meal added to calendar

### Returning User
1. Opens meal planner, clicks "Add Recipe"
2. Sees their favorite recipes listed
3. Search box at top to find more
4. Can pick from favorites OR search new
5. Selection goes to meal planner

### Autocomplete Behavior
- Type → wait 300ms → search fires
- Show top 10 results
- Arrow Up/Down to navigate
- Enter to select
- Escape to close
- Hover with mouse highlights
- Shows ingredient preview under each title
- "No recipes found" if nothing matches

---

## What Has Been Implemented

### ✅ Data Pipeline (recipes/v1/)
- `transform_recipes_csv.dart` - Parses CSV, creates batch JSON files with search fields
- `deploy_recipesv1.sh` - One command to: transform data, deploy indexes, upload recipes, deploy rules

### ✅ Data Upload (meal_planner/lib/scripts/)
- `load_recipes_v1.dart` - Reads batch JSON files, uploads to Firestore with retry logic

### ✅ Repositories (meal_planner/lib/repositories/)
- `recipes_v1_repository.dart`
  - Interface + Firebase implementation
  - `searchByTitlePrefix(prefix)` - for autocomplete
  - `searchByIngredient(ingredient)` - for filtering
  - `getById(id)` - single recipe
  - `getTotalCount()` - collection size

- `user_favourites_v1_repository.dart`
  - Interface + Firebase implementation
  - `watchFavourites(userId)` - real-time stream
  - `addFavourite(userId, recipeId, title)` - add
  - `removeFavourite(userId, recipeId)` - remove
  - `isFavourite(userId, recipeId)` - check

### ✅ Riverpod Providers (meal_planner/lib/providers/)
- `recipes_v1_provider.dart`
  - `recipesV1RepositoryProvider` - repository instance
  - `recipeSearchV1Notifier(query)` - search stream with debounce
  - `recipesV1Count` - total recipe count

- `user_favourites_v1_provider.dart`
  - `userFavouritesV1RepositoryProvider` - repository instance
  - `userFavouritesV1(userId)` - favorites stream
  - `addUserFavouriteV1Notifier` - add/remove notifier

- `auth_provider.dart`
  - `currentUserIdProvider` - current user UID
  - `authInitializerNotifier` - initialize anonymous auth

### ✅ UI Widget (meal_planner/lib/widgets/recipe/)
- `recipe_search_autocomplete.dart`
  - Autocomplete search box
  - Dropdown with results
  - Keyboard navigation (arrows, enter, escape)
  - **BUG**: Missing import for LogicalKeyboardKey

### ✅ Testing (meal_planner/test/ and integration_test/)
- `fake_recipes_v1_repository.dart` - 10 hardcoded test recipes
- `fake_user_favourites_v1_repository.dart` - in-memory fake
- `recipes_v1_repository_test.dart` - 10+ unit tests
- `user_favourites_v1_repository_test.dart` - 8+ unit tests
- `recipe_search_integration_test.dart` - integration tests
- `recipe_count_validation_test.dart` - production validation

### ✅ Firebase Config
- `firestore.indexes.json` - composite indexes
- `firestore.rules` - security rules for recipes_v1 and user_favourites_v1

### ✅ Model Updates
- `lib/models/recipe.freezed_model.dart`
  - Added: `titleLower`, `titleTokens`, `ingredientNamesNormalized`, `version`

---

## What Still Needs To Be Done

### 1. Fix RecipeSearchAutocomplete Import

**File**: `meal_planner/lib/widgets/recipe/recipe_search_autocomplete.dart`

**Problem**: Missing `import 'package:flutter/services.dart';`

**Fix**: Add this line at the top with other imports:
```dart
import 'package:flutter/services.dart';
```

### 2. Update main.dart to Initialize Auth

**File**: `meal_planner/lib/main.dart`

**What to add**:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize anonymous auth
  final container = ProviderContainer();
  await container.read(authInitializerNotifierProvider.future);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MealPlannerApp(),
    ),
  );
}
```

### 3. Create RecipePickerScreen

**File**: `meal_planner/lib/screens/recipe/recipe_picker_screen.dart` (NEW)

**What it does**:
- Takes a callback: `onRecipeSelected(Recipe recipe)`
- Gets userId from `currentUserIdProvider`
- Shows user's favorites from `userFavouritesV1Provider(userId)`
- Shows `RecipeSearchAutocomplete` widget
- When user selects a recipe:
  - Adds to favorites via `addUserFavouriteV1Notifier`
  - Calls the callback

**Implementation**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/recipe.freezed_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_favourites_v1_provider.dart';
import '../../widgets/recipe/recipe_search_autocomplete.dart';

class RecipePickerScreen extends ConsumerWidget {
  final void Function(Recipe)? onRecipeSelected;

  const RecipePickerScreen({
    Key? key,
    this.onRecipeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);

    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final favoritesAsync = ref.watch(userFavouritesV1Provider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Recipe'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: RecipeSearchAutocomplete(
              onRecipeSelected: (recipe) => _handleSelection(
                context,
                ref,
                userId,
                recipe,
              ),
            ),
          ),
          Expanded(
            child: favoritesAsync.when(
              data: (favorites) {
                if (favorites.isEmpty) {
                  return const Center(
                    child: Text('Search above to find recipes'),
                  );
                }
                return ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final recipe = favorites[index];
                    return ListTile(
                      title: Text(recipe.title ?? 'Untitled'),
                      onTap: () => _handleSelection(
                        context,
                        ref,
                        userId,
                        recipe,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSelection(
    BuildContext context,
    WidgetRef ref,
    String userId,
    Recipe recipe,
  ) {
    // Add to favorites (background operation)
    ref.read(addUserFavouriteV1NotifierProvider.notifier).addFavourite(
          userId,
          recipe.id!,
          recipe.title!,
        );

    // Notify caller
    onRecipeSelected?.call(recipe);
  }
}
```

### 4. Create AttributionScreen

**File**: `meal_planner/lib/screens/attribution_screen.dart` (NEW)

**What it does**:
- Shows Epicurious attribution
- Shows Joseph Martinez credit
- Shows CC BY-SA 3.0 license
- Has clickable link to license

**Implementation**:
```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AttributionScreen extends StatelessWidget {
  const AttributionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attribution'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recipe Dataset',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(
              'This application uses recipe data from:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Original Source: Epicurious.com (Condé Nast)'),
            const Text('• Dataset: Joseph Martinez (recipe-dataset)'),
            const Text('• License: CC BY-SA 3.0'),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final uri = Uri.parse('https://creativecommons.org/licenses/by-sa/3.0/');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              child: const Text(
                'View License Details',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.',
            ),
          ],
        ),
      ),
    );
  }
}
```

### 5. Generate Provider Code

**Run**:
```bash
cd meal_planner
dart run build_runner build --delete-conflicting-outputs
```

**This generates**:
- `recipes_v1_provider.g.dart`
- `user_favourites_v1_provider.g.dart`
- `auth_provider.g.dart`

### 6. Run Tests

**Run**:
```bash
cd meal_planner
flutter test test/repositories/recipes_v1_repository_test.dart
flutter test test/repositories/user_favourites_v1_repository_test.dart
```

**Expected**: All tests pass

### 7. Enable Firebase Anonymous Auth (Manual)

**Steps**:
1. Go to https://console.firebase.google.com/project/planmise/authentication
2. Click "Sign-in method" tab
3. Click "Anonymous"
4. Toggle "Enable"
5. Save

---

## Deployment (After Code Complete)

### Deploy Data to Firestore

**Run**:
```bash
cd /Users/Shared/MealPlanner/recipes/v1
chmod +x deploy_recipesv1.sh
./deploy_recipesv1.sh
```

**This will**:
1. Transform CSV → batch JSON files (.tmp/recipesv1_batches/)
2. Deploy Firestore indexes
3. Upload 13,496 recipes to recipes_v1 collection
4. Deploy security rules

**Time**: 5-10 minutes

### Verify Deployment

**Run**:
```bash
cd meal_planner
flutter test integration_test/recipe_count_validation_test.dart
```

**Expected**: Confirms 13,496 recipes in Firestore, indexes deployed, queries performant

---

## Integration with Meal Planner

Wherever you currently let users add recipes to meals, replace with:

```dart
void _addRecipeToMeal() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RecipePickerScreen(
        onRecipeSelected: (recipe) {
          // Your existing meal creation logic here
          // Use recipe.id and recipe.title
          _createMeal(recipe);
          Navigator.pop(context);
        },
      ),
    ),
  );
}
```

---

## Checklist

- [ ] Fix RecipeSearchAutocomplete import
- [ ] Update main.dart with auth init
- [ ] Create RecipePickerScreen
- [ ] Create AttributionScreen
- [ ] Run build_runner
- [ ] All tests pass
- [ ] Enable Firebase Anonymous Auth
- [ ] Deploy data to Firestore
- [ ] Verify with validation test
- [ ] Test app end-to-end

---

## Files Created

**Data/Scripts**:
- `recipes/v1/transform_recipes_csv.dart`
- `recipes/v1/deploy_recipesv1.sh`
- `meal_planner/lib/scripts/load_recipes_v1.dart`

**Repositories**:
- `meal_planner/lib/repositories/recipes_v1_repository.dart`
- `meal_planner/lib/repositories/user_favourites_v1_repository.dart`

**Providers**:
- `meal_planner/lib/providers/recipes_v1_provider.dart`
- `meal_planner/lib/providers/user_favourites_v1_provider.dart`
- `meal_planner/lib/providers/auth_provider.dart`

**UI**:
- `meal_planner/lib/widgets/recipe/recipe_search_autocomplete.dart`

**Testing**:
- `meal_planner/test/repositories/fake_recipes_v1_repository.dart`
- `meal_planner/test/repositories/fake_user_favourites_v1_repository.dart`
- `meal_planner/test/repositories/recipes_v1_repository_test.dart`
- `meal_planner/test/repositories/user_favourites_v1_repository_test.dart`
- `meal_planner/integration_test/recipe_search_integration_test.dart`
- `meal_planner/integration_test/recipe_count_validation_test.dart`

**Config**:
- `firestore.indexes.json`
- `firestore.rules` (updated)

**Models**:
- `meal_planner/lib/models/recipe.freezed_model.dart` (updated)

---

## Tasks for FlutterDevCodex Agent

1. Fix import in `recipe_search_autocomplete.dart`
2. Update `main.dart` 
3. Create `recipe_picker_screen.dart`
4. Create `attribution_screen.dart`
5. Run build_runner
6. Run tests
7. Report completion

DO NOT deploy data - that's manual after code works.
