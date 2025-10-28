# AREA_NEW_LLM_ONBOARDING.md

## Functional Area: LLM Recipe Onboarding (Spec 004)

**Status**: WorkspaceRecipe model exists. Screens, widgets, and tests need to be built.

**Models** (reuse from `./meal_planner/lib/models`):
- `workspace_recipe.freezed_model.dart` - Draft recipe for LLM processing
- `recipe.freezed_model.dart` - Final recipe after review

**Providers** (reuse from `./meal_planner/lib/providers`):
- `recipe_providers.dart` - `RecipeSaveNotifier` for final recipe save

**External Integrations** (Future):
- Camera plugin - `image_picker`
- OCR service - MistralAI Vision API or Google Vision
- Recipe structuring - MistralAI Chat API

**Services**:
- `uuid_generator.dart` - Generate workspace recipe IDs

---

## Feature Overview

**Goal**: Enable users to onboard recipes via:
1. Snap photo of printed recipe card
2. AI reads photo (OCR + vision)
3. AI structures data into WorkspaceRecipe (ingredients, steps, etc.)
4. User reviews and edits AI output
5. User converts to final Recipe and saves

**Current Implementation**: Screens 1-3 with mock AI output for testing

---

## Screens to Build

### 1. CameraCaptureScreen
**Path**: `lib/screens/onboarding/camera_capture_screen.dart`

**Purpose**: Capture photo of recipe card using device camera

**Widgets Used**:
- Camera preview
- Capture button
- Gallery picker button (select existing photo)
- Flash toggle
- Cancel button

**Provider Watches**:
- None (pure camera/gallery interaction)

**UI States**:
- Camera ready: Show preview + buttons
- Capturing: Show loading overlay
- Captured: Show photo with confirm/retake buttons
- Processing: Show "Analyzing recipe..." message
- Error: Show error message + retry

**User Interactions**:
- Tap capture → Take photo
- Tap gallery → Open photo picker
- Tap flash icon → Toggle flash
- Tap confirm → Go to RecipeProcessingScreen with image
- Tap retake → Back to camera
- Tap cancel → Discard and go back

**Implementation Notes**:
- Use `image_picker` package for camera/gallery access
- Store image temporarily (in memory or temp file)
- Pass image to processing screen

---

### 2. RecipeProcessingScreen
**Path**: `lib/screens/onboarding/recipe_processing_screen.dart`

**Purpose**: Show OCR processing and generate WorkspaceRecipe from image

**Widgets Used**:
- Loading indicator with progress
- Image preview (top)
- Processing steps (OCR, AI structuring, validation)
- Cancel button

**Provider Watches**:
- Future provider for OCR + AI processing (async)
- Mock: Return hardcoded WorkspaceRecipe for testing

**UI States**:
- Processing: Show image + "Analyzing recipe..." + progress steps
- Success: Navigate to RecipeReviewScreen with WorkspaceRecipe
- Error: Show error message + "Retry" or "Manual entry" buttons
- Timeout: Show timeout message + options

**User Interactions**:
- Cancel → Discard and go back
- Auto-navigate to review on success
- Retry → Reprocess image
- Manual entry → Skip to empty form

**Processing Flow** (to implement in future):
1. Send image to OCR API (MistralAI Vision)
2. Parse response → Extract text
3. Send text to recipe structuring API (MistralAI Chat)
4. Parse JSON response → Create WorkspaceRecipe
5. Navigate to review screen

**For Testing**: Mock providers that return test WorkspaceRecipe

---

### 3. RecipeReviewScreen
**Path**: `lib/screens/onboarding/recipe_review_screen.dart`

**Purpose**: Review and edit AI-generated recipe before saving

**Widgets Used**:
- RecipeWorkspaceWidget (editable recipe form)
- Accept button (save as Recipe)
- Discard button (delete draft)
- Edit mode toggles (view vs. edit)

**Provider Watches**:
- `workspaceRecipeProvider(id)` - Load draft recipe
- `RecipeSaveNotifier` - Save final recipe

**UI States**:
- Loading: Show skeleton
- Loaded: Show editable workspace
- Saving: Show loading on button
- Success: Show snackbar "Recipe saved", pop screen
- Error: Show error message with retry

