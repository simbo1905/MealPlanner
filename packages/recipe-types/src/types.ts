import type {
  Recipe as GeneratedRecipe,
  Ingredient as GeneratedIngredient
} from './generated/index'

/**
 * Canonical TypeScript representations generated from the JTD schema.
 * These camel-cased forms are useful when interoping with typed codegen or
 * runtime validators that expect the generated layout.
 */
export type GeneratedRecipeType = GeneratedRecipe
export type GeneratedIngredientType = GeneratedIngredient

/**
 * Snake-cased aliases used across the MealPlanner codebase for backwards
 * compatibility. All fields map directly to the generated camel-cased
 * equivalents to ensure schema alignment.
 */
export interface Ingredient {
  name: GeneratedIngredient['name']
  'ucum-unit': GeneratedIngredient['ucumUnit']
  'ucum-amount': GeneratedIngredient['ucumAmount']
  'metric-unit': GeneratedIngredient['metricUnit']
  'metric-amount': GeneratedIngredient['metricAmount']
  notes: GeneratedIngredient['notes']
  'allergen-code'?: GeneratedIngredient['allergenCode']
}

export interface Recipe {
  title: GeneratedRecipe['title']
  image_url: GeneratedRecipe['imageUrl']
  description: GeneratedRecipe['description']
  notes: GeneratedRecipe['notes']
  pre_reqs: GeneratedRecipe['preReqs']
  total_time: GeneratedRecipe['totalTime']
  ingredients: Ingredient[]
  steps: GeneratedRecipe['steps']
  meal_type?: GeneratedRecipe['mealType']
}

/**
 * Literal unions derived from the generated types so that compile-time enums
 * always stay in sync with the schema.
 */
export type UcumUnit = GeneratedIngredient['ucumUnit']
export type MetricUnit = GeneratedIngredient['metricUnit']
export type AllergenCode = NonNullable<GeneratedIngredient['allergenCode']>
export type MealType = NonNullable<GeneratedRecipe['mealType']>

const VALID_UCUM_UNITS = new Set<UcumUnit>([
  'cup_us', 'cup_m', 'cup_imp',
  'tbsp_us', 'tbsp_m', 'tbsp_imp',
  'tsp_us', 'tsp_m', 'tsp_imp'
])

const VALID_METRIC_UNITS = new Set<MetricUnit>(['ml', 'g'])

const VALID_ALLERGEN_CODES = new Set<AllergenCode>([
  'GLUTEN', 'CRUSTACEAN', 'EGG', 'FISH', 'PEANUT', 'SOY', 'MILK', 'NUT',
  'CELERY', 'MUSTARD', 'SESAME', 'SULPHITE', 'LUPIN', 'MOLLUSC',
  'SHELLFISH', 'TREENUT', 'WHEAT'
])

const VALID_MEAL_TYPES = new Set<MealType>([
  'breakfast', 'brunch', 'lunch', 'dinner', 'snack', 'dessert'
])

/**
 * Type guard utilities remain to assist runtime validation in UI layers.
 */
export function isUcumUnit(value: unknown): value is UcumUnit {
  return typeof value === 'string' && VALID_UCUM_UNITS.has(value as UcumUnit)
}

export function isMetricUnit(value: unknown): value is MetricUnit {
  return typeof value === 'string' && VALID_METRIC_UNITS.has(value as MetricUnit)
}

export function isAllergenCode(value: unknown): value is AllergenCode {
  return typeof value === 'string' && VALID_ALLERGEN_CODES.has(value as AllergenCode)
}

export function isMealType(value: unknown): value is MealType {
  return typeof value === 'string' && VALID_MEAL_TYPES.has(value as MealType)
}

export function isIngredient(value: unknown): value is Ingredient {
  if (!value || typeof value !== 'object') return false

  const ingredient = value as Record<string, unknown>
  const ucumAmount = ingredient['ucum-amount']
  const metricAmount = ingredient['metric-amount']

  return (
    typeof ingredient.name === 'string' && ingredient.name.trim().length > 0 &&
    isUcumUnit(ingredient['ucum-unit']) &&
    typeof ucumAmount === 'number' && Number.isFinite(ucumAmount) && isMultipleOf(ucumAmount, 0.1) &&
    isMetricUnit(ingredient['metric-unit']) &&
    typeof metricAmount === 'number' && Number.isInteger(metricAmount) &&
    typeof ingredient.notes === 'string' &&
    (ingredient['allergen-code'] === undefined || isAllergenCode(ingredient['allergen-code']))
  )
}

