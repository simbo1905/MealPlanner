import * as jtd from 'jtd'
import type { Schema } from 'jtd'
import type { Recipe, Ingredient } from '@mealplanner/recipe-types'
import { recipeJtdSchema } from '@mealplanner/recipe-types/schema'
import {
  createValidationError,
  ValidationMessages,
  type ValidationError,
  type ValidationResult
} from './errors.js'

const { validate: jtdValidate } = jtd

const RECIPE_SCHEMA = recipeJtdSchema as unknown as Schema
const INGREDIENT_SCHEMA = (recipeJtdSchema.definitions?.Ingredient ?? {}) as unknown as Schema

const VALID_UCUM_UNITS = [
  'cup_us', 'cup_m', 'cup_imp',
  'tbsp_us', 'tbsp_m', 'tbsp_imp',
  'tsp_us', 'tsp_m', 'tsp_imp'
] as const

const VALID_METRIC_UNITS = ['ml', 'g'] as const
const VALID_ALLERGEN_CODES = [
  'GLUTEN', 'CRUSTACEAN', 'EGG', 'FISH', 'PEANUT', 'SOY', 'MILK', 'NUT',
  'CELERY', 'MUSTARD', 'SESAME', 'SULPHITE', 'LUPIN', 'MOLLUSC',
  'SHELLFISH', 'TREENUT', 'WHEAT'
] as const

const VALID_MEAL_TYPES = ['breakfast', 'brunch', 'lunch', 'dinner', 'snack', 'dessert'] as const

const REQUIRED_INGREDIENT_FIELDS = [
  'name',
  'ucum-unit',
  'ucum-amount',
  'metric-unit',
  'metric-amount',
  'notes'
]

const OPTIONAL_INGREDIENT_FIELDS = ['allergen-code']

const REQUIRED_RECIPE_FIELDS = [
  'title',
  'image_url',
  'description',
  'notes',
  'pre_reqs',
  'total_time',
  'ingredients',
  'steps'
]

const OPTIONAL_RECIPE_FIELDS: string[] = ['meal_type']

/**
 * Helper: determine if number is integer
 */
function isInteger(value: number): boolean {
  return Number.isInteger(value)
}

/**
 * Helper: determine if number is multiple of step (with floating tolerance)
 */
function isMultipleOf(value: number, multiple: number): boolean {
  return Math.abs((value / multiple) - Math.round(value / multiple)) < 1e-8
}

/**
 * Helper: ensure URL is HTTP/HTTPS
 */
function isHttpUrl(value: string): boolean {
  try {
    const url = new URL(value)
    return url.protocol === 'http:' || url.protocol === 'https:'
  } catch (error) {
    return false
  }
}

/**
 * Validate an ingredient object against the RFC 8927 JTD contract
 */
