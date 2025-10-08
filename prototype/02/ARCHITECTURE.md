# Prototype/02 Architecture

## Overview

This prototype implements a modular, layered architecture for a calendar-based meal planning interface with an isolated, searchable recipe database. The design emphasises separation of concerns, type safety, and testability.

---

## Architecture Principles

### 1. Modular Isolation
- **Recipe database** is completely isolated in its own module
- **UI components** consume the database through a well-defined API
- **Type definitions** are separated from implementation
- **Business logic** is decoupled from presentation

### 2. Data Flow
```
User Input → UI Component → Database Module → Data Layer → Results
                ↓                    ↓
         State Management    Search/Filter Logic
```

### 3. Separation of Concerns
- **Types**: Pure type definitions (no logic)
- **Data**: Recipe storage and search logic (no UI)
- **UI**: Presentation and user interaction (no business logic)
- **State**: Local state management in components

---

## Module Structure

### Core Modules

#### 1. Type Definitions (`src/lib/recipe-types.ts`)

**Responsibility**: Define the data contracts for recipes

```typescript
// Exports
- Recipe interface
- Ingredient interface
- UcumUnit type
- MetricUnit type
- AllergenCode type
```

**Characteristics**:
- Pure type definitions derived from JDT schema (RFC 8927)
- No implementation logic
- No dependencies on other modules
- Consumed by both database and UI layers

**Why Isolated?**:
- Types can be imported anywhere without circular dependencies
- Schema changes require updates in one place only
- Enables type-safe API contracts

---

#### 2. Recipe Database Module (`src/lib/recipe-database.ts`)

**Responsibility**: Manage recipe data and search operations

```typescript
// Public API
loadTags(): string[]
addTag(tag: string): string[]
removeTag(tag: string): string[]
getAllRecipes(): Recipe[]
getRecipeById(id: string): Recipe | undefined
searchByText(query: string): Recipe[]
searchByIngredients(tags: string[]): Recipe[]
searchRecipes(textQuery?: string, ingredientTags?: string[]): Recipe[]
```

**Internal Implementation**:
- Hard-coded recipe data (RECIPES constant)
- LocalStorage integration for tag persistence
- Search algorithms (text matching, ingredient filtering)
- Data normalisation (lowercase, trim)

**Dependencies**:
- `recipe-types.ts` (types only)
- Browser localStorage API

**Why Isolated?**:
- Database logic can be tested independently
- Easy to swap data source (API, IndexedDB, etc.)
- Search algorithms can be optimised without touching UI
- Clear API boundary prevents tight coupling

---

#### 3. UI Components (`src/components/calendar/`)

**Responsibility**: User interface and interaction

**AddMealDialog Component**:
```typescript
// Props (API Surface)
interface AddMealDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onSelectRecipe: (recipe: Recipe) => void;
}

// Internal State
- searchText: string
- selectedTags: string[]
- availableTags: string[]
- filteredRecipes: Recipe[]
```

**Interactions with Database**:
```typescript
// Component imports only public API functions
import { 
  searchRecipes, 
  loadTags, 
  addTag 
} from "@/lib/recipe-database"

// No direct access to internal data structures
// No knowledge of storage mechanisms
```

**Why Isolated?**:
- UI can be redesigned without changing database logic
- Component can be tested with mock database functions
- Database implementation details are hidden

---

## Data Flow Patterns

### 1. Tag Management Flow

```
User Types "#celery" + Space
         ↓
handleKeyDown() detects word boundary
         ↓
addTag("celery") → Database Module
         ↓
localStorage.setItem(...)
         ↓
Returns updated tag list
         ↓
setAvailableTags(updatedTags)
         ↓
UI re-renders with new tag
```

### 2. Search Flow

```
User Types "chicken" or Selects Tag "chicken"
         ↓
State updates: searchText or selectedTags
         ↓
useEffect() triggers
         ↓
searchRecipes(text, tags) → Database Module
         ↓
Filter logic executes
         ↓
Returns Recipe[]
         ↓
setFilteredRecipes(results)
         ↓
UI re-renders with filtered results
```

### 3. Multi-Word Tag Flow

```
User Types "#soy" + Shift+Space + "sauce" + Space
         ↓
handleKeyDown() detects modifier key
         ↓
Insert non-breaking space (U+00A0)
         ↓
Word boundary triggers tag creation
         ↓
addTag("soy\u00A0sauce") → Database Module
         ↓
Tag stored with nbsp in localStorage
         ↓
Search converts nbsp to \s+ regex pattern
         ↓
Matches "soy sauce", "soy\njuice", etc.
```

