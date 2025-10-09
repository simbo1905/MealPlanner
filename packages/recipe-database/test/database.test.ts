import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { RecipeDatabase, createRecipeDatabase, SearchOptions } from '../src/database.js';
import { Recipe } from '@mealplanner/recipe-types';

// Mock localStorage
const localStorageMock = (() => {
  let store: Record<string, string> = {};
  
  return {
    getItem: (key: string) => store[key] || null,
    setItem: (key: string, value: string) => {
      store[key] = value;
    },
    removeItem: (key: string) => {
      delete store[key];
    },
    clear: () => {
      store = {};
    }
  };
})();

// Mock window object
Object.defineProperty(global, 'window', {
  value: {
    localStorage: localStorageMock
  },
  writable: true
});

// Also set up global localStorage as fallback for direct access
Object.defineProperty(global, 'localStorage', {
  value: localStorageMock,
  writable: true
});

// Test data
const testRecipes: Recipe[] = [
  {
    title: "Quick Chicken Stir-Fry",
    image_url: "https://example.com/stirfry.jpg",
    description: "A speedy weeknight dinner with tender chicken and crisp vegetables",
    notes: "Perfect for busy weeknights",
    pre_reqs: ["Wok or large skillet"],
    total_time: 25,
    ingredients: [
      {
        name: "chicken breast",
        "ucum-unit": "cup_us",
        "ucum-amount": 2.0,
        "metric-unit": "g",
        "metric-amount": 400,
        notes: "Cut into bite-sized pieces"
      },
      {
        name: "mixed vegetables",
        "ucum-unit": "cup_us",
        "ucum-amount": 3.0,
        "metric-unit": "g",
        "metric-amount": 450,
        notes: "Fresh or frozen"
      },
      {
        name: "soy sauce",
        "ucum-unit": "tbsp_us",
        "ucum-amount": 3.0,
        "metric-unit": "ml",
        "metric-amount": 45,
        notes: "Low sodium preferred"
      }
    ],
    steps: ["Heat wok", "Stir-fry chicken", "Add vegetables", "Add sauce", "Serve"]
  },
  {
    title: "Creamy Mushroom Risotto",
    image_url: "https://example.com/risotto.jpg",
    description: "Rich and creamy Italian rice dish with earthy mushrooms",
    notes: "Requires constant stirring but worth the effort",
    pre_reqs: ["Heavy-bottomed saucepan"],
    total_time: 45,
    ingredients: [
      {
        name: "arborio rice",
        "ucum-unit": "cup_us",
        "ucum-amount": 1.5,
        "metric-unit": "g",
        "metric-amount": 300,
        notes: "Italian short-grain rice"
      },
      {
        name: "mixed mushrooms",
        "ucum-unit": "cup_us",
        "ucum-amount": 2.0,
        "metric-unit": "g",
        "metric-amount": 300,
        notes: "Cleaned and sliced"
      },
      {
        name: "butter",
        "ucum-unit": "tbsp_us",
        "ucum-amount": 3.0,
        "metric-unit": "g",
        "metric-amount": 45,
        notes: "Unsalted",
        "allergen-code": "MILK"
      }
    ],
    steps: ["Sauté mushrooms", "Toast rice", "Add broth", "Stir constantly", "Finish with butter"]
  },
  {
    title: "Simple Tomato Soup",
    image_url: "https://example.com/soup.jpg",
    description: "Classic comfort food with ripe tomatoes and herbs",
    notes: "Use ripe, seasonal tomatoes for best flavor",
    pre_reqs: ["Large pot"],
    total_time: 35,
    ingredients: [
      {
        name: "ripe tomatoes",
        "ucum-unit": "cup_us",
        "ucum-amount": 6.0,
        "metric-unit": "g",
        "metric-amount": 900,
        notes: "Roma or vine-ripened, chopped"
      },
      {
        name: "heavy cream",
        "ucum-unit": "cup_us",
        "ucum-amount": 0.5,
        "metric-unit": "ml",
        "metric-amount": 120,
        notes: "For richness (optional)",
        "allergen-code": "MILK"
      },
      {
        name: "fresh basil",
        "ucum-unit": "tbsp_us",
        "ucum-amount": 2.0,
        "metric-unit": "g",
        "metric-amount": 6,
        notes: "Chopped"
      }
    ],
    steps: ["Sauté aromatics", "Add tomatoes", "Simmer", "Blend until smooth", "Stir in cream"]
  },
  {
    title: "Grilled Salmon with Asparagus",
    image_url: "https://example.com/salmon.jpg",
    description: "Healthy and flavorful salmon with tender asparagus",
    notes: "Don't overcook the salmon",
    pre_reqs: ["Grill or grill pan"],
    total_time: 20,
    ingredients: [
      {
        name: "salmon fillets",
        "ucum-unit": "cup_us",
        "ucum-amount": 4.0,
        "metric-unit": "g",
        "metric-amount": 600,
        notes: "Skin-on, about 150g each"
      },
      {
        name: "asparagus spears",
        "ucum-unit": "cup_us",
        "ucum-amount": 2.0,
        "metric-unit": "g",
        "metric-amount": 300,
        notes: "Trimmed"
      },
      {
        name: "butter",
        "ucum-unit": "tbsp_us",
        "ucum-amount": 2.0,
        "metric-unit": "g",
        "metric-amount": 30,
        notes: "Melted",
        "allergen-code": "MILK"
      },
      {
        name: "fresh dill",
        "ucum-unit": "tbsp_us",
        "ucum-amount": 1.0,
        "metric-unit": "g",
        "metric-amount": 3,
        notes: "Chopped"
      }
    ],
    steps: ["Preheat grill", "Brush with oil", "Grill salmon", "Add asparagus", "Make lemon butter", "Serve"]
  },
  {
    title: "Vegetarian Buddha Bowl",
    image_url: "https://example.com/buddha.jpg",
    description: "Colorful and nutritious bowl with quinoa and roasted vegetables",
    notes: "Great for meal prep",
    pre_reqs: ["Baking sheet"],
    total_time: 40,
    ingredients: [
      {
        name: "quinoa",
        "ucum-unit": "cup_us",
        "ucum-amount": 1.0,
        "metric-unit": "g",
        "metric-amount": 185,
        notes: "Rinsed"
      },
      {
        name: "chickpeas",
        "ucum-unit": "cup_us",
        "ucum-amount": 1.5,
        "metric-unit": "g",
        "metric-amount": 250,
        notes: "Cooked or canned, drained"
      },
      {
        name: "sweet potato",
        "ucum-unit": "cup_us",
        "ucum-amount": 2.0,
        "metric-unit": "g",
        "metric-amount": 300,
        notes: "Cubed"
      },
      {
        name: "kale",
        "ucum-unit": "cup_us",
        "ucum-amount": 2.0,
        "metric-unit": "g",
        "metric-amount": 130,
        notes: "Chopped, tough stems removed"
      },
      {
        name: "tahini",
        "ucum-unit": "tbsp_us",
        "ucum-amount": 2.0,
        "metric-unit": "ml",
        "metric-amount": 30,
        notes: "Sesame paste"
      }
    ],
    steps: ["Cook quinoa", "Roast vegetables", "Massage kale", "Make dressing", "Assemble bowls"]
  }
];

