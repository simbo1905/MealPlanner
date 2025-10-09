import { Recipe, Ingredient } from "@mealplanner/recipe-types";

// Valid recipe fixtures
export const validRecipe: Recipe = {
  title: "Chocolate Chip Cookies",
  image_url: "https://example.com/cookies.jpg",
  description: "Classic homemade chocolate chip cookies that are crispy on the outside and chewy on the inside.",
  notes: "Best served warm with a glass of milk. Store in airtight container for up to 5 days.",
  pre_reqs: ["Preheat oven to 375°F (190°C)", "Line baking sheets with parchment paper"],
  total_time: 45,
  ingredients: [
    {
      name: "All-purpose flour",
      "ucum-unit": "cup_us",
      "ucum-amount": 2.2,
      "metric-unit": "g",
      "metric-amount": 281,
      notes: "Sifted",
      "allergen-code": "GLUTEN"
    },
    {
      name: "Butter",
      "ucum-unit": "cup_us",
      "ucum-amount": 1.0,
      "metric-unit": "g",
      "metric-amount": 227,
      notes: "Unsalted, softened to room temperature",
      "allergen-code": "MILK"
    },
    {
      name: "Granulated sugar",
      "ucum-unit": "cup_us",
      "ucum-amount": 0.7,
      "metric-unit": "g",
      "metric-amount": 150,
      notes: "Regular white sugar"
    },
    {
      name: "Eggs",
      "ucum-unit": "cup_us",
      "ucum-amount": 0.5,
      "metric-unit": "g",
      "metric-amount": 100,
      notes: "Large eggs, room temperature",
      "allergen-code": "EGG"
    },
    {
      name: "Vanilla extract",
      "ucum-unit": "tsp_us",
      "ucum-amount": 2.0,
      "metric-unit": "ml",
      "metric-amount": 10,
      notes: "Pure vanilla extract"
    },
    {
      name: "Baking soda",
      "ucum-unit": "tsp_us",
      "ucum-amount": 1.0,
      "metric-unit": "g",
      "metric-amount": 6,
      notes: "Fresh baking soda"
    },
    {
      name: "Salt",
      "ucum-unit": "tsp_us",
      "ucum-amount": 1.0,
      "metric-unit": "g",
      "metric-amount": 6,
      notes: "Fine sea salt"
    },
    {
      name: "Chocolate chips",
      "ucum-unit": "cup_us",
      "ucum-amount": 2.0,
      "metric-unit": "g",
      "metric-amount": 340,
      notes: "Semi-sweet chocolate chips"
    }
  ],
  steps: [
    "Preheat oven to 375°F (190°C). Line baking sheets with parchment paper.",
    "In a medium bowl, whisk together flour, baking soda, and salt. Set aside.",
    "In a large bowl, cream together softened butter, granulated sugar, and brown sugar until light and fluffy.",
    "Beat in eggs one at a time, then stir in vanilla extract.",
    "Gradually mix in the flour mixture until just combined.",
    "Fold in chocolate chips.",
    "Drop rounded tablespoons of dough onto prepared baking sheets, spacing them 2 inches apart.",
    "Bake for 9-11 minutes, or until golden brown around the edges.",
    "Cool on baking sheet for 5 minutes before transferring to a wire rack to cool completely."
  ]
};

export const minimalValidRecipe: Recipe = {
  title: "Simple Recipe",
  image_url: "https://example.com/simple.jpg",
  description: "",
  notes: "",
  pre_reqs: [],
  total_time: 1,
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
  steps: ["Just one step"]
};

