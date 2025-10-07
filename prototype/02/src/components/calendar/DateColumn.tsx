import { Plus } from "lucide-react";

interface DateColumnProps {
  dayNumber: number;
  dayLabel: string;
  isToday?: boolean;
  onAddClick: () => void;
}

export function DateColumn({ dayNumber, dayLabel, isToday, onAddClick }: DateColumnProps) {
  return (
    <div className="sticky left-0 z-10 bg-white flex flex-col justify-center items-center w-20 min-w-[80px] border-r border-gray-100 py-3">
      <div className="text-xs text-gray-400 font-medium mb-1">{dayLabel}</div>
      <div
        className={`flex items-center justify-center w-10 h-10 rounded-full font-semibold text-lg ${
          isToday
            ? "bg-black text-white"
            : "text-gray-900"
        }`}
      >
        {dayNumber}
      </div>
      <button
        onClick={onAddClick}
        className="text-xs text-blue-500 mt-2 flex items-center gap-1 hover:text-blue-700 transition-colors"
      >
        <Plus className="w-3 h-3" />
        Add
      </button>
    </div>
  );
}
