import { CalendarDay, Activity } from "@/lib/types";
import { DateColumn } from "./DateColumn";
import { ActivitiesScroll } from "./ActivitiesScroll";
import { format } from "date-fns";

interface DayRowProps {
  day: CalendarDay;
  isToday?: boolean;
  onAddClick: () => void;
  onActivityTap: (activity: Activity) => void;
}

export function DayRow({ day, isToday, onAddClick, onActivityTap }: DayRowProps) {
  return (
    <div className="flex border-b border-gray-200 min-h-[80px]">
      <DateColumn
        dayNumber={day.dayNumber}
        dayLabel={day.dayLabel}
        isToday={isToday}
        onAddClick={onAddClick}
      />
      <div className="flex-1 min-w-0">
        {day.activities.length > 0 ? (
          <ActivitiesScroll
            activities={day.activities}
            onActivityTap={onActivityTap}
          />
        ) : (
          <div className="flex items-center justify-center h-full px-4">
            <p className="text-sm text-gray-400">No meals planned</p>
          </div>
        )}
      </div>
    </div>
  );
}