export function validateIngredientJson(data: unknown, path = 'root'): ValidationResult {
  const errors: ValidationError[] = []

  if (!data || typeof data !== 'object' || Array.isArray(data)) {
    errors.push(createValidationError(
      path,
      ValidationMessages.OBJECT_REQUIRED,
      { value: data, expected: 'object', path }
    ))

    return {
      isValid: false,
      errors,
      summary: 'Ingredient data must be an object'
    }
  }

  const ingredient = data as Record<string, unknown>

  const schemaErrors = jtdValidate(INGREDIENT_SCHEMA, ingredient)
  if (schemaErrors.length > 0) {
    for (const error of schemaErrors) {
      const joined = error.instancePath.join('.') || path
      errors.push(createValidationError(
        `schema:${joined}`,
        ValidationMessages.INGREDIENT_INVALID,
        { path: joined }
      ))
    }
  }

  // Detect additional properties
  const allowedFields = new Set([...REQUIRED_INGREDIENT_FIELDS, ...OPTIONAL_INGREDIENT_FIELDS])
  for (const key of Object.keys(ingredient)) {
    if (!allowedFields.has(key)) {
      errors.push(createValidationError(
        key,
        ValidationMessages.ADDITIONAL_PROPERTIES,
        {
          value: ingredient[key],
          expected: `Allowed fields: ${Array.from(allowedFields).join(', ')}`,
          path: `${path}.${key}`
        }
      ))
    }
  }

  // Ensure required fields present
  for (const field of REQUIRED_INGREDIENT_FIELDS) {
    if (!(field in ingredient)) {
      errors.push(createValidationError(
        field,
        ValidationMessages.MISSING_REQUIRED_FIELD,
        { expected: 'Required field', path: `${path}.${field}` }
      ))
    }
  }

  // Only attempt detailed validation if field exists and is correct type
  if (typeof ingredient.name !== 'string') {
    errors.push(createValidationError(
      'name',
      ValidationMessages.STRING_REQUIRED,
      { value: ingredient.name, expected: 'string', path: `${path}.name` }
    ))
  } else if (ingredient.name.trim().length === 0) {
    errors.push(createValidationError(
      'name',
      ValidationMessages.STRING_MIN_LENGTH(1),
      { value: ingredient.name, expected: 'non-empty string', path: `${path}.name` }
    ))
  }

  const ucumUnit = ingredient['ucum-unit']
  if (typeof ucumUnit !== 'string') {
    errors.push(createValidationError(
      'ucum-unit',
      ValidationMessages.STRING_REQUIRED,
      { value: ucumUnit, expected: VALID_UCUM_UNITS.join(', '), path: `${path}.ucum-unit` }
    ))
  } else if (!VALID_UCUM_UNITS.includes(ucumUnit as typeof VALID_UCUM_UNITS[number])) {
    errors.push(createValidationError(
      'ucum-unit',
      ValidationMessages.ENUM_INVALID([...VALID_UCUM_UNITS]),
      { value: ucumUnit, expected: VALID_UCUM_UNITS.join(', '), path: `${path}.ucum-unit` }
    ))
  }

  const ucumAmount = ingredient['ucum-amount']
  if (typeof ucumAmount !== 'number' || Number.isNaN(ucumAmount)) {
    errors.push(createValidationError(
      'ucum-amount',
      ValidationMessages.NUMBER_REQUIRED,
      { value: ucumAmount, expected: 'number', path: `${path}.ucum-amount` }
    ))
  } else if (!isMultipleOf(ucumAmount, 0.1)) {
    errors.push(createValidationError(
      'ucum-amount',
      ValidationMessages.NUMBER_MULTIPLE(0.1),
      { value: ucumAmount, expected: 'multiple of 0.1', path: `${path}.ucum-amount` }
    ))
  }

  const metricUnit = ingredient['metric-unit']
  if (typeof metricUnit !== 'string') {
    errors.push(createValidationError(
      'metric-unit',
      ValidationMessages.STRING_REQUIRED,
      { value: metricUnit, expected: VALID_METRIC_UNITS.join(', '), path: `${path}.metric-unit` }
    ))
  } else if (!VALID_METRIC_UNITS.includes(metricUnit as typeof VALID_METRIC_UNITS[number])) {
    errors.push(createValidationError(
      'metric-unit',
      ValidationMessages.ENUM_INVALID([...VALID_METRIC_UNITS]),
      { value: metricUnit, expected: VALID_METRIC_UNITS.join(', '), path: `${path}.metric-unit` }
    ))
  }

  const metricAmount = ingredient['metric-amount']
  if (typeof metricAmount !== 'number' || Number.isNaN(metricAmount)) {
    errors.push(createValidationError(
      'metric-amount',
      ValidationMessages.NUMBER_REQUIRED,
      { value: metricAmount, expected: 'integer', path: `${path}.metric-amount` }
    ))
  } else if (!isInteger(metricAmount)) {
    errors.push(createValidationError(
      'metric-amount',
      ValidationMessages.NUMBER_INTEGER,
      { value: metricAmount, expected: 'integer value', path: `${path}.metric-amount` }
    ))
  }

  if (typeof ingredient.notes !== 'string') {
    errors.push(createValidationError(
      'notes',
      ValidationMessages.STRING_REQUIRED,
      { value: ingredient.notes, expected: 'string', path: `${path}.notes` }
    ))
  }

  if (ingredient['allergen-code'] !== undefined) {
    const allergen = ingredient['allergen-code']
    if (typeof allergen !== 'string') {
      errors.push(createValidationError(
        'allergen-code',
        ValidationMessages.STRING_REQUIRED,
        { value: allergen, expected: VALID_ALLERGEN_CODES.join(', '), path: `${path}.allergen-code` }
      ))
    } else if (!VALID_ALLERGEN_CODES.includes(allergen as typeof VALID_ALLERGEN_CODES[number])) {
      errors.push(createValidationError(
        'allergen-code',
        ValidationMessages.ENUM_INVALID([...VALID_ALLERGEN_CODES]),
        { value: allergen, expected: VALID_ALLERGEN_CODES.join(', '), path: `${path}.allergen-code` }
      ))
    }
  }

  const hasErrors = errors.some(error => error.severity === 'error')

  return {
    isValid: !hasErrors,
    errors,
    summary: hasErrors
      ? `Ingredient validation failed with ${errors.length} error${errors.length === 1 ? '' : 's'}`
      : 'Ingredient validation passed'
  }
}

/**
 * Validate a recipe object against the RFC 8927 JTD contract
 */
