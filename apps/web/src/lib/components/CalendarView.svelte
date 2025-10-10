<script lang="ts">
  import { onMount } from 'svelte'
  import { writable, derived } from 'svelte/store'
  import { format, addWeeks, startOfWeek, addDays } from 'date-fns'
  import AddMealDialog from './AddMealDialog.svelte'
  import type { Recipe } from '@mealplanner/recipe-database'
  
  // Calendar state
  type PlannedMeal = {
    id: string
    recipe: Recipe
    date: Date
    icon: string
    accentColor: string
  }
  
  const plannedMeals = writable<PlannedMeal[]>([])
  const showAddDialog = writable(false)
  const selectedDate = writable<Date | null>(null)
  const baseDate = writable(startOfWeek(new Date(), { weekStartsOn: 1 }))
  
  // Generate 4 weeks from base date
  const weeks = derived(baseDate, ($baseDate) => {
    return Array.from({ length: 4 }, (_, weekIndex) => {
      const weekStart = addWeeks($baseDate, weekIndex)
      const days = Array.from({ length: 7 }, (_, dayIndex) => 
        addDays(weekStart, dayIndex)
      )
      return { weekStart, days, weekNumber: weekIndex + 1 }
    })
  })
  
  // Total meals count
  const totalMeals = derived(plannedMeals, ($meals) => $meals.length)
  
  // Group meals by date
  const mealsByDate = derived(plannedMeals, ($meals) => {
    const grouped = new Map<string, PlannedMeal[]>()
    $meals.forEach(meal => {
      const key = format(meal.date, 'yyyy-MM-dd')
      if (!grouped.has(key)) {
        grouped.set(key, [])
      }
      grouped.get(key)!.push(meal)
    })
    return grouped
  })
  
  function openAddDialog(date: Date) {
    selectedDate.set(date)
    showAddDialog.set(true)
  }
  
  function closeAddDialog() {
    showAddDialog.set(false)
    selectedDate.set(null)
  }
  
  function addMealToCalendar(recipe: Recipe) {
    if (!$selectedDate) return
    
    const newMeal: PlannedMeal = {
      id: `meal-${Date.now()}`,
      recipe,
      date: $selectedDate,
      icon: '🍽️',
      accentColor: 'green'
    }
    
    plannedMeals.update(meals => [...meals, newMeal])
    closeAddDialog()
  }
  
  function removeMeal(mealId: string) {
    plannedMeals.update(meals => meals.filter(m => m.id !== mealId))
  }
  
  function resetCalendar() {
    plannedMeals.set([])
  }
  
  function saveCalendar() {
    const data = JSON.stringify($plannedMeals)
    localStorage.setItem('mealplanner-calendar', data)
    alert('Calendar saved!')
  }
  
  // Load saved calendar on mount
  onMount(() => {
    const saved = localStorage.getItem('mealplanner-calendar')
    if (saved) {
      try {
        const data = JSON.parse(saved)
        plannedMeals.set(data.map((m: any) => ({
          ...m,
          date: new Date(m.date)
        })))
      } catch (e) {
        console.error('Failed to load calendar:', e)
      }
    }
  })
</script>

<div class="min-h-screen bg-gray-50">
  <!-- Header -->
  <header class="bg-white border-b border-gray-200 sticky top-0 z-10">
    <div class="max-w-7xl mx-auto px-4 py-4 flex items-center justify-between">
      <div class="flex items-center gap-3">
        <button class="p-2 hover:bg-gray-100 rounded-lg transition">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
          </svg>
        </button>
        <h1 class="text-xl font-semibold text-gray-900">MealPlanner Calendar View</h1>
      </div>
      <button 
        on:click={saveCalendar}
        class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition font-medium"
      >
        Save
      </button>
    </div>
  </header>

  <!-- Calendar Content -->
  <main class="max-w-7xl mx-auto px-4 py-6">
    {#each $weeks as { weekStart, days, weekNumber }}
      <div class="mb-8">
        <!-- Week Header -->
        <div class="flex items-center justify-between mb-4">
          <div class="flex items-center gap-3">
            <h2 class="text-lg font-medium text-gray-900">
              {format(weekStart, 'd MMM')} - {format(addDays(weekStart, 6), 'd MMM')}
            </h2>
            <span class="px-2 py-1 bg-black text-white text-xs font-medium rounded">
              WEEK {weekNumber}
            </span>
          </div>
          <button 
            on:click={resetCalendar}
            class="flex items-center gap-2 px-3 py-1.5 text-gray-600 hover:bg-gray-100 rounded-lg transition"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
            </svg>
            <span class="text-sm">Reset</span>
          </button>
        </div>
        
        <p class="text-sm text-gray-500 mb-4">Total: {$totalMeals} activities</p>

        <!-- Days Grid -->
        <div class="grid grid-cols-7 gap-3">
          {#each days as day}
            {@const dateKey = format(day, 'yyyy-MM-dd')}
            {@const dayMeals = $mealsByDate.get(dateKey) || []}
            
            <div class="bg-white rounded-lg border border-gray-200 overflow-hidden">
              <!-- Day Header -->
              <div class="px-3 py-2 border-b border-gray-100">
                <div class="text-xs text-gray-500 font-medium">{format(day, 'EEE').toUpperCase()}</div>
                <div class="text-lg font-semibold text-gray-900">{format(day, 'd')}</div>
              </div>
              
              <!-- Meals List -->
              <div class="p-2 space-y-2 min-h-[100px]">
                {#each dayMeals as meal (meal.id)}
                  <button
                    on:click={() => removeMeal(meal.id)}
                    class="w-full bg-green-50 rounded-lg p-2 hover:bg-green-100 transition text-left group"
                  >
                    <div class="flex items-start justify-between gap-2">
                      <div class="flex-1 min-w-0">
                        <div class="flex items-center gap-2">
                          <span class="text-sm">{meal.icon}</span>
                          <h3 class="text-sm font-medium text-gray-900 truncate">{meal.recipe.title}</h3>
                        </div>
                        <p class="text-xs text-gray-600 mt-0.5">{meal.recipe.total_time} min</p>
                      </div>
                      <svg class="w-4 h-4 text-gray-400 group-hover:text-red-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                      </svg>
                    </div>
                  </button>
                {/each}
                
                <!-- Add Button -->
                <button
                  on:click={() => openAddDialog(day)}
                  class="w-full flex items-center justify-center gap-2 p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-50 rounded-lg transition"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
                  </svg>
                  <span class="text-sm">Add</span>
                </button>
              </div>
            </div>
          {/each}
        </div>
      </div>
    {/each}
  </main>

  <!-- Add Meal Dialog -->
  {#if $showAddDialog && $selectedDate}
    <AddMealDialog
      date={$selectedDate}
      onClose={closeAddDialog}
      onSelectRecipe={addMealToCalendar}
    />
  {/if}
</div>
