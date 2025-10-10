import { writable, derived } from 'svelte/store'
import { RecipeDatabase, defaultRecipes, loadTags, addTag as addTagToDb } from '@mealplanner/recipe-database'
import type { Recipe, SearchResult } from '@mealplanner/recipe-database'

// Initialize database
const db = new RecipeDatabase(defaultRecipes as Recipe[])

// Recipe store
export const recipes = writable<Recipe[]>(db.getAllRecipes())

// Search query store
export const searchQuery = writable<string>('')

// Selected ingredient tags store
export const selectedTags = writable<string[]>([])

// Available tags store
export const availableTags = writable<string[]>(loadTags())

// Derived store for filtered recipes
export const filteredRecipes = derived(
  [searchQuery, selectedTags],
  ([$searchQuery, $selectedTags]) => {
    const results = db.searchRecipes({
      query: $searchQuery.trim() || undefined,
      ingredients: $selectedTags.length > 0 ? $selectedTags : undefined,
      sortBy: 'relevance',
      limit: 50
    })
    return results.map(r => r.recipe)
  }
)

// Selected recipe store
export const selectedRecipe = writable<Recipe | null>(null)

// Set initial selected recipe when filtered recipes change
filteredRecipes.subscribe($recipes => {
  if ($recipes.length > 0) {
    selectedRecipe.set($recipes[0])
  } else {
    selectedRecipe.set(null)
  }
})

// Actions
export function setSearchQuery(query: string) {
  searchQuery.set(query)
}

export function addTag(tag: string) {
  selectedTags.update(tags => {
    if (!tags.includes(tag)) {
      return [...tags, tag]
    }
    return tags
  })
}

export function removeTag(tag: string) {
  selectedTags.update(tags => tags.filter(t => t !== tag))
}

export function createNewTag(tag: string) {
  const updatedTags = addTagToDb(tag.toLowerCase())
  availableTags.set(updatedTags)
  addTag(tag.toLowerCase())
}

export function selectRecipe(recipe: Recipe) {
  selectedRecipe.set(recipe)
}
