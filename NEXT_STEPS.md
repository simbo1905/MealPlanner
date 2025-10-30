# Next Steps: RecipePickerScreen Integration & Final Touches

## Immediate Blockers Resolved ✅
All code generation, repositories, providers, and tests have been created and are ready to use.

## Remaining Manual Tasks

### 1. Enable Firebase Anonymous Authentication
**Location**: [Firebase Console](https://console.firebase.google.com/project/planmise/authentication)

**Steps**:
1. Go to Authentication > Sign-in method
2. Enable "Anonymous" provider
3. Save

**Expected Time**: 2 minutes

---

### 2. Update main.dart to Initialize Auth

**File**: `meal_planner/lib/main.dart`

**Add to main() function**:
```dart
// After Firebase.initializeApp(), before runApp()
final authRef = ProviderContainer().read(authInitializerProvider);
await authRef.future;
```

Or integrate with app startup flow (e.g., in a splash screen notifier)

**Alternative**: Use a FutureBuilder or Riverpod's `.when()` to handle auth initialization before showing UI

**Expected Time**: 5 minutes

---

### 3. Create/Update RecipePickerScreen

**File**: `meal_planner/lib/screens/recipe/recipe_picker_screen.dart` (create or extend existing)

**Required Features**:
```dart
class RecipePickerScreen extends ConsumerWidget {
  final Function(Recipe recipe) onRecipeSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    
    if (userId == null) {
      return Center(child: CircularProgressIndicator());
    }

    final favorites = ref.watch(userFavouritesV1Provider(userId));
    
    return favorites.when(
      data: (recipes) {
        return Column(
          children: [
            // If user has favorites, show them first
            if (recipes.isNotEmpty)
              ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  return RecipeCard(
                    recipe: recipes[index],
                    onTap: () => _selectRecipe(context, recipes[index]),
                  );
                },
              ),
            
            // Show search input
            Padding(
              padding: EdgeInsets.all(16),
              child: RecipeSearchAutocomplete(
                onRecipeSelected: (recipe) {
                  _selectRecipe(context, recipe);
                },
              ),
            ),
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, st) => Center(child: Text('Error: $error')),
    );
  }

  void _selectRecipe(BuildContext context, Recipe recipe) {
    final ref = ProviderScope.containerOf(context);
    final userId = ref.read(currentUserIdProvider);
    
    // Add to favorites if not already there
    ref.read(addUserFavouriteV1NotifierProvider.notifier)
        .addFavourite(userId!, recipe.id!, recipe.title!);
    
    // Notify parent
    onRecipeSelected(recipe);
  }
}
```

**Expected Time**: 15-20 minutes

---

### 4. Integrate with Existing Recipe Flow

**File**: Wherever meals are being created (likely meal_planner screen)

**Changes Needed**:
- Replace current recipe selection with `RecipePickerScreen`
- Pass `onRecipeSelected` callback that adds meal to calendar
- Ensure favorites are shown on screen open

**Example Integration**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RecipePickerScreen(
      onRecipeSelected: (recipe) {
        // Add meal using existing meal creation logic
        _addMealForRecipe(recipe);
        Navigator.pop(context);
      },
    ),
  ),
);
```

**Expected Time**: 10-15 minutes

---

### 5. Create Attribution Screen

**File**: `meal_planner/lib/screens/attribution_screen.dart`

**Requirements** (per `spec/attribution.md`):
- Display recipe dataset attribution
- Show CC BY-SA 3.0 license with link
- Credit Joseph Martinez and Epicurious
- Include link to both

**Simple Implementation**:
```dart
class AttributionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attribution')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recipe Dataset', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 16),
            Text('Source: Epicurious.com (Condé Nast)'),
            Text('Dataset: Joseph Martinez (recipe-dataset)'),
            Text('License: CC BY-SA 3.0'),
            SizedBox(height: 16),
            InkWell(
              onTap: () => launchUrl(Uri.parse('https://creativecommons.org/licenses/by-sa/3.0/')),
              child: Text('View License', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Add to navigation**: Settings/About menu

**Expected Time**: 10 minutes

---

### 6. Run All Tests

**Unit Tests**:
```bash
cd meal_planner
flutter test test/repositories/recipes_v1_repository_test.dart
flutter test test/repositories/user_favourites_v1_repository_test.dart
```

**Expected**: All tests pass (12+ tests)

**Integration Tests** (with Firestore emulator):
```bash
# Terminal 1
firebase emulators:start --only firestore,auth

# Terminal 2
cd meal_planner
flutter test integration_test/recipe_search_integration_test.dart
```

**Expected**: 10+ integration tests pass

**Expected Time**: 20 minutes (including emulator startup)

---

### 7. Deploy to Firebase

**One-command deployment**:
```bash
cd recipes/v1
./deploy_recipesv1.sh
```

**What it does**:
1. Transforms CSV → batch JSON files
2. Deploys Firestore indexes
3. Uploads 13,496 recipes
4. Deploys security rules

**Expected Time**: 5-10 minutes

**Verify with**:
```bash
cd meal_planner
flutter test integration_test/recipe_count_validation_test.dart
```

---

### 8. Manual Testing Checklist

- [ ] App starts without errors
- [ ] Anonymous auth initializes
- [ ] RecipePickerScreen opens
- [ ] Type in search field → autocomplete suggestions appear
- [ ] Arrow keys navigate suggestions
- [ ] Enter selects recipe
- [ ] Selected recipe added to favorites
- [ ] Favorites visible on next screen open
- [ ] Keyboard Escape closes dropdown
- [ ] No match → shows "No recipes found"
- [ ] Attribution screen accessible from menu
- [ ] All tests pass

---

## Dependencies to Verify

Check `meal_planner/pubspec.yaml` has these packages:

```yaml
dependencies:
  cloud_firestore: ^5.6.12
  firebase_core: ^3.12.0
  firebase_auth: ^5.6.0
  flutter_riverpod: ^2.x.x
  freezed_annotation: ^2.x.x
  csv: ^6.x.x (NEW)
  uuid: ^4.x.x (NEW)

dev_dependencies:
  build_runner:
  freezed:
  riverpod_generator:
```

If missing `csv` or `uuid`, add them:
```bash
cd meal_planner
flutter pub add csv uuid
```

---

## Code Generation

After any model or provider changes:
```bash
cd meal_planner
dart run build_runner build --delete-conflicting-outputs
```

This regenerates:
- `recipes_v1_provider.g.dart`
- `user_favourites_v1_provider.g.dart`
- `auth_provider.g.dart`
- Recipe model freezed files

---

## Expected Final State

After completing all steps:

✅ **Data**: 13,496 recipes loaded in Firestore  
✅ **Search**: Autocomplete working with <500ms latency  
✅ **Favorites**: User favorites persisting and visible  
✅ **Tests**: All unit and integration tests passing  
✅ **UI**: RecipePickerScreen integrated with meal creation  
✅ **Attribution**: License compliance displayed in app  
✅ **Security**: Recipes read-only, favorites user-isolated  

---

## Troubleshooting

**"Composite index not found" error**
- Indexes take 5-10 minutes to build
- Check Firebase Console > Firestore > Indexes
- Emulator doesn't require index deployment

**"No recipes found" in search**
- Ensure Firebase project is `planmise`
- Check collection name is `recipes_v1` (not `recipesv1`)
- Run validation test to confirm data load

**"Anonymous auth not working"**
- Enable in Firebase Console > Authentication
- Ensure `authInitializer` runs before UI

**Autocomplete showing loading forever**
- Check Firestore connection (emulator or production)
- Verify Firebase options in `firebase_options.dart`
- Check browser console for errors

---

## Support

Detailed information in:
- `spec/AREA_NEW_RECIPE_MANAGEMENT.md` - Complete specification
- `memory/IMPLEMENTATION_NOTES.md` - Design decisions
- `RECIPES_SETUP.md` - Setup workflow
- `memory/FIREBASE.md` - Collection structure
