import { useState, useEffect, useMemo } from "react";
import type { Recipe } from "@mealplanner/recipe-types";
import { RecipeDatabase, defaultRecipes, loadTags, addTag as addTagToDb } from "@mealplanner/recipe-database";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Utensils, X, Plus, ChevronDown } from "lucide-react";

interface AddMealDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onSelectRecipe: (recipe: Recipe) => void;
}

export function AddMealDialog({
  isOpen,
  onClose,
  onSelectRecipe,
}: AddMealDialogProps) {
  const database = useMemo(() => new RecipeDatabase(defaultRecipes as Recipe[]), []);
  const [searchText, setSearchText] = useState("");
  const [selectedTags, setSelectedTags] = useState<string[]>([]);
  const [availableTags, setAvailableTags] = useState<string[]>([]);
  const [filteredRecipes, setFilteredRecipes] = useState<Recipe[]>([]);

  useEffect(() => {
    setAvailableTags(loadTags());
  }, []);

  useEffect(() => {
    const results = database
      .searchRecipes({
        query: searchText.trim() || undefined,
        ingredients: selectedTags.length > 0 ? selectedTags : undefined,
        sortBy: 'relevance',
        limit: 50
      })
      .map(result => result.recipe);
    setFilteredRecipes(results);
  }, [database, searchText, selectedTags]);

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    const value = searchText;
    const hashMatch = value.match(/#([\w\u00A0]+)$/);
    
    if (hashMatch) {
      const isModifierPressed = e.shiftKey || e.altKey || e.ctrlKey || e.metaKey;
      const isWordBoundary = [' ', ',', '.', ';', '!', '?', 'Enter'].includes(e.key);
      
      if (e.key === ' ' && isModifierPressed) {
        e.preventDefault();
        setSearchText(value + '\u00A0');
      } else if (isWordBoundary) {
        e.preventDefault();
        const newTag = (hashMatch[1] ?? '').toLowerCase();
        const updatedTags = addTagToDb(newTag);
        setAvailableTags(updatedTags);
        if (!selectedTags.includes(newTag)) {
          setSelectedTags((prev) => [...prev, newTag]);
        }
        setSearchText("");
      }
    }
  };

  const handleSearchChange = (value: string) => {
    setSearchText(value);
  };

  const handleTagSelect = (tag: string) => {
    if (!selectedTags.includes(tag)) {
      setSelectedTags((prev) => [...prev, tag]);
    }
  };

  const handleTagRemove = (tag: string) => {
    setSelectedTags((prev) => prev.filter((t) => t !== tag));
  };

  const handleSelect = (recipe: Recipe) => {
    onSelectRecipe(recipe);
    onClose();
  };

  const handleClose = () => {
    setSearchText("");
    setSelectedTags([]);
    onClose();
  };

  return (
    <Dialog open={isOpen} onOpenChange={handleClose}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Add a Meal</DialogTitle>
        </DialogHeader>
        
        <div className="space-y-3">
          <Input
            type="text"
            placeholder="Search recipes or type #ingredient..."
            value={searchText}
            onChange={(e) => handleSearchChange(e.target.value)}
            onKeyDown={handleKeyDown}
            className="w-full"
          />

          <div className="flex items-center gap-2">
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" size="sm" className="gap-1">
                  <Plus className="h-4 w-4" />
                  Ingredient
                  <ChevronDown className="h-4 w-4" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="start">
                {availableTags.map((tag) => (
                  <DropdownMenuItem
                    key={tag}
                    onClick={() => handleTagSelect(tag)}
                    disabled={selectedTags.includes(tag)}
                  >
                    {tag.replace(/\u00A0/g, ' ')}
                  </DropdownMenuItem>
                ))}
              </DropdownMenuContent>
            </DropdownMenu>

            <div className="flex flex-wrap gap-2">
              {selectedTags.map((tag) => (
                <Badge key={tag} variant="secondary" className="gap-1 pr-1">
                  {tag.replace(/\u00A0/g, ' ')}
                  <button
                    onClick={() => handleTagRemove(tag)}
                    className="ml-1 hover:bg-gray-300 rounded-full p-0.5"
                  >
                    <X className="h-3 w-3" />
                  </button>
                </Badge>
              ))}
            </div>
          </div>
        </div>

        <div className="space-y-2 h-[400px] overflow-y-auto mt-4">
          {filteredRecipes.map((recipe) => (
            <button
              key={recipe.title}
              onClick={() => handleSelect(recipe)}
              className="w-full flex items-center gap-3 p-3 rounded-lg hover:bg-gray-50 transition-colors border border-gray-100"
            >
              <div className="w-10 h-10 bg-gray-100 rounded-lg flex items-center justify-center flex-shrink-0">
                <Utensils className="w-5 h-5 text-gray-600" />
              </div>
              <div className="flex-1 text-left">
                <div className="font-medium text-gray-900">{recipe.title}</div>
                <div className="text-sm text-gray-500">{recipe.total_time} min</div>
              </div>
            </button>
          ))}
          {filteredRecipes.length === 0 && (
            <div className="text-center py-8 text-gray-500">
              No recipes found
            </div>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
}
