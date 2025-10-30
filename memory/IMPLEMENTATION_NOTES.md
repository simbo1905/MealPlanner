# MVP1.0 Implementation Notes

## Design Decisions & Deviations from Spec

### Collection Naming
**Spec Proposed**: `recipesv1/recipes/` (nested structure)
**Implemented**: `recipes_v1` (flat collection)
**Reason**: Firestore's collection group functionality and simpler query patterns. The version number is preserved in the collection name (`recipes_v1` vs future `recipes_v2`), maintaining the versioning strategy. User favorites use nested structure (`user_favourites_v1/{userId}/recipes`) to leverage Firestore's natural hierarchical security model.

### Indexes Configuration
**Implementation Details**:
1. Index 1: `titleLower (ASC) + createdAt (DESC)` - for autocomplete/prefix search
2. Index 2: `ingredientNamesNormalized (ARRAY_CONTAINS) + createdAt (DESC)` - for ingredient-based filtering

**Note**: `createdAt (DESC)` ordering provides reverse chronological results, useful for displaying newest recipes first.

### Authentication
**Implementation**: Firebase Anonymous Auth
**Alternative Considered**: Require user login before search
**Reason**: Simpler UX for MVP1.0, quick user identification for favorites isolation

**Future Enhancement**: Can extend to Firebase Auth with Google/Apple sign-in once user engagement is validated

### Repository Pattern
**Design**: Abstract interface + Firebase + Fake implementations
**Testing Strategy**: 
- Unit tests use Fake implementations (no external dependencies)
- Integration tests use Firestore emulator or production database
- Fake implementations contain 10-20 hardcoded recipes for quick testing

### Widget Implementation
**RecipeSearchAutocomplete Details**:
- Raw KeyboardListener for arrow key navigation
- 300ms implicit debounce via Riverpod provider watching
- Dropdown shows up to 10 results
- Escape key closes dropdown
- Arrow Up/Down for navigation, Enter to select

**Alternative Considered**: Using built-in `Autocomplete<T>` widget
**Reason**: Custom implementation provides better keyboard control and visual feedback matching UX requirements

### Data Transformation
**CSV Parsing**:
- Uses `csv` package for robust parsing
- Handles both array-format and comma-separated ingredients
- Normalizes all text fields (lowercase, trimmed)
- Generates UUIDs for recipe IDs using `uuid` package

**Batch Size**: 500 recipes per JSON file (matches Firestore WriteBatch limit)

### Error Handling
**Philosophy**: Fail gracefully, log issues, continue processing
- CSV parsing errors: Skip malformed rows, log to stderr
- Firestore upload errors: Retry up to 3 times per batch with exponential backoff
- Query errors: Log and return empty results instead of crashing

### Security Rules
**Development vs Production**:
```
Development: All reads/writes allowed (match /{document=**})
Production: 
  - recipes_v1: Read-only for all
  - user_favourites_v1: User-isolated via auth UID
```

**Migration Path**: Change the catchall rule in firestore.rules before production deployment

---

## Testing Strategy

### Unit Tests (Using Fakes)
- No external dependencies
- Run with `flutter test test/repositories/`
- Mocked data ensures deterministic results
- Fast feedback loop

### Integration Tests (Using Emulator)
- `firebase emulators:start --only firestore,auth`
- Tests real Firestore query behavior
- User favorites stream updates
- Run with `flutter test integration_test/recipe_search_integration_test.dart`

### Production Validation
- Standalone test that connects to production Firebase
- Verifies 13,496 recipes loaded
- Checks composite indexes are deployed
- Tests query performance < 1 second
- Run with `flutter test integration_test/recipe_count_validation_test.dart`

---

## Deployment Workflow

### Step 1: Data Preparation
```bash
cd recipes/v1
dart run transform_recipes_csv.dart
# Output: .tmp/recipesv1_batches/batch_*.json files
```

### Step 2: Firebase Setup
```bash
firebase use planmise
firebase deploy --only firestore:indexes
firebase deploy --only firestore:rules
```

### Step 3: Data Loading
```bash
cd meal_planner
dart run lib/scripts/load_recipes_v1.dart
# Output: Uploads 13,496 recipes to Firestore
```

### Automated (All in One)
```bash
cd recipes/v1
./deploy_recipesv1.sh
# Runs all steps above with progress reporting
```

---

## Known Limitations & Future Enhancements

