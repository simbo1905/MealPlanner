import { Activity } from "@/lib/types";
import { ActivityCard } from "./ActivityCard";

interface ActivitiesScrollProps {
  activities: Activity[];
  onActivityTap: (activity: Activity) => void;
}

export function ActivitiesScroll({ activities, onActivityTap }: ActivitiesScrollProps) {
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
    </div>
  );
}
