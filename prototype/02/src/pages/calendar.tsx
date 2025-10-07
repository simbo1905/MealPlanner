"use client";

import { useState, useEffect } from "react";
import { WeekSummary as WeekSummaryType, CalendarDay, Activity } from "@/lib/types";
import { Recipe } from "@/lib/recipe-types";
import { generateInitialCalendarData } from "@/lib/calendar-data";
import { WeekSummary } from "@/components/calendar/WeekSummary";
import { DayRow } from "@/components/calendar/DayRow";
import { RecipeBanner } from "@/components/calendar/RecipeBanner";
import { AddMealDialog } from "@/components/calendar/AddMealDialog";
import { ChevronLeft, Save } from "lucide-react";
import { Toaster } from "@/components/ui/toaster";
import { useToast } from "@/hooks/use-toast";
import { format } from "date-fns";
import {
  DndContext,
  DragOverlay,
  PointerSensor,
  useSensor,
  useSensors,
  DragStartEvent,
  DragEndEvent,
  DragOverEvent,
} from "@dnd-kit/core";

const STORAGE_KEY = "mealplanner-calendar-v1";

export default function CalendarPage() {
  const [weeks, setWeeks] = useState<WeekSummaryType[]>([]);
  const [selectedActivity, setSelectedActivity] = useState<Activity | null>(null);
  const [isBannerOpen, setIsBannerOpen] = useState(false);
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
  const [selectedDate, setSelectedDate] = useState<string>("");
  const [activeId, setActiveId] = useState<string | null>(null);
  const [draggedActivity, setDraggedActivity] = useState<Activity | null>(null);
  const { toast } = useToast();

  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8,
      },
    })
  );

  useEffect(() => {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored) {
      try {
        setWeeks(JSON.parse(stored));
      } catch {
        setWeeks(generateInitialCalendarData());
      }
    } else {
      const initialData = generateInitialCalendarData();
      setWeeks(initialData);
      localStorage.setItem(STORAGE_KEY, JSON.stringify(initialData));
    }
  }, []);

  useEffect(() => {
    if (weeks.length > 0) {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(weeks));
    }
  }, [weeks]);

  const handleActivityTap = (activity: Activity) => {
    setSelectedActivity(activity);
    setIsBannerOpen(true);
  };

  const handleCloseBanner = () => {
    setIsBannerOpen(false);
    setTimeout(() => setSelectedActivity(null), 300);
  };

  const handleViewRecipe = () => {
    toast({
      description: `Recipe detail view for "${selectedActivity?.title}" not implemented in prototype`,
      duration: 2000,
    });
    handleCloseBanner();
  };

  const handleRemove = () => {
    if (!selectedActivity) return;

    setWeeks((prevWeeks) => {
      return prevWeeks.map((week) => ({
        ...week,
        days: week.days.map((day) => ({
          ...day,
          activities: day.activities.filter((a) => a.id !== selectedActivity.id),
        })),
        totalActivities: week.days.reduce(
          (sum, day) => sum + day.activities.filter((a) => a.id !== selectedActivity.id).length,
          0
        ),
      }));
    });

    toast({
      description: `"${selectedActivity.title}" removed from calendar`,
      duration: 1500,
    });

    handleCloseBanner();
  };

  const handleAddClick = (date: string) => {
    setSelectedDate(date);
    setIsAddDialogOpen(true);
  };

  const handleSelectRecipe = (recipe: Recipe) => {
    const recipeId = recipe.title.toLowerCase().replace(/\s+/g, "-");
    const newActivity: Activity = {
      id: `${recipeId}-${Date.now()}`,
      title: recipe.title,
      prepTime: `${recipe.total_time} min`,
      icon: "utensils",
      accentColor: "green",
    };

    setWeeks((prevWeeks) => {
      return prevWeeks.map((week) => {
        const dayIndex = week.days.findIndex((d) => d.date === selectedDate);
        if (dayIndex === -1) return week;

        const updatedDays = [...week.days];
        updatedDays[dayIndex] = {
          ...updatedDays[dayIndex],
          activities: [...updatedDays[dayIndex].activities, newActivity],
        };

        return {
          ...week,
          days: updatedDays,
          totalActivities: updatedDays.reduce(
            (sum, day) => sum + day.activities.length,
            0
          ),
        };
      });
    });

    toast({
      description: `"${recipe.title}" added to ${format(new Date(selectedDate), "EEE, MMM d")}`,
      duration: 1500,
    });
  };

  const handleResetWeek = (weekNumber: number) => {
    setWeeks((prevWeeks) => {
      return prevWeeks.map((week) => {
        if (week.weekNumber !== weekNumber) return week;
        return {
          ...week,
          days: week.days.map((day) => ({ ...day, activities: [] })),
          totalActivities: 0,
        };
      });
    });

    toast({
      description: `Week ${weekNumber} cleared`,
      duration: 1500,
    });
  };

  const getTodayDate = () => {
    return format(new Date(2025, 9, 6), "yyyy-MM-dd");
  };

  const handleDragStart = (event: DragStartEvent) => {
    const { active } = event;
    setActiveId(active.id as string);
    
    const activity = weeks
      .flatMap(week => week.days)
      .flatMap(day => day.activities)
      .find(a => a.id === active.id);
    
    setDraggedActivity(activity || null);
  };

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;
    setActiveId(null);
    setDraggedActivity(null);

    if (!over) return;

    const activityId = active.id as string;
    const targetDate = over.id as string;

    let sourceDate: string | null = null;
    let movedActivity: Activity | null = null;

    for (const week of weeks) {
      for (const day of week.days) {
        const activity = day.activities.find(a => a.id === activityId);
        if (activity) {
          sourceDate = day.date;
          movedActivity = activity;
          break;
        }
      }
      if (sourceDate) break;
    }

    if (!sourceDate || !movedActivity || sourceDate === targetDate) return;

    setWeeks(prevWeeks => {
      return prevWeeks.map(week => {
        const updatedDays = week.days.map(day => {
          if (day.date === sourceDate) {
            return {
              ...day,
              activities: day.activities.filter(a => a.id !== activityId),
            };
          }
          if (day.date === targetDate) {
            return {
              ...day,
              activities: [...day.activities, movedActivity],
            };
          }
          return day;
        });

        return {
          ...week,
          days: updatedDays,
          totalActivities: updatedDays.reduce(
            (sum, day) => sum + day.activities.length,
            0
          ),
        };
      });
    });

    toast({
      description: `"${movedActivity.title}" moved to ${format(new Date(targetDate), "EEE, MMM d")}`,
      duration: 1500,
    });
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto bg-white shadow-sm min-h-screen">
        <div className="sticky top-0 z-30 bg-white border-b border-gray-200 px-4 py-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <button className="p-2 -ml-2 hover:bg-gray-100 rounded-lg transition-colors">
                <ChevronLeft className="w-5 h-5 text-gray-600" />
              </button>
              <h1 className="text-xl font-bold text-gray-900">MealPlanner Calendar View</h1>
            </div>
            <button className="text-gray-400 text-sm font-medium hover:text-gray-600 transition-colors">
              Save
            </button>
          </div>
        </div>

        <DndContext
          sensors={sensors}
          onDragStart={handleDragStart}
          onDragEnd={handleDragEnd}
        >
          <div className="calendar-container overflow-y-auto" style={{ height: "calc(100vh - 60px)" }}>
            {weeks.map((week) => (
              <div key={week.weekNumber}>
                <WeekSummary week={week} onReset={() => handleResetWeek(week.weekNumber)} />
                {week.days.map((day) => (
                  <DayRow
                    key={day.date}
                    day={day}
                    isToday={day.date === getTodayDate()}
                    onAddClick={() => handleAddClick(day.date)}
                    onActivityTap={handleActivityTap}
                  />
                ))}
              </div>
            ))}
          </div>

          <DragOverlay>
            {draggedActivity && (
              <div className="w-52 p-4 bg-white rounded-xl shadow-2xl border-l-4 border-l-green-500 opacity-90">
                <div className="font-semibold text-sm text-gray-900">
                  {draggedActivity.title}
                </div>
                {draggedActivity.prepTime && (
                  <p className="text-xs text-gray-500 mt-1">{draggedActivity.prepTime}</p>
                )}
              </div>
            )}
          </DragOverlay>
        </DndContext>

        <RecipeBanner
          activity={selectedActivity}
          isOpen={isBannerOpen}
          onClose={handleCloseBanner}
          onViewRecipe={handleViewRecipe}
          onRemove={handleRemove}
        />

        <AddMealDialog
          isOpen={isAddDialogOpen}
          onClose={() => setIsAddDialogOpen(false)}
          onSelectRecipe={handleSelectRecipe}
        />
      </div>
      <Toaster />
    </div>
  );
}