**User Interactions**:
- Edit any field (title, ingredients, steps, time, etc.)
- Add/remove ingredients
- Add/remove steps
- Tap "Accept & Save" → Convert WorkspaceRecipe to Recipe + save
- Tap "Discard" → Show confirmation, delete workspace recipe
- Tap "Cancel" → Go back without saving

**Conversion Logic**:
```dart
Recipe convertToRecipe(WorkspaceRecipe workspace) {
  return Recipe(
    id: UuidGenerator.next(),
    title: workspace.title,
    imageUrl: workspace.imageUrl ?? '',
    description: workspace.description ?? '',
    notes: workspace.notes ?? '',
    preReqs: workspace.preReqs ?? [],
    totalTime: workspace.totalTime ?? 0,
    ingredients: workspace.ingredients ?? [],
    steps: workspace.steps ?? [],
  );
}
```

---

## Widgets to Build

### 1. RecipeWorkspaceWidget
**Path**: `lib/widgets/onboarding/recipe_workspace_widget.dart`

**Props**:
- `workspace: WorkspaceRecipe` - Editable draft
- `onChanged: Function(WorkspaceRecipe updated)` - Called on any edit
- `readOnly: bool = false` - Disable editing

**Displays**:
- Title field (editable text)
- Image URL field or upload button
- Description field (editable text area)
- Notes field (editable text area)
- Pre-requisites field (list of items)
- Total time field (number input)
- Ingredients list (add/edit/remove items)
- Steps list (add/edit/remove items)

**UI**:
- Form layout with sections
- Each section expandable
- Visual indication if fields are empty vs. populated

**Behavior**:
- Any change → Call `onChanged(updatedWorkspace)`
- Add ingredient → New empty ingredient at end
- Remove ingredient → Delete from list
- Add step → New empty step at end
- Remove step → Delete from list

---

### 2. WorkspaceIngredientField
**Path**: `lib/widgets/onboarding/workspace_ingredient_field.dart`

**Props**:
- `ingredient: Ingredient` - Item to edit
- `onChanged: Function(Ingredient updated)` - Called on any change
- `onRemove: VoidCallback` - Called on delete button
- `readOnly: bool = false`

**Displays**:
- Name field
- UCUM amount + unit dropdown
- Metric amount + unit dropdown
- Notes field
- Remove button (X)

**UI**:
- Single row or expandable card
- All fields inline if space allows

**Behavior**:
- Edit any field → Call `onChanged` with updated ingredient
- Tap remove → Call `onRemove()`

---

## Unit Tests to Build

### Widget Tests

**CameraCaptureScreen Tests**  
`test/widgets/onboarding/camera_capture_screen_test.dart`
- Test: Display camera preview (mock)
- Test: Show capture button
- Test: Show gallery button
- Test: Show flash toggle
- Test: Tap gallery → Open image picker (mock)
- Test: Cancel button → Pop screen
- Test: Confirm photo → Navigate to processing screen
- Test: Retake button → Back to camera

**RecipeProcessingScreen Tests**  
`test/widgets/onboarding/recipe_processing_screen_test.dart`
- Test: Display loading state with progress
- Test: Show image preview
- Test: Process image → Generate WorkspaceRecipe (mocked)
- Test: Success → Navigate to review screen
- Test: Error → Show error message + retry
- Test: Cancel → Pop screen
- Test: Timeout → Show timeout message
- Test: Mock different OCR responses

**RecipeReviewScreen Tests**  
`test/widgets/onboarding/recipe_review_screen_test.dart`
- Test: Load and display workspace recipe
- Test: Edit recipe title and save
- Test: Add/remove ingredients
- Test: Add/remove steps
- Test: Convert workspace to recipe with generated ID
- Test: Save recipe (calls RecipeSaveNotifier)
- Test: Delete workspace recipe on discard
- Test: Cancel without saving
- Test: Show success snackbar after save

**RecipeWorkspaceWidget Tests**  
`test/widgets/onboarding/recipe_workspace_widget_test.dart`
- Test: Display all recipe fields
- Test: Edit title field and call onChanged
- Test: Edit description field
- Test: Display ingredients list
- Test: Add ingredient to list
- Test: Remove ingredient from list
- Test: Edit ingredient details
- Test: Add step to list
- Test: Remove step from list
- Test: Read-only mode disables all edits

