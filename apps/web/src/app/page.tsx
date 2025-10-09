'use client'

import { useEffect, useMemo, useState } from 'react'
import {
  RecipeDatabase,
  defaultRecipes,
  loadTags,
  addTag
} from '@mealplanner/recipe-database'
import type { Recipe } from '@mealplanner/recipe-types'

function normaliseTagLabel(tag: string) {
  return tag.replace(/\u00A0/g, ' ')
}

export default function RecipeExplorerPage() {
  const database = useMemo(() => new RecipeDatabase(defaultRecipes as Recipe[]), [])
  const [searchText, setSearchText] = useState('')
  const [selectedTags, setSelectedTags] = useState<string[]>([])
  const [availableTags, setAvailableTags] = useState<string[]>([])
  const [recipes, setRecipes] = useState<Recipe[]>([])
  const [selectedRecipe, setSelectedRecipe] = useState<Recipe | null>(null)

  useEffect(() => {
    setAvailableTags(loadTags())
  }, [])

  useEffect(() => {
    const results = database
      .searchRecipes({
        query: searchText.trim() || undefined,
        ingredients: selectedTags.length ? selectedTags : undefined,
        sortBy: 'relevance',
        limit: 50
      })
      .map(result => result.recipe)

    setRecipes(results)
    setSelectedRecipe(results.length > 0 ? results[0]! : null)
  }, [database, searchText, selectedTags])

  const handleKeyDown = (event: React.KeyboardEvent<HTMLInputElement>) => {
    const hashMatch = searchText.match(/#([\w\u00A0]+)$/)
    if (!hashMatch) {
      return
    }

    const isModifierPressed = event.shiftKey || event.altKey || event.ctrlKey || event.metaKey
    const isWordBoundary = [' ', ',', '.', ';', '!', '?', 'Enter'].includes(event.key)

    if (event.key === ' ' && isModifierPressed) {
      event.preventDefault()
      setSearchText(prev => `${prev}\u00A0`)
      return
    }

    if (isWordBoundary) {
      event.preventDefault()
      const newTag = (hashMatch[1] ?? '').toLowerCase()
      const updatedTags = addTag(newTag)
      setAvailableTags(updatedTags)
      if (!selectedTags.includes(newTag)) {
        setSelectedTags(prev => [...prev, newTag])
      }
      setSearchText('')
    }
  }

  const handleSearchChange = (value: string) => {
    setSearchText(value)
  }

  const handleAddTag = (tag: string) => {
    if (!selectedTags.includes(tag)) {
      setSelectedTags(prev => [...prev, tag])
    }
  }

  const handleRemoveTag = (tag: string) => {
    setSelectedTags(prev => prev.filter(existing => existing !== tag))
  }

  return (
    <div className="min-h-screen bg-slate-50">
      <main className="max-w-6xl mx-auto px-4 py-10">
        <header className="mb-10">
          <h1 className="text-3xl font-semibold text-slate-900">MealPlanner Recipe Explorer</h1>
          <p className="text-slate-600 mt-2 max-w-2xl">
            Search across the shared recipe catalogue, experiment with #ingredient tags, and preview full recipe details before adding them to iOS, Android or calendar flows.
          </p>
        </header>

        <section className="bg-white rounded-xl shadow-sm border border-slate-100 p-6 mb-8">
          <label className="block text-sm font-medium text-slate-700 mb-2">Search Recipes</label>
          <input
            type="text"
            value={searchText}
            onChange={event => handleSearchChange(event.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Try 'stir fry' or type #chicken to add a tag"
            className="w-full rounded-lg border border-slate-200 px-4 py-2 text-base focus:outline-none focus:ring-2 focus:ring-blue-500"
          />

          {selectedTags.length > 0 && (
            <div className="flex flex-wrap gap-2 mt-4">
              {selectedTags.map(tag => (
                <span
                  key={tag}
                  className="inline-flex items-center gap-2 bg-blue-50 text-blue-700 text-sm px-3 py-1 rounded-full"
                >
                  {normaliseTagLabel(tag)}
                  <button
                    type="button"
                    onClick={() => handleRemoveTag(tag)}
                    className="rounded-full p-1 hover:bg-blue-100"
                    aria-label={`Remove ${normaliseTagLabel(tag)}`}
                  >
                    ×
                  </button>
                </span>
              ))}
            </div>
          )}

          <div className="mt-6">
            <h2 className="text-sm font-medium text-slate-700 mb-3">Common Ingredients</h2>
            <div className="flex flex-wrap gap-2">
              {availableTags.map(tag => (
                <button
                  key={tag}
                  type="button"
                  onClick={() => handleAddTag(tag)}
                  className={`px-3 py-1 rounded-full border text-sm transition ${selectedTags.includes(tag)
                    ? 'bg-blue-600 text-white border-blue-600'
                    : 'bg-white text-slate-700 border-slate-200 hover:border-blue-400'
                  }`}
                >
                  #{normaliseTagLabel(tag)}
                </button>
              ))}
            </div>
          </div>

        </section>

        <section className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2 space-y-4">
            {recipes.length === 0 && (
              <div className="bg-white border border-dashed border-slate-200 rounded-xl p-10 text-center text-slate-500">
                No recipes match your filters yet. Adjust the search text or tags to explore the catalogue.
              </div>
            )}

            {recipes.map(recipe => (
              <button
                key={recipe.title}
                type="button"
                onClick={() => setSelectedRecipe(recipe)}
                data-testid="recipe-card"
                className={`w-full text-left bg-white border rounded-xl px-5 py-4 shadow-sm transition focus:outline-none focus:ring-2 focus:ring-blue-500 ${selectedRecipe?.title === recipe.title ? 'border-blue-500 shadow-md' : 'border-slate-200 hover:border-blue-300'}`}
              >
                <div className="flex items-start justify-between gap-4">
                  <div>
                    <h3 className="text-lg font-semibold text-slate-900">
                      {recipe.title}
                    </h3>
                    <p className="text-sm text-slate-600 mt-1">
                      {recipe.description}
                    </p>
                  </div>
                  <span className="text-sm text-slate-500 whitespace-nowrap">
                    {recipe.total_time} min
                  </span>
                </div>
                <div className="mt-3 flex flex-wrap gap-2">
                  {recipe.ingredients.slice(0, 5).map(ingredient => (
                    <span key={ingredient.name} className="text-xs bg-slate-100 text-slate-600 px-2 py-1 rounded-full">
                      {ingredient.name}
                    </span>
                  ))}
                  {recipe.ingredients.length > 5 && (
                    <span className="text-xs text-slate-500">
                      +{recipe.ingredients.length - 5} more
                    </span>
                  )}
                </div>
              </button>
            ))}
          </div>

          <aside className="bg-white border border-slate-200 rounded-xl shadow-sm p-5">
            {selectedRecipe ? (
              <div className="space-y-4">
                <div>
                  <h2 className="text-xl font-semibold text-slate-900">{selectedRecipe.title}</h2>
                  <p className="text-sm text-slate-600 mt-2">{selectedRecipe.description}</p>
                </div>

                <div>
                  <h3 className="text-sm font-medium text-slate-700 mb-2">Ingredients</h3>
                  <ul className="space-y-2 text-sm text-slate-600">
                    {selectedRecipe.ingredients.map(ingredient => (
                      <li key={`${selectedRecipe.title}-${ingredient.name}`}>
                        <span className="font-medium text-slate-700">{ingredient.name}</span>
                        {ingredient.notes && <span className="text-slate-500"> — {ingredient.notes}</span>}
                      </li>
                    ))}
                  </ul>
                </div>

                <div>
                  <h3 className="text-sm font-medium text-slate-700 mb-2">Steps</h3>
                  <ol className="list-decimal list-inside space-y-2 text-sm text-slate-600">
                    {selectedRecipe.steps.map((step, index) => (
                      <li key={`${selectedRecipe.title}-step-${index}`}>{step}</li>
                    ))}
                  </ol>
                </div>

                <div className="text-xs text-slate-500">
                  Ready to share? Hook this module into the native shells or calendar UI using the shared TypeScript contracts.
                </div>
              </div>
            ) : (
              <div className="text-center text-slate-500 text-sm">
                Select a recipe from the list to preview full details.
              </div>
            )}
          </aside>
        </section>
      </main>
    </div>
  )
}
