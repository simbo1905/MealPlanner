# AREA_NEW_SHOPPING_LIST.md

## Functional Area: Shopping List Generation & Management (Spec 001)

**Status**: Models & providers exist. Screens, widgets, and tests need to be built.

**Models** (reuse from `./meal_planner/lib/models`):
- `shopping_list.freezed_model.dart` - Shopping list with aggregated items
- `ingredient.freezed_model.dart` - Ingredient details with units

**Providers** (reuse from `./meal_planner/lib/providers`):
- `shopping_list_providers.dart` - `generateShoppingListProvider(assignmentIds)`, `ShoppingListNotifier`
- `meal_assignment_providers.dart` - Access assignments for aggregation
- `recipe_providers.dart` - Access recipes for ingredients

**Services**:
- `uuid_generator.dart` - Generate shopping list IDs

---

## Screens to Build

### 1. ShoppingListGenerationScreen
**Path**: `lib/screens/shopping/shopping_list_generation_screen.dart`

**Purpose**: Select meal assignments and generate consolidated shopping list

**Widgets Used**:
- Date range picker (start date and end date)
- Meal assignment list (checkboxes for each meal to include)
- Generate button
- Preview of aggregated items

**Provider Watches**:
- `weekMealAssignmentsProvider(startIsoDate)` - Get assignments in date range
- `recipesProvider` - Access recipe ingredients
- `generateShoppingListProvider(selectedIds)` - Generate shopping list
- `ShoppingListNotifier` - Save generated list

**UI States**:
- Empty: "Select meals to create shopping list"
- Selected: Show selected meals count
- Generating: Show loading spinner
- Generated: Show preview of shopping list items
- Saved: Show snackbar "Shopping list saved"

**User Interactions**:
- Select date range (calendar picker)
- Show assignments in range
- Toggle assignment checkboxes
- Tap "Generate" → Calls `generateShoppingListProvider` with selected IDs
- Preview aggregated items (grouped by section)
- Tap "Save" → Calls `ShoppingListNotifier.save()` to persist list

---

### 2. ShoppingListScreen
**Path**: `lib/screens/shopping/shopping_list_screen.dart`

**Purpose**: Display saved shopping list with ability to check off items

**Widgets Used**:
- Shopping list header (date created, total items, estimated cost)
- Shopping list items (grouped by section)
- ShoppingListItem widget per item
- CostSummary widget
- Clear completed button
- Delete list button

**Provider Watches**:
- `shoppingListProvider(listId)` - Load specific shopping list
- `ShoppingListNotifier` - Update item check state

**UI States**:
- Loading: Show skeleton
- Loaded: Show items grouped by section
- Empty: "No items in list"
- Error: Show error message

**User Interactions**:
- Tap checkbox on item → Toggle checked state (optimistic update)
- Tap section header → Collapse/expand that section
- Swipe item → Delete item from list
- Tap "Clear completed" → Remove all checked items
- Tap "Delete list" → Show confirmation, delete entire list

---

## Widgets to Build

### 1. ShoppingListItem
**Path**: `lib/widgets/shopping/shopping_list_item.dart`

**Props**:
- `item: ShoppingListItem` - Item to display
- `isChecked: bool` - Check state
- `onCheckChanged: Function(bool)` - Called on checkbox toggle
- `onDelete: VoidCallback?` - Called on delete
- `onShowAlternatives: VoidCallback?` - Show substitution options (future)

**Displays**:
- Checkbox (left)
- Item name
- Quantity + unit
- Section badge
- Optional: Alternatives link (future)
- Delete button (trash icon, right)

**UI**:
- ListTile-like layout
- Strikethrough text if checked
- Subtle background highlight if checked
- Swipe-to-delete (future)

**Behavior**:
- Tap checkbox → Call `onCheckChanged(!isChecked)`
- Tap delete → Call `onDelete()`
- Tap item → Show details or alternatives (future)

---

### 2. CostSummary
**Path**: `lib/widgets/shopping/cost_summary.dart`

**Props**:
- `totalEstimatedCost: double?` - Total in currency
- `itemCount: int` - Number of items
- `checkedCount: int` - Number of checked items
- `currencySymbol: String = '\$'` - Display currency

**Displays**:
- Total estimated cost (if available)
- Item count: "X of Y items"
- Progress bar: checked/total
- Savings label (future)

**UI**:
- Summary card at bottom of list
- Icons: cart (items), money (cost), checkmark (progress)

---

### 3. ShoppingListSection
**Path**: `lib/widgets/shopping/shopping_list_section.dart`

**Props**:
- `section: String` - Section name (Produce, Dairy, Meat, etc.)
- `items: List<ShoppingListItem>` - Items in section
- `isExpanded: bool`
- `onExpandChanged: Function(bool)`
- `onItemCheckChanged: Function(String itemId, bool isChecked)`
- `onItemDelete: Function(String itemId)`

**Displays**:
- Section header (collapsible)
- List of ShoppingListItem widgets
- Item count badge on header

**UI**:
- ExpansionTile or custom collapsible header
- Grouped by section (Produce, Dairy, Meat, Pantry, Frozen, etc.)

---

## Unit Tests to Build

### Test Repositories

**FakeShoppingListRepository**  
`test/repositories/fake_shopping_list_repository.dart`
- In-memory storage
- Methods: `getShoppingList(id)`, `save(list)`, `delete(id)`
- Seed/clear for test setup

