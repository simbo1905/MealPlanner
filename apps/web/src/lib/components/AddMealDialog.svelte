<script lang="ts">
  import { onMount } from 'svelte'
  import { format } from 'date-fns'
  import { searchQuery, selectedTags, availableTags, filteredRecipes, setSearchQuery, addTag, removeTag, createNewTag } from '$lib/stores/recipes'
  import type { Recipe } from '@mealplanner/recipe-types'
  
  const { date, onClose, onSelectRecipe } = $props<{
    date: Date
    onClose: () => void
    onSelectRecipe: (recipe: Recipe) => void
  }>()

  const formattedDate = $derived(format(date, 'EEEE d MMM yyyy'))
  
  let showIngredientDropdown = $state(false)
  let searchInput: HTMLInputElement | null = null

  onMount(() => {
    searchInput?.focus()
  })
  
  function normalizeTagLabel(tag: string): string {
    return tag.replace(/\u00A0/g, ' ')
  }
  
  function handleKeyDown(event: KeyboardEvent) {
    const target = event.target as HTMLInputElement
    const hashMatch = target.value.match(/#([\w\u00A0]+)$/)
    
    if (!hashMatch) return

    const isModifierPressed = event.shiftKey || event.altKey || event.ctrlKey || event.metaKey
    const isWordBoundary = [' ', ',', '.', ';', '!', '?', 'Enter'].includes(event.key)

    if (event.key === ' ' && isModifierPressed) {
      event.preventDefault()
      setSearchQuery($searchQuery + '\u00A0')
      return
    }

    if (isWordBoundary) {
      event.preventDefault()
      const newTag = (hashMatch[1] ?? '').toLowerCase()
      createNewTag(newTag)
      setSearchQuery('')
    }
  }
  
  function toggleIngredientDropdown() {
    showIngredientDropdown = !showIngredientDropdown
  }
  
  function selectIngredient(tag: string) {
    addTag(tag)
    showIngredientDropdown = false
  }
  
  function handleSelectRecipe(recipe: Recipe) {
    onSelectRecipe(recipe)
    setSearchQuery('')
    selectedTags.set([])
  }
</script>

<!-- Backdrop -->
<div 
  class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
  onclick={(event) => {
    if (event.target === event.currentTarget) {
      onClose()
    }
  }}
  onkeydown={(e) => e.key === 'Escape' && onClose()}
  role="presentation"
  tabindex="-1"
>
  <!-- Dialog -->
  <div 
    class="bg-white rounded-2xl shadow-2xl max-w-2xl w-full max-h-[80vh] flex flex-col"
    role="dialog"
    aria-modal="true"
    aria-labelledby="dialog-title"
    tabindex="-1"
  >
    <!-- Header -->
    <div class="px-6 py-4 border-b border-gray-200">
      <h2 id="dialog-title" class="text-xl font-semibold text-gray-900">
        Add a Meal
        <span class="block text-sm font-normal text-gray-500 mt-1">
          {formattedDate}
        </span>
      </h2>
    </div>
    
    <!-- Search Section -->
    <div class="px-6 py-4 border-b border-gray-100 space-y-3">
      <!-- Search Input -->
      <input
        type="text"
        value={$searchQuery}
        bind:this={searchInput}
        oninput={(e) => setSearchQuery(e.currentTarget.value)}
        onkeydown={handleKeyDown}
        placeholder="Search recipes or type #ingredient..."
        class="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
      />
      
      <!-- Ingredient Dropdown Trigger & Selected Tags -->
      <div class="flex items-center gap-2 flex-wrap">
        <div class="relative">
          <button
            type="button"
            onclick={toggleIngredientDropdown}
            class="inline-flex items-center gap-2 px-3 py-1.5 border border-gray-300 rounded-lg hover:bg-gray-50 transition"
          >
            <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
            </svg>
            <span class="text-sm text-gray-700">Ingredient</span>
            <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
            </svg>
          </button>
          
          <!-- Dropdown Menu -->
          {#if showIngredientDropdown}
            <div class="absolute top-full left-0 mt-1 bg-white border border-gray-200 rounded-lg shadow-lg py-1 min-w-[150px] z-10">
              {#each $availableTags as tag}
                <button
                  type="button"
                  onclick={() => selectIngredient(tag)}
                  class="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition"
                >
                  {normalizeTagLabel(tag)}
                </button>
              {/each}
            </div>
          {/if}
        </div>
        
        <!-- Selected Tags -->
        {#each $selectedTags as tag}
          <span class="inline-flex items-center gap-2 bg-blue-50 text-blue-700 px-3 py-1 rounded-lg text-sm">
            {normalizeTagLabel(tag)}
            <button
              type="button"
              onclick={() => removeTag(tag)}
              class="hover:bg-blue-100 rounded-full p-0.5 transition"
              aria-label="Remove {normalizeTagLabel(tag)}"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </span>
        {/each}
      </div>
    </div>
    
    <!-- Recipe List -->
    <div class="flex-1 overflow-y-auto px-6 py-4">
      <div class="space-y-2">
        {#if $filteredRecipes.length === 0}
          <div class="text-center py-8 text-gray-500">
            No recipes found. Try adjusting your search.
          </div>
        {:else}
          {#each $filteredRecipes as recipe}
            <button
              type="button"
              onclick={() => handleSelectRecipe(recipe)}
              class="w-full flex items-center gap-3 p-3 hover:bg-gray-50 rounded-lg transition text-left group"
            >
              <!-- Recipe Icon -->
              <div class="flex-shrink-0 w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
                </svg>
              </div>
              
              <!-- Recipe Info -->
              <div class="flex-1 min-w-0">
                <div class="font-medium text-gray-900">{recipe.title}</div>
                <div class="text-sm text-gray-600">{recipe.total_time} min</div>
              </div>
            </button>
          {/each}
        {/if}
      </div>
    </div>
    
    <!-- Footer -->
    <div class="px-6 py-4 border-t border-gray-200">
      <button
        type="button"
        onclick={onClose}
        class="w-full flex items-center justify-center gap-2 px-4 py-2.5 bg-gray-100 hover:bg-gray-200 rounded-lg transition font-medium text-gray-700"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
        </svg>
        <span>Close</span>
      </button>
    </div>
  </div>
</div>
