
"use client";

import { useState, useRef, useEffect } from "react";
import {
  Circle,
  CheckCircle2,
  Star,
  ChevronLeft,
  MoreVertical,
  CalendarDays,
  Sun,
  Bell,
  Calendar,
  StickyNote,
  Eye,
  EyeOff,
  Edit3,
  Printer,
} from "lucide-react";
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  DragEndEvent,
  DragStartEvent,
  DragOverlay,
} from "@dnd-kit/core";
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  useSortable,
  verticalListSortingStrategy,
} from "@dnd-kit/sortable";
import { CSS } from "@dnd-kit/utilities";
import { useToast } from "@/hooks/use-toast";
import { Toaster } from "@/components/ui/toaster";

type MealItem = {
  id: string;
  title: string;
  when: "Dinner";
  dayLabel: "Today" | "Tomorrow" | "Mon" | "Tue" | "Wed" | "Thu" | "Fri" | "Sat" | "Sun";
  dateISO: string;
  isDone: boolean;
  isStarred: boolean;
};

const getDateString = (dayLabel: MealItem["dayLabel"]): string => {
  const today = new Date();
  const dayMap: Record<string, number> = {
    Today: 0,
    Tomorrow: 1,
    Mon: 1,
    Tue: 2,
    Wed: 3,
    Thu: 4,
    Fri: 5,
    Sat: 6,
    Sun: 0,
  };

  if (dayLabel === "Today") {
    return today.toISOString().split("T")[0];
  } else if (dayLabel === "Tomorrow") {
    const tomorrow = new Date(today);
    tomorrow.setDate(today.getDate() + 1);
    return tomorrow.toISOString().split("T")[0];
  } else {
    const targetDay = dayMap[dayLabel];
    const currentDay = today.getDay();
    let daysToAdd = targetDay - currentDay;
    if (daysToAdd <= 0) daysToAdd += 7;
    const targetDate = new Date(today);
    targetDate.setDate(today.getDate() + daysToAdd);
    return targetDate.toISOString().split("T")[0];
  }
};

const formatDate = (dateISO: string): string => {
  const date = new Date(dateISO);
  return date.toLocaleDateString("en-US", { month: "short", day: "numeric" });
};

const INITIAL_MEALS: MealItem[] = [
  {
    id: "m1",
    title: "Roast Chicken Dinner",
    when: "Dinner",
    dayLabel: "Today",
    dateISO: getDateString("Today"),
    isDone: false,
    isStarred: false,
  },
  {
    id: "m2",
    title: "Pork Chops and Mash",
    when: "Dinner",
    dayLabel: "Tomorrow",
    dateISO: getDateString("Tomorrow"),
    isDone: false,
    isStarred: false,
  },
  {
    id: "m3",
    title: "Veggie Stir-Fry",
    when: "Dinner",
    dayLabel: "Wed",
    dateISO: getDateString("Wed"),
    isDone: false,
    isStarred: true,
  },
  {
    id: "m4",
    title: "Spaghetti Bolognese",
    when: "Dinner",
    dayLabel: "Fri",
    dateISO: getDateString("Fri"),
    isDone: false,
    isStarred: false,
  },
];

