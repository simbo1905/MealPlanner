import { describe, it, expect, beforeEach } from 'vitest';
import { RecipeDatabase, createRecipeDatabase } from '../src/database.js';
import { validateRecipeJson, validateIngredientJson } from '@mealplanner/recipe-validator';
import { isRecipe, isIngredient, createRecipe, createIngredient } from '@mealplanner/recipe-types';
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

describe('Module Integration Tests', () => {
  let database: RecipeDatabase;

  beforeEach(() => {
    localStorageMock.clear();
  });

  describe('Recipe Types <-> Recipe Validator Integration', () => {
    it('should validate recipe created with type helpers', () => {
      const recipe = createRecipe({
        title: 'Integration Test Recipe',
        image_url: 'https://example.com/test.jpg',
        description: 'Test recipe created with type helpers',
        ingredients: [
          createIngredient({ name: 'Test Ingredient' })
        ],
        steps: ['Step 1', 'Step 2']
      });

      // Type guard should pass
      expect(isRecipe(recipe)).toBe(true);

      // Validator should also pass
      const validationResult = validateRecipeJson(recipe);
      expect(validationResult.isValid).toBe(true);
      expect(validationResult.errors).toHaveLength(0);
    });

    it('should validate ingredient created with type helpers', () => {
      const ingredient = createIngredient({ name: 'Test Ingredient' });

      // Type guard should pass
      expect(isIngredient(ingredient)).toBe(true);

      // Validator should also pass
      const validationResult = validateIngredientJson(ingredient);
      expect(validationResult.isValid).toBe(true);
      expect(validationResult.errors).toHaveLength(0);
    });

    it('should catch invalid recipes created with partial type helpers', () => {
      const invalidRecipe = {
        title: '', // Invalid: empty title
        image_url: '',
        description: '',
        notes: '',
        pre_reqs: [],
        total_time: 30,
        ingredients: [
          createIngredient({ name: 'Test Ingredient' })
        ],
        steps: ['Step 1']
      };

      // Type guard should fail
      expect(isRecipe(invalidRecipe)).toBe(false);

      // Validator should also fail
      const validationResult = validateRecipeJson(invalidRecipe);
      expect(validationResult.isValid).toBe(false);
      expect(validationResult.errors.length).toBeGreaterThan(0);
    });
  });

  describe('Recipe Validator <-> Recipe Database Integration', () => {
    beforeEach(() => {
      database = createRecipeDatabase();
    });

    it('should only store valid recipes in database', () => {
      const validRecipe: Recipe = {
        title: 'Valid Integration Recipe',
        image_url: 'https://example.com/valid.jpg',
        description: 'A valid recipe for integration testing',
        notes: 'Integration test notes',
        pre_reqs: [],
        total_time: 30,
        ingredients: [
          {
            name: 'Valid Ingredient',
            'ucum-unit': 'cup_us',
            'ucum-amount': 1.0,
            'metric-unit': 'g',
            'metric-amount': 100,
            notes: 'Valid ingredient note'
          }
        ],
        steps: ['Valid step 1', 'Valid step 2']
      };

      // Validate first
      const validationResult = validateRecipeJson(validRecipe);
      expect(validationResult.isValid).toBe(true);

      // Then store in database
      const addResult = database.addRecipe(validRecipe);
      expect(addResult.success).toBe(true);
      expect(addResult.recipe).toBeDefined();
      expect(database.getAllRecipes()).toHaveLength(1);
    });

    it('should reject invalid recipes from database', () => {
      const invalidRecipe = {
        title: '', // Invalid: empty title
        image_url: 'https://example.com/invalid.jpg',
        description: 'Invalid recipe',
        notes: 'Invalid notes',
        pre_reqs: [],
        total_time: 30,
        ingredients: [
          {
            name: 'Invalid Ingredient',
            'ucum-unit': 'cup_us',
            'ucum-amount': 1.0,
            'metric-unit': 'g',
            'metric-amount': 100,
            notes: 'Invalid ingredient note'
          }
        ],
        steps: ['Invalid step']
      };

      // Validate first
      const validationResult = validateRecipeJson(invalidRecipe);
      expect(validationResult.isValid).toBe(false);

      // Database should also reject
      const addResult = database.addRecipe(invalidRecipe);
      expect(addResult.success).toBe(false);
      expect(addResult.recipe).toBeUndefined();
      expect(addResult.errors.length).toBeGreaterThan(0);
      expect(database.getAllRecipes()).toHaveLength(0);
    });

    it('should maintain data integrity between validation and storage', () => {
      const recipe: Recipe = {
        title: 'Data Integrity Test',
        image_url: 'https://example.com/integrity.jpg',
        description: 'Testing data integrity',
        notes: 'Integrity notes',
        pre_reqs: ['Test prerequisite'],
        total_time: 45,
        ingredients: [
          {
            name: 'Integrity Ingredient',
            'ucum-unit': 'tbsp_us',
            'ucum-amount': 2.0,
            'metric-unit': 'ml',
            'metric-amount': 30,
            notes: 'Integrity ingredient note',
            'allergen-code': 'GLUTEN'
          }
        ],
        steps: ['Integrity step 1', 'Integrity step 2', 'Integrity step 3']
      };

      // Validate
      const validationResult = validateRecipeJson(recipe);
      expect(validationResult.isValid).toBe(true);

      // Store
      const addResult = database.addRecipe(recipe);
      expect(addResult.success).toBe(true);

      // Retrieve and verify integrity
      const retrievedRecipe = database.getRecipeByTitle('Data Integrity Test');
      expect(retrievedRecipe).toBeDefined();
      expect(retrievedRecipe?.title).toBe(recipe.title);
      expect(retrievedRecipe?.ingredients).toHaveLength(1);
      expect(retrievedRecipe?.ingredients[0]['allergen-code']).toBe('GLUTEN');
      expect(retrievedRecipe?.steps).toHaveLength(3);
    });
  });

  describe('Recipe Types <-> Recipe Database Integration', () => {
    beforeEach(() => {
      database = createRecipeDatabase();
    });

    it('should store recipes created with type helpers', () => {
      const recipe = createRecipe({
        title: 'Type Helper Recipe',
        image_url: 'https://example.com/type-helper.jpg',
        description: 'Recipe created with type helpers',
        ingredients: [
          createIngredient({ 
            name: 'Type Helper Ingredient',
            'ucum-unit': 'tsp_us',
            'ucum-amount': 3.0,
            'metric-unit': 'ml',
            'metric-amount': 15,
            notes: 'Created with createIngredient'
          })
        ],
        steps: ['Type helper step']
      });

      // Verify with type guard
      expect(isRecipe(recipe)).toBe(true);

      // Store in database
      const addResult = database.addRecipe(recipe);
      expect(addResult.success).toBe(true);

      // Retrieve and verify
      const retrieved = database.getRecipeByTitle('Type Helper Recipe');
      expect(retrieved).toBeDefined();
      expect(retrieved?.ingredients[0].name).toBe('Type Helper Ingredient');
      expect(retrieved?.ingredients[0]['ucum-unit']).toBe('tsp_us');
      expect(retrieved?.ingredients[0]['ucum-amount']).toBe(3.0);
    });

    it('should support complex recipe creation workflow', () => {
      // Step 1: Create ingredients using type helpers
      const flour = createIngredient({ 
        name: 'All-purpose flour',
        'ucum-unit': 'cup_us',
        'ucum-amount': 2.0,
        'metric-unit': 'g',
        'metric-amount': 240,
        notes: 'Sifted',
        'allergen-code': 'GLUTEN'
      });

      const butter = createIngredient({ 
        name: 'Butter',
        'ucum-unit': 'cup_us',
        'ucum-amount': 1.0,
        'metric-unit': 'g',
        'metric-amount': 227,
        notes: 'Unsalted, softened',
        'allergen-code': 'MILK'
      });

      // Step 2: Validate individual ingredients
      expect(validateIngredientJson(flour).isValid).toBe(true);
      expect(validateIngredientJson(butter).isValid).toBe(true);

      // Step 3: Create recipe using type helpers
      const recipe = createRecipe({
        title: 'Complex Workflow Recipe',
        image_url: 'https://example.com/complex.jpg',
        description: 'Recipe created through complex workflow',
        total_time: 60,
        ingredients: [flour, butter],
        steps: ['Mix ingredients', 'Bake until golden']
      });

      // Step 4: Validate complete recipe
      const validationResult = validateRecipeJson(recipe);
      expect(validationResult.isValid).toBe(true);

      // Step 5: Store in database
      const addResult = database.addRecipe(recipe);
      expect(addResult.success).toBe(true);

      // Step 6: Search and verify
      const searchResults = database.searchRecipes({ 
        query: 'Complex Workflow',
        excludeAllergens: ['EGG'] // Should still find it since no egg
      });
      expect(searchResults).toHaveLength(1);
      expect(searchResults[0].recipe.title).toBe('Complex Workflow Recipe');
    });
  });

  describe('End-to-End Recipe Management Workflow', () => {
    beforeEach(() => {
      database = createRecipeDatabase();
    });

    it('should handle complete recipe lifecycle', () => {
      // 1. Create a recipe with allergens
      const recipe = createRecipe({
        title: 'Complete Lifecycle Recipe',
        image_url: 'https://example.com/lifecycle.jpg',
        description: 'Testing complete recipe lifecycle',
        total_time: 90,
        ingredients: [
          createIngredient({ 
            name: 'Wheat flour',
            'ucum-unit': 'cup_us',
            'ucum-amount': 2.0,
            'metric-unit': 'g',
            'metric-amount': 240,
            notes: 'All-purpose flour',
            'allergen-code': 'GLUTEN'
          }),
          createIngredient({ 
            name: 'Whole milk',
            'ucum-unit': 'cup_us',
            'ucum-amount': 1.0,
            'metric-unit': 'ml',
            'metric-amount': 240,
            notes: 'Fresh milk',
            'allergen-code': 'MILK'
          }),
          createIngredient({ 
            name: 'Peanuts',
            'ucum-unit': 'cup_us',
            'ucum-amount': 0.5,
            'metric-unit': 'g',
            'metric-amount': 75,
            notes: 'Chopped peanuts',
            'allergen-code': 'PEANUT'
          })
        ],
        steps: ['Mix dry ingredients', 'Add wet ingredients', 'Bake']
      });

      // 2. Validate before storing
      const validationResult = validateRecipeJson(recipe);
      expect(validationResult.isValid).toBe(true);

      // 3. Store in database
      const addResult = database.addRecipe(recipe);
      expect(addResult.success).toBe(true);

      // 4. Verify storage
      expect(database.getAllRecipes()).toHaveLength(1);

      // 5. Test allergen filtering
      const glutenFreeResults = database.searchRecipes({ 
        excludeAllergens: ['GLUTEN'] 
      });
      expect(glutenFreeResults).toHaveLength(0); // Should exclude our recipe

      const dairyFreeResults = database.searchRecipes({ 
        excludeAllergens: ['MILK'] 
      });
      expect(dairyFreeResults).toHaveLength(0); // Should exclude our recipe

      // 6. Test ingredient-based search
      const flourResults = database.searchRecipes({ ingredients: ['flour'] });
      expect(flourResults).toHaveLength(1);

      // 7. Test time-based filtering
      const quickResults = database.searchRecipes({ maxTime: 60 });
      expect(quickResults).toHaveLength(0); // Our recipe takes 90 minutes

      const slowResults = database.searchRecipes({ maxTime: 120 });
      expect(slowResults).toHaveLength(1);

      // 8. Test statistics
      const stats = database.getStats();
      expect(stats.totalRecipes).toBe(1);
      expect(stats.allergenCount).toBe(3); // GLUTEN, MILK, PEANUT
      expect(stats.ingredientCount).toBe(3);
      expect(stats.averageTime).toBe(90);
    });

    it('should handle recipe with complex search criteria', () => {
      const recipe = createRecipe({
        title: 'Search Test Recipe',
        image_url: 'https://example.com/search.jpg',
        description: 'Recipe for testing complex search functionality',
        total_time: 45,
        ingredients: [
          createIngredient({ 
            name: 'Chicken breast',
            'ucum-unit': 'cup_us',
            'ucum-amount': 2.0,
            'metric-unit': 'g',
            'metric-amount': 300,
            notes: 'Boneless, skinless'
          }),
          createIngredient({ 
            name: 'Broccoli',
            'ucum-unit': 'cup_us',
            'ucum-amount': 1.0,
            'metric-unit': 'g',
            'metric-amount': 150,
            notes: 'Fresh broccoli florets'
          }),
          createIngredient({ 
            name: 'Carrots',
            'ucum-unit': 'cup_us',
            'ucum-amount': 0.5,
            'metric-unit': 'g',
            'metric-amount': 75,
            notes: 'Sliced carrots'
          }),
          createIngredient({ 
            name: 'Butter',
            'ucum-unit': 'tbsp_us',
            'ucum-amount': 2.0,
            'metric-unit': 'g',
            'metric-amount': 30,
            notes: 'For cooking',
            'allergen-code': 'MILK'
          })
        ],
        steps: ['Prep vegetables', 'Cook chicken', 'Combine and serve']
      });

      database.addRecipe(recipe);

      // Complex search: chicken recipes under 60 minutes without gluten
      const results = database.searchRecipes({
        query: 'chicken',
        maxTime: 60,
        excludeAllergens: ['GLUTEN'], // Should still find it (no gluten)
        ingredients: ['chicken', 'broccoli'], // Should match
        sortBy: 'total_time',
        limit: 5
      });

      expect(results).toHaveLength(1);
      expect(results[0].recipe.title).toBe('Search Test Recipe');
      expect(results[0].score).toBeGreaterThan(1); // Should have bonus for ingredient matches
      expect(results[0].matchedFields).toContain('ingredients'); // Matches ingredients, not title
    });
  });

  describe('Error Handling Integration', () => {
    beforeEach(() => {
      database = createRecipeDatabase();
    });

    it('should provide meaningful error messages for invalid data', () => {
      const invalidRecipes = [
        {
          title: '', // Empty title
          image_url: 'https://example.com/test.jpg',
          description: 'Test description',
          notes: 'Test notes',
          pre_reqs: [],
          total_time: 30,
          ingredients: [
            createIngredient({ name: 'Test ingredient' })
          ],
          steps: ['Step 1']
        },
        {
          title: 'Valid Title',
          image_url: 'not-a-url', // Invalid URL
          description: 'Test description',
          notes: 'Test notes',
          pre_reqs: [],
          total_time: 30,
          ingredients: [
            createIngredient({ name: 'Test ingredient' })
          ],
          steps: ['Step 1']
        }
      ];

      // Test first invalid recipe (empty title) - should fail type guard
      const invalidRecipe1 = invalidRecipes[0];
      expect(isRecipe(invalidRecipe1)).toBe(false);
      
      let validationResult = validateRecipeJson(invalidRecipe1);
      expect(validationResult.isValid).toBe(false);
      expect(validationResult.errors.length).toBeGreaterThan(0);
      
      let addResult = database.addRecipe(invalidRecipe1);
      expect(addResult.success).toBe(false);
      expect(addResult.errors.length).toBeGreaterThan(0);

      // Test second invalid recipe (invalid URL) - should pass type guard but fail validator
      const invalidRecipe2 = invalidRecipes[1];
      expect(isRecipe(invalidRecipe2)).toBe(true); // Type guard only checks type, not format
      
      validationResult = validateRecipeJson(invalidRecipe2);
      expect(validationResult.isValid).toBe(false);
      expect(validationResult.errors.length).toBeGreaterThan(0);
      
      addResult = database.addRecipe(invalidRecipe2);
      expect(addResult.success).toBe(false);
      expect(addResult.errors.length).toBeGreaterThan(0);
    });

    it('should handle database operations with validation errors gracefully', () => {
      const validRecipe = createRecipe({
        title: 'Valid Recipe',
        image_url: 'https://example.com/valid.jpg',
        description: 'A valid recipe for testing',
        ingredients: [
          createIngredient({ name: 'Valid ingredient' })
        ],
        steps: ['Valid step']
      });

      // Add valid recipe first
      database.addRecipe(validRecipe);

      // Try to add invalid recipe
      const invalidRecipe = {
        title: 'Valid Recipe', // Duplicate title
        image_url: 'https://example.com/test.jpg',
        description: 'Test description',
        notes: 'Test notes',
        pre_reqs: [],
        total_time: 30,
        ingredients: [
          createIngredient({ name: 'Test ingredient' })
        ],
        steps: ['Step 1']
      };

      const addResult = database.addRecipe(invalidRecipe);
      expect(addResult.success).toBe(false);
      expect(addResult.errors[0]).toContain('already exists');

      // Database should still have only the original recipe
      expect(database.getAllRecipes()).toHaveLength(1);
    });
  });
});