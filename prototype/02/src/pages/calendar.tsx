"use client";

import { useState, useEffect } from "react";
import { WeekSummary as WeekSummaryType, CalendarDay, Activity } from "@/lib/types";
import { generateInitialCalendarData, SAMPLE_RECIPES } from "@/lib/calendar-data";
import { WeekSummary } from "@/components/calendar/WeekSummary";
import { DayRow } from "@/components/calendar/DayRow";
import { RecipeBanner } from "@/components/calendar/RecipeBanner";
import { AddMealDialog } from "@/components/calendar/AddMealDialog";
import { ChevronLeft, Save } from "lucide-react";
import { Toaster } from "@/components/ui/toaster";
import { useToast } from "@/hooks/use-toast";
import { format } from "date-fns";

const STORAGE_KEY = "mealplanner-calendar-v1";

export default function CalendarPage() {
  const [weeks, setWeeks] = useState<WeekSummaryType[]>([]);
  const [selectedActivity, setSelectedActivity] = useState<Activity | null>(null);
  const [isBannerOpen, setIsBannerOpen] = useState(false);
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
  const [selectedDate, setSelectedDate] = useState<string>("");
  const { toast } = useToast();

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

  const handleSelectRecipe = (recipe: Activity) => {
    const newActivity: Activity = {
      ...recipe,
      id: `${recipe.id}-${Date.now()}`,
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
          availableRecipes={SAMPLE_RECIPES}
        />
      </div>
      <Toaster />
    </div>
  );
}