export function isRecipe(value: unknown): value is Recipe {
  if (!value || typeof value !== 'object') return false

  const recipe = value as Record<string, unknown>

  return (
    typeof recipe.title === 'string' && recipe.title.length > 0 &&
    typeof recipe.image_url === 'string' &&
    typeof recipe.description === 'string' && recipe.description.length <= 250 &&
    typeof recipe.notes === 'string' &&
    Array.isArray(recipe.pre_reqs) && recipe.pre_reqs.every(item => typeof item === 'string') &&
    typeof recipe.total_time === 'number' && Number.isInteger(recipe.total_time) && recipe.total_time >= 1 &&
    Array.isArray(recipe.ingredients) && recipe.ingredients.length >= 1 && recipe.ingredients.every(isIngredient) &&
    Array.isArray(recipe.steps) && recipe.steps.length >= 1 && recipe.steps.every(step => typeof step === 'string' && step.trim().length > 0) &&
    (recipe.meal_type === undefined || isMealType(recipe.meal_type))
  )
}

function isMultipleOf(value: number, multiple: number): boolean {
  return Math.abs(value / multiple - Math.round(value / multiple)) < 1e-8
}

/**
 * Helper factories maintain backwards compatibility with legacy call sites.
 */
export function createIngredient(overrides: Partial<Ingredient> & Pick<Ingredient, 'name'>): Ingredient {
  return {
    name: overrides.name,
    'ucum-unit': overrides['ucum-unit'] ?? 'cup_us',
    'ucum-amount': overrides['ucum-amount'] ?? 1.0,
    'metric-unit': overrides['metric-unit'] ?? 'g',
    'metric-amount': overrides['metric-amount'] ?? 100,
    notes: overrides.notes ?? '',
    'allergen-code': overrides['allergen-code']
  }
}

export function createRecipe(overrides: Partial<Recipe> & Pick<Recipe, 'title' | 'ingredients' | 'steps'>): Recipe {
  return {
    title: overrides.title,
    image_url: overrides.image_url ?? '',
    description: overrides.description ?? '',
    notes: overrides.notes ?? '',
    pre_reqs: overrides.pre_reqs ?? [],
    total_time: overrides.total_time ?? 30,
    ingredients: overrides.ingredients,
    steps: overrides.steps,
    meal_type: overrides.meal_type
  }
}

/**
 * Conversion helpers bridge between camel-cased generated types and the
 * snake-cased structures currently persisted across the codebase.
 */
export function toGeneratedIngredient(ingredient: Ingredient): GeneratedIngredient {
  return {
    name: ingredient.name,
    ucumUnit: ingredient['ucum-unit'],
    ucumAmount: ingredient['ucum-amount'],
    metricUnit: ingredient['metric-unit'],
    metricAmount: ingredient['metric-amount'],
    notes: ingredient.notes,
    allergenCode: ingredient['allergen-code']
  }
}

export function fromGeneratedIngredient(ingredient: GeneratedIngredient): Ingredient {
  return {
    name: ingredient.name,
    'ucum-unit': ingredient.ucumUnit,
    'ucum-amount': ingredient.ucumAmount,
    'metric-unit': ingredient.metricUnit,
    'metric-amount': ingredient.metricAmount,
    notes: ingredient.notes,
    'allergen-code': ingredient.allergenCode
  }
}

export function toGeneratedRecipe(recipe: Recipe): GeneratedRecipe {
  return {
    title: recipe.title,
    imageUrl: recipe.image_url,
    description: recipe.description,
    notes: recipe.notes,
    preReqs: recipe.pre_reqs,
    totalTime: recipe.total_time,
    ingredients: recipe.ingredients.map(toGeneratedIngredient),
    steps: recipe.steps,
    mealType: recipe.meal_type
  }
}

export function fromGeneratedRecipe(recipe: GeneratedRecipe): Recipe {
  return {
    title: recipe.title,
    image_url: recipe.imageUrl,
    description: recipe.description,
    notes: recipe.notes,
    pre_reqs: recipe.preReqs,
    total_time: recipe.totalTime,
    ingredients: recipe.ingredients.map(fromGeneratedIngredient),
    steps: recipe.steps,
    meal_type: recipe.mealType
  }
}