function SortableMealCard({
  meal,
  onToggleDone,
  onToggleStar,
  isDragging,
}: {
  meal: MealItem;
  onToggleDone: (id: string) => void;
  onToggleStar: (id: string) => void;
  isDragging: boolean;
}) {
  const { attributes, listeners, setNodeRef, transform, transition, isDragging: isSortableDragging } = useSortable({
    id: meal.id,
  });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  const isBeingDragged = isDragging || isSortableDragging;

  return (
    <div
      ref={setNodeRef}
      style={style}
      {...attributes}
      {...listeners}
      className={`rounded-2xl bg-neutral-900/60 ring-1 ring-white/5 px-4 py-3 flex items-center justify-between transition-all duration-150 touch-none ${
        isBeingDragged ? "shadow-2xl scale-[1.02] ring-2 ring-teal-400/40 z-50" : ""
      } active:bg-white/5`}
    >
      <div className="flex items-center gap-3 flex-1 min-w-0">
        <button
          onClick={(e) => {
            e.stopPropagation();
            onToggleDone(meal.id);
          }}
          className="flex-shrink-0 w-11 h-11 flex items-center justify-center -ml-1"
          aria-label={meal.isDone ? "Mark as incomplete" : "Mark as complete"}
          role="checkbox"
          aria-checked={meal.isDone}
        >
          {meal.isDone ? (
            <CheckCircle2 className="w-6 h-6 text-teal-300" />
          ) : (
            <Circle className="w-6 h-6 text-white/60" />
          )}
        </button>
        <div className="flex-1 min-w-0">
          <div
            className={`text-base font-semibold transition-all duration-150 ${
              meal.isDone ? "line-through text-white/40" : "text-white"
            }`}
          >
            {meal.title}
          </div>
          <div
            className={`mt-0.5 text-sm transition-all duration-150 ${
              meal.isDone ? "text-white/30" : "text-white/60"
            }`}
          >
            {meal.when} • {meal.dayLabel} • {formatDate(meal.dateISO)}
          </div>
        </div>
      </div>
      <button
        onClick={(e) => {
          e.stopPropagation();
          onToggleStar(meal.id);
        }}
        className="flex-shrink-0 w-11 h-11 flex items-center justify-center -mr-1 transition-transform duration-100 active:scale-90"
        aria-label={meal.isStarred ? "Remove from favorites" : "Add to favorites"}
        aria-pressed={meal.isStarred}
      >
        <Star
          className={`w-5 h-5 transition-all duration-120 ${
            meal.isStarred ? "fill-white/60 text-white/60" : "text-white/60"
          }`}
        />
      </button>
    </div>
  );
}

