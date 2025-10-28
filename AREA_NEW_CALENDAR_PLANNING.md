# AREA_NEW_CALENDAR_PLANNING.md

## Functional Area: Calendar & Meal Planning (Spec 002)

**Status**: Models & providers exist. Screens, widgets, and tests need to be built.

**Models** (reuse from `./meal_planner/lib/models`):
- `meal_assignment.freezed_model.dart` - Links recipes to calendar days
- `meal_plan.freezed_model.dart` - Collection of assignments

**Providers** (reuse from `./meal_planner/lib/providers`):
- `meal_assignment_providers.dart` - `mealAssignmentsForDayProvider(isoDate)`, `weekMealAssignmentsProvider(startIsoDate)`, `MealAssignmentNotifier`
- `calendar_providers.dart` - `recipesForDayProvider(isoDate)`, `weekMealCountsProvider(startIsoDate)`, `weekTotalTimeProvider(startIsoDate)`
- `recipe_providers.dart` - Access recipe data for assigned meals

**Services**:
- `uuid_generator.dart` - Generate assignment IDs

---

## Screens to Build

### 1. WeekCalendarScreen
**Path**: `lib/screens/calendar/week_calendar_screen.dart`

**Purpose**: Display week of meal assignments with navigation and summary

**Widgets Used**:
- Week navigation (prev/next buttons)
- Calendar day grid (7 columns, 1 week)
- CalendarDayCell (for each day)
- WeeklySummary widget (total meals, cook time)
- FloatingActionButton (assign meal modal)

**Provider Watches**:
- `weekMealAssignmentsProvider(startIsoDate)` - All assignments for week
- `weekMealCountsProvider(startIsoDate)` - Computed: meals per day
- `weekTotalTimeProvider(startIsoDate)` - Computed: total cook time
- `recipesProvider` - Access recipe data for assignments

**UI States**:
- Loading: Show skeleton for each day
- Loaded: Show day cells with meal counts
- Empty week: Show "No meals planned" message
- Error: Show error with retry

**User Interactions**:
- Tap prev/next buttons → Navigate to previous/next week
- Tap day cell → Navigate to DayDetailScreen
- Tap FAB → Show modal to select recipe and assign to day
- Assign meal → Updates `MealAssignmentNotifier`

---

### 2. DayDetailScreen
**Path**: `lib/screens/calendar/day_detail_screen.dart`

**Purpose**: Display all recipes for a selected day with unassign options

**Widgets Used**:
- Day header (date, day of week)
- Meal list (RecipeCard for each assignment)
- Total cook time for day
- Add meal button (recipe selection modal)
- Unassign button per meal (with confirmation)

**Provider Watches**:
- `mealAssignmentsForDayProvider(isoDate)` - Assignments for selected day
- `recipesForDayProvider(isoDate)` - Computed recipes for day
- `MealAssignmentNotifier` - Handle assign/unassign

**UI States**:
- Loading: Show skeleton
- Loaded: Show meals for day
- Empty day: Show "No meals planned for this day"
- Error: Show error message

**User Interactions**:
- Tap recipe card → Navigate to RecipeDetailScreen
- Tap "Add meal" → Show recipe picker modal
- Select recipe from modal → Call `MealAssignmentNotifier.assign()`
- Tap unassign → Show confirmation, call `MealAssignmentNotifier.unassign()`

---

### 3. MealAssignmentModal
**Path**: `lib/screens/calendar/meal_assignment_modal.dart`

**Purpose**: Modal dialog to select recipe and assign to a specific day

**Widgets Used**:
- RecipeSearchBar (filter recipes)
- RecipeCard list (selectable)
- Assign button (calls notifier)

**Provider Watches**:
- `recipesProvider` - All recipes to choose from
- `userPreferencesProvider` - Filter by dietary restrictions/allergens
- `MealAssignmentNotifier` - Perform assignment

**UI States**:
- Loading: Show loading spinner
- Loaded: Show recipes
- Empty: Show "No recipes found"
- Assigning: Show loading on button

**User Interactions**:
- Search recipes (filters locally)
- Tap recipe → Select (highlight/checkbox)
- Tap Assign button → Call `MealAssignmentNotifier.assign()` and close modal

---

## Widgets to Build

### 1. CalendarDayCell
**Path**: `lib/widgets/calendar/calendar_day_cell.dart`

**Props**:
- `date: DateTime`
- `mealCount: int` - Number of meals assigned
- `totalTime: int?` - Total cook time in minutes
- `isToday: bool`
- `onTap: VoidCallback`

**Displays**:
- Day of month (large)
- Day of week abbreviation (Mon, Tue, etc.)
- Meal count badge
- Total cook time (HH:MM format if >0)
- Highlight if today

**UI**:
- Card-like appearance
- Border highlight if selected or today
- Colors: Light if empty, highlight color if meals assigned

---

### 2. MealAssignmentWidget
**Path**: `lib/widgets/calendar/meal_assignment_widget.dart`

**Props**:
- `assignment: MealAssignment`
- `recipe: Recipe`
- `onUnassign: VoidCallback`
- `onTap: VoidCallback?`

**Displays**:
- Recipe title
- Cook time
- Ingredient count
- Unassign button (X icon)

**UI**:
- Compact card format
- Drag-enabled (future: drag between days)
- Swipe-to-delete (future)

---

### 3. WeeklySummary
**Path**: `lib/widgets/calendar/weekly_summary.dart`

**Props**:
- `totalMeals: int`
- `totalCookTime: int?` - minutes
- `mealsPerDay: Map<String, int>` - isoDate → count

**Displays**:
- Total meals planned this week
- Total cook time (formatted as hours:minutes)
- Breakdown: meals per day
- Cost estimate (future)

