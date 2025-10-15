import type { Recipe } from '@mealplanner/recipe-types';

export interface CalendarRecipe extends Recipe {
  id: string;
}

export interface Day {
  date: string;
  dayName: string;
  activities: number;
  recipes?: CalendarRecipe[];
}

export interface Week {
  startDate: string;
  endDate: string;
  weekNumber: number;
  totalActivities: number;
  days: Day[];
}

// Drag and drop event types for svelte-dnd-action
export interface DndEvent<T = any> {
  items: T[];
  info: {
    trigger: string;
    id: string;
    source: string;
  };
}