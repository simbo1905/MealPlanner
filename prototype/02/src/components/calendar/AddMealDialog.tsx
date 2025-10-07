import { Activity } from "@/lib/types";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Utensils, Cookie, ChefHat, Soup, Salad } from "lucide-react";

const iconMap = {
  utensils: Utensils,
  cookie: Cookie,
  "chef-hat": ChefHat,
  soup: Soup,
  salad: Salad,
};

interface AddMealDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onSelectRecipe: (recipe: Activity) => void;
  availableRecipes: Activity[];
}

export function AddMealDialog({
  isOpen,
  onClose,
  onSelectRecipe,
  availableRecipes,
}: AddMealDialogProps) {
  const handleSelect = (recipe: Activity) => {
    onSelectRecipe(recipe);
    onClose();
  };

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Add a Meal</DialogTitle>
        </DialogHeader>
        <div className="space-y-2 max-h-[400px] overflow-y-auto">
          {availableRecipes.map((recipe) => {
            const Icon = iconMap[recipe.icon] || Utensils;
            return (
              <button
                key={recipe.id}
                onClick={() => handleSelect(recipe)}
                className="w-full flex items-center gap-3 p-3 rounded-lg hover:bg-gray-50 transition-colors border border-gray-100"
              >
                <div className="w-10 h-10 bg-gray-100 rounded-lg flex items-center justify-center flex-shrink-0">
                  <Icon className="w-5 h-5 text-gray-600" />
                </div>
                <div className="flex-1 text-left">
                  <div className="font-medium text-gray-900">{recipe.title}</div>
                  {recipe.prepTime && (
                    <div className="text-sm text-gray-500">{recipe.prepTime}</div>
                  )}
                </div>
              </button>
            );
          })}
        </div>
      </DialogContent>
    </Dialog>
  );
}
