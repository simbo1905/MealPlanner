import { describe, it, expect } from 'vitest';
import {
  formatValidationErrors,
  createValidationError,
  ValidationMessages
} from '../src/errors.js';

describe('recipe-validator errors', () => {
  describe('createValidationError', () => {
    it('should create basic validation error', () => {
      const error = createValidationError('title', 'Title is required');
      
      expect(error.field).toBe('title');
      expect(error.message).toBe('Title is required');
      expect(error.path).toBe('title');
      expect(error.severity).toBe('error');
      expect(error.value).toBeUndefined();
      expect(error.expected).toBeUndefined();
    });

    it('should create validation error with all options', () => {
      const error = createValidationError(
        'title',
        'Title is too short',
        {
          value: 'A',
          expected: 'minimum 1 characters',
          path: 'recipe.title',
          severity: 'warning'
        }
      );
      
      expect(error.field).toBe('title');
      expect(error.message).toBe('Title is too short');
      expect(error.value).toBe('A');
      expect(error.expected).toBe('minimum 1 characters');
      expect(error.path).toBe('recipe.title');
      expect(error.severity).toBe('warning');
    });

    it('should use field as default path when path not provided', () => {
      const error = createValidationError('title', 'Title error');
      
      expect(error.path).toBe('title');
    });

    it('should default to error severity when not specified', () => {
      const error = createValidationError('title', 'Title error');
      
      expect(error.severity).toBe('error');
    });
  });

  describe('formatValidationErrors', () => {
    it('should format empty errors array', () => {
      const formatted = formatValidationErrors([]);
      
      expect(formatted).toBe('No validation errors found.');
    });

    it('should format single error', () => {
      const errors = [
        createValidationError('title', 'Title is required', {
          value: '',
          expected: 'non-empty string'
        })
      ];
      
      const formatted = formatValidationErrors(errors);
      
      expect(formatted).toContain('Found 1 validation error:');
      expect(formatted).toContain('❌ title:');
      expect(formatted).toContain('Title is required');
      expect(formatted).toContain('Received: ""');
      expect(formatted).toContain('Expected: non-empty string');
    });

    it('should format multiple errors on same path', () => {
      const errors = [
        createValidationError('title', 'Title is too short', {
          value: 'A',
          expected: 'minimum 5 characters'
        }),
        createValidationError('title', 'Title should not contain numbers', {
          value: 'A123',
          expected: 'letters only'
        })
      ];
      
      const formatted = formatValidationErrors(errors);
      
      expect(formatted).toContain('Found 2 validation errors:');
      expect(formatted).toContain('❌ title:');
      expect(formatted).toContain('- Title is too short');
      expect(formatted).toContain('- Title should not contain numbers');
    });

    it('should format errors on different paths', () => {
      const errors = [
        createValidationError('title', 'Title is required'),
        createValidationError('description', 'Description is too long', {
          value: 'a'.repeat(300),
          expected: 'maximum 250 characters'
        })
      ];
      
      const formatted = formatValidationErrors(errors);
      
      expect(formatted).toContain('Found 2 validation errors:');
      expect(formatted).toContain('❌ title:');
      expect(formatted).toContain('❌ description:');
    });

    it('should handle errors without value or expected', () => {
      const errors = [
        createValidationError('ingredients', 'Array cannot be empty')
      ];
      
      const formatted = formatValidationErrors(errors);
      
      expect(formatted).toContain('❌ ingredients:');
      expect(formatted).toContain('Array cannot be empty');
      expect(formatted).not.toContain('Received:');
      expect(formatted).not.toContain('Expected:');
    });

    it('should handle nested paths', () => {
      const errors = [
        createValidationError('ingredients[0].name', 'Name is required', {
          path: 'ingredients[0].name',
          value: ''
        })
      ];
      
      const formatted = formatValidationErrors(errors);
      
      expect(formatted).toContain('❌ ingredients[0].name:');
      expect(formatted).toContain('Name is required');
    });

    it('should pluralize error count correctly', () => {
      const singleError = [createValidationError('title', 'Title error')];
      const multipleErrors = [
        createValidationError('title', 'Title error'),
        createValidationError('description', 'Description error')
      ];
      
      const singleFormatted = formatValidationErrors(singleError);
      const multipleFormatted = formatValidationErrors(multipleErrors);
      
      expect(singleFormatted).toContain('1 validation error');
      expect(multipleFormatted).toContain('2 validation errors');
    });
  });

  describe('ValidationMessages', () => {
    it('should contain all expected message types', () => {
      expect(ValidationMessages.STRING_REQUIRED).toBe('Field must be a string');
      expect(ValidationMessages.NUMBER_REQUIRED).toBe('Field must be a number');
      expect(ValidationMessages.ARRAY_REQUIRED).toBe('Field must be an array');
      expect(ValidationMessages.OBJECT_REQUIRED).toBe('Field must be an object');
      expect(ValidationMessages.FIELD_REQUIRED).toBe('This field is required');
    });

    it('should generate dynamic string length messages', () => {
      expect(ValidationMessages.STRING_MIN_LENGTH(1)).toBe('String must be at least 1 character long');
      expect(ValidationMessages.STRING_MIN_LENGTH(5)).toBe('String must be at least 5 characters long');
      
      expect(ValidationMessages.STRING_MAX_LENGTH(10)).toBe('String must be no more than 10 characters long');
      expect(ValidationMessages.STRING_MAX_LENGTH(250)).toBe('String must be no more than 250 characters long');
    });

    it('should generate dynamic number messages', () => {
      expect(ValidationMessages.NUMBER_MIN(1)).toBe('Number must be at least 1');
      expect(ValidationMessages.NUMBER_MIN(10)).toBe('Number must be at least 10');
      
      expect(ValidationMessages.NUMBER_MULTIPLE(0.1)).toBe('Number must be a multiple of 0.1');
      expect(ValidationMessages.NUMBER_MULTIPLE(1)).toBe('Number must be a multiple of 1');
    });

    it('should generate dynamic array messages', () => {
      expect(ValidationMessages.ARRAY_MIN_ITEMS(1)).toBe('Array must contain at least 1 item');
      expect(ValidationMessages.ARRAY_MIN_ITEMS(5)).toBe('Array must contain at least 5 items');
    });

    it('should generate dynamic enum messages', () => {
      const validValues = ['cup_us', 'tbsp_us', 'tsp_us'];
      expect(ValidationMessages.ENUM_INVALID(validValues)).toBe('Value must be one of: cup_us, tbsp_us, tsp_us');
    });

    it('should contain recipe-specific messages', () => {
      expect(ValidationMessages.RECIPE_INVALID).toBe('Recipe validation failed');
      expect(ValidationMessages.INGREDIENT_INVALID).toBe('Ingredient validation failed');
      expect(ValidationMessages.MISSING_REQUIRED_FIELD).toBe('Missing required field');
      expect(ValidationMessages.ADDITIONAL_PROPERTIES).toBe('Object contains unexpected properties');
    });
  });
});