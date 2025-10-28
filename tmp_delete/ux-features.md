# UX Features from Old apps/web (to rebuild incrementally)

## Navigation
- **Feature**: Tab navigation allows user to switch between Calendar View and Recipe Explorer
- **User Action**: Click on tabs in top navigation bar
- **Outcome**: Different views displayed without page reload

## Recipe Explorer View
- **Feature**: Search box allows user to find recipes by name or description
- **User Action**: Type search text into input field
- **Outcome**: Recipe list filters in real-time

- **Feature**: Tag-based filtering allows user to filter by ingredients
- **User Action**: Type #tagname in search box OR click common ingredient tags
- **Outcome**: Recipes matching tags are displayed; selected tags shown as removable chips

- **Feature**: Infinite scroll loads recipes progressively
- **User Action**: Scroll down the recipe list
- **Outcome**: More recipes load automatically without page navigation

- **Feature**: Recipe selection shows full details
- **User Action**: Click on a recipe card
- **Outcome**: Right sidebar displays full recipe with ingredients and steps

- **Feature**: Common ingredient quick filters
- **User Action**: Click pre-defined ingredient tag buttons
- **Outcome**: Filter applied immediately to recipe list

## Recipe Form (Add New Recipe)
- **Feature**: Recipe creation form allows user to add custom recipes
- **User Action**: Fill in title, description, prep time, ingredients, steps, notes
- **Outcome**: New recipe saved to recipe store and appears in explorer

- **Feature**: Dynamic ingredient list management
- **User Action**: Click "+ Add Ingredient" or "×" to remove
- **Outcome**: Ingredient fields added/removed dynamically

- **Feature**: Dynamic step list management
- **User Action**: Click "+ Add Step" or "×" to remove
- **Outcome**: Step fields added/removed dynamically

- **Feature**: Form validation
- **User Action**: Try to submit without title
- **Outcome**: Alert shown, form not submitted

- **Feature**: Form cancel/reset
- **User Action**: Click Cancel button
- **Outcome**: Form cleared and hidden

## Calendar View
- **Note**: This was junk/debug code - will be fully replaced with demo
- No UX features to preserve from old calendar implementation
