import { validateRecipeJson } from '@mealplanner/recipe-validator';
import { createRecipe, createIngredient, isRecipe } from '@mealplanner/recipe-types';

describe('Debug Validation Issues', () => {
  it('should debug createRecipe validation', () => {
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

    console.log('Recipe from createRecipe:', JSON.stringify(recipe, null, 2));

    const validationResult = validateRecipeJson(recipe);
    console.log('Validation Result:', validationResult);
    
    expect(validationResult.isValid).toBe(true);
  });

  it('should debug complex workflow recipe', () => {
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

    console.log('Flour ingredient:', JSON.stringify(flour, null, 2));
    console.log('Butter ingredient:', JSON.stringify(butter, null, 2));

    // Step 2: Validate individual ingredients
    const flourValidation = validateRecipeJson({
      title: 'Test',
      image_url: 'https://example.com/test.jpg',
      description: 'Test',
      notes: 'Test',
      pre_reqs: [],
      total_time: 30,
      ingredients: [flour],
      steps: ['Test step']
    });
    console.log('Flour validation:', flourValidation);

    const butterValidation = validateRecipeJson({
      title: 'Test',
      image_url: 'https://example.com/test.jpg',
      description: 'Test',
      notes: 'Test',
      pre_reqs: [],
      total_time: 30,
      ingredients: [butter],
      steps: ['Test step']
    });
    console.log('Butter validation:', butterValidation);

    // Step 3: Create recipe using type helpers
    const recipe = createRecipe({
      title: 'Complex Workflow Recipe',
      image_url: 'https://example.com/complex.jpg',
      description: 'Recipe created through complex workflow',
      total_time: 90,
      ingredients: [flour, butter],
      steps: ['Mix ingredients', 'Add wet ingredients', 'Bake']
    });

    console.log('Complex recipe:', JSON.stringify(recipe, null, 2));

    // Step 4: Validate complete recipe
    const validationResult = validateRecipeJson(recipe);
    console.log('Final validation:', validationResult);
    
    expect(validationResult.isValid).toBe(true);
  });

  it('should debug isRecipe validation for invalid recipes', () => {
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
      }
    ];

    invalidRecipes.forEach(invalidRecipe => {
      console.log('Testing invalid recipe:', JSON.stringify(invalidRecipe, null, 2));
      
      // Type validation
      const typeResult = isRecipe(invalidRecipe);
      console.log('isRecipe result:', typeResult);
      
      // JSON validation
      const validationResult = validateRecipeJson(invalidRecipe);
      console.log('validateRecipeJson result:', validationResult);
    });
  });
});