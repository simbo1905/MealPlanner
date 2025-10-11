<script lang="ts">
  import { searchQuery, selectedTags, availableTags, filteredRecipes, selectedRecipe, setSearchQuery, addTag, removeTag, createNewTag, selectRecipe } from '$lib/stores/recipes'

  const INITIAL_BATCH = 12
  const BATCH_SIZE = 12

  const searchInputId = 'recipe-search-input'

  function normalizeTagLabel(tag: string): string {
    return tag.replace(/\u00A0/g, ' ')
  }

  let visibleCount = $state(INITIAL_BATCH)
  let listSentinel: HTMLElement | null = $state(null)
  let filterSignature = $state('')
  let observerEnabled = $state(false)

  $effect(() => {
    const signature = `${$searchQuery.trim().toLowerCase()}::${$selectedTags.join('|')}::${$filteredRecipes.length}`
    if (signature !== filterSignature) {
      filterSignature = signature
      visibleCount = Math.min(INITIAL_BATCH, $filteredRecipes.length)
    }
  })

  $effect(() => {
    const total = $filteredRecipes.length

    if (total === 0) {
      return
    }

    if (visibleCount === 0) {
      visibleCount = Math.min(INITIAL_BATCH, total)
      return
    }

    if (visibleCount > total) {
      visibleCount = total
    }
  })

  $effect(() => {
    if (!observerEnabled) return
    if (!listSentinel) return
    if ($filteredRecipes.length <= visibleCount) return

    const observer = new IntersectionObserver((entries) => {
      if (entries.some((entry) => entry.isIntersecting)) {
        visibleCount = Math.min(visibleCount + BATCH_SIZE, $filteredRecipes.length)
      }
    }, { rootMargin: '0px', threshold: 1 })

    observer.observe(listSentinel)

    return () => observer.disconnect()
  })

  $effect(() => {
    if (typeof window === 'undefined') return

    const enableObserver = () => {
      observerEnabled = true
    }

    window.addEventListener('scroll', enableObserver, { once: true })

    return () => window.removeEventListener('scroll', enableObserver)
  })

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
</script>