describe('RecipeDatabase', () => {
  let database: RecipeDatabase;

  beforeEach(() => {
    localStorageMock.clear();
    database = createRecipeDatabase(testRecipes);
  });

  afterEach(() => {
    localStorageMock.clear();
  });

  describe('Constructor and Initialization', () => {
    it('should initialize with provided recipes', () => {
      expect(database.getAllRecipes()).toHaveLength(5);
    });

    it('should create empty database when no recipes provided', () => {
      const emptyDb = createRecipeDatabase();
      expect(emptyDb.getAllRecipes()).toHaveLength(0);
    });

    it('should load recipes from localStorage if available', () => {
      localStorageMock.setItem('mealplanner-recipes', JSON.stringify(testRecipes));
      const dbFromStorage = createRecipeDatabase();
      expect(dbFromStorage.getAllRecipes()).toHaveLength(5);
    });

    it('should handle corrupted localStorage data gracefully', () => {
      localStorageMock.setItem('mealplanner-recipes', 'invalid json');
      const dbFromStorage = createRecipeDatabase();
      expect(dbFromStorage.getAllRecipes()).toHaveLength(0);
    });
  });

  describe('addRecipe', () => {
    it('should add valid recipe successfully', () => {
      const newRecipe: Recipe = {
        title: "Test Recipe",
        image_url: "https://example.com/test.jpg",
        description: "Test description",
        notes: "Test notes",
        pre_reqs: [],
        total_time: 30,
        ingredients: [
          {
            name: "test ingredient",
            "ucum-unit": "cup_us",
            "ucum-amount": 1.0,
            "metric-unit": "g",
            "metric-amount": 100,
            notes: "test note"
          }
        ],
        steps: ["Step 1"]
      };

      const result = database.addRecipe(newRecipe);
      
      expect(result.success).toBe(true);
      expect(result.recipe).toEqual(newRecipe);
      expect(result.errors).toHaveLength(0);
      expect(database.getAllRecipes()).toHaveLength(6);
    });

    it('should reject duplicate recipe titles', () => {
      const duplicateRecipe = {
        title: "Quick Chicken Stir-Fry",
        image_url: "https://example.com/duplicate.jpg",
        description: "Duplicate recipe",
        notes: "Duplicate notes",
        pre_reqs: [],
        total_time: 30,
        ingredients: [
          {
            name: "test ingredient",
            "ucum-unit": "cup_us",
            "ucum-amount": 1.0,
            "metric-unit": "g",
            "metric-amount": 100,
            notes: "test note"
          }
        ],
        steps: ["Step 1"]
      };

      const result = database.addRecipe(duplicateRecipe);
      
      expect(result.success).toBe(false);
      expect(result.recipe).toBeUndefined();
      expect(result.errors).toContain('Recipe with title "Quick Chicken Stir-Fry" already exists');
      expect(database.getAllRecipes()).toHaveLength(5);
    });

    it('should reject invalid recipe data', () => {
      const invalidRecipe = {
        title: "", // Empty title
        image_url: "https://example.com/test.jpg",
        description: "Test description",
        notes: "Test notes",
        pre_reqs: [],
        total_time: 30,
        ingredients: [
          {
            name: "test ingredient",
            "ucum-unit": "cup_us",
            "ucum-amount": 1.0,
            "metric-unit": "g",
            "metric-amount": 100,
            notes: "test note"
          }
        ],
        steps: ["Step 1"]
      };

      const result = database.addRecipe(invalidRecipe);
      
      expect(result.success).toBe(false);
      expect(result.recipe).toBeUndefined();
      expect(result.errors.length).toBeGreaterThan(0);
      expect(database.getAllRecipes()).toHaveLength(5);
    });
  });

  describe('getAllRecipes', () => {
    it('should return all recipes', () => {
      const recipes = database.getAllRecipes();
      expect(recipes).toHaveLength(5);
      expect(recipes[0].title).toBe("Quick Chicken Stir-Fry");
    });

    it('should return a copy of recipes array', () => {
      const recipes1 = database.getAllRecipes();
      const recipes2 = database.getAllRecipes();
      expect(recipes1).not.toBe(recipes2); // Different array instances
      expect(recipes1).toEqual(recipes2); // Same content
    });
  });

  describe('getRecipeByTitle', () => {
    it('should find recipe by exact title', () => {
      const recipe = database.getRecipeByTitle("Quick Chicken Stir-Fry");
      expect(recipe).toBeDefined();
      expect(recipe?.title).toBe("Quick Chicken Stir-Fry");
    });

    it('should find recipe by title (case insensitive)', () => {
      const recipe = database.getRecipeByTitle("quick chicken stir-fry");
      expect(recipe).toBeDefined();
      expect(recipe?.title).toBe("Quick Chicken Stir-Fry");
    });

    it('should return undefined for non-existent title', () => {
      const recipe = database.getRecipeByTitle("Non-existent Recipe");
      expect(recipe).toBeUndefined();
    });
  });

  describe('searchRecipes', () => {
    it('should search by query in title', () => {
      const results = database.searchRecipes({ query: "chicken" });
      expect(results).toHaveLength(1);
      expect(results[0].recipe.title).toBe("Quick Chicken Stir-Fry");
      expect(results[0].matchedFields).toContain('title');
    });

    it('should search by query in description', () => {
      const results = database.searchRecipes({ query: "creamy" });
      expect(results).toHaveLength(1);
      expect(results[0].recipe.title).toBe("Creamy Mushroom Risotto");
      expect(results[0].matchedFields).toContain('description');
    });

    it('should search by query in ingredients', () => {
      const results = database.searchRecipes({ query: "quinoa" });
      expect(results).toHaveLength(1);
      expect(results[0].recipe.title).toBe("Vegetarian Buddha Bowl");
      expect(results[0].matchedFields).toContain('ingredients');
    });

    it('should search with multiple matches', () => {
      const results = database.searchRecipes({ query: "vegetables" });
      expect(results.length).toBeGreaterThan(1);
    });

    it('should filter by maxTime', () => {
      const results = database.searchRecipes({ maxTime: 30 });
      expect(results.length).toBeLessThanOrEqual(5);
      results.forEach(result => {
        expect(result.recipe.total_time).toBeLessThanOrEqual(30);
      });
    });

    it('should filter by ingredients', () => {
      const results = database.searchRecipes({ ingredients: ["chicken", "quinoa"] });
      expect(results.length).toBeGreaterThan(0);
      const titles = results.map(r => r.recipe.title);
      expect(titles.some(t => t.includes("Chicken"))).toBe(true);
      expect(titles.some(t => t.includes("Buddha"))).toBe(true);
    });

    it('should filter by excludeAllergens', () => {
      const results = database.searchRecipes({ excludeAllergens: ["MILK"] });
      results.forEach(result => {
        const hasMilk = result.recipe.ingredients.some(ing => ing['allergen-code'] === 'MILK');
        expect(hasMilk).toBe(false);
      });
    });

    it('should sort by title', () => {
      const results = database.searchRecipes({ sortBy: 'title' });
      const titles = results.map(r => r.recipe.title);
      const sortedTitles = [...titles].sort();
      expect(titles).toEqual(sortedTitles);
    });

    it('should sort by total_time', () => {
      const results = database.searchRecipes({ sortBy: 'total_time' });
      const times = results.map(r => r.recipe.total_time);
      const sortedTimes = [...times].sort((a, b) => a - b);
      expect(times).toEqual(sortedTimes);
    });

    it('should sort by relevance (score)', () => {
      const results = database.searchRecipes({ query: 'chicken', sortBy: 'relevance' });
      const scores = results.map(r => r.score);
      const sortedScores = [...scores].sort((a, b) => b - a);
      expect(scores).toEqual(sortedScores);
    });

    it('should apply limit', () => {
      const results = database.searchRecipes({ limit: 2 });
      expect(results).toHaveLength(2);
    });

    it('should combine multiple search options', () => {
      const results = database.searchRecipes({
        query: 'chicken',
        maxTime: 30,
        limit: 1,
        sortBy: 'total_time'
      });
      expect(results).toHaveLength(1);
      expect(results[0].recipe.title).toBe("Quick Chicken Stir-Fry");
      expect(results[0].recipe.total_time).toBeLessThanOrEqual(30);
    });

    it('should return empty array when no matches', () => {
      const results = database.searchRecipes({ query: 'nonexistent' });
      expect(results).toHaveLength(0);
    });
  });

  describe('getRecipesByTimeRange', () => {
    it('should return recipes within time range', () => {
      const recipes = database.getRecipesByTimeRange(20, 40);
      expect(recipes.length).toBeGreaterThan(0);
      recipes.forEach(recipe => {
        expect(recipe.total_time).toBeGreaterThanOrEqual(20);
        expect(recipe.total_time).toBeLessThanOrEqual(40);
      });
    });

    it('should return empty array when no recipes in range', () => {
      const recipes = database.getRecipesByTimeRange(100, 200);
      expect(recipes).toHaveLength(0);
    });

    it('should handle edge cases', () => {
      const recipes = database.getRecipesByTimeRange(0, 1000);
      expect(recipes).toHaveLength(5);
    });
  });

  describe('getQuickRecipes', () => {
    it('should return quick recipes (default 30 min)', () => {
      const recipes = database.getQuickRecipes();
      expect(recipes.length).toBeGreaterThan(0);
      recipes.forEach(recipe => {
        expect(recipe.total_time).toBeLessThanOrEqual(30);
      });
    });

    it('should return quick recipes with custom time', () => {
      const recipes = database.getQuickRecipes(25);
      expect(recipes.length).toBeGreaterThan(0);
      recipes.forEach(recipe => {
        expect(recipe.total_time).toBeLessThanOrEqual(25);
      });
    });

    it('should be sorted by total_time', () => {
      const recipes = database.getQuickRecipes();
      const times = recipes.map(r => r.total_time);
      const sortedTimes = [...times].sort((a, b) => a - b);
      expect(times).toEqual(sortedTimes);
    });
  });

  describe('getRecipesByIngredient', () => {
    it('should return recipes containing ingredient', () => {
      const recipes = database.getRecipesByIngredient('chicken');
      expect(recipes.length).toBeGreaterThan(0);
      recipes.forEach(recipe => {
        const hasIngredient = recipe.ingredients.some(ing => 
          ing.name.toLowerCase().includes('chicken')
        );
        expect(hasIngredient).toBe(true);
      });
    });

    it('should return empty array for non-existent ingredient', () => {
      const recipes = database.getRecipesByIngredient('unicorn meat');
      expect(recipes).toHaveLength(0);
    });

    it('should be case insensitive', () => {
      const recipes1 = database.getRecipesByIngredient('CHICKEN');
      const recipes2 = database.getRecipesByIngredient('chicken');
      expect(recipes1.length).toBe(recipes2.length);
    });
  });

  describe('getAllIngredients', () => {
    it('should return all unique ingredients', () => {
      const ingredients = database.getAllIngredients();
      expect(ingredients.length).toBeGreaterThan(0);
      // Check that ingredients are unique and sorted
      const uniqueIngredients = Array.from(new Set(ingredients));
      expect(ingredients).toEqual(uniqueIngredients.sort());
    });

    it('should return empty array for empty database', () => {
      const emptyDb = createRecipeDatabase();
      const ingredients = emptyDb.getAllIngredients();
      expect(ingredients).toHaveLength(0);
    });
  });

  describe('getAllAllergens', () => {
    it('should return all unique allergen codes', () => {
      const allergens = database.getAllAllergens();
      expect(allergens).toContain('MILK');
      // Check that allergens are unique and sorted
      const uniqueAllergens = Array.from(new Set(allergens));
      expect(allergens).toEqual(uniqueAllergens.sort());
    });

    it('should return empty array when no allergens', () => {
      const allergenFreeRecipes = testRecipes.map(recipe => ({
        ...recipe,
        ingredients: recipe.ingredients.map(ing => ({
          ...ing,
          'allergen-code': undefined
        }))
      }));
      const db = createRecipeDatabase(allergenFreeRecipes);
      const allergens = db.getAllAllergens();
      expect(allergens).toHaveLength(0);
    });
  });

  describe('getStats', () => {
    it('should return comprehensive statistics', () => {
      const stats = database.getStats();
      
      expect(stats.totalRecipes).toBe(5);
      expect(stats.ingredientCount).toBeGreaterThan(0);
      expect(stats.allergenCount).toBeGreaterThan(0);
      expect(stats.averageTime).toBeGreaterThan(0);
      expect(stats.timeRange.min).toBeGreaterThan(0);
      expect(stats.timeRange.max).toBeGreaterThanOrEqual(stats.timeRange.min);
    });

    it('should handle empty database', () => {
      const emptyDb = createRecipeDatabase();
      const stats = emptyDb.getStats();
      
      expect(stats.totalRecipes).toBe(0);
      expect(stats.ingredientCount).toBe(0);
      expect(stats.allergenCount).toBe(0);
      expect(stats.averageTime).toBe(0);
      expect(stats.timeRange.min).toBe(0);
      expect(stats.timeRange.max).toBe(0);
    });
  });

  describe('Storage Operations', () => {
    it('should save to localStorage when adding recipe', () => {
      const newRecipe: Recipe = {
        title: "Storage Test Recipe",
        image_url: "https://example.com/test.jpg",
        description: "Test description",
        notes: "Test notes",
        pre_reqs: [],
        total_time: 30,
        ingredients: [
          {
            name: "test ingredient",
            "ucum-unit": "cup_us",
            "ucum-amount": 1.0,
            "metric-unit": "g",
            "metric-amount": 100,
            notes: "test note"
          }
        ],
        steps: ["Step 1"]
      };

      database.addRecipe(newRecipe);
      
      const stored = localStorageMock.getItem('mealplanner-recipes');
      expect(stored).toBeTruthy();
      
      const parsed = JSON.parse(stored!);
      expect(parsed).toHaveLength(6);
      expect(parsed[5].title).toBe("Storage Test Recipe");
    });

    it('should persist data across instances', () => {
      const newRecipe: Recipe = {
        title: "Persistence Test Recipe",
        image_url: "https://example.com/test.jpg",
        description: "Test description",
        notes: "Test notes",
        pre_reqs: [],
        total_time: 30,
        ingredients: [
          {
            name: "test ingredient",
            "ucum-unit": "cup_us",
            "ucum-amount": 1.0,
            "metric-unit": "g",
            "metric-amount": 100,
            notes: "test note"
          }
        ],
        steps: ["Step 1"]
      };

      database.addRecipe(newRecipe);
      
      const newDatabase = createRecipeDatabase();
      expect(newDatabase.getAllRecipes()).toHaveLength(6);
      expect(newDatabase.getRecipeByTitle("Persistence Test Recipe")).toBeDefined();
    });

    it('should handle localStorage errors gracefully', () => {
      // Mock localStorage.setItem to throw an error
      const originalSetItem = localStorageMock.setItem;
      localStorageMock.setItem = () => {
        throw new Error('Storage full');
      };

      const consoleSpy = vi.spyOn(console, 'warn').mockImplementation(() => {});

      const newRecipe: Recipe = {
        title: "Error Test Recipe",
        image_url: "https://example.com/test.jpg",
        description: "Test description",
        notes: "Test notes",
        pre_reqs: [],
        total_time: 30,
        ingredients: [
          {
            name: "test ingredient",
            "ucum-unit": "cup_us",
            "ucum-amount": 1.0,
            "metric-unit": "g",
            "metric-amount": 100,
            notes: "test note"
          }
        ],
        steps: ["Step 1"]
      };

      // Should not throw, but should log warning
      expect(() => database.addRecipe(newRecipe)).not.toThrow();
      expect(consoleSpy).toHaveBeenCalledWith('Failed to save recipes to localStorage:', expect.any(Error));

      // Restore original function
      localStorageMock.setItem = originalSetItem;
      consoleSpy.mockRestore();
    });
  });

  describe('clear', () => {
    it('should clear all recipes', () => {
      database.clear();
      expect(database.getAllRecipes()).toHaveLength(0);
      
      const stored = localStorageMock.getItem('mealplanner-recipes');
      expect(stored).toBe('[]');
    });
  });

  describe('resetToDefaults', () => {
    it('should reset to provided default recipes', () => {
      database.clear();
      database.resetToDefaults(testRecipes);
      expect(database.getAllRecipes()).toHaveLength(5);
    });

    it('should overwrite existing recipes', () => {
      const originalCount = database.getAllRecipes().length;
      database.resetToDefaults([testRecipes[0]]); // Just one recipe
      expect(database.getAllRecipes()).toHaveLength(1);
    });
  });

  describe('createRecipeDatabase', () => {
    it('should create database instance with factory function', () => {
      const db = createRecipeDatabase(testRecipes);
      expect(db).toBeInstanceOf(RecipeDatabase);
      expect(db.getAllRecipes()).toHaveLength(5);
    });

    it('should create empty database when no parameters', () => {
      const db = createRecipeDatabase();
      expect(db).toBeInstanceOf(RecipeDatabase);
      expect(db.getAllRecipes()).toHaveLength(0);
    });
  });
});