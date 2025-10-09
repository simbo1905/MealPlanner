import type { Recipe } from "@mealplanner/recipe-types";
import { storeRecipe, formatValidationResult } from "@mealplanner/recipe-validator";
import type { Storage } from "./browser.js";

const TAGS_STORAGE_KEY = 'mealplanner-recipe-tags-v1'
const DEFAULT_TAGS = ['chicken', 'fish', 'vegetables']

/**
 * Safe localStorage accessor that handles privacy mode and disabled storage
 */
function getSafeLocalStorage(): Storage | null {
  try {
    if (typeof window !== 'undefined' && window.localStorage) {
      const test = '__storage_test__'
      window.localStorage.setItem(test, test)
      window.localStorage.removeItem(test)
      return window.localStorage
    }
  } catch {
    // Privacy mode, disabled, or not available
  }
  return null
}

/**
 * Search options for recipe queries
 */
export interface SearchOptions {
  /** Text to search in titles and descriptions */
  query?: string;
  /** Filter by maximum total time in minutes */
  maxTime?: number;
  /** Filter by ingredients (any match) */
  ingredients?: string[];
  /** Filter by allergen codes to exclude */
  excludeAllergens?: string[];
  /** Maximum number of results to return */
  limit?: number;
  /** Sort order for results */
  sortBy?: 'title' | 'total_time' | 'relevance';
}

/**
 * Search result with relevance score
 */
export interface SearchResult {
  recipe: Recipe;
  score: number;
  matchedFields: string[];
}

/**
 * Recipe database implementation with search functionality
 */
export class RecipeDatabase {
  private recipes: Recipe[] = [];
  private storageKey = 'mealplanner-recipes';

  constructor(initialRecipes?: Recipe[]) {
    if (initialRecipes) {
      this.recipes = [...initialRecipes];
    } else {
      this.loadFromStorage();
    }
  }

  /**
   * Add a recipe to the database after validation
   */
  addRecipe(recipeData: unknown): { success: boolean; recipe?: Recipe; errors: string[] } {
    const result = storeRecipe(recipeData);
    
    if (!result.success) {
      return {
        success: false,
        errors: result.errors.map(error => formatValidationResult({ isValid: false, errors: [error], summary: 'Validation failed' }))
      };
    }

    const recipe = result.recipe!;
    
    // Check for duplicate titles
    if (this.recipes.some(r => r.title.toLowerCase() === recipe.title.toLowerCase())) {
      return {
        success: false,
        errors: [`Recipe with title "${recipe.title}" already exists`]
      };
    }

    this.recipes.push(recipe);
    this.saveToStorage();
    
    return {
      success: true,
      recipe,
      errors: []
    };
  }

  /**
   * Get all recipes
   */
  getAllRecipes(): Recipe[] {
    return [...this.recipes];
  }

  /**
   * Get a recipe by title
   */
  getRecipeByTitle(title: string): Recipe | undefined {
    return this.recipes.find(recipe => recipe.title.toLowerCase() === title.toLowerCase());
  }

  /**
   * Search recipes with various filters
   */
  searchRecipes(options: SearchOptions = {}): SearchResult[] {
    let results: SearchResult[] = this.recipes.map(recipe => ({
      recipe,
      score: 1.0,
      matchedFields: []
    }));

    // Text search in title and description
    if (options.query && options.query.trim()) {
      const query = options.query.toLowerCase().trim();
      results = results.filter(result => {
        const titleMatch = result.recipe.title.toLowerCase().includes(query);
        const descriptionMatch = result.recipe.description.toLowerCase().includes(query);
        const ingredientMatch = result.recipe.ingredients.some(ing => 
          ing.name.toLowerCase().includes(query)
        );

        if (titleMatch) {
          result.score += 2.0;
          result.matchedFields.push('title');
        }
        if (descriptionMatch) {
          result.score += 1.0;
          result.matchedFields.push('description');
        }
        if (ingredientMatch) {
          result.score += 0.5;
          result.matchedFields.push('ingredients');
        }

        return titleMatch || descriptionMatch || ingredientMatch;
      });
    }

    // Filter by maximum time
    if (options.maxTime !== undefined) {
      results = results.filter(result => result.recipe.total_time <= options.maxTime!);
    }

    // Filter by ingredients
    if (options.ingredients && options.ingredients.length > 0) {
      const searchIngredients = options.ingredients.map(ing => ing.toLowerCase());
      results = results.filter(result => {
        return searchIngredients.some(searchIng => 
          result.recipe.ingredients.some(recipeIng => 
            recipeIng.name.toLowerCase().includes(searchIng)
          )
        );
      });
    }

    // Filter by allergens to exclude
    if (options.excludeAllergens && options.excludeAllergens.length > 0) {
      const excludeAllergens = options.excludeAllergens.map(a => a.toLowerCase());
      results = results.filter(result => {
        return !result.recipe.ingredients.some(ingredient => 
          ingredient['allergen-code'] && 
          excludeAllergens.includes(ingredient['allergen-code'].toLowerCase())
        );
      });
    }

    // Sort results
    if (options.sortBy === 'title') {
      results.sort((a, b) => a.recipe.title.localeCompare(b.recipe.title));
    } else if (options.sortBy === 'total_time') {
      results.sort((a, b) => a.recipe.total_time - b.recipe.total_time);
    } else {
      // Default: sort by relevance (score)
      results.sort((a, b) => b.score - a.score);
    }

    // Apply limit
    if (options.limit && options.limit > 0) {
      results = results.slice(0, options.limit);
    }

    return results;
  }

