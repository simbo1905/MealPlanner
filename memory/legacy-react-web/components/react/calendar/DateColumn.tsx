interface DateColumnProps {
  dayNumber: number;
  dayLabel: string;
  isToday?: boolean;
}

export function DateColumn({ dayNumber, dayLabel, isToday }: DateColumnProps) {
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
    </div>
  );
}
