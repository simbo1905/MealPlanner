import { Activity, CalendarDay, WeekSummary } from "./types";
import { format, addDays, startOfWeek } from "date-fns";

export const SAMPLE_RECIPES: Activity[] = [
  {
    id: "r1",
    title: "Spaghetti Bolognese",
    prepTime: "45 min",
    icon: "utensils",
    accentColor: "green",
  },
  {
    id: "r2",
    title: "Chicken Stir-Fry",
    prepTime: "30 min",
    icon: "chef-hat",
    accentColor: "yellow",
  },
  {
    id: "r3",
    title: "Fish and Chips",
    prepTime: "40 min",
    icon: "utensils",
    accentColor: "teal",
  },
  {
    id: "r4",
    title: "Vegetable Curry",
    prepTime: "35 min",
    icon: "soup",
    accentColor: "orange",
  },
  {
    id: "r5",
    title: "Roast Chicken",
    prepTime: "90 min",
    icon: "chef-hat",
    accentColor: "green",
  },
  {
    id: "r6",
    title: "Shepherd's Pie",
    prepTime: "60 min",
    icon: "utensils",
    accentColor: "purple",
  },
  {
    id: "r7",
    title: "Caesar Salad",
    prepTime: "15 min",
    icon: "salad",
    accentColor: "green",
  },
  {
    id: "r8",
    title: "Beef Tacos",
    prepTime: "25 min",
    icon: "utensils",
    accentColor: "yellow",
  },
];

function generateWeekData(weekNumber: number, startDate: Date): WeekSummary {
  const days: CalendarDay[] = [];
  
  for (let i = 0; i < 7; i++) {
    const currentDate = addDays(startDate, i);
    const dayLabel = format(currentDate, "EEE").toUpperCase();
    const dayNumber = parseInt(format(currentDate, "d"));
    const dateISO = format(currentDate, "yyyy-MM-dd");
    
    days.push({
      date: dateISO,
      dayLabel,
      dayNumber,
      activities: [],
    });
  }

  const endDate = format(addDays(startDate, 6), "yyyy-MM-dd");

  return {
    weekNumber,
    startDate: format(startDate, "yyyy-MM-dd"),
    endDate,
    totalActivities: 0,
    days,
  };
}

export function generateInitialCalendarData(): WeekSummary[] {
  const today = new Date(2025, 9, 6);
  const weekStart = startOfWeek(today, { weekStartsOn: 1 });
  
  const weeks: WeekSummary[] = [];
  
  for (let i = 0; i < 4; i++) {
    const currentWeekStart = addDays(weekStart, i * 7);
    weeks.push(generateWeekData(i + 1, currentWeekStart));
  }

  weeks[0].days[4].activities = [
    {
      id: "a1",
      title: "My First Run",
      distance: "2.6 km",
      icon: "utensils",
      accentColor: "green",
    },
    {
      id: "a2",
      title: "Hill Repeats",
      distance: "6 km",
      icon: "chef-hat",
      accentColor: "green",
    },
    {
      id: "a3",
      title: "parkrun",
      distance: "5 km",
      icon: "utensils",
      accentColor: "teal",
    },
  ];

  weeks[0].days[6].activities = [
    {
      id: "a4",
      title: "Gradual Build",
      distance: "3.1 km",
      icon: "utensils",
      accentColor: "yellow",
    },
  ];

  weeks[0].totalActivities = 4;

  return weeks;
}
