/**
 * Detailed validation error for recipe JSON validation
 */
export interface ValidationError {
  /** The field that failed validation */
  field: string;
  /** The specific validation error message */
  message: string;
  /** The value that caused the error */
  value?: unknown;
  /** The expected format or type */
  expected?: string;
  /** Path to the field in the JSON structure */
  path: string;
  /** Error severity */
  severity: 'error' | 'warning';
}

/**
 * Validation result containing success status and any errors
 */
export interface ValidationResult {
  /** Whether the validation passed */
  isValid: boolean;
  /** Array of validation errors */
  errors: ValidationError[];
  /** Human-readable summary of validation result */
  summary: string;
}

/**
 * Format validation errors into human-readable messages
 */
export function formatValidationErrors(errors: ValidationError[]): string {
  if (errors.length === 0) {
    return 'No validation errors found.';
  }

  const errorGroups = groupErrorsByPath(errors);
  const lines: string[] = [];

  lines.push(`Found ${errors.length} validation error${errors.length === 1 ? '' : 's'}:`);

  for (const [path, pathErrors] of Object.entries(errorGroups)) {
    if (pathErrors.length === 1) {
      const error = pathErrors[0]!;
      lines.push(`  ❌ ${path}: ${error.message}`);
      if (error.value !== undefined) {
        lines.push(`     Received: ${JSON.stringify(error.value)}`);
      }
      if (error.expected) {
        lines.push(`     Expected: ${error.expected}`);
      }
    } else {
      lines.push(`  ❌ ${path}:`);
      for (const error of pathErrors) {
        lines.push(`     - ${error.message}`);
        if (error.value !== undefined) {
          lines.push(`       Received: ${JSON.stringify(error.value)}`);
        }
        if (error.expected) {
          lines.push(`       Expected: ${error.expected}`);
        }
      }
    }
  }

  return lines.join('\n');
}

/**
 * Group errors by their path for better organization
 */
function groupErrorsByPath(errors: ValidationError[]): Record<string, ValidationError[]> {
  const groups: Record<string, ValidationError[]> = {};
  
  for (const error of errors) {
    const path = error.path ?? 'unknown';
    if (!groups[path]) {
      groups[path] = [];
    }
    groups[path].push(error);
  }
  
  return groups;
}

/**
 * Create a validation error object
 */
export function createValidationError(
  field: string,
  message: string,
  options: {
    value?: unknown;
    expected?: string;
    path?: string;
    severity?: 'error' | 'warning';
  } = {}
): ValidationError {
  return {
    field,
    message,
    value: options.value,
    expected: options.expected,
    path: options.path || field,
    severity: options.severity || 'error'
  };
}

/**
 * Common validation error messages
 */
export const ValidationMessages = {
  // String validation
  STRING_REQUIRED: 'Field must be a string',
  STRING_MIN_LENGTH: (min: number) => `String must be at least ${min} character${min === 1 ? '' : 's'} long`,
  STRING_MAX_LENGTH: (max: number) => `String must be no more than ${max} character${max === 1 ? '' : 's'} long`,
  STRING_URI: 'String must be a valid URI',
  
  // Number validation
  NUMBER_REQUIRED: 'Field must be a number',
  NUMBER_MIN: (min: number) => `Number must be at least ${min}`,
  NUMBER_INTEGER: 'Number must be an integer',
  NUMBER_MULTIPLE: (multiple: number) => `Number must be a multiple of ${multiple}`,
  
  // Array validation
  ARRAY_REQUIRED: 'Field must be an array',
  ARRAY_MIN_ITEMS: (min: number) => `Array must contain at least ${min} item${min === 1 ? '' : 's'}`,
  ARRAY_STRING_ITEMS: 'All array items must be strings',
  
  // Object validation
  OBJECT_REQUIRED: 'Field must be an object',
  FIELD_REQUIRED: 'This field is required',
  
  // Enum validation
  ENUM_INVALID: (validValues: string[]) => `Value must be one of: ${validValues.join(', ')}`,
  
  // Recipe-specific
  RECIPE_INVALID: 'Recipe validation failed',
  INGREDIENT_INVALID: 'Ingredient validation failed',
  MISSING_REQUIRED_FIELD: 'Missing required field',
  ADDITIONAL_PROPERTIES: 'Object contains unexpected properties',
} as const;
