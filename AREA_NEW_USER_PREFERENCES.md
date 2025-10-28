# AREA_NEW_USER_PREFERENCES.md

## Functional Area: User Preferences (Spec 001)

**Status**: Models & providers exist. Screens, widgets, and tests need to be built.

**Models** (reuse from `./meal_planner/lib/models`):
- `user_preferences.freezed_model.dart` - User settings (portions, dietary restrictions, etc.)
- `enums.dart` - Allergen codes and other enums

**Providers** (reuse from `./meal_planner/lib/providers`):
- `user_preferences_providers.dart` - `userPreferencesProvider(userId)`, `UserPreferencesNotifier`

**Services**:
- Firebase Auth - Get current user ID (via provider)

---

## Screens to Build

### 1. UserPreferencesScreen
**Path**: `lib/screens/preferences/user_preferences_screen.dart`

**Purpose**: Edit user preferences (portions, dietary restrictions, disliked ingredients, supermarkets)

**Widgets Used**:
- PortionsSelector
- DietaryRestrictionsSelector
- DislikedIngredientsInput
- PreferredSupermarketsSelector
- Save button (calls `UserPreferencesNotifier.save()`)
- Cancel button

**Provider Watches**:
- `userPreferencesProvider(userId)` - Load current preferences
- `UserPreferencesNotifier` - Handle save state

**UI States**:
- Loading: Show skeleton loaders
- Loaded: Show all preference controls
- Saving: Show loading on save button
- Success: Show snackbar "Preferences saved"
- Error: Show error message with retry

**User Interactions**:
- Adjust portions (number input or slider)
- Toggle dietary restrictions (checkboxes/chips)
- Add/remove disliked ingredients
- Add/remove preferred supermarkets
- Save → Call `UserPreferencesNotifier.save(userPreferences)`
- Cancel → Pop screen (discard changes)

---

## Widgets to Build

### 1. PortionsSelector
**Path**: `lib/widgets/preferences/portions_selector.dart`

**Props**:
- `currentPortions: int` - Current selection (e.g., 4)
- `onChanged: Function(int newPortions)` - Callback on value change
- `minPortions: int = 1` - Minimum value
- `maxPortions: int = 12` - Maximum value

**Displays**:
- Label "Portions"
- Slider or spinner control (+/- buttons with text display)
- Subtitle: "Ingredient quantities will scale accordingly"

**UI**:
- Slider 1-12 with value display
- Or: Text field + plus/minus buttons

**Behavior**:
- Call `onChanged` on every adjustment
- Update display immediately

---

### 2. DietaryRestrictionsSelector
**Path**: `lib/widgets/preferences/dietary_restrictions_selector.dart`

**Props**:
- `selectedRestrictions: List<String>` - Currently selected (e.g., ['vegetarian', 'gluten-free'])
- `onChanged: Function(List<String> selected)` - Called on any selection change
- `availableRestrictions: List<String> = [...]` - List of all possible restrictions

**Displays**:
- Label "Dietary Restrictions"
- List of FilterChips (each restriction type)
- None/All buttons (select/deselect all)

**UI**:
- Horizontal list of toggleable chips
- Selected chips highlighted

**Behavior**:
- Tapping chip toggles selection
- Call `onChanged` with updated list
- None/All buttons update all selections

---

### 3. DislikedIngredientsInput
**Path**: `lib/widgets/preferences/disliked_ingredients_input.dart`

**Props**:
- `dislikedIngredients: List<String>` - Current list
- `onChanged: Function(List<String> updated)` - Callback on any change
- `existingIngredients: List<String>?` - Autocomplete suggestions

**Displays**:
- Input field with chip display below
- Add button or Enter key to add
- Remove (X) icon per chip
- Autocomplete dropdown (if suggestions provided)

**UI**:
- Text field + chips layout
- AutocompleteTextField if suggestions available

**Behavior**:
- Type ingredient + press Enter/Add → Add to list
- Show autocomplete suggestions while typing
- Tap X on chip → Remove from list
- Call `onChanged` on any modification

---

### 4. PreferredSupermarketsSelector
**Path**: `lib/widgets/preferences/preferred_supermarkets_selector.dart`

**Props**:
- `selectedSupermarkets: List<String>` - Currently selected
- `onChanged: Function(List<String> selected)` - Called on any change
- `availableSupermarkets: List<String> = [...]` - All supermarket options

**Displays**:
- Label "Preferred Supermarkets"
- List of checkboxes or chips
- Search field to filter supermarkets

**UI**:
- Column of checkboxes or horizontal chip list
- Search field above to filter

**Behavior**:
- Tap checkbox/chip to toggle
- Call `onChanged` with updated list
- Search filters displayed supermarkets

