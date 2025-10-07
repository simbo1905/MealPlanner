import { CalendarDay, Activity } from "@/lib/types";
import { DateColumn } from "./DateColumn";
import { ActivitiesScroll } from "./ActivitiesScroll";
import { useDroppable } from "@dnd-kit/core";

interface DayRowProps {
  day: CalendarDay;
  isToday?: boolean;
  onAddClick: () => void;
  onActivityTap: (activity: Activity) => void;
}

export function DayRow({ day, isToday, onAddClick, onActivityTap }: DayRowProps) {
  const { setNodeRef, isOver } = useDroppable({
    id: day.date,
  });

  return (
    <div
      ref={setNodeRef}
      className={`flex border-b border-gray-200 min-h-[80px] transition-colors ${
        isOver ? "bg-blue-50" : ""
      }`}
    >
      <DateColumn
        dayNumber={day.dayNumber}
        dayLabel={day.dayLabel}
        isToday={isToday}
      />
      <div className="flex-1 min-w-0">
        <ActivitiesScroll
          activities={day.activities}
          onActivityTap={onActivityTap}
          onAddClick={onAddClick}
        />
      </div>
    </div>
  );
}
