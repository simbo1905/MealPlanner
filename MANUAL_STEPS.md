# Manual Steps Required

## Critical: Fix pnpm Store Corruption

The pnpm store is corrupted and blocking all package installations. This MUST be fixed before the webapp can be built.

### Steps to Fix

```bash
# 1. Remove all pnpm stores and caches
rm -rf ~/.pnpm-store
rm -rf ~/.local/share/pnpm/store
rm -rf /Users/Shared/MealPlanner/node_modules/.pnpm/store

# 2. Clean all node_modules in the monorepo
cd /Users/Shared/MealPlanner
rm -rf node_modules
rm -rf pnpm-lock.yaml
find apps packages tooling -name "node_modules" -type d -exec rm -rf {} +

# 3. Fresh install
pnpm install

# 4. Build packages
pnpm build:packages

# 5. Build webapp
pnpm build:web
```

### Verify Success

```bash
# All packages should build successfully
cd /Users/Shared/MealPlanner
pnpm build:packages

# Should output built files in:
# - packages/recipe-types/dist/
# - packages/recipe-validator/dist/
# - packages/recipe-database/dist/

# Test with justfile
just build-webapp
```

## Remove Contaminated iOS Directories

These directories contain old NextJS artifacts and should be removed:

```bash
cd /Users/Shared/MealPlanner
rm -rf apps/ios/webapp
rm -rf apps/ios/Resources/webapp
```

## Prototype Features Documented

### Main Calendar View
- Header: logo, "MealPlanner Calendar View" title, Save button
- Weekly grid showing 4 weeks
- Each day displays: day name (MON-SUN), date, activities/meals
- Add button on each empty day
- Reset button
- Total activities count

### Add Meal Dialog
- Search textbox: "Search recipes or type #ingredient..."
- Ingredient dropdown with tags: chicken, fish, vegetables
- Recipe list with cooking times:
  - Spaghetti Bolognese (45 min)
  - Chicken Stir-Fry (30 min)
  - Fish and Chips (40 min)
  - Vegetable Curry (35 min)
  - Roast Chicken (90 min)
- Filter by ingredient tags (shows selected tags as removable badges)
- Close button

### Screenshots Captured
- `/tmp/playwright-mcp-output/1760133052455/prototype-calendar-main.png`
- `/tmp/playwright-mcp-output/1760133052455/prototype-add-meal-dialog.png`
- `/tmp/playwright-mcp-output/1760133052455/prototype-ingredient-dropdown.png`

## Next Steps (After pnpm Fix)

1. Implement Svelte components matching prototype screens
2. Use recipe database package for data
3. Implement drag-and-drop for calendar (using svelte-dnd-action)
4. Add localStorage persistence for calendar state
5. Test with Playwright to verify visual parity