  /**
   * Get recipes by cooking time range
   */
  getRecipesByTimeRange(minTime: number, maxTime: number): Recipe[] {
    return this.recipes.filter(recipe => 
      recipe.total_time >= minTime && recipe.total_time <= maxTime
    );
  }

  /**
   * Get recipes that can be made with available time
   */
  getQuickRecipes(maxTime: number = 30): Recipe[] {
    return this.searchRecipes({ maxTime, sortBy: 'total_time' }).map(r => r.recipe);
  }

  /**
   * Get recipes by ingredient
   */
  getRecipesByIngredient(ingredientName: string): Recipe[] {
    return this.searchRecipes({ ingredients: [ingredientName] }).map(r => r.recipe);
  }

  /**
   * Get all unique ingredients across all recipes
   */
  getAllIngredients(): string[] {
    const ingredients = new Set<string>();
    this.recipes.forEach(recipe => {
      recipe.ingredients.forEach(ingredient => {
        ingredients.add(ingredient.name);
      });
    });
    return Array.from(ingredients).sort();
  }

  /**
   * Get all unique allergen codes
   */
  getAllAllergens(): string[] {
    const allergens = new Set<string>();
    this.recipes.forEach(recipe => {
      recipe.ingredients.forEach(ingredient => {
        if (ingredient['allergen-code']) {
          allergens.add(ingredient['allergen-code']);
        }
      });
    });
    return Array.from(allergens).sort();
  }

  /**
   * Get recipe statistics
   */
  getStats(): {
    totalRecipes: number;
    averageTime: number;
    ingredientCount: number;
    allergenCount: number;
    timeRange: { min: number; max: number };
  } {
    const times = this.recipes.map(r => r.total_time);
    const ingredients = this.getAllIngredients();
    const allergens = this.getAllAllergens();

    return {
      totalRecipes: this.recipes.length,
      averageTime: times.length > 0 ? times.reduce((a, b) => a + b, 0) / times.length : 0,
      ingredientCount: ingredients.length,
      allergenCount: allergens.length,
      timeRange: {
        min: times.length > 0 ? Math.min(...times) : 0,
        max: times.length > 0 ? Math.max(...times) : 0
      }
    };
  }

  /**
   * Save recipes to localStorage
   */
  private saveToStorage(): void {
    const storage = getSafeLocalStorage()
    if (storage) {
      try {
        storage.setItem(this.storageKey, JSON.stringify(this.recipes))
      } catch (error) {
        console.warn('Failed to save recipes to localStorage:', error)
      }
    }
  }

  /**
   * Load recipes from localStorage
   */
  private loadFromStorage(): void {
    const storage = getSafeLocalStorage()
    if (storage) {
      try {
        const stored = storage.getItem(this.storageKey)
        if (stored) {
          const parsed = JSON.parse(stored)
          if (Array.isArray(parsed)) {
            this.recipes = parsed
          }
        }
      } catch (error) {
        console.warn('Failed to load recipes from localStorage:', error)
      }
    }
  }

  /**
   * Clear all recipes
   */
  clear(): void {
    this.recipes = [];
    this.saveToStorage();
  }

  /**
   * Reset to default recipes
   */
  resetToDefaults(defaultRecipes: Recipe[]): void {
    this.recipes = [...defaultRecipes];
    this.saveToStorage();
  }
}

export function loadTags(): string[] {
  const storage = getSafeLocalStorage()
  
  if (!storage) {
    return [...DEFAULT_TAGS]
  }

  try {
    const stored = storage.getItem(TAGS_STORAGE_KEY)
    if (stored) {
      const parsed = JSON.parse(stored)
      if (Array.isArray(parsed)) {
        return parsed
      }
    }
  } catch (error) {
    console.warn('Failed to load stored tags, resetting to defaults', error)
  }

  try {
    storage.setItem(TAGS_STORAGE_KEY, JSON.stringify(DEFAULT_TAGS))
  } catch (error) {
    console.warn('Failed to save default tags to localStorage:', error)
  }
  
  return [...DEFAULT_TAGS]
}

export function addTag(tag: string): string[] {
  const normalised = tag.toLowerCase().trim()
  if (!normalised) {
    return loadTags()
  }

  const currentTags = loadTags()
  if (currentTags.includes(normalised)) {
    return currentTags
  }

  const updatedTags = [...currentTags, normalised]
  
  const storage = getSafeLocalStorage()
  if (storage) {
    try {
      storage.setItem(TAGS_STORAGE_KEY, JSON.stringify(updatedTags))
    } catch (error) {
      console.warn('Failed to save tag to localStorage:', error)
    }
  }
  
  return updatedTags
}

export function removeTag(tag: string): string[] {
  const normalised = tag.toLowerCase().trim()
  const currentTags = loadTags()
  const updatedTags = currentTags.filter(existing => existing !== normalised)

  const storage = getSafeLocalStorage()
  if (storage) {
    try {
      storage.setItem(TAGS_STORAGE_KEY, JSON.stringify(updatedTags))
    } catch (error) {
      console.warn('Failed to remove tag from localStorage:', error)
    }
  }

  return updatedTags
}

/**
 * Create a new recipe database instance
 */
export function createRecipeDatabase(initialRecipes?: Recipe[]): RecipeDatabase {
  return new RecipeDatabase(initialRecipes);
}
