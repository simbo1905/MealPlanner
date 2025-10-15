<script lang="ts">
  console.log("[DEBUG] Svelte bootstrap start", { time: Date.now() });
  import { onMount } from "svelte";
  import { InfiniteLoader, LoaderState } from "$lib/index.js";
  import WeekSection from "$routes/lib/WeekSection.svelte";
  import RecipeForm from "$routes/lib/RecipeForm.svelte";
  import { generateCalendarWeeks, generateCalendarWeeksFromCurrent } from "$routes/lib/calendarData";
  import type { Week, Day, CalendarRecipe } from "$routes/lib/types";
  import type { Recipe } from '@mealplanner/recipe-types';

  onMount(() => {
    console.log("[DEBUG] App.svelte onMount fired");
  });

  console.log("[DEBUG] App.svelte script block executed");

  const loaderState = new LoaderState();
  let calendarWeeks = $state<Week[]>([]);
  let pageNumber = $state(1);
  let rootElement = $state<HTMLElement>();
  let activeTab = $state<'calendar' | 'new'>('calendar');
  
  calendarWeeks = generateCalendarWeeksFromCurrent(4);

  const generateId = () => Math.random().toString(36).substr(2, 9);

  const addRecipe = (date: string, recipe: Recipe) => {
    const recipeWithId: CalendarRecipe = {
      ...recipe,
      id: generateId()
    };

    const weekIndex = calendarWeeks.findIndex(week => week.days.some(day => day.date === date));
    if (weekIndex !== -1) {
      const dayIndex = calendarWeeks[weekIndex].days.findIndex(day => day.date === date);
      if (dayIndex !== -1) {
        if (!calendarWeeks[weekIndex].days[dayIndex].recipes) {
          calendarWeeks[weekIndex].days[dayIndex].recipes = [];
        }
        calendarWeeks[weekIndex].days[dayIndex].recipes!.push(recipeWithId);
        calendarWeeks[weekIndex].days[dayIndex].activities += 1;
        calendarWeeks[weekIndex].totalActivities += 1;
        calendarWeeks[weekIndex] = { ...calendarWeeks[weekIndex] };
        calendarWeeks[weekIndex].days = [...calendarWeeks[weekIndex].days];
        calendarWeeks = [...calendarWeeks];
      }
    }
  };

  const moveRecipe = (fromDate: string, toDate: string, recipeId: string) => {
    const fromWeekIndex = calendarWeeks.findIndex(week => week.days.some(day => day.date === fromDate));
    const toWeekIndex = calendarWeeks.findIndex(week => week.days.some(day => day.date === toDate));
    if (fromWeekIndex !== -1 && toWeekIndex !== -1) {
      const fromDayIndex = calendarWeeks[fromWeekIndex].days.findIndex(day => day.date === fromDate);
      const toDayIndex = calendarWeeks[toWeekIndex].days.findIndex(day => day.date === toDate);
      if (fromDayIndex !== -1 && toDayIndex !== -1) {
        const fromRecipes = calendarWeeks[fromWeekIndex].days[fromDayIndex].recipes || [];
        const recipeToMove = fromRecipes.find(recipe => recipe.id === recipeId);
        if (recipeToMove) {
          calendarWeeks[fromWeekIndex].days[fromDayIndex].recipes = fromRecipes.filter(recipe => recipe.id !== recipeId);
          calendarWeeks[fromWeekIndex].days[fromDayIndex].activities = calendarWeeks[fromWeekIndex].days[fromDayIndex].recipes!.length;
          calendarWeeks[fromWeekIndex].totalActivities = calendarWeeks[fromWeekIndex].days.reduce((sum, day) => sum + (day.recipes?.length || 0), 0);
          if (!calendarWeeks[toWeekIndex].days[toDayIndex].recipes) {
            calendarWeeks[toWeekIndex].days[toDayIndex].recipes = [];
          }
          calendarWeeks[toWeekIndex].days[toDayIndex].recipes!.push(recipeToMove);
          calendarWeeks[toWeekIndex].days[toDayIndex].activities = calendarWeeks[toWeekIndex].days[toDayIndex].recipes!.length;
          calendarWeeks[toWeekIndex].totalActivities = calendarWeeks[toWeekIndex].days.reduce((sum, day) => sum + (day.recipes?.length || 0), 0);
          calendarWeeks[fromWeekIndex] = { ...calendarWeeks[fromWeekIndex] };
          calendarWeeks[fromWeekIndex].days = [...calendarWeeks[fromWeekIndex].days];
          calendarWeeks[toWeekIndex] = { ...calendarWeeks[toWeekIndex] };
          calendarWeeks[toWeekIndex].days = [...calendarWeeks[toWeekIndex].days];
          calendarWeeks = [...calendarWeeks];
        }
      }
    }
  };

  const loadMore = async () => {
    try {
      pageNumber += 1;
      const lastWeek = calendarWeeks[calendarWeeks.length - 1];
      const lastDate = new Date(lastWeek.endDate);
      lastDate.setDate(lastDate.getDate() + 1);
      const newWeeks = generateCalendarWeeks(lastDate, 2);
      if (newWeeks.length > 0) {
        calendarWeeks.push(...newWeeks);
        loaderState.loaded();
      } else {
        if (pageNumber > 10) {
          loaderState.complete();
        } else {
          loaderState.loaded();
        }
      }
    } catch (error) {
      console.error(error);
      loaderState.error();
      pageNumber -= 1;
    }
  };

  const handleRecipeCreated = () => {
    activeTab = 'calendar';
  };
</script>

<div class="flex flex-col h-screen bg-gray-50">
  <!-- Tab Navigation -->
  <div class="bg-white border-b border-gray-200 sticky top-0 z-30">
    <div class="flex">
      <button 
        onclick={() => activeTab = 'calendar'}
        class="flex-1 px-4 py-3 text-sm font-medium transition-colors {activeTab === 'calendar' ? 'text-blue-600 border-b-2 border-blue-600' : 'text-gray-600 hover:text-gray-900'}"
      >
        Calendar
      </button>
      <button 
        onclick={() => activeTab = 'new'}
        class="flex-1 px-4 py-3 text-sm font-medium transition-colors {activeTab === 'new' ? 'text-blue-600 border-b-2 border-blue-600' : 'text-gray-600 hover:text-gray-900'}"
      >
        +New
      </button>
    </div>
  </div>

  <!-- Content -->
  <div class="flex-1 overflow-y-auto" bind:this={rootElement}>
    {#if activeTab === 'calendar'}
      <InfiniteLoader
        {loaderState}
        triggerLoad={loadMore}
        loopDetectionTimeout={7500}
        intersectionOptions={{ root: rootElement, rootMargin: "0px 0px 500px 0px" }}
      >
        {#each calendarWeeks as week (week.startDate)}
          <WeekSection {week} onAddRecipe={addRecipe} onMoveRecipe={moveRecipe} />
        {/each}
        {#snippet loading()}
          <div class="flex justify-center py-6 text-gray-400 text-sm">Loading more weeks...</div>
        {/snippet}
      </InfiniteLoader>
    {:else}
      <RecipeForm onSuccess={handleRecipeCreated} />
    {/if}
  </div>
</div>

<style>
  :global(html) {
    height: 100%;
  }
  :global(body) {
    height: 100%;
    margin: 0;
    padding: 0;
  }
</style>