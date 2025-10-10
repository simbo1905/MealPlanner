# Feature Specification: Recipe Management API

**Feature Branch**: `003-recipe-api`  
**Created**: 2025-10-07  
**Status**: Implemented  
**Feature Description**: TypeScript-based recipe management system with JDT RFC 8927 validation, searchable database, and localStorage persistence

---

## User Scenarios & Testing *(mandatory)*

### Primary User Story
As a developer building the MealPlanner web and mobile applications, I need a robust recipe management API that validates recipe data against strict schemas, provides fast search capabilities across recipe content, and persists data locally without requiring a backend server.

### Acceptance Scenarios
1. **Given** I have a recipe JSON object, **When** I validate it against the schema, **Then** I receive either success confirmation or detailed error messages explaining exactly what is wrong
2. **Given** I have initialized the recipe database, **When** I search for "chicken", **Then** I receive all recipes that mention chicken in their title, description, or ingredients list
3. **Given** I add recipes to the database, **When** I close and reopen the application, **Then** all my recipes are still available from localStorage
4. **Given** I search with multiple filters (text + ingredients + time), **When** results are returned, **Then** they are ranked by relevance with matching fields identified

### Edge Cases
- What happens when recipe JSON has invalid UCUM units? → Validation fails with specific field error
- How does search handle case sensitivity? → All searches are case-insensitive
- What if localStorage quota is exceeded? → Graceful degradation with in-memory fallback
- How are duplicate recipes handled? → Titles must be unique; duplicates rejected
- What happens with empty search queries? → Returns all recipes sorted by title

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: System MUST validate recipe JSON against JDT RFC 8927 schema with detailed field-level error messages
- **FR-002**: System MUST support UCUM units (cups, tablespoons, teaspoons) and metric units (grams, milliliters)
- **FR-003**: System MUST validate allergen codes against EU regulation 1169/2011 standard codes
- **FR-004**: System MUST provide free-text search across recipe titles, descriptions, and ingredient names
- **FR-005**: System MUST provide ingredient-based filtering (tag search) that only searches ingredient names
- **FR-006**: System MUST support combined search with both free-text and ingredient filters
- **FR-007**: System MUST rank search results by relevance score with matched fields identified
- **FR-008**: System MUST persist recipe data to localStorage automatically after changes
- **FR-009**: System MUST load persisted recipes from localStorage on initialization
- **FR-010**: System MUST handle localStorage failures gracefully and continue in memory-only mode
- **FR-011**: System MUST include 5 default recipes matching prototype examples (Spaghetti Bolognese, Chicken Stir-Fry, Fish and Chips, Vegetable Curry, Roast Chicken)
- **FR-012**: System MUST provide TypeScript type definitions exported from shared package
- **FR-013**: System MUST support filtering by maximum cooking time
- **FR-014**: System MUST support filtering by allergen exclusion
- **FR-015**: System MUST provide recipe statistics (total count, ingredient list, allergen list)

### Performance Requirements
- **PR-001**: Free text search MUST complete in <100ms for 1000 recipes
- **PR-002**: Ingredient search MUST complete in <50ms for 1000 recipes
- **PR-003**: Combined search MUST complete in <150ms for complex queries
- **PR-004**: Memory usage MUST stay under 10MB for 1000 recipes
- **PR-005**: localStorage save MUST complete in <10ms for 100 recipes
- **PR-006**: localStorage load MUST complete in <5ms for 100 recipes

### Key Entities *(include if feature involves data)*

**Recipe**
- title: string (minLength: 1)
- image_url: string (valid URI format)
- description: string (maxLength: 250)
- notes: string
- pre_reqs: string[] (array of prerequisite steps)
- total_time: integer (minimum: 1, in minutes)
- ingredients: Ingredient[] (minItems: 1)
- steps: string[] (minItems: 1, cooking instructions)

**Ingredient**
- name: string
- ucum-unit: enum (cup_us, cup_m, cup_imp, tbsp_us, tbsp_m, tbsp_imp, tsp_us, tsp_m, tsp_imp)
- ucum-amount: number (multipleOf: 0.1)
- metric-unit: enum (ml, g)
- metric-amount: number (integer)
- notes: string
- allergen-code: optional enum (GLUTEN, CRUSTACEAN, EGG, FISH, PEANUT, SOY, MILK, NUT, CELERY, MUSTARD, SESAME, SULPHITE, LUPIN, MOLLUSC, SHELLFISH, TREENUT, WHEAT)

