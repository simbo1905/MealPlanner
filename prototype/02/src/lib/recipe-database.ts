import { Recipe } from "./recipe-types";

const TAGS_STORAGE_KEY = "mealplanner-recipe-tags-v1";
const DEFAULT_TAGS = ["chicken", "fish", "vegetables"];

const RECIPES: Recipe[] = [
  {
    title: "Spaghetti Bolognese",
    image_url: "https://example.com/images/spaghetti-bolognese.jpg",
    description: "Classic spaghetti with rich, savoury meat sauce simmered with herbs and tomato.",
    notes: "Best served with grated cheese and fresh basil.",
    pre_reqs: ["Boil water for pasta", "Preheat pan for sauce"],
    total_time: 45,
    ingredients: [
      {
        name: "spaghetti",
        "ucum-unit": "cup_us",
        "ucum-amount": 4,
        "metric-unit": "g",
        "metric-amount": 400,
        notes: "dry pasta",
        "allergen-code": "GLUTEN",
      },
      {
        name: "minced beef",
        "ucum-unit": "cup_us",
        "ucum-amount": 2,
        "metric-unit": "g",
        "metric-amount": 300,
        notes: "browned",
      },
      {
        name: "tomato sauce",
        "ucum-unit": "cup_us",
        "ucum-amount": 2,
        "metric-unit": "ml",
        "metric-amount": 480,
        notes: "simmered with herbs",
      },
      {
        name: "onion",
        "ucum-unit": "cup_us",
        "ucum-amount": 0.5,
        "metric-unit": "g",
        "metric-amount": 75,
        notes: "chopped finely",
      },
    ],
    steps: [
      "Cook spaghetti in salted boiling water until al dente.",
      "Sauté onion until translucent, then add minced beef and brown.",
      "Add tomato sauce and simmer for 20 minutes.",
      "Combine pasta and sauce, toss to coat, and serve hot.",
    ],
  },
  {
    title: "Chicken Stir-Fry",
    image_url: "https://example.com/images/chicken-stirfry.jpg",
    description: "Quick and colourful chicken stir-fry with vegetables and savoury soy sauce.",
    notes: "Serve immediately to keep vegetables crisp.",
    pre_reqs: [
      "Prepare and chop all vegetables",
      "Heat wok or large frying pan on high heat",
    ],
    total_time: 30,
    ingredients: [
      {
        name: "chicken breast",
        "ucum-unit": "cup_us",
        "ucum-amount": 2,
        "metric-unit": "g",
        "metric-amount": 250,
        notes: "sliced thinly",
      },
      {
        name: "soy sauce",
        "ucum-unit": "tbsp_us",
        "ucum-amount": 2,
        "metric-unit": "ml",
        "metric-amount": 30,
        notes: "added for flavour",
        "allergen-code": "SOY",
      },
      {
        name: "mixed vegetables",
        "ucum-unit": "cup_us",
        "ucum-amount": 3,
        "metric-unit": "g",
        "metric-amount": 350,
        notes: "bite-sized pieces",
      },
    ],
    steps: [
      "Heat oil in a wok over high heat.",
      "Add chicken and stir-fry until nearly cooked through.",
      "Add vegetables and stir-fry for 3–4 minutes.",
      "Pour in soy sauce, toss to coat, and serve hot.",
    ],
  },
  {
    title: "Fish and Chips",
    image_url: "https://example.com/images/fish-and-chips.jpg",
    description: "Crispy battered fish with golden fries, a classic comfort meal.",
    notes: "Serve with tartar sauce or malt vinegar.",
    pre_reqs: ["Preheat oil for frying to 350°F (175°C)"],
    total_time: 40,
    ingredients: [
      {
        name: "white fish fillet",
        "ucum-unit": "cup_us",
        "ucum-amount": 2,
        "metric-unit": "g",
        "metric-amount": 300,
        notes: "cut into portions",
        "allergen-code": "FISH",
      },
      {
        name: "flour",
        "ucum-unit": "cup_us",
        "ucum-amount": 1,
        "metric-unit": "g",
        "metric-amount": 120,
        notes: "used for batter",
        "allergen-code": "GLUTEN",
      },
      {
        name: "potatoes",
        "ucum-unit": "cup_us",
        "ucum-amount": 4,
        "metric-unit": "g",
        "metric-amount": 500,
        notes: "cut into fries",
      },
    ],
    steps: [
      "Coat fish in flour and dip in batter.",
      "Fry fish until golden brown and cooked through.",
      "Fry potatoes until crisp and golden.",
      "Drain on paper towels and serve hot.",
    ],
  },
  {
    title: "Vegetable Curry",
    image_url: "https://example.com/images/vegetable-curry.jpg",
    description: "A fragrant curry packed with mixed vegetables in a rich coconut sauce.",
    notes: "Adjust spice level to taste.",
    pre_reqs: ["Chop all vegetables evenly", "Preheat saucepan over medium heat"],
    total_time: 35,
    ingredients: [
      {
        name: "mixed vegetables",
        "ucum-unit": "cup_us",
        "ucum-amount": 4,
        "metric-unit": "g",
        "metric-amount": 400,
        notes: "diced evenly",
      },
      {
        name: "coconut milk",
        "ucum-unit": "cup_us",
        "ucum-amount": 2,
        "metric-unit": "ml",
        "metric-amount": 480,
        notes: "stirred well",
      },
      {
        name: "curry paste",
        "ucum-unit": "tbsp_us",
        "ucum-amount": 2,
        "metric-unit": "g",
        "metric-amount": 40,
        notes: "added during sauté",
      },
    ],
    steps: [
      "Sauté curry paste for 1 minute to release aroma.",
      "Add vegetables and coat with paste.",
      "Pour in coconut milk and simmer until vegetables are tender.",
      "Serve hot with rice or naan.",
    ],
  },
  {
    title: "Roast Chicken",
    image_url: "https://example.com/images/roast-chicken.jpg",
    description: "A perfectly seasoned, juicy roasted chicken with buttery flavour and tender meat.",
    notes: "Some people prefer to roast a whole chicken at 425°F (220°C) for 50–60 minutes to get crispier skin.",
    pre_reqs: [
      "Preheat oven to 350°F (175°C)",
      "Remove chicken from refrigerator an hour before cooking",
    ],
    total_time: 90,
    ingredients: [
      {
        name: "whole chicken",
        "ucum-unit": "cup_us",
        "ucum-amount": 6,
        "metric-unit": "g",
        "metric-amount": 1360,
        notes: "3-pound whole chicken, giblets removed",
      },
      {
        name: "salt and black pepper",
        "ucum-unit": "tsp_us",
        "ucum-amount": 2,
        "metric-unit": "g",
        "metric-amount": 10,
        notes: "to taste",
      },
      {
        name: "onion powder",
        "ucum-unit": "tbsp_us",
        "ucum-amount": 1,
        "metric-unit": "g",
        "metric-amount": 10,
        notes: "or to taste",
      },
      {
        name: "butter",
        "ucum-unit": "cup_us",
        "ucum-amount": 0.5,
        "metric-unit": "g",
        "metric-amount": 115,
        notes: "divided, 3 tablespoons for cavity, remainder for outside",
        "allergen-code": "MILK",
      },
      {
        name: "celery",
        "ucum-unit": "cup_us",
        "ucum-amount": 0.5,
        "metric-unit": "g",
        "metric-amount": 50,
        notes: "1 stalk, leaves removed, cut into 3 or 4 pieces",
      },
    ],
    steps: [
      "Place chicken in a roasting pan and season inside and out with salt, pepper, and onion powder.",
      "Place 3 tablespoons of butter inside the cavity and spread the remaining butter over the skin.",
      "Cut celery into 3–4 pieces and place inside the cavity.",
      "Roast uncovered for about 75 minutes until juices run clear and internal temperature reaches 165°F (74°C).",
      "Remove from oven, baste with drippings, cover with foil, and rest for 30 minutes before serving.",
    ],
  },
];

