import { describe, it, expect } from 'vitest'
import { validateRecipeJson, storeRecipe } from '../src/validator.js'

const sampleRecipe = {
  title: 'Integration Sample',
  image_url: 'https://example.com/sample.jpg',
  description: 'Quick sample recipe',
  notes: 'Integration test fixture',
  pre_reqs: [],
  total_time: 20,
  ingredients: [
    {
      name: 'Sample Ingredient',
      'ucum-unit': 'cup_us',
      'ucum-amount': 1.0,
      'metric-unit': 'g',
      'metric-amount': 120,
      notes: 'Example note'
    }
  ],
  steps: ['Mix', 'Serve']
}

describe('recipe-validator integration', () => {
  it('should validate and store a recipe using the new JTD guard', () => {
    const validation = validateRecipeJson(sampleRecipe)

    expect(validation.isValid).toBe(true)
    expect(validation.errors).toHaveLength(0)

    const stored = storeRecipe(sampleRecipe)

    expect(stored.success).toBe(true)
    expect(stored.recipe).toEqual(sampleRecipe)
  })

  it('should reject a recipe with bad UCUM amount precision', () => {
    const invalid = {
      ...sampleRecipe,
      ingredients: [
        {
          ...sampleRecipe.ingredients[0],
          'ucum-amount': 1.23
        }
      ]
    }

    const validation = validateRecipeJson(invalid)

    expect(validation.isValid).toBe(false)
    expect(validation.errors.some(error => error.path.includes('ucum-amount'))).toBe(true)
  })
})
