import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/models/recipe.freezed_model.dart';
import 'package:meal_planner/models/search_models.freezed_model.dart';
import 'package:meal_planner/providers/recipe_providers.dart';
import 'package:meal_planner/widgets/recipe/recipe_card.dart';
import 'package:meal_planner/widgets/recipe/recipe_search_bar.dart';
import 'package:meal_planner/widgets/recipe/recipe_filter_chips.dart';

/// RecipeListScreen displays a searchable, filterable list of recipes.
class RecipeListScreen extends ConsumerStatefulWidget {
  const RecipeListScreen({super.key});

  @override
  ConsumerState<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends ConsumerState<RecipeListScreen> {
  String _searchQuery = '';
  List<String> _selectedAllergens = [];
  int? _selectedMaxTime;
  List<String> _selectedIngredients = [];

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RecipeSearchBar(
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                _performSearch();
              },
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: RecipeFilterChips(
              onAllergenChanged: (allergens) {
                setState(() {
                  _selectedAllergens = allergens;
                });
                _performSearch();
              },
              onMaxTimeChanged: (maxTime) {
                setState(() {
                  _selectedMaxTime = maxTime;
                });
                _performSearch();
              },
              onIngredientsChanged: (ingredients) {
                setState(() {
                  _selectedIngredients = ingredients;
                });
                _performSearch();
              },
              selectedAllergens: _selectedAllergens,
              selectedMaxTime: _selectedMaxTime,
              selectedIngredients: _selectedIngredients,
            ),
          ),

          const SizedBox(height: 16),

          // Recipe list
          Expanded(
            child: recipesAsync.when(
              data: (recipes) {
                final filteredRecipes = _filterRecipes(recipes);

                if (filteredRecipes.isEmpty) {
                  return const Center(
                    child: Text('No recipes found'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = filteredRecipes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: RecipeCard(
                        recipe: recipe,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/recipe-detail',
                            arguments: recipe.id,
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(recipesProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/recipe-form');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _performSearch() {
    // Trigger search with current filters
    if (_searchQuery.isNotEmpty ||
        _selectedAllergens.isNotEmpty ||
        _selectedMaxTime != null ||
        _selectedIngredients.isNotEmpty) {
      ref.read(recipeSearchNotifierProvider.notifier).search(
            SearchOptions(
              query: _searchQuery.isEmpty ? null : _searchQuery,
              maxTime: _selectedMaxTime,
              ingredients: _selectedIngredients.isEmpty ? null : _selectedIngredients,
              excludeAllergens: _selectedAllergens.isEmpty ? null : _selectedAllergens,
            ),
          );
    }
  }

  List<Recipe> _filterRecipes(List<Recipe> recipes) {
    var filtered = recipes;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final queryLower = _searchQuery.toLowerCase();
      filtered = filtered.where((recipe) {
        return recipe.title.toLowerCase().contains(queryLower) ||
            recipe.description.toLowerCase().contains(queryLower);
      }).toList();
    }

    // Filter by max time
    if (_selectedMaxTime != null) {
      filtered = filtered.where((recipe) {
        return recipe.totalTime <= _selectedMaxTime!;
      }).toList();
    }

    // Filter by excluded allergens
    if (_selectedAllergens.isNotEmpty) {
      filtered = filtered.where((recipe) {
        return !recipe.ingredients.any((ingredient) {
          return ingredient.allergenCode != null &&
              _selectedAllergens.contains(ingredient.allergenCode!.name);
        });
      }).toList();
    }

    // Filter by required ingredients
    if (_selectedIngredients.isNotEmpty) {
      filtered = filtered.where((recipe) {
        return _selectedIngredients.every((ingredientName) {
          return recipe.ingredients.any((ingredient) {
            return ingredient.name.toLowerCase() == ingredientName.toLowerCase();
          });
        });
      }).toList();
    }

    return filtered;
  }
}