export default function MealPlanPage() {
  const [meals, setMeals] = useState<MealItem[]>(INITIAL_MEALS);
  const [showCompleted, setShowCompleted] = useState(false);
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [newMealTitle, setNewMealTitle] = useState("");
  const [isComposerFocused, setIsComposerFocused] = useState(false);
  const [activeId, setActiveId] = useState<string | null>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const { toast } = useToast();

  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        delay: 300,
        tolerance: 5,
      },
    }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  const activeMeals = meals.filter((m) => !m.isDone);
  const completedMeals = meals.filter((m) => m.isDone);

  const handleToggleDone = (id: string) => {
    setMeals((prev) =>
      prev.map((m) => (m.id === id ? { ...m, isDone: !m.isDone } : m))
    );
  };

  const handleToggleStar = (id: string) => {
    setMeals((prev) =>
      prev.map((m) => (m.id === id ? { ...m, isStarred: !m.isStarred } : m))
    );
  };

  const handleAddMeal = () => {
    if (!newMealTitle.trim()) return;

    const newMeal: MealItem = {
      id: `m${Date.now()}`,
      title: newMealTitle.trim(),
      when: "Dinner",
      dayLabel: "Today",
      dateISO: getDateString("Today"),
      isDone: false,
      isStarred: false,
    };

    setMeals((prev) => [...prev, newMeal]);
    setNewMealTitle("");
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter") {
      e.preventDefault();
      handleAddMeal();
    }
  };

  const handleDoneClick = () => {
    inputRef.current?.blur();
    setIsComposerFocused(false);
  };

  const handleEditClick = () => {
    setIsMenuOpen(false);
    setTimeout(() => {
      inputRef.current?.focus();
    }, 100);
  };

  const handlePrintClick = () => {
    setIsMenuOpen(false);
    toast({
      description: "Print preview not available in prototype",
      duration: 1500,
    });
  };

  const handleDragStart = (event: DragStartEvent) => {
    setActiveId(event.active.id as string);
  };

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;
    setActiveId(null);

    if (over && active.id !== over.id) {
      setMeals((items) => {
        const activeIndex = items.findIndex((item) => item.id === active.id);
        const overIndex = items.findIndex((item) => item.id === over.id);
        return arrayMove(items, activeIndex, overIndex);
      });
    }
  };

  const activeMeal = activeId ? meals.find((m) => m.id === activeId) : null;

  return (
    <div className="min-h-screen bg-black">
      <div className="max-w-sm mx-auto bg-black text-white/90 pt-3 px-3 pb-2 min-h-screen">
        <div className="relative mb-4">
          <button className="flex items-center gap-1 text-teal-200/90 text-sm">
            <ChevronLeft className="w-4 h-4" />
            <span>Lists</span>
          </button>

          <h1 className="text-4xl font-extrabold text-teal-200 mt-2 mb-3">
            Family Meal Plan
          </h1>

          <button
            onClick={() => (isComposerFocused ? handleDoneClick() : setIsMenuOpen(true))}
            className="absolute right-0 top-0 text-teal-200 font-semibold h-11 px-3 flex items-center justify-center"
            aria-label={isComposerFocused ? "Done editing" : "More options"}
          >
            {isComposerFocused ? "Done" : <MoreVertical className="w-5 h-5" />}
          </button>

          <div className="inline-flex items-center gap-2 bg-neutral-900 px-3 py-1 text-sm text-white/80 rounded-xl">
            <CalendarDays className="w-4 h-4" />
            <span>This Week</span>
          </div>
        </div>

        <DndContext
          sensors={sensors}
          collisionDetection={closestCenter}
          onDragStart={handleDragStart}
          onDragEnd={handleDragEnd}
        >
          <div className="space-y-3 mb-4">
            {activeMeals.length === 0 && !showCompleted && (
              <div className="text-center py-12 text-white/40 text-sm">
                No planned dinners yet. Add a meal below.
              </div>
            )}

            <SortableContext
              items={activeMeals.map((m) => m.id)}
              strategy={verticalListSortingStrategy}
            >
              {activeMeals.map((meal) => (
                <SortableMealCard
                  key={meal.id}
                  meal={meal}
                  onToggleDone={handleToggleDone}
                  onToggleStar={handleToggleStar}
                  isDragging={activeId === meal.id}
                />
              ))}
            </SortableContext>

            {showCompleted && completedMeals.length > 0 && (
              <>
                <div className="text-xs uppercase text-white/40 font-semibold tracking-wider mt-6 mb-3 px-1">
                  Completed
                </div>
                {completedMeals.map((meal) => (
                  <div
                    key={meal.id}
                    className="rounded-2xl bg-neutral-900/60 ring-1 ring-white/5 px-4 py-3 flex items-center justify-between transition-all duration-150"
                  >
                    <div className="flex items-center gap-3 flex-1 min-w-0">
                      <button
                        onClick={() => handleToggleDone(meal.id)}
                        className="flex-shrink-0 w-11 h-11 flex items-center justify-center -ml-1"
                        aria-label="Mark as incomplete"
                        role="checkbox"
                        aria-checked={true}
                      >
                        <CheckCircle2 className="w-6 h-6 text-teal-300" />
                      </button>
                      <div className="flex-1 min-w-0">
                        <div className="text-base font-semibold line-through text-white/40">
                          {meal.title}
                        </div>
                        <div className="mt-0.5 text-sm text-white/30">
                          {meal.when} • {meal.dayLabel} • {formatDate(meal.dateISO)}
                        </div>
                      </div>
                    </div>
                    <button
                      onClick={() => handleToggleStar(meal.id)}
                      className="flex-shrink-0 w-11 h-11 flex items-center justify-center -mr-1 transition-transform duration-100 active:scale-90"
                      aria-label={meal.isStarred ? "Remove from favorites" : "Add to favorites"}
                      aria-pressed={meal.isStarred}
                    >
                      <Star
                        className={`w-5 h-5 transition-all duration-120 ${
                          meal.isStarred ? "fill-white/60 text-white/60" : "text-white/60"
                        }`}
                      />
                    </button>
                  </div>
                ))}
              </>
            )}
          </div>

          <DragOverlay>
            {activeMeal ? (
              <div className="rounded-2xl bg-neutral-900/60 ring-1 ring-white/5 px-4 py-3 flex items-center justify-between shadow-2xl ring-2 ring-teal-400/40">
                <div className="flex items-center gap-3 flex-1 min-w-0">
                  <div className="flex-shrink-0 w-11 h-11 flex items-center justify-center -ml-1">
                    <Circle className="w-6 h-6 text-white/60" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="text-base font-semibold text-white">
                      {activeMeal.title}
                    </div>
                    <div className="mt-0.5 text-sm text-white/60">
                      {activeMeal.when} • {activeMeal.dayLabel} • {formatDate(activeMeal.dateISO)}
                    </div>
                  </div>
                </div>
                <div className="flex-shrink-0 w-11 h-11 flex items-center justify-center -mr-1">
                  <Star
                    className={`w-5 h-5 ${
                      activeMeal.isStarred ? "fill-white/60 text-white/60" : "text-white/60"
                    }`}
                  />
                </div>
              </div>
            ) : null}
          </DragOverlay>
        </DndContext>

        <div className="mt-2 rounded-2xl bg-neutral-900/60 ring-1 ring-white/5 px-4 py-3 flex items-center gap-3">
          <div className="flex-shrink-0 w-6 h-6 flex items-center justify-center">
            <Circle className="w-6 h-6 text-white/40" />
          </div>
          <input
            ref={inputRef}
            type="text"
            placeholder="Add a Meal"
            value={newMealTitle}
            onChange={(e) => setNewMealTitle(e.target.value)}
            onKeyDown={handleKeyDown}
            onFocus={() => setIsComposerFocused(true)}
            onBlur={() => setIsComposerFocused(false)}
            className="flex-1 bg-transparent text-base text-white placeholder-white/40 focus:outline-none"
          />
          <div className="flex items-center gap-2">
            <Sun className="w-5 h-5 text-white/50" />
            <Bell className="w-5 h-5 text-white/50" />
            <Calendar className="w-5 h-5 text-white/50" />
            <StickyNote className="w-5 h-5 text-white/50" />
          </div>
        </div>

        {isMenuOpen && (
          <>
            <div
              className="fixed inset-0 bg-black/60 z-40"
              onClick={() => setIsMenuOpen(false)}
            />
            <div className="fixed inset-x-0 bottom-0 rounded-t-3xl bg-neutral-900 ring-1 ring-white/10 p-3 pb-6 z-50">
              <button
                onClick={() => setShowCompleted(!showCompleted)}
                className="w-full flex items-center gap-3 px-3 py-3 rounded-xl active:bg-white/5 transition-colors"
              >
                {showCompleted ? (
                  <EyeOff className="w-5 h-5 text-white/70" />
                ) : (
                  <Eye className="w-5 h-5 text-white/70" />
                )}
                <span className="text-base text-white/90">
                  {showCompleted ? "Hide" : "Show"} Completed Meals
                </span>
              </button>
              <button
                onClick={handleEditClick}
                className="w-full flex items-center gap-3 px-3 py-3 rounded-xl active:bg-white/5 transition-colors"
              >
                <Edit3 className="w-5 h-5 text-white/70" />
                <span className="text-base text-white/90">Edit</span>
              </button>
              <button
                onClick={handlePrintClick}
                className="w-full flex items-center gap-3 px-3 py-3 rounded-xl active:bg-white/5 transition-colors"
              >
                <Printer className="w-5 h-5 text-white/70" />
                <span className="text-base text-white/90">Print</span>
              </button>
            </div>
          </>
        )}
      </div>
      <Toaster />
    </div>
  );
}