---

### Widget Tests

**ShoppingListGenerationScreen Tests**  
`test/widgets/shopping/shopping_list_generation_screen_test.dart`
- Test: Display date range picker
- Test: Display meal assignments in selected range
- Test: Toggle assignment selection
- Test: Show selected count
- Test: Generate shopping list on button tap
- Test: Aggregate items from multiple recipes
- Test: Group items by section in preview
- Test: Save shopping list
- Test: Show success message after save

**ShoppingListScreen Tests**  
`test/widgets/shopping/shopping_list_screen_test.dart`
- Test: Load and display shopping list
- Test: Display items grouped by section
- Test: Toggle item checkbox
- Test: Show checked/unchecked count
- Test: Delete item from list
- Test: Clear all completed items
- Test: Delete entire list with confirmation
- Test: Collapse/expand sections
- Test: Show cost summary
- Test: Empty list shows message

**ShoppingListItem Tests**  
`test/widgets/shopping/shopping_list_item_test.dart`
- Test: Display item name, quantity, unit
- Test: Show section badge
- Test: Toggle checkbox and call callback
- Test: Strike-through text when checked
- Test: Call onDelete when delete button tapped
- Test: Tap item to show details (future)

**CostSummary Tests**  
`test/widgets/shopping/cost_summary_test.dart`
- Test: Display total estimated cost
- Test: Show item count (X of Y)
- Test: Display progress bar with checked/total
- Test: Format currency symbol correctly
- Test: Show 0 cost if not available

**ShoppingListSection Tests**  
`test/widgets/shopping/shopping_list_section_test.dart`
- Test: Display section header with item count
- Test: Collapse/expand section on header tap
- Test: Display all items in section
- Test: Call onItemCheckChanged when item checkbox tapped
- Test: Call onItemDelete when delete button tapped

---

## Architecture Notes

### State Management Flow

1. **ShoppingListGenerationScreen**
   - User selects date range and assignments
   - Tap "Generate" → `generateShoppingListProvider(assignmentIds)` computes aggregated list
   - Preview shows grouped items
   - Tap "Save" → `ShoppingListNotifier.save(list)` persists to Firestore

2. **ShoppingListScreen**
   - Watches `shoppingListProvider(listId)`
   - User checks/unchecks items → Local UI state (could be notifier)
   - Delete item → Calls `ShoppingListNotifier.deleteItem(listId, itemId)`
   - Clear completed → Calls `ShoppingListNotifier.clearCompleted(listId)`

3. **Item Aggregation Logic**
   - Recipes have ingredients with quantities and units
   - Same ingredient from multiple recipes → Aggregate quantities
   - Group by section (Produce, Dairy, Meat, etc.)
   - Handle unit conversions if needed (e.g., 2 × 250g → 500g)

### Provider Override in Tests

```dart
// In test setup
final fakeShoppingListRepo = FakeShoppingListRepository();
final fakeRecipeRepo = FakeRecipeRepository();
final fakeAssignmentRepo = FakeMealAssignmentRepository();

// Seed recipes with ingredients
fakeRecipeRepo.seed('recipe-1', Recipe(
  id: 'recipe-1',
  title: 'Pasta',
  ingredients: [
    Ingredient(name: 'Pasta', ucumAmount: 500, ucumUnit: 'g', ...),
    Ingredient(name: 'Tomato', ucumAmount: 2, ucumUnit: 'count', ...),
  ],
));

// Seed assignments
fakeAssignmentRepo.seed('assign-1', MealAssignment(...));

// Seed shopping lists
fakeShoppingListRepo.seed('list-1', ShoppingList(...));

// In ProviderScope
ProviderScope(
  overrides: [
    shoppingListRepositoryProvider.overrideWithValue(fakeShoppingListRepo),
    recipeRepositoryProvider.overrideWithValue(fakeRecipeRepo),
    mealAssignmentRepositoryProvider.overrideWithValue(fakeAssignmentRepo),
  ],
  child: ShoppingListScreen(listId: 'list-1'),
)
```

---

## Implementation Checklist

### Screens
- [ ] ShoppingListGenerationScreen
- [ ] ShoppingListScreen

### Widgets
- [ ] ShoppingListItem
- [ ] CostSummary
- [ ] ShoppingListSection

### Fake Repository
- [ ] FakeShoppingListRepository

### Tests
- [ ] shopping_list_generation_screen_test.dart (9+ test cases)
- [ ] shopping_list_screen_test.dart (10+ test cases)
- [ ] shopping_list_item_test.dart (5+ test cases)
- [ ] cost_summary_test.dart (5+ test cases)
- [ ] shopping_list_section_test.dart (5+ test cases)

### Code Generation
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`

### Quality Checks
- [ ] `flutter analyze` passes
- [ ] `flutter test test/widgets/shopping/` passes
- [ ] No Firebase imports in tests

---

## References

- **Models**: `./meal_planner/lib/models/shopping_list.freezed_model.dart`, `ingredient.freezed_model.dart`
- **Providers**: `./meal_planner/lib/providers/shopping_list_providers.dart`
- **Testing**: `TESTING_TAO.md`
- **Development**: `FLUTTER_DEV.md`
- **Architecture**: `TAO_OF_TEEMU.md`
- **ID Generation**: `./meal_planner/lib/services/uuid_generator.dart`