export function loadTags(): string[] {
  if (typeof window === "undefined") return DEFAULT_TAGS;
  
  const stored = localStorage.getItem(TAGS_STORAGE_KEY);
  if (stored) {
    try {
      return JSON.parse(stored);
    } catch {
      return DEFAULT_TAGS;
    }
  }
  
  localStorage.setItem(TAGS_STORAGE_KEY, JSON.stringify(DEFAULT_TAGS));
  return DEFAULT_TAGS;
}

export function addTag(tag: string): string[] {
  const normalised = tag.toLowerCase().trim();
  if (!normalised) return loadTags();
  
  const currentTags = loadTags();
  if (currentTags.includes(normalised)) return currentTags;
  
  const updatedTags = [...currentTags, normalised];
  if (typeof window !== "undefined") {
    localStorage.setItem(TAGS_STORAGE_KEY, JSON.stringify(updatedTags));
  }
  return updatedTags;
}

export function removeTag(tag: string): string[] {
  const normalised = tag.toLowerCase().trim();
  const currentTags = loadTags();
  const updatedTags = currentTags.filter((t) => t !== normalised);
  
  if (typeof window !== "undefined") {
    localStorage.setItem(TAGS_STORAGE_KEY, JSON.stringify(updatedTags));
  }
  return updatedTags;
}

export function getAllRecipes(): Recipe[] {
  return RECIPES;
}

export function getRecipeById(id: string): Recipe | undefined {
  return RECIPES.find((r) => r.title.toLowerCase().replace(/\s+/g, "-") === id);
}

export function searchByText(query: string): Recipe[] {
  if (!query.trim()) return RECIPES;
  
  const lowerQuery = query.toLowerCase();
  return RECIPES.filter(
    (recipe) =>
      recipe.title.toLowerCase().includes(lowerQuery) ||
      recipe.description.toLowerCase().includes(lowerQuery)
  );
}

export function searchByIngredients(tags: string[]): Recipe[] {
  if (tags.length === 0) return RECIPES;
  
  return RECIPES.filter((recipe) =>
    recipe.ingredients.some((ingredient) =>
      tags.some((tag) => {
        const lowerTag = tag.toLowerCase();
        const lowerIngredient = ingredient.name.toLowerCase();
        
        if (lowerTag.includes('\u00A0')) {
          const pattern = lowerTag.replace(/\u00A0/g, '\\s+');
          const regex = new RegExp(pattern, 'i');
          return regex.test(lowerIngredient);
        }
        
        return lowerIngredient.includes(lowerTag);
      })
    )
  );
}

export function searchRecipes(
  textQuery?: string,
  ingredientTags?: string[]
): Recipe[] {
  const hasTextQuery = textQuery && textQuery.trim().length > 0;
  const hasTags = ingredientTags && ingredientTags.length > 0;

  if (!hasTextQuery && !hasTags) return RECIPES;

  let results = RECIPES;

  if (hasTextQuery) {
    results = searchByText(textQuery);
  }

  if (hasTags) {
    const tagResults = searchByIngredients(ingredientTags);
    results = hasTextQuery
      ? results.filter((r) => tagResults.includes(r))
      : tagResults;
  }

  return results;
}
