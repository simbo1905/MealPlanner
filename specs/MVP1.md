MVP1 Final Specification
Status: Final Created: 2025-10-30 Based on: Sonia conversation + user research clarifications
User Story
A busy parent wants to see their weekly meal plan in one place, easily swap meals between days when plans change (e.g., cook burgers tonight instead of fish, reschedule fish for tomorrow), and build a personal collection of favorite recipes they like to cook.
Core Features
1. Calendar View (Dual Mode)
Portrait (default):
Infinite vertical scroll showing multiple weeks
Each day displays as a card or row
Shows assigned meals for that day (breakfast, lunch, dinner, other slots)
User can scroll up/down through past and future weeks
Landscape:
Week-view grid (7 columns for Mon-Sun)
One week fits on screen
Each day is a column showing stacked meal cards
Same week view as portrait but rotated
Context: selected_date is sticky across app (riverpod state), updated when user clicks any date/day. Not persisted on app restart.
2. Meal Data Model
Meal (instance):
id: unique identifier
recipeTitle: string (the recipe name selected by user)
date: Date
slot: "breakfast" | "lunch" | "dinner" | "other"
userId: reference to user
createdAt: timestamp
Recipe (template - in Firestore):
title: string (searchable)
ingredients: array (loaded but not displayed in MVP1)
instructions: array (not displayed in MVP1)
(other fields added by agent, not used MVP1)
User Favorites:
userId: reference
recipeTitle: string
addedAt: timestamp
3. Recipe Selection Flow
User adds a meal:
Tap "+" button → opens recipe selector
selected_date auto-populates (sticky context)
Search box: "Type to search for recipes..."
Autocomplete search against Firestore hardcoded recipes:
User types 2-3 letters
System returns top 10 matches (sorted)
User navigates with up/down arrows
User presses Enter to select
If no match: user can type custom recipe name + Enter to create
Recipe selected → added to user's Favorites (background)
User selects meal slot: breakfast / lunch / dinner / other button
If slot already occupied: dialog "Keep both meals today or replace?"
Confirm → Meal added, calendar updates
4. Meal Editing
User can open any meal and:
Change date (move to different day)
Change slot (breakfast → lunch on same day)
Change recipe (swap fish for burger)
Delete (remove from plan)
Example workflow (the core UX need):
Fish planned for tonight, but kids are hungry after burger last night
User opens app (landscape, rotated phone)
Drags burger card onto fish card (same day/slot)
Meals swap: fish moves where burger was, burger moves where fish was
User can now see fish is tonight's dinner
When parents get home, they see the plan clearly: "Fish for dinner tonight"
In portrait infinite scroll:
User can also tap a meal to open detail view
Edit/delete options accessible from meal detail
5. Drag-and-Drop (Landscape Week Grid Only)
Available in landscape week-view grid only
Drag meal card to swap with another meal
Can swap meals within same day (breakfast ↔ lunch) or between days
Drop triggers: update both meals' dates/slots
Visual feedback during drag (opacity, elevation)
No complex reordering within a day's stack; just swap two meals
6. Storage
User accounts: Required (Firestore authentication)
Meals: Firestore database (per user)
Recipes (hardcoded): Firestore collection (shared, read-only)
User Favorites: Firestore collection (per user, auto-updated on selection)
Offline: No offline support required (app requires network for Firestore)
Sync: All data auto-synced to Firestore (multi-device ready)
7. Empty State
First time user opens app:
Recipe search box prominently displayed
Placeholder text: "Type to search for recipes..."
Below: hint text "Search our library or add your own"
No meals visible yet (calendar is empty)
User starts searching and building their plan
8. Out of Scope (MVP1)
❌ AI recipe onboarding (MistralAI photo extraction)
❌ Shopping list generation
❌ Recipe detail pages (instructions, full ingredients display)
❌ Dietary restrictions / allergen filtering
❌ Recipe photo/images in search results
❌ Social features (sharing meal plans)
❌ Calendar export (Google Calendar, iCal)
These are deferred to MVP2 and beyond.
9. In Scope (MVP1)
✅ Infinite scroll calendar (portrait) ✅ Week-view grid (landscape) ✅ Recipe search by title (autocomplete) ✅ Custom recipe entry (if no match) ✅ User Favorites collection ✅ Add/edit/delete meals ✅ Swap meals between days/slots (drag-drop or manual edit) ✅ Firestore persistence ✅ User authentication ✅ Multi-week visibility in portrait ✅ Single-week visibility in landscape ✅ Keep/Replace dialog for slot conflicts
10. Key Interactions
Add Meal:
Tap "+" on day or global "Add" button
Search recipe (or pick favorite)
Select slot
Confirm
Meal appears on calendar
Reschedule Meal:
Landscape: drag-drop meal to new day
Portrait: tap meal → edit → change date/slot → save
Meal moves to new date/slot
Delete Meal:
Tap meal → delete button
Meal removed from calendar
Technical Notes
Riverpod manages selected_date state (sticky, not persisted)
Firestore collections: users, meals, recipes (hardcoded), userFavourites
Recipe autocomplete: debounce 300ms, top 10 results
Meal slot buttons: use clear visual differentiation
Landscape grid: simple 2D drag-drop (swap operation)
Success Criteria
User can view full week (portrait) or single week (landscape) without scrolling
User can add 5 meals in under 2 minutes
User can swap two meals between days in landscape with one drag-drop
Meals persist across app restarts
No errors when user creates custom recipe name
Favorites are visible and selectable on next search