**UI**:
- Simple row/column layout with icons
- Icons: fork (meals), clock (time)

---

## Unit Tests to Build

### Test Repositories

**FakeMealAssignmentRepository**  
`test/repositories/fake_meal_assignment_repository.dart`
- In-memory storage with StreamController for watches
- Methods: `watchAssignmentsForDay(isoDate)`, `assign(assignment)`, `unassign(id)`
- Seed/clear for test setup
- Emits streams immediately on watch

---

### Widget Tests

**WeekCalendarScreen Tests**  
`test/widgets/calendar/week_calendar_screen_test.dart`
- Test: Display current week with day cells
- Test: Show week navigation buttons
- Test: Navigate to previous week
- Test: Navigate to next week
- Test: Display weekly summary (total meals, cook time)
- Test: Display meal counts per day
- Test: Tap day cell → Navigate to DayDetailScreen
- Test: Tap FAB → Show meal assignment modal
- Test: Empty week shows "No meals planned"

**DayDetailScreen Tests**  
`test/widgets/calendar/day_detail_screen_test.dart`
- Test: Display date and day of week
- Test: Show recipes assigned to day
- Test: Show total cook time
- Test: Tap recipe → Navigate to RecipeDetailScreen
- Test: Tap unassign → Show confirmation dialog
- Test: Unassign removes meal from day
- Test: Add meal button → Show modal
- Test: Empty day shows "No meals"
- Test: Assign new meal updates UI

**MealAssignmentModal Tests**  
`test/widgets/calendar/meal_assignment_modal_test.dart`
- Test: Display all available recipes
- Test: Search filters recipes
- Test: Select recipe (visual highlight)
- Test: Assign button disabled until recipe selected
- Test: Assign button calls notifier with correct date
- Test: Close modal after assign
- Test: Cancel closes modal without assigning

**CalendarDayCell Tests**  
`test/widgets/calendar/calendar_day_cell_test.dart`
- Test: Display day of month
- Test: Display day of week abbreviation
- Test: Show meal count badge
- Test: Show total cook time formatted
- Test: Highlight if today
- Test: Call onTap when tapped

**MealAssignmentWidget Tests**  
`test/widgets/calendar/meal_assignment_widget_test.dart`
- Test: Display recipe title and cook time
- Test: Show ingredient count
- Test: Call onUnassign when unassign button tapped
- Test: Show confirmation dialog before unassigning

**WeeklySummary Tests**  
`test/widgets/calendar/weekly_summary_test.dart`
- Test: Display total meals
- Test: Display total cook time formatted (HH:MM)
- Test: Display meals per day breakdown
- Test: Show 0 meals when empty

---

## Architecture Notes

### State Management Flow

1. **WeekCalendarScreen watches `weekMealAssignmentsProvider(startIsoDate)`**
   - Gets all assignments for the week
   - Computed providers calculate meal counts and total time
   - User navigates weeks → Updates startIsoDate

2. **DayDetailScreen watches `mealAssignmentsForDayProvider(isoDate)`**
   - Gets assignments for selected day
   - Joins with `recipesProvider` to get recipe data
   - User assigns/unassigns → Updates `MealAssignmentNotifier`

3. **MealAssignmentModal watches `recipesProvider`**
   - Lists all recipes to choose from
   - User selects → Calls `MealAssignmentNotifier.assign()`
   - Modal closes on success

### Provider Override in Tests

```dart
// In test setup
final fakeAssignmentRepo = FakeMealAssignmentRepository();
final fakeRecipeRepo = FakeRecipeRepository();

fakeRecipeRepo.seed('recipe-1', Recipe(...));
fakeAssignmentRepo.seed('assign-1', MealAssignment(
  id: 'assign-1',
  recipeId: 'recipe-1',
  dayIsoDate: '2025-10-27',
  assignedAt: DateTime.now(),
));

// In ProviderScope
ProviderScope(
  overrides: [
    mealAssignmentRepositoryProvider.overrideWithValue(fakeAssignmentRepo),
    recipeRepositoryProvider.overrideWithValue(fakeRecipeRepo),
  ],
  child: WeekCalendarScreen(),
)
```

---

## Implementation Checklist

### Screens
- [ ] WeekCalendarScreen
- [ ] DayDetailScreen
- [ ] MealAssignmentModal

### Widgets
- [ ] CalendarDayCell
- [ ] MealAssignmentWidget
- [ ] WeeklySummary

### Fake Repository
- [ ] FakeMealAssignmentRepository

### Tests
- [ ] week_calendar_screen_test.dart (8+ test cases)
- [ ] day_detail_screen_test.dart (8+ test cases)
- [ ] meal_assignment_modal_test.dart (6+ test cases)
- [ ] calendar_day_cell_test.dart (5+ test cases)
- [ ] meal_assignment_widget_test.dart (4+ test cases)
- [ ] weekly_summary_test.dart (4+ test cases)

### Code Generation
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`

### Quality Checks
- [ ] `flutter analyze` passes
- [ ] `flutter test test/widgets/calendar/` passes
- [ ] No Firebase imports in tests

---

## References

- **Models**: `./meal_planner/lib/models/meal_assignment.freezed_model.dart`, `meal_plan.freezed_model.dart`
- **Providers**: `./meal_planner/lib/providers/meal_assignment_providers.dart`, `calendar_providers.dart`
- **Testing**: `TESTING_TAO.md`
- **Development**: `FLUTTER_DEV.md`
- **Architecture**: `TAO_OF_TEEMU.md`
- **ID Generation**: `./meal_planner/lib/services/uuid_generator.dart`