**SearchOptions**
- query: optional string (free text search)
- maxTime: optional number (filter by cooking time)
- ingredients: optional string[] (ingredient tag filters)
- excludeAllergens: optional string[] (allergen codes to exclude)
- limit: optional number (max results)
- sortBy: optional enum (title, total_time, relevance)

**SearchResult**
- recipe: Recipe (the matching recipe)
- score: number (relevance score for ranking)
- matchedFields: string[] (fields that matched the search)

---

## Module Architecture

### @mealplanner/recipe-types
**Purpose**: Core TypeScript type definitions
**Exports**:
- Recipe, Ingredient interfaces
- UcumUnit, MetricUnit, AllergenCode enums
- Type guards: isRecipe(), isIngredient(), etc.
- Helper functions: createRecipe(), createIngredient()

### @mealplanner/recipe-validator
**Purpose**: JDT RFC 8927 JSON schema validation
**Exports**:
- validateRecipeJson(data): ValidationResult
- validateIngredientJson(data): ValidationResult
- storeRecipe(data): { success, recipe?, errors }
- storeIngredient(data): { success, ingredient?, errors }

### @mealplanner/recipe-database
**Purpose**: Searchable recipe database with persistence
**Exports**:
- RecipeDatabase class
- createRecipeDatabase(recipes?): RecipeDatabase
- defaultRecipes constant (5 example recipes)

**RecipeDatabase Methods**:
- addRecipe(recipeData): { success, recipe?, errors }
- getAllRecipes(): Recipe[]
- getRecipeByTitle(title): Recipe | undefined
- searchRecipes(options?): SearchResult[]
- getRecipesByTimeRange(min, max): Recipe[]
- getQuickRecipes(maxTime?): Recipe[]
- getRecipesByIngredient(name): Recipe[]
- getAllIngredients(): string[]
- getAllAllergens(): string[]
- getStats(): RecipeStats
- clear(): void
- resetToDefaults(recipes): void

---

## Integration Examples

### Basic Usage
```typescript
import { createRecipeDatabase, defaultRecipes } from '@mealplanner/recipe-database';

const db = createRecipeDatabase(defaultRecipes);
const allRecipes = db.getAllRecipes();
const results = db.searchRecipes({ query: "chicken" });
```

### Validation
```typescript
import { validateRecipeJson } from '@mealplanner/recipe-validator';

const result = validateRecipeJson(recipeData);
if (!result.isValid) {
  console.error(result.errors);
}
```

### Search
```typescript
const results = db.searchRecipes({
  query: "quick",
  ingredients: ["chicken"],
  maxTime: 30,
  excludeAllergens: ["GLUTEN"],
  sortBy: 'total_time',
  limit: 5
});
```

---

## Testing Coverage

### Unit Tests
- **recipe-types**: 32 tests (type guards, helpers, validation)
- **recipe-validator**: 63 tests (JDT validation, error messages, edge cases)
- **recipe-database**: 63 tests (search, persistence, operations)
- **Total**: 158 tests with 100% pass rate

### Test Categories
1. Schema validation success/failure cases
2. Search functionality with various filters
3. localStorage integration and error handling
4. Type guard validation
5. Helper function edge cases
6. Cross-module integration

---

## Review & Acceptance Checklist

### Content Quality
- [x] No unnecessary implementation details exposed in public API
- [x] Focused on developer experience and type safety
- [x] Comprehensive error messages for validation failures
- [x] All mandatory sections completed

### Requirement Completeness
- [x] No ambiguities in API contracts
- [x] Requirements are testable and have test coverage  
- [x] Performance criteria are measurable and met
- [x] All packages build and export correctly
- [x] Documentation is complete

---

## Execution Status

- [x] TypeScript type definitions created
- [x] JDT RFC 8927 validation implemented
- [x] Recipe database with search implemented
- [x] localStorage persistence implemented
- [x] Default recipes added
- [x] Unit tests written and passing
- [x] API documentation complete
- [x] Integration with webapp verified