**WorkspaceIngredientField Tests**  
`test/widgets/onboarding/workspace_ingredient_field_test.dart`
- Test: Display ingredient name, amounts, units
- Test: Edit ingredient name and call onChanged
- Test: Change UCUM unit dropdown
- Test: Change metric unit dropdown
- Test: Edit notes field
- Test: Remove ingredient button calls onRemove
- Test: Read-only mode disables edits

---

## Architecture Notes

### State Management Flow

1. **CameraCaptureScreen**
   - Pure camera/gallery interaction (no providers)
   - Returns image file → Pass to RecipeProcessingScreen

2. **RecipeProcessingScreen**
   - Async processing: `processingProvider(imageFile)` (Future)
   - Mocked for now → Returns test WorkspaceRecipe
   - Success → Navigate with workspace data

3. **RecipeReviewScreen**
   - Watch `workspaceRecipeProvider(id)` to load draft
   - Local form state or StateNotifier for edits
   - Save → Convert to Recipe + call `RecipeSaveNotifier.save()`

### Mock Providers for Testing

```dart
// In test setup, mock the processing provider
final testWorkspace = WorkspaceRecipe(
  id: 'workspace-1',
  title: 'Pasta Carbonara',
  imageUrl: 'https://example.com/image.jpg',
  description: 'Classic Roman pasta',
  notes: 'Use guanciale if available',
  preReqs: ['Boil water', 'Cook pasta'],
  totalTime: 30,
  ingredients: [
    Ingredient(name: 'Pasta', ucumAmount: 500, ...),
  ],
  steps: ['Boil water', 'Cook pasta', 'Mix ingredients'],
);

ProviderScope(
  overrides: [
    processingProvider('image_path').overrideWithValue(AsyncValue.data(testWorkspace)),
  ],
  child: RecipeProcessingScreen(imagePath: 'image_path'),
)
```

---

## Implementation Checklist

### Screens
- [ ] CameraCaptureScreen
- [ ] RecipeProcessingScreen
- [ ] RecipeReviewScreen

### Widgets
- [ ] RecipeWorkspaceWidget
- [ ] WorkspaceIngredientField

### Tests
- [ ] camera_capture_screen_test.dart (8+ test cases)
- [ ] recipe_processing_screen_test.dart (8+ test cases)
- [ ] recipe_review_screen_test.dart (9+ test cases)
- [ ] recipe_workspace_widget_test.dart (10+ test cases)
- [ ] workspace_ingredient_field_test.dart (6+ test cases)

### Dependencies (if using real camera)
- [ ] Add `image_picker` to pubspec.yaml
- [ ] Add iOS/Android camera permissions in manifest files
- [ ] Mock image_picker in tests

### Code Generation
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`

### Quality Checks
- [ ] `flutter analyze` passes
- [ ] `flutter test test/widgets/onboarding/` passes
- [ ] No Firebase imports in tests (except where explicitly needed)

---

## Future Integrations

### Phase 1 (Current): Mock Implementation
- Camera capture (real)
- Processing screen shows mock data
- Review and save to Firestore

### Phase 2: Real LLM Integration
- Replace mock with MistralAI Vision API
- OCR text extraction from recipe photo
- Replace mock with MistralAI Chat API
- Structured recipe generation

### Phase 3: Advanced Features
- Multiple photo support (multi-page recipes)
- User corrections feedback loop (improve AI model)
- Recipe template suggestions (match similar recipes)
- Bulk recipe upload

---

## References

- **Models**: `./meal_planner/lib/models/workspace_recipe.freezed_model.dart`, `recipe.freezed_model.dart`
- **Providers**: `./meal_planner/lib/providers/recipe_providers.dart`
- **Testing**: `TESTING_TAO.md`
- **Development**: `FLUTTER_DEV.md`
- **Architecture**: `TAO_OF_TEEMU.md`
- **ID Generation**: `./meal_planner/lib/services/uuid_generator.dart`
- **Image Picker**: https://pub.dev/packages/image_picker
- **MistralAI API**: https://docs.mistral.ai/ (future)