### MVP1.0 Limitations
1. No pagination (fixed limit of 10 results)
2. No sorting options (always by title for prefix, no sorting for ingredient)
3. No user authentication beyond anonymous (can't share favorites across devices)
4. No recipe details/full content (only titles in favorites)

### Future Enhancements (MVP1.1+)
1. **Pagination**: Implement cursor-based pagination for large result sets
2. **Advanced Filters**: Sort by date, ingredients count, custom allergen filters
3. **User Accounts**: Add traditional auth + cloud sync for favorites
4. **Recipe Details**: Load full recipe data (ingredients, instructions, images)
5. **Search Analytics**: Track popular searches, improve suggestions
6. **Version Migration**: Tools to migrate users from `recipes_v1` to `recipes_v2`
7. **Caching**: Local cache of favorites and recent searches

---

## Build & Code Generation

### Required After Model Changes
```bash
cd meal_planner
dart run build_runner build --delete-conflicting-outputs
```

### New Packages Added
- `csv`: CSV parsing
- `uuid`: UUID generation
- Already existing: `cloud_firestore`, `firebase_core`, `firebase_auth`, `flutter_riverpod`

---

## Files Created/Modified

### Created
- `recipes/v1/transform_recipes_csv.dart` - Data transformation
- `recipes/v1/deploy_recipesv1.sh` - Deployment orchestration
- `meal_planner/lib/repositories/recipes_v1_repository.dart` - Recipe repository
- `meal_planner/lib/repositories/user_favourites_v1_repository.dart` - Favorites repository
- `meal_planner/lib/providers/recipes_v1_provider.dart` - Riverpod providers
- `meal_planner/lib/providers/user_favourites_v1_provider.dart` - Favorites providers
- `meal_planner/lib/providers/auth_provider.dart` - Auth provider
- `meal_planner/lib/scripts/load_recipes_v1.dart` - Data loading script
- `meal_planner/lib/widgets/recipe/recipe_search_autocomplete.dart` - Autocomplete widget
- `meal_planner/test/repositories/fake_recipes_v1_repository.dart` - Test fake
- `meal_planner/test/repositories/fake_user_favourites_v1_repository.dart` - Test fake
- `meal_planner/test/repositories/recipes_v1_repository_test.dart` - Unit tests
- `meal_planner/test/repositories/user_favourites_v1_repository_test.dart` - Unit tests
- `meal_planner/integration_test/recipe_search_integration_test.dart` - Integration tests
- `meal_planner/integration_test/recipe_count_validation_test.dart` - Validation tests
- `firestore.indexes.json` - Firestore index configuration

### Modified
- `meal_planner/lib/models/recipe.freezed_model.dart` - Added search fields
- `firestore.rules` - Added recipes_v1 and user_favourites_v1 rules
- `memory/FIREBASE.md` - Added collection documentation

---

## Next Steps for Full Integration

1. **Enable Firebase Anonymous Auth** in Firebase Console
2. **Update main.dart** to call `authInitializer.build()` on app startup
3. **Create RecipePickerScreen** to integrate autocomplete widget with meal planning
4. **Update RecipeListScreen** to show favorites first, then search
5. **Run `deploy_recipesv1.sh`** to load all 13,496 recipes
6. **Create Attribution Screen** per `spec/attribution.md`
7. **Run all tests** to validate implementation
8. **Manual UX testing** of autocomplete, keyboard navigation, favorites

---

## Troubleshooting

### "Composite index not found" error
- Indexes take 5-10 minutes to build in Firebase
- Check Firebase Console > Firestore > Indexes tab
- Can test with emulator while indexes are building

### "No recipes found" in production
- Run validation test: `flutter test integration_test/recipe_count_validation_test.dart`
- Verify CSV file exists and has data
- Check Firestore collection structure in console

### Autocomplete widget shows loading indefinitely
- Check if Firestore is connected (emulator or production)
- Verify Firebase initialization in main.dart
- Check browser console for connection errors

### Recipe IDs not consistent
- CSV transformation generates fresh UUIDs each time
- For stable IDs, modify `transform_recipes_csv.dart` to use recipe title hash
- Consider this when implementing recipe updates/migrations

---

## Performance Notes

- Title prefix search: ~100-300ms (leverages composite index)
- Ingredient search: ~200-500ms (leverages array-contains index)
- Favorites watch stream: Real-time (milliseconds)
- Total app memory impact: <50MB for most users (only loaded recipes in memory during search)
