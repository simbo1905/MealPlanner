import { WeekSummary as WeekSummaryType } from "@/lib/types";
import { format } from "date-fns";
import { RotateCcw } from "lucide-react";

interface WeekSummaryProps {
  week: WeekSummaryType;
  onReset?: () => void;
}

export function WeekSummary({ week, onReset }: WeekSummaryProps) {
  const startDateFormatted = format(new Date(week.startDate), "d MMM");
  const endDateFormatted = format(new Date(week.endDate), "d MMM");

  return (
    <div className="bg-white border-b border-gray-200 px-4 py-3 sticky top-0 z-20">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <h2 className="text-lg font-semibold text-gray-900">
            {startDateFormatted} - {endDateFormatted}
          </h2>
          <span className="bg-black text-white text-xs font-semibold px-3 py-1 rounded-full">
            WEEK {week.weekNumber}
          </span>
        </div>
        {onReset && week.totalActivities > 0 && (
          <button
            onClick={onReset}
            className="flex items-center gap-2 text-sm text-gray-600 hover:text-gray-900 transition-colors"
          >
            <RotateCcw className="w-4 h-4" />
            Reset
          </button>
        )}
      </div>
      {week.totalActivities > 0 && (
        <p className="text-sm text-gray-500 mt-1">
          Total: {week.totalActivities} {week.totalActivities === 1 ? "activity" : "activities"}
        </p>
      )}
    </div>
  );
}