// Invalid recipe fixtures
export const invalidRecipeEmptyTitle = {
  title: "",
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

export const invalidRecipeLongDescription = {
  title: "Valid Title",
  image_url: "https://example.com/image.jpg",
  description: "a".repeat(251), // 251 characters, exceeds maxLength of 250
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

export const invalidRecipeNoIngredients = {
  title: "Valid Title",
  image_url: "https://example.com/image.jpg",
  description: "Valid description",
  notes: "Valid notes",
  pre_reqs: [],
  total_time: 30,
  ingredients: [], // Empty array, violates minItems: 1
  steps: ["Step 1"]
};

export const invalidRecipeNoSteps = {
  title: "Valid Title",
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
  steps: [] // Empty array, violates minItems: 1
};

export const invalidRecipeZeroTime = {
  title: "Valid Title",
  image_url: "https://example.com/image.jpg",
  description: "Valid description",
  notes: "Valid notes",
  pre_reqs: [],
  total_time: 0, // Zero time, violates minimum: 1
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

export const invalidRecipeInvalidImageUrl = {
  title: "Valid Title",
  image_url: "not-a-valid-url",
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

// Valid ingredient fixtures
export const validIngredient: Ingredient = {
  name: "All-purpose flour",
  "ucum-unit": "cup_us",
  "ucum-amount": 2.2,
  "metric-unit": "g",
  "metric-amount": 281,
  notes: "Sifted before measuring",
  "allergen-code": "GLUTEN"
};

export const validIngredientNoAllergen: Ingredient = {
  name: "Granulated sugar",
  "ucum-unit": "cup_us",
  "ucum-amount": 1.0,
  "metric-unit": "g",
  "metric-amount": 200,
  notes: "Regular white sugar"
};

// Invalid ingredient fixtures
export const invalidIngredientMissingField = {
  name: "Test ingredient",
  "ucum-unit": "cup_us",
  "ucum-amount": 1.0,
  "metric-unit": "g",
  // Missing "metric-amount" and "notes"
};

export const invalidIngredientInvalidUcumUnit = {
  name: "Test ingredient",
  "ucum-unit": "invalid_unit",
  "ucum-amount": 1.0,
  "metric-unit": "g",
  "metric-amount": 100,
  notes: "Test note"
};

export const invalidIngredientInvalidMetricUnit = {
  name: "Test ingredient",
  "ucum-unit": "cup_us",
  "ucum-amount": 1.0,
  "metric-unit": "invalid_metric",
  "metric-amount": 100,
  notes: "Test note"
};

export const invalidIngredientInvalidUcumAmount = {
  name: "Test ingredient",
  "ucum-unit": "cup_us",
  "ucum-amount": 1.15, // Not a multiple of 0.1
  "metric-unit": "g",
  "metric-amount": 100,
  notes: "Test note"
};

export const invalidIngredientInvalidMetricAmount = {
  name: "Test ingredient",
  "ucum-unit": "cup_us",
  "ucum-amount": 1.0,
  "metric-unit": "g",
  "metric-amount": 100.5, // Not an integer
  notes: "Test note"
};

export const invalidIngredientInvalidAllergen = {
  name: "Test ingredient",
  "ucum-unit": "cup_us",
  "ucum-amount": 1.0,
  "metric-unit": "g",
  "metric-amount": 100,
  notes: "Test note",
  "allergen-code": "INVALID_ALLERGEN"
};

// Edge case fixtures
export const recipeWithLongTime: Recipe = {
  title: "Fermented Recipe",
  image_url: "https://example.com/fermented.jpg",
  description: "Recipe that takes a very long time",
  notes: "Requires fermentation",
  pre_reqs: [],
  total_time: 2000, // Very long time (over 24 hours)
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

export const recipeWithNonHttpImageUrl: Recipe = {
  title: "Recipe with FTP Image",
  image_url: "ftp://example.com/image.jpg",
  description: "Recipe with FTP image URL",
  notes: "Notes",
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

export const recipeWithInvalidIngredient: Recipe = {
  title: "Recipe with Invalid Ingredient",
  image_url: "https://example.com/image.jpg",
  description: "Valid description",
  notes: "Valid notes",
  pre_reqs: [],
  total_time: 30,
  ingredients: [
    {
      name: "Valid ingredient",
      "ucum-unit": "cup_us",
      "ucum-amount": 1.0,
      "metric-unit": "g",
      "metric-amount": 100,
      notes: "Valid note"
    },
    {
      name: "Invalid ingredient",
      "ucum-unit": "invalid_unit", // Invalid unit
      "ucum-amount": 1.0,
      "metric-unit": "g",
      "metric-amount": 100,
      notes: "Invalid ingredient"
    }
  ],
  steps: ["Step 1"]
};
