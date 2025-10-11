'use client'

import { useState, useEffect } from 'react'
import type { SearchResult, RecipeDatabase } from '@mealplanner/recipe-database'
import type { Recipe } from '@mealplanner/recipe-types'

interface RecipeSearchPanelProps {
  database: RecipeDatabase
  onRecipeSelect: (recipe: Recipe) => void
  onClose: () => void
}

export function RecipeSearchPanel({ database, onRecipeSelect, onClose }: RecipeSearchPanelProps) {
  const [searchQuery, setSearchQuery] = useState('')
  const [ingredientTags, setIngredientTags] = useState<string[]>([])
  const [availableIngredients, setAvailableIngredients] = useState<string[]>([])
  const [searchResults, setSearchResults] = useState<SearchResult[]>([])
  const [isLoading, setIsLoading] = useState(false)

  // Initialize available ingredients from database
  useEffect(() => {
    const ingredients = database.getAllIngredients()
    // Filter to common ingredients for tags
    const commonIngredients = ingredients.filter(ing => 
      ['chicken', 'beef', 'fish', 'vegetables', 'pasta', 'rice', 'onion', 'garlic', 'tomato'].includes(ing.toLowerCase())
    )
    setAvailableIngredients(commonIngredients)
  }, [database])

  // Perform search when query or tags change
  useEffect(() => {
    performSearch()
  }, [searchQuery, ingredientTags])

  const performSearch = () => {
    setIsLoading(true)
    
    try {
      const options = {
        query: searchQuery.trim() || undefined,
        ingredients: ingredientTags.length > 0 ? ingredientTags : undefined,
        sortBy: 'relevance' as const,
        limit: 50
      }
      
      const results = database.searchRecipes(options)
      setSearchResults(results)
    } catch (error) {
      console.error('Search error:', error)
      setSearchResults([])
    } finally {
      setIsLoading(false)
    }
  }

  const handleSearchChange = (value: string) => {
    setSearchQuery(value)
    
    // Check for #tag syntax
    const tagMatch = value.match(/#(\w+)$/)
    if (tagMatch && tagMatch[1]) {
      const tag = tagMatch[1].toLowerCase()
      if (availableIngredients.includes(tag) && !ingredientTags.includes(tag)) {
        // Remove the #tag from search and add as ingredient
        const cleanQuery = value.replace(/#\w+$/, '').trim()
        setSearchQuery(cleanQuery)
        setIngredientTags(prev => [...prev, tag])
      }
    }
  }

  const handleAddIngredient = (ingredient: string) => {
    if (!ingredientTags.includes(ingredient)) {
      setIngredientTags(prev => [...prev, ingredient])
    }
  }

  const handleRemoveIngredient = (ingredient: string) => {
    setIngredientTags(prev => prev.filter(tag => tag !== ingredient))
  }

  const handleRecipeSelect = (recipe: Recipe) => {
    onRecipeSelect(recipe)
  }

  const clearAllFilters = () => {
    setSearchQuery('')
    setIngredientTags([])
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-xl max-w-4xl w-full mx-4 max-h-[90vh] flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b">
          <h2 className="text-xl font-semibold text-gray-900">Add Recipe</h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 text-2xl font-bold"
          >
            ×
          </button>
        </div>

        {/* Search Controls */}
        <div className="p-6 border-b">
          {/* Free Text Search */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">Search Recipes</label>
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => handleSearchChange(e.target.value)}
              placeholder="Search by recipe name or description... (try #ingredient for tags)"
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          {/* Ingredient Tags */}
          <div className="mb-4">
            <div className="flex items-center justify-between mb-2">
              <label className="text-sm font-medium text-gray-700">Filter by Ingredients</label>
              <button
                onClick={clearAllFilters}
                className="text-sm text-blue-600 hover:text-blue-800"
              >
                Clear All
              </button>
            </div>
            
            {/* Current Tags */}
            {ingredientTags.length > 0 && (
              <div className="flex flex-wrap gap-2 mb-3">
                {ingredientTags.map((tag) => (
                  <span
                    key={tag}
                    className="inline-flex items-center px-3 py-1 rounded-full text-sm bg-blue-100 text-blue-800"
                  >
                    {tag}
                    <button
                      onClick={() => handleRemoveIngredient(tag)}
                      className="ml-2 text-blue-600 hover:text-blue-800"
                    >
                      ×
                    </button>
                  </span>
                ))}
              </div>
            )}
            
            {/* Add Ingredient Buttons */}
            <div className="flex flex-wrap gap-2">
              {availableIngredients.map((ingredient) => (
                <button
                  key={ingredient}
                  onClick={() => handleAddIngredient(ingredient)}
                  disabled={ingredientTags.includes(ingredient)}
                  className={`px-3 py-1 rounded-full text-sm transition-colors ${
                    ingredientTags.includes(ingredient)
                      ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                      : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
                  }`}
                >
                  + {ingredient}
                </button>
              ))}
            </div>
          </div>

          {/* Search Stats */}
          <div className="text-sm text-gray-600">
            Found {searchResults.length} recipes
            {ingredientTags.length > 0 && ` with ${ingredientTags.length} ingredient filters`}
          </div>
        </div>

        {/* Search Results */}
        <div className="flex-1 overflow-y-auto p-6">
          {isLoading ? (
            <div className="flex items-center justify-center h-32">
              <div className="text-gray-500">Searching recipes...</div>
            </div>
          ) : searchResults.length === 0 ? (
            <div className="text-center text-gray-500 py-8">
              <p className="mb-2">No recipes found matching your criteria.</p>
              <p className="text-sm">Try adjusting your search terms or ingredient filters.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {searchResults.map((result) => (
                <div
                  key={result.recipe.title}
                  className="border rounded-lg p-4 hover:shadow-md transition-shadow cursor-pointer"
                  onClick={() => handleRecipeSelect(result.recipe)}
                >
                  <div className="flex items-start justify-between mb-2">
                    <h4 className="font-medium text-gray-900">{result.recipe.title}</h4>
                    <div className="text-xs text-gray-500">
                      {result.score.toFixed(1)} score
                    </div>
                  </div>
                  
                  <p className="text-sm text-gray-600 mb-3">{result.recipe.description}</p>
                  
                  <div className="flex items-center justify-between text-xs text-gray-500">
                    <div className="flex items-center gap-3">
                      <span>⏱️ {result.recipe.total_time} min</span>
                      <span>📝 {result.recipe.ingredients.length} ingredients</span>
                    </div>
                    <div className="text-blue-600">
                      Select →
                    </div>
                  </div>
                  
                  {result.matchedFields.length > 0 && (
                    <div className="mt-2 text-xs text-green-600">
                      Matched: {result.matchedFields.join(', ')}
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}