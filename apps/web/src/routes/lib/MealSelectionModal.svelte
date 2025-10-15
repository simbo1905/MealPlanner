<script lang="ts">
  import { recipeDB } from './recipeStore.svelte';
  import type { Recipe } from '@mealplanner/recipe-types';

  let { isOpen = $bindable(), onSelectRecipe } = $props<{
    isOpen: boolean;
    onSelectRecipe: (recipe: Recipe) => void;
  }>();

  const generateId = () => Math.random().toString(36).substr(2, 9);

  let searchTerm = $state("");

  const searchResults = $derived(
    recipeDB.searchRecipes({ 
      query: searchTerm,
      sortBy: 'relevance'
    })
  );

  const handleSelectRecipe = (recipe: Recipe) => {
    onSelectRecipe(recipe);
    isOpen = false;
  };

  const handleClose = () => {
    isOpen = false;
  };

  const handleBackdropClick = (e: MouseEvent) => {
    if (e.target === e.currentTarget) {
      handleClose();
    }
  };
</script>

{#if isOpen}
  <div 
    class="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4"
    onclick={handleBackdropClick}
    role="presentation"
  >
    <div 
      role="dialog" 
      aria-labelledby="meal-modal-title"
      aria-describedby="meal-modal-description"
      class="fixed left-[50%] top-[50%] z-50 grid w-full max-w-lg translate-x-[-50%] translate-y-[-50%] gap-4 border bg-white p-6 shadow-lg duration-200 data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[state=closed]:slide-out-to-left-1/2 data-[state=closed]:slide-out-to-top-[48%] data-[state=open]:slide-in-from-left-1/2 data-[state=open]:slide-in-from-top-[48%] sm:rounded-lg sm:max-w-md"
      tabindex="-1"
      style="pointer-events: auto;"
    >
      <!-- Header -->
      <div class="flex flex-col space-y-1.5 text-center sm:text-left">
        <div class="flex items-center justify-between">
          <h2 id="meal-modal-title" class="text-lg font-semibold leading-none tracking-tight">Add a Meal</h2>
          <button 
            type="button" 
            class="absolute right-4 top-4 rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:pointer-events-none"
            onclick={handleClose}
            aria-label="Close"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-x h-4 w-4">
              <path d="M18 6 6 18"></path>
              <path d="m6 6 12 12"></path>
            </svg>
            <span class="sr-only">Close</span>
          </button>
        </div>
      </div>

      <!-- Search -->
      <div class="space-y-3">
        <input 
          type="text" 
          class="flex h-9 rounded-md border border-gray-300 bg-white px-3 py-1 text-base shadow-xs transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-blue-500 disabled:cursor-not-allowed disabled:opacity-50 md:text-sm w-full" 
          placeholder="Search recipes..." 
          bind:value={searchTerm}
        />
      </div>

      <!-- Meal list -->
      <div class="space-y-2 h-[400px] overflow-y-auto mt-4">
        {#each searchResults as result}
          <button 
            class="w-full flex items-center gap-3 p-3 rounded-lg hover:bg-gray-50 transition-colors border border-gray-100 text-left"
            onclick={() => handleSelectRecipe(result.recipe)}
          >
            <div class="w-10 h-10 bg-gray-100 rounded-lg flex items-center justify-center flex-shrink-0">
              <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-utensils w-5 h-5 text-gray-600">
                <path d="M3 2v7c0 1.1.9 2 2 2h4a2 2 0 0 0 2-2V2"></path>
                <path d="M7 2v20"></path>
                <path d="M21 15V2a5 5 0 0 0-5 5v6c0 1.1.9 2 2 2h3Zm0 0v7"></path>
              </svg>
            </div>
            <div class="flex-1 text-left">
              <div class="font-medium text-gray-900">{result.recipe.title}</div>
              <div class="text-sm text-gray-500">{result.recipe.total_time} min</div>
              {#if result.recipe.description}
                <div class="text-xs text-gray-400 mt-1 line-clamp-1">{result.recipe.description}</div>
              {/if}
            </div>
          </button>
        {/each}
        
        {#if searchResults.length === 0}
          <div class="text-center text-gray-500 py-8">
            No recipes found matching "{searchTerm}"
          </div>
        {/if}
      </div>
    </div>
  </div>
{/if}