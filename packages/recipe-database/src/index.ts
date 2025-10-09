// Export database functionality
export {
  RecipeDatabase,
  createRecipeDatabase
} from './database.js';

// Export search interfaces
export type {
  SearchOptions,
  SearchResult
} from './database.js';

export {
  loadTags,
  addTag,
  removeTag
} from './database.js';

// Export default recipe data
export { default as defaultRecipes } from '../data/recipes.json' with { type: 'json' };

// Re-export everything for convenience
export * from './database.js';