export function validateRecipeJson(data: unknown, path = 'root'): ValidationResult {
  const errors: ValidationError[] = []

  if (!data || typeof data !== 'object' || Array.isArray(data)) {
    errors.push(createValidationError(
      path,
      ValidationMessages.OBJECT_REQUIRED,
      { value: data, expected: 'object', path }
    ))

    return {
      isValid: false,
      errors,
      summary: 'Recipe data must be an object'
    }
  }

  const recipe = data as Record<string, unknown>

  const schemaErrors = jtdValidate(RECIPE_SCHEMA, recipe)
  if (schemaErrors.length > 0) {
    for (const error of schemaErrors) {
      const joined = error.instancePath.join('.') || path
      errors.push(createValidationError(
        `schema:${joined}`,
        ValidationMessages.RECIPE_INVALID,
        { path: joined }
      ))
    }
  }

  // Detect additional properties
  const allowedFields = new Set([...REQUIRED_RECIPE_FIELDS, ...OPTIONAL_RECIPE_FIELDS])
  for (const key of Object.keys(recipe)) {
    if (!allowedFields.has(key)) {
      errors.push(createValidationError(
        key,
        ValidationMessages.ADDITIONAL_PROPERTIES,
        {
          value: recipe[key],
          expected: `Allowed fields: ${Array.from(allowedFields).join(', ')}`,
          path: `${path}.${key}`
        }
      ))
    }
  }

  // Ensure required fields present
  for (const field of REQUIRED_RECIPE_FIELDS) {
    if (!(field in recipe)) {
      errors.push(createValidationError(
        field,
        ValidationMessages.MISSING_REQUIRED_FIELD,
        { expected: 'Required field', path: `${path}.${field}` }
      ))
    }
  }

  if (typeof recipe.title !== 'string') {
    errors.push(createValidationError(
      'title',
      ValidationMessages.STRING_REQUIRED,
      { value: recipe.title, expected: 'non-empty string', path: `${path}.title` }
    ))
  } else if (recipe.title.trim().length === 0) {
    errors.push(createValidationError(
      'title',
      ValidationMessages.STRING_MIN_LENGTH(1),
      { value: recipe.title, expected: 'non-empty string', path: `${path}.title` }
    ))
  }

  if (typeof recipe.image_url !== 'string') {
    errors.push(createValidationError(
      'image_url',
      ValidationMessages.STRING_REQUIRED,
      { value: recipe.image_url, expected: 'http(s) URL', path: `${path}.image_url` }
    ))
  } else if (!isHttpUrl(recipe.image_url)) {
    errors.push(createValidationError(
      'image_url',
      ValidationMessages.STRING_URI,
      { value: recipe.image_url, expected: 'http(s) URL', path: `${path}.image_url` }
    ))
  }

  if (typeof recipe.description !== 'string') {
    errors.push(createValidationError(
      'description',
      ValidationMessages.STRING_REQUIRED,
      { value: recipe.description, expected: 'string', path: `${path}.description` }
    ))
  } else if (recipe.description.length > 250) {
    errors.push(createValidationError(
      'description',
      ValidationMessages.STRING_MAX_LENGTH(250),
      { value: recipe.description, expected: 'max length 250', path: `${path}.description` }
    ))
  }

  if (typeof recipe.notes !== 'string') {
    errors.push(createValidationError(
      'notes',
      ValidationMessages.STRING_REQUIRED,
      { value: recipe.notes, expected: 'string', path: `${path}.notes` }
    ))
  }

  if (!Array.isArray(recipe.pre_reqs)) {
    errors.push(createValidationError(
      'pre_reqs',
      ValidationMessages.ARRAY_REQUIRED,
      { value: recipe.pre_reqs, expected: 'string[]', path: `${path}.pre_reqs` }
    ))
  } else if (!recipe.pre_reqs.every(item => typeof item === 'string')) {
    errors.push(createValidationError(
      'pre_reqs',
      ValidationMessages.ARRAY_STRING_ITEMS,
      { value: recipe.pre_reqs, expected: 'string[]', path: `${path}.pre_reqs` }
    ))
  }

  const totalTime = recipe.total_time
  if (typeof totalTime !== 'number' || Number.isNaN(totalTime)) {
    errors.push(createValidationError(
      'total_time',
      ValidationMessages.NUMBER_REQUIRED,
      { value: totalTime, expected: 'integer >= 1', path: `${path}.total_time` }
    ))
  } else if (!isInteger(totalTime)) {
    errors.push(createValidationError(
      'total_time',
      ValidationMessages.NUMBER_INTEGER,
      { value: totalTime, expected: 'integer >= 1', path: `${path}.total_time` }
    ))
  } else if (totalTime < 1) {
    errors.push(createValidationError(
      'total_time',
      ValidationMessages.NUMBER_MIN(1),
      { value: totalTime, expected: '>= 1', path: `${path}.total_time` }
    ))
  } else if (totalTime > 1440) {
    errors.push(createValidationError(
      'total_time',
      'Total time exceeds 24 hours – confirm long-duration recipes with research lead',
      {
        value: totalTime,
        expected: '<= 1440',
        path: `${path}.total_time`,
        severity: 'warning'
      }
    ))
  }

  if (!Array.isArray(recipe.ingredients)) {
    errors.push(createValidationError(
      'ingredients',
      ValidationMessages.ARRAY_REQUIRED,
      { value: recipe.ingredients, expected: 'Ingredient[]', path: `${path}.ingredients` }
    ))
  } else if (recipe.ingredients.length === 0) {
    errors.push(createValidationError(
      'ingredients',
      ValidationMessages.ARRAY_MIN_ITEMS(1),
      { value: recipe.ingredients, expected: '>= 1 item', path: `${path}.ingredients` }
    ))
  } else {
    recipe.ingredients.forEach((ingredient, index) => {
      const ingredientPath = `${path}.ingredients[${index}]`
      const result = validateIngredientJson(ingredient, ingredientPath)
      if (!result.isValid) {
        for (const error of result.errors) {
          const resolvedPath = error.path ?? ingredientPath
          errors.push({
            ...error,
            field: resolvedPath,
            path: resolvedPath
          })
        }
      }
    })
  }

  if (!Array.isArray(recipe.steps)) {
    errors.push(createValidationError(
      'steps',
      ValidationMessages.ARRAY_REQUIRED,
      { value: recipe.steps, expected: 'string[]', path: `${path}.steps` }
    ))
  } else if (recipe.steps.length === 0) {
    errors.push(createValidationError(
      'steps',
      ValidationMessages.ARRAY_MIN_ITEMS(1),
      { value: recipe.steps, expected: '>= 1 item', path: `${path}.steps` }
    ))
  } else if (!recipe.steps.every(step => typeof step === 'string' && step.trim().length > 0)) {
    errors.push(createValidationError(
      'steps',
      ValidationMessages.ARRAY_STRING_ITEMS,
      { value: recipe.steps, expected: 'string[]', path: `${path}.steps` }
    ))
  }

  if (recipe.meal_type !== undefined) {
    const mealType = recipe.meal_type
    if (typeof mealType !== 'string') {
      errors.push(createValidationError(
        'meal_type',
        ValidationMessages.STRING_REQUIRED,
        { value: mealType, expected: VALID_MEAL_TYPES.join(', '), path: `${path}.meal_type` }
      ))
    } else if (!VALID_MEAL_TYPES.includes(mealType as typeof VALID_MEAL_TYPES[number])) {
      errors.push(createValidationError(
        'meal_type',
        ValidationMessages.ENUM_INVALID([...VALID_MEAL_TYPES]),
        { value: mealType, expected: VALID_MEAL_TYPES.join(', '), path: `${path}.meal_type` }
      ))
    }
  }

  const hasErrors = errors.some(error => error.severity === 'error')
  const errorCount = errors.filter(e => e.severity === 'error').length
  const warningCount = errors.filter(error => error.severity === 'warning').length

  let summary = hasErrors
    ? `Recipe validation failed with ${errorCount} error${errorCount === 1 ? '' : 's'}`
    : 'Recipe validation passed'

  if (warningCount > 0) {
    const warningFragment = `${warningCount} warning${warningCount === 1 ? '' : 's'}`
    summary = hasErrors
      ? `${summary} and ${warningFragment}`
      : `Recipe validation failed with ${warningFragment}`
  }

  return {
    isValid: !hasErrors,
    errors,
    summary: summary
  }
}

/**
 * Store a recipe after validation
 */
export function storeRecipe(data: unknown): { success: boolean; recipe?: Recipe; errors: ValidationError[] } {
  const result = validateRecipeJson(data)

  if (!result.isValid) {
    return {
      success: false,
      errors: result.errors
    }
  }

  return {
    success: true,
    recipe: data as Recipe,
    errors: result.errors
  }
}

/**
 * Store an ingredient after validation
 */
export function storeIngredient(data: unknown): { success: boolean; ingredient?: Ingredient; errors: ValidationError[] } {
  const result = validateIngredientJson(data)

  if (!result.isValid) {
    return {
      success: false,
      errors: result.errors
    }
  }

  return {
    success: true,
    ingredient: data as Ingredient,
    errors: result.errors
  }
}

/**
 * Format validation result for display
 */
export function formatValidationResult(result: ValidationResult): string {
  if (result.isValid && result.errors.length === 0) {
    return `✅ ${result.summary}`
  }

  const prefix = result.isValid ? '⚠️' : '❌'
  return `${prefix} ${result.summary}\n\n${result.errors.length > 0 ? result.errors.map(error => `${error.path}: ${error.message}`).join('\n') : ''}`.trim()
}