---

## Unit Tests to Build

### Test Repositories

**FakeUserPreferencesRepository**  
`test/repositories/fake_user_preferences_repository.dart`
- In-memory storage
- Methods: `getUserPreferences(userId)`, `save(preferences)`
- Seed/clear for test setup
- No streams needed (Future-based)

---

### Widget Tests

**UserPreferencesScreen Tests**  
`test/widgets/preferences/user_preferences_screen_test.dart`
- Test: Load and display current preferences
- Test: Change portions and save
- Test: Add/remove dietary restrictions and save
- Test: Add/remove disliked ingredients and save
- Test: Add/remove supermarkets and save
- Test: Show loading state while saving
- Test: Show error state on save failure
- Test: Cancel button discards changes
- Test: Show success snackbar after save
- Test: Validate all changes persist after reload

**PortionsSelector Tests**  
`test/widgets/preferences/portions_selector_test.dart`
- Test: Display current portion value
- Test: Adjust portions with slider
- Test: Enforce min/max boundaries
- Test: Call onChanged on adjustment
- Test: Display new value in real-time

**DietaryRestrictionsSelector Tests**  
`test/widgets/preferences/dietary_restrictions_selector_test.dart`
- Test: Display all available restrictions
- Test: Toggle restriction selection
- Test: Show selected restrictions highlighted
- Test: Call onChanged with updated list
- Test: "Select All" button selects all restrictions
- Test: "Clear All" button deselects all

**DislikedIngredientsInput Tests**  
`test/widgets/preferences/disliked_ingredients_input_test.dart`
- Test: Display existing disliked ingredients as chips
- Test: Add ingredient by typing and pressing Enter
- Test: Show autocomplete suggestions
- Test: Remove ingredient by tapping X
- Test: Call onChanged on add/remove
- Test: Prevent duplicate ingredients
- Test: Clear input field after adding

**PreferredSupermarketsSelector Tests**  
`test/widgets/preferences/preferred_supermarkets_selector_test.dart`
- Test: Display all available supermarkets
- Test: Toggle supermarket selection
- Test: Show selected supermarkets highlighted
- Test: Call onChanged with updated list
- Test: Search field filters supermarket list
- Test: Case-insensitive search

---

## Architecture Notes

### State Management Flow

1. **UserPreferencesScreen watches `userPreferencesProvider(userId)`**
   - Loads user's current preferences on mount
   - Form controls update local state (not provider)
   - Save button → Calls `UserPreferencesNotifier.save(userPreferences)`

2. **Form State**
   - Can be managed locally in screen widget or in Riverpod notifier
   - Recommended: Local state until save, then notifier update
   - Or: Riverpod StateNotifier for reactive form updates

3. **Portions Scaling**
   - Other screens watch `userPreferencesProvider` for portions
   - Computed providers scale ingredient quantities based on portions

### Provider Override in Tests

```dart
// In test setup
final fakePrefsRepo = FakeUserPreferencesRepository();
fakePrefsRepo.seed('user-123', UserPreferences(
  userId: 'user-123',
  portions: 4,
  dietaryRestrictions: [],
  dislikedIngredients: [],
  preferredSupermarkets: [],
));

// In ProviderScope
ProviderScope(
  overrides: [
    userPreferencesRepositoryProvider.overrideWithValue(fakePrefsRepo),
  ],
  child: UserPreferencesScreen(userId: 'user-123'),
)
```

---

## Implementation Checklist

### Screen
- [ ] UserPreferencesScreen

### Widgets
- [ ] PortionsSelector
- [ ] DietaryRestrictionsSelector
- [ ] DislikedIngredientsInput
- [ ] PreferredSupermarketsSelector

### Fake Repository
- [ ] FakeUserPreferencesRepository

### Tests
- [ ] user_preferences_screen_test.dart (10+ test cases)
- [ ] portions_selector_test.dart (5+ test cases)
- [ ] dietary_restrictions_selector_test.dart (6+ test cases)
- [ ] disliked_ingredients_input_test.dart (6+ test cases)
- [ ] preferred_supermarkets_selector_test.dart (6+ test cases)

### Code Generation
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`

### Quality Checks
- [ ] `flutter analyze` passes
- [ ] `flutter test test/widgets/preferences/` passes
- [ ] No Firebase imports in tests

---

## References

- **Models**: `./meal_planner/lib/models/user_preferences.freezed_model.dart`
- **Providers**: `./meal_planner/lib/providers/user_preferences_providers.dart`
- **Testing**: `TESTING_TAO.md`
- **Development**: `FLUTTER_DEV.md`
- **Architecture**: `TAO_OF_TEEMU.md`
