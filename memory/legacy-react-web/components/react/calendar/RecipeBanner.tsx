import type { Activity } from "@/lib/types";
import { motion, AnimatePresence } from "framer-motion";
import { X, Utensils, Cookie, ChefHat, Soup, Salad, Clock, Eye } from "lucide-react";
import { Button } from "@/components/ui/button";

const iconMap = {
  utensils: Utensils,
  cookie: Cookie,
  "chef-hat": ChefHat,
  soup: Soup,
  salad: Salad,
};

interface RecipeBannerProps {
  activity: Activity | null;
  isOpen: boolean;
  onClose: () => void;
  onViewRecipe: () => void;
  onRemove: () => void;
}

export function RecipeBanner({
  activity,
  isOpen,
  onClose,
  onViewRecipe,
  onRemove,
}: RecipeBannerProps) {
  if (!activity) return null;

  const Icon = iconMap[activity.icon] || Utensils;

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-black/60 z-40"
            onClick={onClose}
          />
          <motion.div
            initial={{ y: "100%" }}
            animate={{ y: 0 }}
            exit={{ y: "100%" }}
            transition={{ type: "spring", damping: 30, stiffness: 300 }}
            className="fixed inset-x-0 bottom-0 rounded-t-3xl bg-white p-6 pb-8 z-50 shadow-2xl"
          >
            <button
              onClick={onClose}
              className="absolute top-4 right-4 p-2 rounded-full hover:bg-gray-100 transition-colors"
            >
              <X className="w-5 h-5 text-gray-600" />
            </button>

            <div className="flex items-start gap-4">
              <div className="w-20 h-20 bg-gray-100 rounded-xl flex items-center justify-center flex-shrink-0">
                <Icon className="w-10 h-10 text-gray-600" />
              </div>

              <div className="flex-1 min-w-0">
                <h3 className="text-2xl font-semibold text-gray-900 mb-2">
                  {activity.title}
                </h3>
                {activity.prepTime && (
                  <div className="flex items-center gap-2 text-sm text-gray-600">
                    <Clock className="w-4 h-4" />
                    <span>{activity.prepTime}</span>
                  </div>
                )}
              </div>
            </div>

            <div className="flex gap-3 mt-6">
              <Button
                onClick={onViewRecipe}
                className="flex-1 bg-black text-white hover:bg-gray-800"
              >
                <Eye className="w-4 h-4 mr-2" />
                View Recipe
              </Button>
              <Button
                onClick={onRemove}
                variant="outline"
                className="flex-1 border-gray-300 text-gray-700 hover:bg-gray-50"
              >
                <X className="w-4 h-4 mr-2" />
                Remove
              </Button>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
