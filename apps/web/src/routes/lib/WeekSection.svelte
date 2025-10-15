<script lang="ts">
  import { dndzone } from 'svelte-dnd-action';
  import { flip } from 'svelte/animate';
  import type { Week, Day, CalendarRecipe, DndEvent } from './types';
  import type { Recipe } from '@mealplanner/recipe-types';
  import MealSelectionModal from './MealSelectionModal.svelte';
  
  const { week, onAddRecipe, onMoveRecipe } = $props<{ 
    week: Week; 
    onAddRecipe: (date: string, recipe: Recipe) => void;
    onMoveRecipe?: (fromDate: string, toDate: string, recipeId: string) => void;
  }>();

  const generateId = () => Math.random().toString(36).substr(2, 9);

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr);
    return date.toLocaleDateString('en-US', { day: 'numeric', month: 'short' });
  };

  const formatYear = (dateStr: string) => {
    const date = new Date(dateStr);
    return date.getFullYear();
  };

  const formatDayName = (dateStr: string) => {
    const date = new Date(dateStr);
    return date.toLocaleDateString('en-US', { weekday: 'short' });
  };

  let isModalOpen = $state(false);
  let selectedDate = $state('');

  const openRecipeModal = (date: string) => {
    selectedDate = date;
    isModalOpen = true;
  };

  const handleSelectRecipe = (recipe: Recipe) => {
    const recipeWithId: CalendarRecipe = {
      ...recipe,
      id: generateId()
    };
    onAddRecipe(selectedDate, recipeWithId);
  };

  // Drag and drop handlers
  const handleDndConsider = (e: CustomEvent<any>, date: string) => {
    const dayIndex = week.days.findIndex((day: Day) => day.date === date);
    if (dayIndex !== -1 && week.days[dayIndex].recipes) {
      week.days[dayIndex].recipes = e.detail.items as CalendarRecipe[];
      week.days = [...week.days];
    }
  };

  const handleDndFinalize = (e: CustomEvent<any>, date: string) => {
    const dayIndex = week.days.findIndex((day: Day) => day.date === date);
    if (dayIndex !== -1) {
      week.days[dayIndex].recipes = e.detail.items as CalendarRecipe[];
      week.days[dayIndex].activities = (e.detail.items as CalendarRecipe[]).length;
      
      week.totalActivities = week.days.reduce((sum: number, day: Day) => sum + (day.recipes?.length || 0), 0);
      
      week.days = [...week.days];
    }
  };
</script>

<section class="bg-white border-b border-gray-200">
  <div class="bg-white border-b border-gray-200 px-4 py-3 sticky top-0 z-20">
    <div class="flex items-center justify-between">
      <div class="flex items-center gap-3">
        <h2 class="text-lg font-semibold text-gray-900">{formatDate(week.startDate)} - {formatDate(week.endDate)} {formatYear(week.startDate)}</h2>
        <span class="bg-black text-white text-xs font-semibold px-3 py-1 rounded-full">WEEK {week.weekNumber}</span>
      </div>
      <button class="flex items-center gap-2 text-sm text-gray-600 hover:text-gray-900 transition-colors">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-rotate-ccw w-4 h-4">
          <path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"></path>
          <path d="M3 3v5h5"></path>
        </svg>
        Reset
      </button>
    </div>
    <p class="text-sm text-gray-500 mt-1">Total: {week.totalActivities} activity{week.totalActivities !== 1 ? 'ies' : 'y'}</p>
  </div>

  <!-- Days -->
  <div>
    {#each week.days as day, dayIndex}
      <div class="flex border-b border-gray-200 min-h-[80px] transition-colors">
        <div class="sticky left-0 z-10 bg-white flex flex-col justify-center items-center w-20 min-w-[80px] border-r border-gray-100 py-3">
          <div class="text-xs text-gray-400 font-medium mb-1">{formatDayName(day.date)}</div>
          <div class="flex items-center justify-center w-10 h-10 rounded-full font-semibold text-lg {dayIndex === 0 ? 'bg-black text-white' : 'text-gray-900'}">
            {new Date(day.date).getDate()}
          </div>
        </div>
        <div class="flex-1 min-w-0">
          <div class="flex gap-3 px-3 py-2 overflow-x-auto" style="scroll-snap-type: x mandatory;">
            <div 
              use:dndzone={{
                items: day.recipes || [],
                flipDurationMs: 200,
                type: 'recipe',
                dropTargetClasses: ['drag-over'],
                dropTargetStyle: { outline: '2px solid #3b82f6' },
                centreDraggedOnCursor: true
              }}
              onconsider={(e) => handleDndConsider(e, day.date)}
              onfinalize={(e) => handleDndFinalize(e, day.date)}
              class="flex gap-3 min-h-[88px] w-full"
              data-date={day.date}
            >
              {#each day.recipes || [] as recipe (recipe.id)}
                <div 
                  animate:flip={{duration: 200}}
                  role="button" 
                  tabindex="0" 
                  aria-disabled="false" 
                  aria-roledescription="draggable" 
                  class="flex-shrink-0 w-52 p-4 bg-white rounded-xl shadow-sm border border-gray-100 border-l-green-500 border-l-4 cursor-move transition-all hover:shadow-md active:scale-[0.98] scroll-snap-align-start"
                >
                  <div class="flex items-start justify-between">
                    <div class="flex-1 min-w-0">
                      <div class="flex items-center gap-2 mb-2">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-utensils w-4 h-4 text-gray-500 flex-shrink-0">
                          <path d="M3 2v7c0 1.1.9 2 2 2h4a2 2 0 0 0 2-2V2"></path>
                          <path d="M7 2v20"></path>
                          <path d="M21 15V2a5 5 0 0 0-5 5v6c0 1.1.9 2 2 2h3Zm0 0v7"></path>
                        </svg>
                        <h3 class="font-semibold text-sm text-gray-900 truncate">{recipe.title}</h3>
                      </div>
                      <div class="flex items-center gap-2">
                        <p class="text-xs text-gray-500">{recipe.total_time} min</p>
                      </div>
                    </div>
                  </div>
                </div>
              {/each}
              
              <button 
                onclick={() => openRecipeModal(day.date)}
                class="flex-shrink-0 w-36 h-[88px] rounded-xl border flex items-center gap-1 text-gray-500 hover:bg-white hover:border-white hover:text-gray-700 transition-colors scroll-snap-align-start"
                style="background-color: rgb(249, 250, 251); border-color: rgb(249, 250, 251); justify-content: flex-start; padding-left: 0.75rem;"
              >
                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-plus w-4 h-4 flex-shrink-0">
                  <path d="M5 12h14"></path>
                  <path d="M12 5v14"></path>
                </svg>
                <span class="font-medium text-sm whitespace-nowrap">Add</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    {/each}
  </div>

  <!-- Recipe Selection Modal -->
  <MealSelectionModal 
    bind:isOpen={isModalOpen}
    onSelectRecipe={handleSelectRecipe}
  />
</section>

<style>
  .drag-over {
    background-color: rgba(59, 130, 246, 0.1);
    border-radius: 8px;
    transition: background-color 0.2s ease;
  }
</style>