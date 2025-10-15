import { describe, it, expect } from 'vitest';
import {
  validateRecipeJson,
  validateIngredientJson,
  storeRecipe,
  storeIngredient,
  formatValidationResult
} from '../src/validator.js';
import {
  validRecipe,
  minimalValidRecipe,
  invalidRecipeEmptyTitle,
  invalidRecipeLongDescription,
  invalidRecipeNoIngredients,
  invalidRecipeNoSteps,
  invalidRecipeZeroTime,
  invalidRecipeInvalidImageUrl,
  validIngredient,
  validIngredientNoAllergen,
  invalidIngredientMissingField,
  invalidIngredientInvalidUcumUnit,
  invalidIngredientInvalidMetricUnit,
  invalidIngredientInvalidUcumAmount,
  invalidIngredientInvalidMetricAmount,
  invalidIngredientInvalidAllergen,
  recipeWithLongTime,
  recipeWithNonHttpImageUrl,
  recipeWithInvalidIngredient
} from './fixtures.js';

describe('recipe-validator', () => {
  describe('validateRecipeJson', () => {
    describe('Valid Recipes', () => {
      it('should validate a complete valid recipe', () => {
        const result = validateRecipeJson(validRecipe);
        
        expect(result.isValid).toBe(true);
        expect(result.errors).toHaveLength(0);
        expect(result.summary).toBe('Recipe validation passed');
      });

      it('should validate a minimal valid recipe', () => {
        const result = validateRecipeJson(minimalValidRecipe);
        
        expect(result.isValid).toBe(true);
        expect(result.errors).toHaveLength(0);
        expect(result.summary).toBe('Recipe validation passed');
      });

      it('should handle recipe with long total_time with warning', () => {
        const result = validateRecipeJson(recipeWithLongTime);
        
        expect(result.isValid).toBe(true); // Should be valid despite warning
        expect(result.errors).toHaveLength(1); // Should have 1 warning
        expect(result.errors[0].severity).toBe('warning');
        expect(result.errors[0].field).toBe('total_time');
        expect(result.summary).toContain('validation failed'); // Summary mentions the warning
      });

      it('should validate recipe with valid meal_type', () => {
        const recipeWithMealType = {
          ...validRecipe,
          meal_type: 'breakfast'
        };
        const result = validateRecipeJson(recipeWithMealType);
        
        expect(result.isValid).toBe(true);
        expect(result.errors).toHaveLength(0);
        expect(result.summary).toBe('Recipe validation passed');
      });

      it('should validate recipe without meal_type (optional field)', () => {
        const result = validateRecipeJson(validRecipe);
        
        expect(result.isValid).toBe(true);
        expect(result.errors).toHaveLength(0);
      });

      it('should validate all valid meal_type values', () => {
        const mealTypes = ['breakfast', 'brunch', 'lunch', 'dinner', 'snack', 'dessert'];
        
        mealTypes.forEach(mealType => {
          const recipeWithMealType = {
            ...validRecipe,
            meal_type: mealType
          };
          const result = validateRecipeJson(recipeWithMealType);
          
          expect(result.isValid).toBe(true);
          expect(result.errors).toHaveLength(0);
        });
      });
    });

    describe('Invalid Recipes', () => {
      it('should reject recipe with empty title', () => {
        const result = validateRecipeJson(invalidRecipeEmptyTitle);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors.some(error => error.field === 'title')).toBe(true);
        expect(result.summary).toContain('failed');
      });

      it('should reject recipe with description over 250 characters', () => {
        const result = validateRecipeJson(invalidRecipeLongDescription);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors.some(error => error.field === 'description')).toBe(true);
      });

      it('should reject recipe with no ingredients', () => {
        const result = validateRecipeJson(invalidRecipeNoIngredients);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors.some(error => error.field === 'ingredients')).toBe(true);
      });

      it('should reject recipe with no steps', () => {
        const result = validateRecipeJson(invalidRecipeNoSteps);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors.some(error => error.field === 'steps')).toBe(true);
      });

      it('should reject recipe with zero total_time', () => {
        const result = validateRecipeJson(invalidRecipeZeroTime);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors.some(error => error.field === 'total_time')).toBe(true);
      });

      it('should reject recipe with invalid image_url', () => {
        const result = validateRecipeJson(invalidRecipeInvalidImageUrl);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors.some(error => error.field === 'image_url')).toBe(true);
      });

      it('should reject recipe with non-HTTP image URL', () => {
        const result = validateRecipeJson(recipeWithNonHttpImageUrl);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors.some(error => error.field === 'image_url')).toBe(true);
      });

      it('should reject recipe with invalid ingredients', () => {
        const result = validateRecipeJson(recipeWithInvalidIngredient);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors.some(error => error.field.includes('ingredients[1]'))).toBe(true);
      });

      it('should reject recipe with invalid meal_type', () => {
        const recipeWithInvalidMealType = {
          ...validRecipe,
          meal_type: 'invalid_type'
        };
        const result = validateRecipeJson(recipeWithInvalidMealType);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors.some(error => error.field === 'meal_type')).toBe(true);
      });

      it('should reject recipe with non-string meal_type', () => {
        const recipeWithNonStringMealType = {
          ...validRecipe,
          meal_type: 123
        };
        const result = validateRecipeJson(recipeWithNonStringMealType);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors.some(error => error.field === 'meal_type')).toBe(true);
      });
    });

    describe('Edge Cases', () => {
      it('should reject null input', () => {
        const result = validateRecipeJson(null);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors[0].field).toBe('root');
      });

      it('should reject undefined input', () => {
        const result = validateRecipeJson(undefined);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors[0].field).toBe('root');
      });

      it('should reject string input', () => {
        const result = validateRecipeJson('not an object');
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors[0].field).toBe('root');
      });

      it('should reject number input', () => {
        const result = validateRecipeJson(123);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors[0].field).toBe('root');
      });

      it('should reject array input', () => {
        const result = validateRecipeJson([]);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors[0].field).toBe('root');
      });

      it('should reject empty object', () => {
        const result = validateRecipeJson({});
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
      });

      it('should handle additional properties', () => {
        const recipeWithExtraProps = {
          ...validRecipe,
          extraField: 'should not be here'
        };
        
        const result = validateRecipeJson(recipeWithExtraProps);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors.some(error => error.message.includes('unexpected properties'))).toBe(true);
      });
    });

    describe('Error Message Quality', () => {
      it('should provide clear error messages for type errors', () => {
        const invalidRecipe = {
          title: 123, // Should be string
          image_url: "https://example.com/image.jpg",
          description: "Valid description",
          notes: "Valid notes",
          pre_reqs: [],
          total_time: 30,
          ingredients: [
            {
              name: "Test ingredient",
              "ucum-unit": "cup_us",
              "ucum-amount": 1.0,
              "metric-unit": "g",
              "metric-amount": 100,
              notes: "Test note"
            }
          ],
          steps: ["Step 1"]
        };
        
        const result = validateRecipeJson(invalidRecipe);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.some(error => error.field === 'title')).toBe(true);
        expect(result.errors.find(error => error.field === 'title')?.message).toContain('string');
      });

      it('should provide clear error messages for missing required fields', () => {
        const invalidRecipe = {
          title: "Valid Title",
          // Missing image_url
          description: "Valid description",
          notes: "Valid notes",
          pre_reqs: [],
          total_time: 30,
          ingredients: [
            {
              name: "Test ingredient",
              "ucum-unit": "cup_us",
              "ucum-amount": 1.0,
              "metric-unit": "g",
              "metric-amount": 100,
              notes: "Test note"
            }
          ],
          steps: ["Step 1"]
        };
        
        const result = validateRecipeJson(invalidRecipe);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.some(error => error.message.includes('Missing required'))).toBe(true);
      });
    });
  });

  describe('validateIngredientJson', () => {
    describe('Valid Ingredients', () => {
      it('should validate a complete valid ingredient', () => {
        const result = validateIngredientJson(validIngredient);
        
        expect(result.isValid).toBe(true);
        expect(result.errors).toHaveLength(0);
        expect(result.summary).toBe('Ingredient validation passed');
      });

      it('should validate ingredient without allergen code', () => {
        const result = validateIngredientJson(validIngredientNoAllergen);
        
        expect(result.isValid).toBe(true);
        expect(result.errors).toHaveLength(0);
        expect(result.summary).toBe('Ingredient validation passed');
      });
    });

    describe('Invalid Ingredients', () => {
      it('should reject ingredient with missing required field', () => {
        const result = validateIngredientJson(invalidIngredientMissingField);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors.some(error => error.message.includes('Missing required'))).toBe(true);
      });

      it('should reject ingredient with invalid UCUM unit', () => {
        const result = validateIngredientJson(invalidIngredientInvalidUcumUnit);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors.some(error => error.field === 'ucum-unit')).toBe(true);
      });

      it('should reject ingredient with invalid metric unit', () => {
        const result = validateIngredientJson(invalidIngredientInvalidMetricUnit);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors.some(error => error.field === 'metric-unit')).toBe(true);
      });

      it('should reject ingredient with invalid UCUM amount (not multiple of 0.1)', () => {
        const result = validateIngredientJson(invalidIngredientInvalidUcumAmount);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors.some(error => error.field === 'ucum-amount')).toBe(true);
      });

      it('should reject ingredient with invalid metric amount (not integer)', () => {
        const result = validateIngredientJson(invalidIngredientInvalidMetricAmount);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors.some(error => error.field === 'metric-amount')).toBe(true);
      });

      it('should reject ingredient with invalid allergen code', () => {
        const result = validateIngredientJson(invalidIngredientInvalidAllergen);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors.some(error => error.field === 'allergen-code')).toBe(true);
      });
    });

    describe('Edge Cases', () => {
      it('should reject null input', () => {
        const result = validateIngredientJson(null);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors[0].field).toBe('root');
      });

      it('should reject undefined input', () => {
        const result = validateIngredientJson(undefined);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors[0].field).toBe('root');
      });

      it('should reject string input', () => {
        const result = validateIngredientJson('not an object');
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors[0].field).toBe('root');
      });

      it('should reject number input', () => {
        const result = validateIngredientJson(123);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors[0].field).toBe('root');
      });

      it('should reject array input', () => {
        const result = validateIngredientJson([]);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors[0].field).toBe('root');
      });

      it('should reject empty object', () => {
        const result = validateIngredientJson({});
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
      });

      it('should handle additional properties', () => {
        const ingredientWithExtraProps = {
          ...validIngredient,
          extraField: 'should not be here'
        };
        
        const result = validateIngredientJson(ingredientWithExtraProps);
        
        expect(result.isValid).toBe(false);
        expect(result.errors.length).toBeGreaterThan(0);
        expect(result.errors.some(error => error.message.includes('unexpected properties'))).toBe(true);
      });
    });
  });

  describe('storeRecipe', () => {
    it('should store valid recipe successfully', () => {
      const result = storeRecipe(validRecipe);
      
      expect(result.success).toBe(true);
      expect(result.recipe).toEqual(validRecipe);
      expect(result.errors).toHaveLength(0);
    });

    it('should reject invalid recipe', () => {
      const result = storeRecipe(invalidRecipeEmptyTitle);
      
      expect(result.success).toBe(false);
      expect(result.recipe).toBeUndefined();
      expect(result.errors.length).toBeGreaterThan(0);
    });
  });

  describe('storeIngredient', () => {
    it('should store valid ingredient successfully', () => {
      const result = storeIngredient(validIngredient);
      
      expect(result.success).toBe(true);
      expect(result.ingredient).toEqual(validIngredient);
      expect(result.errors).toHaveLength(0);
    });

    it('should reject invalid ingredient', () => {
      const result = storeIngredient(invalidIngredientMissingField);
      
      expect(result.success).toBe(false);
      expect(result.ingredient).toBeUndefined();
      expect(result.errors.length).toBeGreaterThan(0);
    });
  });

  describe('formatValidationResult', () => {
    it('should format valid result', () => {
      const result = {
        isValid: true,
        errors: [],
        summary: 'Validation passed'
      };
      
      const formatted = formatValidationResult(result);
      
      expect(formatted).toContain('✅');
      expect(formatted).toContain('Validation passed');
    });

    it('should format invalid result', () => {
      const result = {
        isValid: false,
        errors: [
          {
            field: 'title',
            message: 'Title is required',
            path: 'title',
            severity: 'error' as const
          }
        ],
        summary: 'Validation failed with 1 error'
      };
      
      const formatted = formatValidationResult(result);
      
      expect(formatted).toContain('❌');
      expect(formatted).toContain('Validation failed with 1 error');
      expect(formatted).toContain('title');
    });
  });
});
