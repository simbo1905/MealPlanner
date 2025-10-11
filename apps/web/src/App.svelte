<script lang="ts">
  import { writable } from 'svelte/store'
  import CalendarView from '$lib/components/CalendarView.svelte'
  import RecipeExplorer from '$lib/components/RecipeExplorer.svelte'
  
  type View = 'calendar' | 'recipes'
  const currentView = writable<View>('calendar')
</script>

<div class="min-h-screen bg-slate-50">
  <!-- Navigation Tabs -->
  <nav class="bg-white border-b border-gray-200">
    <div class="max-w-7xl mx-auto px-4">
      <div class="flex gap-8">
        <button
          onclick={() => currentView.set('calendar')}
          class={`py-4 px-2 border-b-2 font-medium text-sm transition ${
            $currentView === 'calendar'
              ? 'border-blue-600 text-blue-600'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          }`}
        >
          Calendar View
        </button>
        <button
          onclick={() => currentView.set('recipes')}
          class={`py-4 px-2 border-b-2 font-medium text-sm transition ${
            $currentView === 'recipes'
              ? 'border-blue-600 text-blue-600'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          }`}
        >
          Recipe Explorer
        </button>
      </div>
    </div>
  </nav>

  <!-- View Content -->
  {#if $currentView === 'calendar'}
    <CalendarView />
  {:else}
    <main class="min-h-screen bg-slate-50">
      <RecipeExplorer />
    </main>
  {/if}
</div>

