import { Activity } from "@/lib/types";
import { ActivityCard } from "./ActivityCard";
import { Plus } from "lucide-react";

interface ActivitiesScrollProps {
  activities: Activity[];
  onActivityTap: (activity: Activity) => void;
  onAddClick: () => void;
}

export function ActivitiesScroll({ activities, onActivityTap, onAddClick }: ActivitiesScrollProps) {
  return (
    <div
      className="flex gap-3 px-3 py-2 overflow-x-auto"
      style={{
        scrollSnapType: "x mandatory",
        WebkitOverflowScrolling: "touch",
      }}
    >
      {activities.map((activity) => (
        <ActivityCard
          key={activity.id}
          activity={activity}
          onTap={() => onActivityTap(activity)}
        />
      ))}
      <button
        onClick={onAddClick}
        className="flex-shrink-0 w-52 h-[88px] rounded-xl border flex items-center justify-center gap-2 text-gray-500 hover:bg-white hover:border-white hover:text-gray-700 transition-colors scroll-snap-align-start"
        style={{ backgroundColor: '#f9fafb', borderColor: '#f9fafb' }}
      >
        <Plus className="w-5 h-5" />
        <span className="font-medium text-sm">Add Meal</span>
      </button>
    </div>
  );
}
