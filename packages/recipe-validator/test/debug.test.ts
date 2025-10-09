import { validateRecipeJson, validateIngredientJson } from '../src/validator.js';
import { validRecipe, minimalValidRecipe, validIngredient, recipeWithLongTime } from './fixtures.js';

describe('Debug Validation Errors', () => {
  it('should show validation errors for validRecipe', () => {
    const result = validateRecipeJson(validRecipe);
    
    console.log('Validation Result:', result);
    console.log('Is Valid:', result.isValid);
    console.log('Errors:', result.errors);
    console.log('Summary:', result.summary);
    
    if (!result.isValid) {
      result.errors.forEach((error, index) => {
        console.log(`Error ${index + 1}:`, {
          field: error.field,
          message: error.message,
          value: error.value,
          expected: error.expected,
          path: error.path
        });
      });
    }
    
    expect(result.isValid).toBe(true);
  });

  it('should show validation errors for minimalValidRecipe', () => {
    const result = validateRecipeJson(minimalValidRecipe);
    
    console.log('Minimal Recipe Validation Result:', result);
    console.log('Is Valid:', result.isValid);
    console.log('Errors:', result.errors);
    console.log('Summary:', result.summary);
    
    if (!result.isValid) {
      result.errors.forEach((error, index) => {
        console.log(`Error ${index + 1}:`, {
          field: error.field,
          message: error.message,
          value: error.value,
          expected: error.expected,
          path: error.path
        });
      });
    }
    
    expect(result.isValid).toBe(true);
  });

  it('should show validation errors for ingredient with additional properties', () => {
    const ingredientWithExtraProps = {
      ...validIngredient,
      extraField: 'should not be here'
    };
    
    const result = validateIngredientJson(ingredientWithExtraProps);
    
    console.log('Ingredient with Extra Props Validation Result:', result);
    console.log('Is Valid:', result.isValid);
    console.log('Errors:', result.errors);
    console.log('Summary:', result.summary);
    
    if (!result.isValid) {
      result.errors.forEach((error, index) => {
        console.log(`Error ${index + 1}:`, {
          field: error.field,
          message: error.message,
          value: error.value,
          expected: error.expected,
          path: error.path
        });
      });
    }
    
    expect(result.isValid).toBe(false);
  });

  it('should show validation errors for recipeWithLongTime', () => {
    const result = validateRecipeJson(recipeWithLongTime);
    
    console.log('Recipe with Long Time Validation Result:', result);
    console.log('Is Valid:', result.isValid);
    console.log('Errors:', result.errors);
    console.log('Summary:', result.summary);
    
    if (!result.isValid) {
      result.errors.forEach((error, index) => {
        console.log(`Error ${index + 1}:`, {
          field: error.field,
          message: error.message,
          value: error.value,
          expected: error.expected,
          path: error.path
        });
      });
    }
    
    expect(result.isValid).toBe(true);
  });

  it('should show validation errors for recipe with additional properties', () => {
    const recipeWithExtraProps = {
      ...validRecipe,
      extraField: 'should not be here'
    };
    
    const result = validateRecipeJson(recipeWithExtraProps);
    
    console.log('Recipe with Extra Props Validation Result:', result);
    console.log('Is Valid:', result.isValid);
    console.log('Errors:', result.errors);
    console.log('Summary:', result.summary);
    
    if (!result.isValid) {
      result.errors.forEach((error, index) => {
        console.log(`Error ${index + 1}:`, {
          field: error.field,
          message: error.message,
          value: error.value,
          expected: error.expected,
          path: error.path
        });
      });
    }
    
    expect(result.isValid).toBe(false);
  });
});