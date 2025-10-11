import { writable } from 'svelte/store'

export interface Recipe {
  id: string
  title: string
  description: string
  total_time: number
  ingredients: string[]
  steps: string[]
  notes: string
  image_url?: string
}

const STORAGE_KEY = 'mealplanner_recipes'

const seedRecipes: Recipe[] = [
  {
    id: '1',
    title: 'Spaghetti Bolognese',
    description: 'Classic spaghetti with rich, savory meat sauce simmered with herbs and tomato.',
    total_time: 45,
    ingredients: ['500g ground beef', '1 onion, diced', '2 cloves garlic', '400g crushed tomatoes', 'Italian herbs'],
    steps: ['Brown the beef', 'Add onions and garlic', 'Add tomatoes and simmer 30 min', 'Cook pasta and serve'],
    notes: 'Best served with grated cheese and fresh basil.',
    image_url: 'https://example.com/images/spaghetti-bolognese.jpg'
  },
  {
    id: '2',
    title: 'Chicken Stir-Fry',
    description: 'Quick and colorful chicken stir-fry with vegetables and savory soy sauce.',
    total_time: 30,
    ingredients: ['300g chicken breast', 'Mixed vegetables', '2 tbsp soy sauce', '1 tbsp oil', 'Ginger and garlic'],
    steps: ['Cut chicken into strips', 'Heat oil in wok', 'Stir-fry chicken until cooked', 'Add vegetables and sauce'],
    notes: 'Serve immediately to keep vegetables crisp.',
    image_url: 'https://example.com/images/chicken-stirfry.jpg'
  },
  {
    id: '3',
    title: 'Fish and Chips',
    description: 'Crispy battered fish with golden fries, a classic comfort meal.',
    total_time: 40,
    ingredients: ['4 fish fillets', '1 cup flour', '1 egg', '4 potatoes', 'Oil for frying'],
    steps: ['Cut potatoes into chips', 'Make batter with flour and egg', 'Batter fish and fry until golden', 'Fry chips until crispy'],
    notes: 'Serve with tartar sauce or malt vinegar.',
    image_url: 'https://example.com/images/fish-and-chips.jpg'
  },
  {
    id: '4',
    title: 'Vegetable Curry',
    description: 'A fragrant curry packed with mixed vegetables in a rich coconut sauce.',
    total_time: 35,
    ingredients: ['Mixed vegetables', '1 can coconut milk', '2 tbsp curry paste', '1 onion', 'Rice for serving'],
    steps: ['Sauté onion', 'Add curry paste', 'Add vegetables and coconut milk', 'Simmer 20 minutes', 'Serve with rice'],
    notes: 'Adjust spice level to taste.',
    image_url: 'https://example.com/images/vegetable-curry.jpg'
  },
  {
    id: '5',
    title: 'Roasted Chicken',
    description: 'A perfectly seasoned, juicy roasted chicken with buttery flavor and tender meat.',
    total_time: 90,
    ingredients: ['1 whole chicken', 'Butter', 'Herbs (rosemary, thyme)', 'Salt and pepper', 'Lemon'],
    steps: ['Preheat oven to 425°F', 'Season chicken with herbs and butter', 'Place lemon inside cavity', 'Roast 60-70 minutes'],
    notes: 'Some people prefer to roast a whole chicken at 425°F (220°C) for 50–60 minutes to get crispier skin.',
    image_url: 'https://example.com/images/roast-chicken.jpg'
  }
]

function loadRecipes(): Recipe[] {
  try {
    const stored = localStorage.getItem(STORAGE_KEY)
    if (stored) {
      return JSON.parse(stored)
    }
  } catch (error) {
    console.error('Failed to load recipes from localStorage:', error)
  }
  return seedRecipes
}

function saveRecipes(recipes: Recipe[]): void {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(recipes))
  } catch (error) {
    console.error('Failed to save recipes to localStorage:', error)
  }
}

function createRecipeStore() {
  const { subscribe, set, update } = writable<Recipe[]>(loadRecipes())

  return {
    subscribe,
    addRecipe: (recipe: Omit<Recipe, 'id'>) => {
      update(recipes => {
        const newRecipe: Recipe = {
          ...recipe,
          id: Date.now().toString()
        }
        const updated = [...recipes, newRecipe]
        saveRecipes(updated)
        return updated
      })
    },
    deleteRecipe: (id: string) => {
      update(recipes => {
        const updated = recipes.filter(r => r.id !== id)
        saveRecipes(updated)
        return updated
      })
    },
    updateRecipe: (id: string, updates: Partial<Recipe>) => {
      update(recipes => {
        const updated = recipes.map(r => r.id === id ? { ...r, ...updates } : r)
        saveRecipes(updated)
        return updated
      })
    }
  }
}

export const recipeStore = createRecipeStore()
