import type { Activity } from "@/lib/types";
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
        className="flex-shrink-0 w-36 h-[88px] rounded-xl border flex items-center gap-1 text-gray-500 hover:bg-white hover:border-white hover:text-gray-700 transition-colors scroll-snap-align-start"
        style={{ 
          backgroundColor: '#f9fafb', 
          borderColor: '#f9fafb',
          justifyContent: 'flex-start',
          paddingLeft: '0.75rem'
        }}
      >
        <Plus className="w-4 h-4 flex-shrink-0" />
        <span className="font-medium text-sm whitespace-nowrap">Add</span>
      </button>
    </div>
  );
}