## What Must Change
1. Infinite portrait calendar must swap InMemory repositories for Firestore-backed providers while preserving `WeekSection` rendering and sticky `selectedDate` state (meal_providers.dart:83:144).
2. `InfiniteCalendarScreen` has OCR buttons, save/reset actions, and in-memory meal templates that must be replaced with Firestore meal CRUD and a recipe selector modal using slots (screens/calendar/infinite_calendar_screen.dart:60:225).
3. `AddMealBottomSheet` currently lists local recipes and templates; it must become an autocomplete selector backed by Firestore favorites, slot selection, and conflict resolution dialog (screens/calendar/add_meal_bottom_sheet.dart:28:225).
4. `MealCard` and `DayRow` rely on template metadata with generic slots; they must display slot labels and support tap-to-edit and drag-to-swap behaviors, calling Firestore updates (widgets/calendar/day_row.dart:41:217; widgets/calendar/meal_card.dart:25:163).
5. `InMemoryMealRepository` seeding and persistence logic must be replaced by Firestore meal documents keyed by user/slot; keep interface alignment but point providers to new repository (repositories/in_memory_meal_repository.dart:7:261; repositories/meal_repository.dart:1:13).
6. `InMemoryRecipeRepository` and template repository seeding should be replaced by Firestore recipe collection reads suitable for autocomplete and favorites tracking (repositories/in_memory_recipe_repository.dart:6:94; repositories/in_memory_meal_template_repository.dart:5:44).
7. `WeekCalendarScreen` and related widgets must be simplified or removed in MVP1 since landscape mode will rely on drag-and-drop grid within main calendar, removing legacy meal assignment dependencies (screens/calendar/week_calendar_screen.dart:1:200).
8. OCR/onboarding screens (camera capture, recipe processing, review) are out of scope and should be removed or guarded off for MVP1 (screens/onboarding/**).
9. Planned meals counter and week header should calculate counts via Firestore queries rather than in-memory aggregates, aligned with slots (widgets/calendar/planned_meals_counter.dart:5:28; widgets/calendar/week_header.dart:1:102).
10. Provider wiring must introduce authenticated user context and Firestore repositories, replacing deterministic harness overrides where necessary (main.dart:15:204; providers/recipe_providers.dart:1:230).

## Tests to Delete
- `test/demo/deterministic_harness_test.dart`
- `test/training_calendar_test.dart`
- `test/models/phase1_foundation_test.dart`
- `test/unit/models/day_event_test.dart`
- `test/unit/models/day_log_test.dart`
- `test/unit/models/ingredient_test.dart`
- `test/unit/models/recipe_test.dart`
- `test/widgets/calendar/week_calendar_screen_test.dart`
- `test/widgets/calendar/meal_assignment_widget_test.dart`
- `test/widgets/onboarding/camera_capture_screen_test.dart`
- `test/widgets/onboarding/recipe_processing_screen_test.dart`
- `test/widgets/onboarding/recipe_review_screen_test.dart`
- `integration_test/dnd_comprehensive_test.dart`
- `integration_test/helpers/emulator_reset.dart`
- `integration_test/infinite_calendar_flow_test.dart`

## Tests to Keep
- `test/widgets/calendar/infinite_calendar_screen_test.dart`
- `test/widgets/calendar/calendar_day_cell_test.dart`

## Critical Tests to Write
- Add Firestore-backed meal slot CRUD integration tests covering add, replace, and delete flows in portrait infinite scroll.
- Add landscape drag-and-drop widget tests validating swap updates across days with Firestore state verification.
- Add recipe selector autocomplete tests asserting Firestore search debounce, favorites auto-add, and custom recipe creation.
- Add authentication gating tests ensuring screens react properly to signed-out vs signed-in states.
- Add Firestore persistence integration test ensuring meals persist across app restart and rehydrate selected date state.
