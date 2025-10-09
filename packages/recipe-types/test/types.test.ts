import { describe, it, expect } from 'vitest';
import {
  // Type guards
  isUcumUnit,
  isMetricUnit,
  isAllergenCode,
  isIngredient,
  isRecipe,
  // Helper functions
  createRecipe,
  createIngredient,
  // Types
  UcumUnit,
  MetricUnit,
  AllergenCode,
  Ingredient,
  Recipe
} from '../src/index.js';

describe('recipe-types', () => {
  describe('Type Guards', () => {
    describe('isUcumUnit', () => {
      it('should return true for valid UCUM units', () => {
        const validUnits: UcumUnit[] = [
          'cup_us', 'cup_m', 'cup_imp',
          'tbsp_us', 'tbsp_m', 'tbsp_imp',
          'tsp_us', 'tsp_m', 'tsp_imp'
        ];
        
        validUnits.forEach(unit => {
          expect(isUcumUnit(unit)).toBe(true);
        });
      });

      it('should return false for invalid UCUM units', () => {
        const invalidUnits = ['cup', 'tablespoon', 'teaspoon', 'invalid', 'ml', 'g', 123, null, undefined, {}];
        
        invalidUnits.forEach(unit => {
          expect(isUcumUnit(unit)).toBe(false);
        });
      });

      it('should handle edge cases correctly', () => {
        expect(isUcumUnit('')).toBe(false);
        expect(isUcumUnit(null)).toBe(false);
        expect(isUcumUnit(undefined)).toBe(false);
        expect(isUcumUnit(123)).toBe(false);
        expect(isUcumUnit({})).toBe(false);
        expect(isUcumUnit([])).toBe(false);
      });
    });

    describe('isMetricUnit', () => {
      it('should return true for valid metric units', () => {
        const validUnits: MetricUnit[] = ['ml', 'g'];
        
        validUnits.forEach(unit => {
          expect(isMetricUnit(unit)).toBe(true);
        });
      });

      it('should return false for invalid metric units', () => {
        const invalidUnits = ['cup_us', 'tbsp_us', 'kg', 'liter', 'invalid', 123, null, undefined, {}];
        
        invalidUnits.forEach(unit => {
          expect(isMetricUnit(unit)).toBe(false);
        });
      });

      it('should handle edge cases correctly', () => {
        expect(isMetricUnit('')).toBe(false);
        expect(isMetricUnit(null)).toBe(false);
        expect(isMetricUnit(undefined)).toBe(false);
        expect(isMetricUnit(123)).toBe(false);
        expect(isMetricUnit({})).toBe(false);
        expect(isMetricUnit([])).toBe(false);
      });
    });

    describe('isAllergenCode', () => {
      it('should return true for valid allergen codes', () => {
        const validAllergens: AllergenCode[] = [
          'GLUTEN', 'CRUSTACEAN', 'EGG', 'FISH', 'PEANUT', 'SOY', 'MILK', 'NUT',
          'CELERY', 'MUSTARD', 'SESAME', 'SULPHITE', 'LUPIN', 'MOLLUSC',
          'SHELLFISH', 'TREENUT', 'WHEAT'
        ];
        
        validAllergens.forEach(allergen => {
          expect(isAllergenCode(allergen)).toBe(true);
        });
      });

      it('should return false for invalid allergen codes', () => {
        const invalidAllergens = ['PEANUTS', 'DAIRY', 'invalid', 'nuts', 123, null, undefined, {}];
        
        invalidAllergens.forEach(allergen => {
          expect(isAllergenCode(allergen)).toBe(false);
        });
      });

      it('should handle edge cases correctly', () => {
        expect(isAllergenCode('')).toBe(false);
        expect(isAllergenCode(null)).toBe(false);
        expect(isAllergenCode(undefined)).toBe(false);
        expect(isAllergenCode(123)).toBe(false);
        expect(isAllergenCode({})).toBe(false);
        expect(isAllergenCode([])).toBe(false);
      });
    });

    describe('isIngredient', () => {
      it('should return true for valid ingredients', () => {
        const validIngredient: Ingredient = {
          name: 'Flour',
          'ucum-unit': 'cup_us',
          'ucum-amount': 2.0,
          'metric-unit': 'g',
          'metric-amount': 240,
          notes: 'All-purpose flour',
          'allergen-code': 'GLUTEN'
        };

        expect(isIngredient(validIngredient)).toBe(true);
      });

      it('should return true for ingredients without allergen code', () => {
        const ingredientWithoutAllergen: Ingredient = {
          name: 'Sugar',
          'ucum-unit': 'cup_us',
          'ucum-amount': 1.0,
          'metric-unit': 'g',
          'metric-amount': 200,
          notes: 'Granulated sugar'
        };

        expect(isIngredient(ingredientWithoutAllergen)).toBe(true);
      });

      it('should return false for invalid ingredients', () => {
        const invalidIngredients = [
          null,
          undefined,
          {},
          [],
          'string',
          123,
          { name: 'Invalid' }, // Missing required fields
          {
            name: 'Invalid',
            'ucum-unit': 'invalid_unit',
            'ucum-amount': 1.0,
            'metric-unit': 'g',
            'metric-amount': 100,
            notes: 'Invalid unit'
          },
          {
            name: 'Invalid',
            'ucum-unit': 'cup_us',
            'ucum-amount': 'not-a-number',
            'metric-unit': 'g',
            'metric-amount': 100,
            notes: 'Invalid amount type'
          }
        ];

        invalidIngredients.forEach(invalidIngredient => {
          expect(isIngredient(invalidIngredient)).toBe(false);
        });
      });

      it('should return false for ingredients with invalid allergen code', () => {
        const invalidIngredient = {
          name: 'Invalid',
          'ucum-unit': 'cup_us',
          'ucum-amount': 1.0,
          'metric-unit': 'g',
          'metric-amount': 100,
          notes: 'Invalid allergen',
          'allergen-code': 'INVALID_ALLERGEN'
        };

        expect(isIngredient(invalidIngredient)).toBe(false);
      });
    });

    describe('isRecipe', () => {
      it('should return true for valid recipes', () => {
        const validRecipe: Recipe = {
          title: 'Chocolate Cake',
          image_url: 'https://example.com/cake.jpg',
          description: 'Delicious chocolate cake recipe',
          notes: 'Best served warm',
          pre_reqs: ['Oven preheated to 180°C'],
          total_time: 60,
          ingredients: [
            {
              name: 'Flour',
              'ucum-unit': 'cup_us',
              'ucum-amount': 2.0,
              'metric-unit': 'g',
              'metric-amount': 240,
              notes: 'All-purpose flour',
              'allergen-code': 'GLUTEN'
            }
          ],
          steps: ['Mix ingredients', 'Bake for 30 minutes']
        };

        expect(isRecipe(validRecipe)).toBe(true);
      });

      it('should return true for recipes with minimal required fields', () => {
        const minimalRecipe: Recipe = {
          title: 'Simple Recipe',
          image_url: '',
          description: '',
          notes: '',
          pre_reqs: [],
          total_time: 1,
          ingredients: [
            {
              name: 'Ingredient',
              'ucum-unit': 'cup_us',
              'ucum-amount': 1.0,
              'metric-unit': 'g',
              'metric-amount': 100,
              notes: 'Note'
            }
          ],
          steps: ['Step 1']
        };

        expect(isRecipe(minimalRecipe)).toBe(true);
      });

      it('should return false for recipes with empty title', () => {
        const invalidRecipe = {
          title: '',
          image_url: '',
          description: '',
          notes: '',
          pre_reqs: [],
          total_time: 1,
          ingredients: [
            {
              name: 'Ingredient',
              'ucum-unit': 'cup_us',
              'ucum-amount': 1.0,
              'metric-unit': 'g',
              'metric-amount': 100,
              notes: 'Note'
            }
          ],
          steps: ['Step 1']
        };

        expect(isRecipe(invalidRecipe)).toBe(false);
      });

      it('should return false for recipes with description over 250 characters', () => {
        const invalidRecipe = {
          title: 'Valid Title',
          image_url: '',
          description: 'a'.repeat(251),
          notes: '',
          pre_reqs: [],
          total_time: 1,
          ingredients: [
            {
              name: 'Ingredient',
              'ucum-unit': 'cup_us',
              'ucum-amount': 1.0,
              'metric-unit': 'g',
              'metric-amount': 100,
              notes: 'Note'
            }
          ],
          steps: ['Step 1']
        };

        expect(isRecipe(invalidRecipe)).toBe(false);
      });

      it('should return false for recipes with no ingredients', () => {
        const invalidRecipe = {
          title: 'Valid Title',
          image_url: '',
          description: '',
          notes: '',
          pre_reqs: [],
          total_time: 1,
          ingredients: [],
          steps: ['Step 1']
        };

        expect(isRecipe(invalidRecipe)).toBe(false);
      });

      it('should return false for recipes with no steps', () => {
        const invalidRecipe = {
          title: 'Valid Title',
          image_url: '',
          description: '',
          notes: '',
          pre_reqs: [],
          total_time: 1,
          ingredients: [
            {
              name: 'Ingredient',
              'ucum-unit': 'cup_us',
              'ucum-amount': 1.0,
              'metric-unit': 'g',
              'metric-amount': 100,
              notes: 'Note'
            }
          ],
          steps: []
        };

        expect(isRecipe(invalidRecipe)).toBe(false);
      });

      it('should return false for recipes with invalid total_time', () => {
        const invalidRecipe = {
          title: 'Valid Title',
          image_url: '',
          description: '',
          notes: '',
          pre_reqs: [],
          total_time: 0,
          ingredients: [
            {
              name: 'Ingredient',
              'ucum-unit': 'cup_us',
              'ucum-amount': 1.0,
              'metric-unit': 'g',
              'metric-amount': 100,
              notes: 'Note'
            }
          ],
          steps: ['Step 1']
        };

        expect(isRecipe(invalidRecipe)).toBe(false);
      });

      it('should return false for invalid recipe structures', () => {
        const invalidRecipes = [
          null,
          undefined,
          {},
          [],
          'string',
          123,
          { title: 'Only title' }, // Missing required fields
          {
            title: 'Invalid',
            image_url: '',
            description: '',
            notes: '',
            pre_reqs: 'not-an-array', // Invalid pre_reqs type
            total_time: 1,
            ingredients: [],
            steps: ['Step 1']
          }
        ];

        invalidRecipes.forEach(invalidRecipe => {
          expect(isRecipe(invalidRecipe)).toBe(false);
        });
      });
    });
  });

  describe('Helper Functions', () => {
    describe('createRecipe', () => {
      it('should create a recipe with required fields', () => {
        const recipe = createRecipe({
          title: 'Test Recipe',
          ingredients: [
            {
              name: 'Test Ingredient',
              'ucum-unit': 'cup_us',
              'ucum-amount': 1.0,
              'metric-unit': 'g',
              'metric-amount': 100,
              notes: 'Test note'
            }
          ],
          steps: ['Step 1', 'Step 2']
        });

        expect(recipe.title).toBe('Test Recipe');
        expect(recipe.ingredients).toHaveLength(1);
        expect(recipe.steps).toHaveLength(2);
        expect(recipe.image_url).toBe('');
        expect(recipe.description).toBe('');
        expect(recipe.notes).toBe('');
        expect(recipe.pre_reqs).toEqual([]);
        expect(recipe.total_time).toBe(30);
      });

      it('should override default values with provided values', () => {
        const recipe = createRecipe({
          title: 'Custom Recipe',
          image_url: 'https://example.com/image.jpg',
          description: 'Custom description',
          notes: 'Custom notes',
          pre_reqs: ['Preheat oven'],
          total_time: 45,
          ingredients: [
            {
              name: 'Custom Ingredient',
              'ucum-unit': 'tbsp_us',
              'ucum-amount': 2.0,
              'metric-unit': 'ml',
              'metric-amount': 30,
              notes: 'Custom ingredient note'
            }
          ],
          steps: ['Custom step']
        });

        expect(recipe.title).toBe('Custom Recipe');
        expect(recipe.image_url).toBe('https://example.com/image.jpg');
        expect(recipe.description).toBe('Custom description');
        expect(recipe.notes).toBe('Custom notes');
        expect(recipe.pre_reqs).toEqual(['Preheat oven']);
        expect(recipe.total_time).toBe(45);
        expect(recipe.ingredients[0].name).toBe('Custom Ingredient');
        expect(recipe.steps).toEqual(['Custom step']);
      });

      it('should allow partial overrides to override defaults', () => {
        const recipe = createRecipe({
          title: 'Test Recipe',
          image_url: '',
          description: '',
          notes: '',
          pre_reqs: [],
          total_time: 0,
          ingredients: [
            {
              name: 'Test Ingredient',
              'ucum-unit': 'cup_us',
              'ucum-amount': 1.0,
              'metric-unit': 'g',
              'metric-amount': 100,
              notes: 'Test note'
            }
          ],
          steps: ['Step 1']
        });

        // Even with falsy overrides, the spread operator should preserve them
        expect(recipe.image_url).toBe('');
        expect(recipe.description).toBe('');
        expect(recipe.notes).toBe('');
        expect(recipe.pre_reqs).toEqual([]);
        expect(recipe.total_time).toBe(0);
      });
    });

    describe('createIngredient', () => {
      it('should create an ingredient with required fields', () => {
        const ingredient = createIngredient({
          name: 'Test Ingredient'
        });

        expect(ingredient.name).toBe('Test Ingredient');
        expect(ingredient['ucum-unit']).toBe('cup_us');
        expect(ingredient['ucum-amount']).toBe(1.0);
        expect(ingredient['metric-unit']).toBe('g');
        expect(ingredient['metric-amount']).toBe(100);
        expect(ingredient.notes).toBe('');
        expect(ingredient['allergen-code']).toBeUndefined();
      });

      it('should override default values with provided values', () => {
        const ingredient = createIngredient({
          name: 'Custom Ingredient',
          'ucum-unit': 'tbsp_us',
          'ucum-amount': 2.5,
          'metric-unit': 'ml',
          'metric-amount': 37,
          notes: 'Custom notes',
          'allergen-code': 'GLUTEN'
        });

        expect(ingredient.name).toBe('Custom Ingredient');
        expect(ingredient['ucum-unit']).toBe('tbsp_us');
        expect(ingredient['ucum-amount']).toBe(2.5);
        expect(ingredient['metric-unit']).toBe('ml');
        expect(ingredient['metric-amount']).toBe(37);
        expect(ingredient.notes).toBe('Custom notes');
        expect(ingredient['allergen-code']).toBe('GLUTEN');
      });

      it('should allow partial overrides to override defaults', () => {
        const ingredient = createIngredient({
          name: 'Test Ingredient',
          notes: '',
          'ucum-amount': 0
        });

        expect(ingredient.notes).toBe('');
        expect(ingredient['ucum-amount']).toBe(0);
      });
    });
  });

  describe('Type Definitions', () => {
    it('should properly type valid UCUM units', () => {
      const testUnits: UcumUnit[] = [
        'cup_us', 'cup_m', 'cup_imp',
        'tbsp_us', 'tbsp_m', 'tbsp_imp', 
        'tsp_us', 'tsp_m', 'tsp_imp'
      ];

      // This test mainly ensures TypeScript compilation
      expect(testUnits).toBeDefined();
      expect(testUnits.length).toBe(9);
    });

    it('should properly type valid metric units', () => {
      const testUnits: MetricUnit[] = ['ml', 'g'];

      // This test mainly ensures TypeScript compilation
      expect(testUnits).toBeDefined();
      expect(testUnits.length).toBe(2);
    });

    it('should properly type valid allergen codes', () => {
      const testAllergens: AllergenCode[] = [
        'GLUTEN', 'CRUSTACEAN', 'EGG', 'FISH', 'PEANUT', 'SOY', 'MILK', 'NUT',
        'CELERY', 'MUSTARD', 'SESAME', 'SULPHITE', 'LUPIN', 'MOLLUSC',
        'SHELLFISH', 'TREENUT', 'WHEAT'
      ];

      // This test mainly ensures TypeScript compilation
      expect(testAllergens).toBeDefined();
      expect(testAllergens.length).toBe(17);
    });

    it('should properly type valid ingredient structure', () => {
      const testIngredient: Ingredient = {
        name: 'Test Ingredient',
        'ucum-unit': 'cup_us',
        'ucum-amount': 1.0,
        'metric-unit': 'g',
        'metric-amount': 100,
        notes: 'Test note',
        'allergen-code': 'GLUTEN'
      };

      expect(testIngredient).toBeDefined();
      expect(testIngredient.name).toBe('Test Ingredient');
    });

    it('should properly type valid recipe structure', () => {
      const testRecipe: Recipe = {
        title: 'Test Recipe',
        image_url: 'https://example.com/image.jpg',
        description: 'Test description',
        notes: 'Test notes',
        pre_reqs: ['Prerequisite 1'],
        total_time: 30,
        ingredients: [
          {
            name: 'Test Ingredient',
            'ucum-unit': 'cup_us',
            'ucum-amount': 1.0,
            'metric-unit': 'g',
            'metric-amount': 100,
            notes: 'Test note'
          }
        ],
        steps: ['Step 1', 'Step 2']
      };

      expect(testRecipe).toBeDefined();
      expect(testRecipe.title).toBe('Test Recipe');
    });
  });
});