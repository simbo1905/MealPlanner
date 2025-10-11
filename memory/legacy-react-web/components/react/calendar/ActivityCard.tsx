import type { Activity } from "@/lib/types";
import { Utensils, Cookie, ChefHat, Soup, Salad, Zap } from "lucide-react";
import { useDraggable } from "@dnd-kit/core";
import { CSS } from "@dnd-kit/utilities";

const iconMap = {
  utensils: Utensils,
  cookie: Cookie,
  "chef-hat": ChefHat,
  soup: Soup,
  salad: Salad,
};

const colorMap = {
  green: "border-l-green-500",
  yellow: "border-l-yellow-500",
  teal: "border-l-teal-500",
  orange: "border-l-orange-500",
  purple: "border-l-purple-500",
};

interface ActivityCardProps {
  activity: Activity;
  onTap: () => void;
}

export function ActivityCard({ activity, onTap }: ActivityCardProps) {
  const Icon = iconMap[activity.icon] || Utensils;
  const colorClass = colorMap[activity.accentColor] || colorMap.green;

  const { attributes, listeners, setNodeRef, transform, isDragging } = useDraggable({
    id: activity.id,
  });

  const style = {
    transform: CSS.Translate.toString(transform),
    opacity: isDragging ? 0.5 : 1,
  };

  return (
    <div
      ref={setNodeRef}
      style={style}
      {...attributes}
      {...listeners}
      onClick={onTap}
      className={`flex-shrink-0 w-52 p-4 bg-white rounded-xl shadow-sm border border-gray-100 ${colorClass} border-l-4 cursor-pointer transition-all hover:shadow-md active:scale-[0.98] scroll-snap-align-start ${
        isDragging ? "z-50" : ""
      }`}
    >
      <div className="flex items-start justify-between">
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-2">
            <Icon className="w-4 h-4 text-gray-500 flex-shrink-0" />
            <h3 className="font-semibold text-sm text-gray-900 truncate">
              {activity.title}
            </h3>
          </div>
          <div className="flex items-center gap-2">
            {activity.distance && (
              <p className="text-xs text-gray-500">{activity.distance}</p>
            )}
            {activity.prepTime && (
              <p className="text-xs text-gray-500">{activity.prepTime}</p>
            )}
          </div>
        </div>
        <Zap className="w-4 h-4 text-gray-400 flex-shrink-0 ml-2" />
      </div>
    </div>
  );
}