---

## API Boundaries

### Database Module Public API

| Function | Input | Output | Side Effects |
|----------|-------|--------|--------------|
| `loadTags()` | None | `string[]` | Reads localStorage |
| `addTag(tag)` | `string` | `string[]` | Writes localStorage |
| `removeTag(tag)` | `string` | `string[]` | Writes localStorage |
| `getAllRecipes()` | None | `Recipe[]` | None |
| `getRecipeById(id)` | `string` | `Recipe \| undefined` | None |
| `searchByText(query)` | `string` | `Recipe[]` | None |
| `searchByIngredients(tags)` | `string[]` | `Recipe[]` | None |
| `searchRecipes(text?, tags?)` | `string?, string[]?` | `Recipe[]` | None |

**Guarantees**:
- All functions are pure (no side effects) except tag management
- Tag functions always return the current state after mutation
- Search functions never mutate input or internal data
- All operations are synchronous

---

## Storage Strategy

### What's Stored Where

| Data Type | Storage Location | Persistence | Scope |
|-----------|-----------------|-------------|-------|
| Recipe Data | Hard-coded in module | N/A (static) | All users |
| User Tags | localStorage | Survives refresh | Per browser |
| Search State | React state | Session only | Per component instance |
| Calendar Data | localStorage | Survives refresh | Per browser |

### LocalStorage Keys

```
mealplanner-recipe-tags-v1    // User-created ingredient tags
mealplanner-calendar-v1        // Calendar meal assignments
```

**Versioning Strategy**: Key suffix allows migration if schema changes

---

## Type Safety

### TypeScript Strictness

```typescript
// All database functions are fully typed
function searchRecipes(
  textQuery?: string,
  ingredientTags?: string[]
): Recipe[]

// Recipe type enforces schema compliance
interface Recipe {
  title: string;           // Required
  total_time: number;      // Required, integer
  ingredients: Ingredient[]; // Required, min 1 item
  // ... all fields from JDT schema
}
```

**Benefits**:
- Compile-time validation of API usage
- IDE autocomplete for all functions
- Refactoring safety across modules
- Documentation through types

---

## Testing Strategy

### Unit Testing (Future)

```typescript
// Database module can be tested in isolation
describe('searchByIngredients', () => {
  it('matches single-word tags', () => {
    const results = searchByIngredients(['chicken']);
    expect(results).toContainRecipe('Chicken Stir-Fry');
  });

  it('handles multi-word tags with nbsp', () => {
    const results = searchByIngredients(['soy\u00A0sauce']);
    expect(results).toContainRecipe('Chicken Stir-Fry');
  });
});

// UI components can be tested with mocks
jest.mock('@/lib/recipe-database', () => ({
  searchRecipes: jest.fn(),
  loadTags: jest.fn(() => ['chicken', 'fish']),
  addTag: jest.fn((tag) => ['chicken', 'fish', tag])
}));
```

### Integration Testing (Future)

```typescript
// Test full flow without mocking database
it('creates tag and filters recipes', async () => {
  render(<AddMealDialog ... />);
  
  await userEvent.type(input, '#celery ');
  expect(screen.getByText('celery')).toBeInTheDocument();
  
  expect(screen.getByText('Roast Chicken')).toBeInTheDocument();
  expect(screen.queryByText('Fish and Chips')).not.toBeInTheDocument();
});
```

---

## Migration Path

### Current State: Hard-Coded Data
```typescript
const RECIPES: Recipe[] = [ /* ... */ ];
```

### Future: API Backend
```typescript
// Database module internal changes only
async function getAllRecipes(): Promise<Recipe[]> {
  const response = await fetch('/api/recipes');
  return response.json();
}

// UI components unchanged - same API surface
```

### Future: IndexedDB
```typescript
// Database module internal changes only
async function getAllRecipes(): Promise<Recipe[]> {
  const db = await openDB('mealplanner', 1);
  return db.getAll('recipes');
}

// UI components unchanged - same API surface
```

**Key Point**: Because the database is isolated, the data source can change without touching UI code.

---

## Performance Considerations

### Current Implementation

| Operation | Complexity | Performance |
|-----------|-----------|-------------|
| Load all recipes | O(1) | Instant (in-memory) |
| Text search | O(n) | Fast (5 recipes) |
| Ingredient search | O(n*m) | Fast (n=5 recipes, m=ingredients) |
| Tag management | O(1) | Instant (localStorage) |

