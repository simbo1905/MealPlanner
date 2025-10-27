<script lang="ts">
  import { InfiniteLoader, LoaderState } from "$lib/index.js"
  import WeekSection from "$routes/lib/WeekSection.svelte"
  import ShoppingList from "$routes/lib/ShoppingList.svelte"
  import { generateCalendarWeeks, generateCalendarWeeksFromCurrent } from "$routes/lib/calendarData"
  import type { Week, Day } from "$routes/lib/types"
  import { onMount } from 'svelte'

  const loaderState = new LoaderState()
  let calendarWeeks = $state<Week[]>([])
  let pageNumber = $state(1)
  let rootElement = $state<HTMLElement>()
  let activeTab = $state<'calendar' | 'shopping'>('calendar')
  
  onMount(() => {
    if (typeof window !== 'undefined' && (window as any).__activeTab) {
      const tabController = (window as any).__activeTab
      activeTab = tabController.get()
      
      const interval = setInterval(() => {
        activeTab = tabController.get()
      }, 100)
      
      return () => clearInterval(interval)
    }
  })
  
  calendarWeeks = generateCalendarWeeksFromCurrent(4);

  const addActivity = (date: string, meal: any) => {
    const weekIndex = calendarWeeks.findIndex(week => 
      week.days.some(day => day.date === date)
    );
    
    if (weekIndex !== -1) {
      const dayIndex = calendarWeeks[weekIndex].days.findIndex(day => day.date === date);
      if (dayIndex !== -1) {
        if (!calendarWeeks[weekIndex].days[dayIndex].meals) {
          calendarWeeks[weekIndex].days[dayIndex].meals = [];
        }
        
        calendarWeeks[weekIndex].days[dayIndex].meals.push(meal);
        calendarWeeks[weekIndex].days[dayIndex].activities += 1;
        calendarWeeks[weekIndex].totalActivities += 1;
        
        calendarWeeks[weekIndex] = { ...calendarWeeks[weekIndex] };
        calendarWeeks[weekIndex].days = [...calendarWeeks[weekIndex].days];
        calendarWeeks = [...calendarWeeks];
      }
    }
  };

  const moveMeal = (fromDate: string, toDate: string, mealId: string) => {
    const fromWeekIndex = calendarWeeks.findIndex(week => 
      week.days.some(day => day.date === fromDate)
    );
    
    const toWeekIndex = calendarWeeks.findIndex(week => 
      week.days.some(day => day.date === toDate)
    );
    
    if (fromWeekIndex !== -1 && toWeekIndex !== -1) {
      const fromDayIndex = calendarWeeks[fromWeekIndex].days.findIndex(day => day.date === fromDate);
      const toDayIndex = calendarWeeks[toWeekIndex].days.findIndex(day => day.date === toDate);
      
      if (fromDayIndex !== -1 && toDayIndex !== -1) {
        const fromMeals = calendarWeeks[fromWeekIndex].days[fromDayIndex].meals || [];
        const mealToMove = fromMeals.find(meal => meal.id === mealId);
        
        if (mealToMove) {
          calendarWeeks[fromWeekIndex].days[fromDayIndex].meals = fromMeals.filter(meal => meal.id !== mealId);
          calendarWeeks[fromWeekIndex].days[fromDayIndex].activities = calendarWeeks[fromWeekIndex].days[fromDayIndex].meals.length;
          calendarWeeks[fromWeekIndex].totalActivities = calendarWeeks[fromWeekIndex].days.reduce((sum, day) => sum + (day.meals?.length || 0), 0);
          
          if (!calendarWeeks[toWeekIndex].days[toDayIndex].meals) {
            calendarWeeks[toWeekIndex].days[toDayIndex].meals = [];
          }
          calendarWeeks[toWeekIndex].days[toDayIndex].meals.push(mealToMove);
          calendarWeeks[toWeekIndex].days[toDayIndex].activities = calendarWeeks[toWeekIndex].days[toDayIndex].meals.length;
          calendarWeeks[toWeekIndex].totalActivities = calendarWeeks[toWeekIndex].days.reduce((sum, day) => sum + (day.meals?.length || 0), 0);
          
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
      pageNumber += 1
      
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
  }
</script>

{#if activeTab === 'calendar'}
  <div class="flex flex-col h-full bg-gray-50">
    <div class="flex-1 overflow-y-auto" bind:this={rootElement}>
      <InfiniteLoader
        {loaderState}
        triggerLoad={loadMore}
        loopDetectionTimeout={7500}
        intersectionOptions={{ root: rootElement, rootMargin: "0px 0px 500px 0px" }}
      >
        {#each calendarWeeks as week (week.startDate)}
          <WeekSection {week} onAddActivity={addActivity} onMoveMeal={moveMeal} />
        {/each}
        {#snippet loading()}
          <div class="flex justify-center py-6 text-gray-400 text-sm">Loading more weeks...</div>
        {/snippet}
      </InfiniteLoader>
    </div>
  </div>
{:else}
  <ShoppingList />
{/if}

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