<main class="max-w-6xl mx-auto px-4 py-10">
  <header class="mb-10">
    <h1 class="text-3xl font-semibold text-slate-900">MealPlanner Recipe Explorer</h1>
    <p class="text-slate-600 mt-2 max-w-2xl">
      Search across the shared recipe catalogue, experiment with #ingredient tags, and preview full recipe details before adding them to iOS, Android or calendar flows.
    </p>
  </header>

  <section class="bg-white rounded-xl shadow-sm border border-slate-100 p-6 mb-8">
    <label class="block text-sm font-medium text-slate-700 mb-2" for={searchInputId}>
      Search Recipes
    </label>
    <input
      type="text"
      id={searchInputId}
      value={$searchQuery}
      oninput={(e) => setSearchQuery(e.currentTarget.value)}
      onkeydown={handleKeyDown}
      placeholder="Try 'stir fry' or type #chicken to add a tag"
      class="w-full rounded-lg border border-slate-200 px-4 py-2 text-base focus:outline-none focus:ring-2 focus:ring-blue-500"
    />

    {#if $selectedTags.length > 0}
      <div class="flex flex-wrap gap-2 mt-4">
        {#each $selectedTags as tag}
          <span class="inline-flex items-center gap-2 bg-blue-50 text-blue-700 text-sm px-3 py-1 rounded-full">
            {normalizeTagLabel(tag)}
            <button
              type="button"
              onclick={() => removeTag(tag)}
              class="rounded-full p-1 hover:bg-blue-100"
              aria-label="Remove {normalizeTagLabel(tag)}"
            >
              ×
            </button>
          </span>
        {/each}
      </div>
    {/if}

    <div class="mt-6">
      <h2 class="text-sm font-medium text-slate-700 mb-3">Common Ingredients</h2>
      <div class="flex flex-wrap gap-2">
        {#each $availableTags as tag}
          <button
            type="button"
            onclick={() => addTag(tag)}
            class={`px-3 py-1 rounded-full border text-sm transition ${
              $selectedTags.includes(tag)
                ? 'bg-blue-600 text-white border-blue-600'
                : 'bg-white text-slate-700 border-slate-200 hover:border-blue-400'
            }`}
          >
            #{normalizeTagLabel(tag)}
          </button>
        {/each}
      </div>
    </div>
  </section>

  <section class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <div class="lg:col-span-2 space-y-4">
      {#if $filteredRecipes.length === 0}
        <div class="bg-white border border-dashed border-slate-200 rounded-xl p-10 text-center text-slate-500">
          No recipes match your filters yet. Adjust the search text or tags to explore the catalogue.
        </div>
      {:else}
        {#each $filteredRecipes.slice(0, visibleCount) as recipe}
          <button
            type="button"
            onclick={() => selectRecipe(recipe)}
            class={`w-full text-left bg-white border rounded-xl px-5 py-4 shadow-sm transition focus:outline-none focus:ring-2 focus:ring-blue-500 ${
              $selectedRecipe?.title === recipe.title ? 'border-blue-500 shadow-md' : 'border-slate-200 hover:border-blue-300'
            }`}
            data-testid="recipe-card"
          >
            <div class="flex items-start justify-between gap-4">
              <div>
                <h3 class="text-lg font-semibold text-slate-900">
                  {recipe.title}
                </h3>
                <p class="text-sm text-slate-600 mt-1">
                  {recipe.description}
                </p>
              </div>
              <span class="text-sm text-slate-500 whitespace-nowrap">
                {recipe.total_time} min
              </span>
            </div>
            <div class="mt-3 flex flex-wrap gap-2">
              {#each recipe.ingredients.slice(0, 5) as ingredient}
                <span class="text-xs bg-slate-100 text-slate-600 px-2 py-1 rounded-full">
                  {ingredient.name}
                </span>
              {/each}
              {#if recipe.ingredients.length > 5}
                <span class="text-xs text-slate-500">
                  +{recipe.ingredients.length - 5} more
                </span>
              {/if}
            </div>
         </button>
        {/each}

        {#if $filteredRecipes.length > visibleCount}
          <div class="flex justify-center py-6">
            <div
              class="h-2 w-32 rounded-full bg-gradient-to-r from-slate-200 via-slate-100 to-slate-200 animate-pulse"
              bind:this={listSentinel}
              data-testid="infinite-scroll-sentinel"
              aria-hidden="true"
            ></div>
          </div>
        {:else if $filteredRecipes.length > 0}
          <div class="text-center text-slate-400 text-sm py-4">
            Showing all {$filteredRecipes.length} recipes.
          </div>
        {/if}
      {/if}
    </div>

    <aside
      class="bg-white border border-slate-200 rounded-xl shadow-sm p-5"
      aria-label="Selected recipe details"
    >
      {#if $selectedRecipe}
        <div class="space-y-4">
          <div>
            <h2 class="text-xl font-semibold text-slate-900">{$selectedRecipe.title}</h2>
            <p class="text-sm text-slate-600 mt-2">{$selectedRecipe.description}</p>
          </div>

          <div>
            <h3 class="text-sm font-medium text-slate-700 mb-2">Ingredients</h3>
            <ul class="space-y-2 text-sm text-slate-600">
              {#each $selectedRecipe.ingredients as ingredient}
                <li>
                  <span class="font-medium text-slate-700">{ingredient.name}</span>
                  {#if ingredient.notes}
                    <span class="text-slate-500"> — {ingredient.notes}</span>
                  {/if}
                </li>
              {/each}
            </ul>
          </div>

          <div>
            <h3 class="text-sm font-medium text-slate-700 mb-2">Steps</h3>
            <ol class="list-decimal list-inside space-y-2 text-sm text-slate-600">
              {#each $selectedRecipe.steps as step}
                <li>{step}</li>
              {/each}
            </ol>
          </div>

          <div class="text-xs text-slate-500">
            Ready to share? Hook this module into the native shells or calendar UI using the shared TypeScript contracts.
          </div>
        </div>
      {:else}
        <div class="text-center text-slate-500 text-sm">
          Select a recipe from the list to preview full details.
        </div>
      {/if}
    </aside>
  </section>
</main>