### Optimisation Opportunities

1. **Memoisation**: Cache search results
   ```typescript
   const memoizedSearch = useMemo(
     () => searchRecipes(text, tags),
     [text, tags]
   );
   ```

2. **Debouncing**: Delay search while typing
   ```typescript
   const debouncedSearch = useDebounce(searchText, 300);
   ```

3. **Indexing**: Pre-build search indices
   ```typescript
   const INDEX = buildIngredientIndex(RECIPES);
   ```

---

## Security Considerations

### Input Validation

- Tag names: Alphanumeric + nbsp only (regex validated)
- Search queries: No regex injection (literal string matching)
- LocalStorage: No sensitive data stored

### XSS Prevention

- All user input is React-escaped automatically
- No `dangerouslySetInnerHTML` usage
- Tag display uses `.replace()` for nbsp (safe transformation)

---

## Scalability

### Current Limits

- **Recipes**: 5 (hard-coded)
- **Tags**: ~100 practical limit (localStorage + UI)
- **Search**: Suitable for <1000 recipes

### Scaling Strategy

1. **100-1000 recipes**: Add client-side indexing
2. **1000-10000 recipes**: Move to IndexedDB with Web Workers
3. **10000+ recipes**: Server-side search with pagination

---

## Extension Points

### Adding New Search Criteria

```typescript
// Extend database module
export function searchByAllergen(
  allergens: AllergenCode[]
): Recipe[] {
  return RECIPES.filter(recipe =>
    !recipe.ingredients.some(ing =>
      ing['allergen-code'] && 
      allergens.includes(ing['allergen-code'])
    )
  );
}

// UI components import new function
import { searchByAllergen } from '@/lib/recipe-database';
```

### Adding Recipe Favourites

```typescript
// New module: src/lib/recipe-favourites.ts
const FAVOURITES_KEY = 'mealplanner-favourites-v1';

export function getFavourites(): string[] { /* ... */ }
export function addFavourite(recipeId: string): void { /* ... */ }
export function removeFavourite(recipeId: string): void { /* ... */ }

// Integrate with search
const favouriteIds = getFavourites();
const favouriteRecipes = favouriteIds
  .map(id => getRecipeById(id))
  .filter(Boolean);
```

---

## Dependency Graph

```
┌─────────────────────────────────────────────┐
│          UI Components (React)              │
│                                             │
│  AddMealDialog.tsx                          │
│  ├── searchRecipes()                        │
│  ├── loadTags()                             │
│  └── addTag()                               │
└─────────────────┬───────────────────────────┘
                  │
                  ↓
┌─────────────────────────────────────────────┐
│       Database Module (Pure TS)             │
│                                             │
│  recipe-database.ts                         │
│  ├── RECIPES (private)                      │
│  ├── Search algorithms (private)            │
│  └── Tag management (private)               │
└─────────────────┬───────────────────────────┘
                  │
                  ↓
┌─────────────────────────────────────────────┐
│         Type Definitions (Pure TS)          │
│                                             │
│  recipe-types.ts                            │
│  ├── Recipe interface                       │
│  ├── Ingredient interface                   │
│  └── Enum types                             │
└─────────────────────────────────────────────┘
```

**Key Insight**: Dependencies flow downward only. No circular dependencies.

---

## Best Practices Demonstrated

1. **Separation of Concerns**: Data, logic, and UI are isolated
2. **Type Safety**: Full TypeScript coverage with strict types
3. **API Design**: Clear, minimal public interfaces
4. **Encapsulation**: Internal implementation hidden from consumers
5. **Testability**: Pure functions enable easy unit testing
6. **Extensibility**: New features can be added without refactoring
7. **Performance**: Efficient algorithms with clear complexity bounds
8. **Security**: Input validation and XSS prevention
9. **Documentation**: Code structure is self-documenting

---

## Summary

This architecture achieves **modular isolation** through:

- **Separated type definitions** that establish contracts
- **Encapsulated database module** with well-defined API
- **UI components** that consume the API without knowing implementation
- **Clear data flow** from user input to filtered results
- **Migration-ready design** that supports future data sources

The recipe search model is fully isolated - it can be tested, optimised, and replaced independently of the UI layer.

---

*Last Updated: 2025-10-07*  
*Prototype Version: 02*  
*Architecture Version: 1.0*
