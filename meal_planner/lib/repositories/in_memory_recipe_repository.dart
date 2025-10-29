import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:meal_planner/models/recipe.freezed_model.dart';
import 'package:meal_planner/providers/recipe_providers.dart';

class InMemoryRecipeRepository implements RecipeRepository {
  final List<Recipe> _recipes = [];
  final StreamController<List<Recipe>> _controller =
      StreamController<List<Recipe>>.broadcast();

  InMemoryRecipeRepository() {
    _seedDemoRecipes();
  }

  void _seedDemoRecipes() {
    _recipes.addAll([
      const Recipe(
        id: 'recipe_demo_1',
        title: 'Pasta Carbonara',
        imageUrl: '',
        description: 'Classic Italian pasta',
        notes: '',
        preReqs: [],
        totalTime: 20,
        ingredients: [],
        steps: [],
      ),
      const Recipe(
        id: 'recipe_demo_2',
        title: 'Grilled Chicken',
        imageUrl: '',
        description: 'Simple grilled chicken breast',
        notes: '',
        preReqs: [],
        totalTime: 25,
        ingredients: [],
        steps: [],
      ),
    ]);
    _notifyListeners();
  }

  @override
  Stream<List<Recipe>> watchAllRecipes() {
    Future.microtask(() {
      _notifyListeners();
    });
    return _controller.stream;
  }

  @override
  Future<Recipe?> getRecipe(String id) async {
    try {
      return _recipes.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> save(Recipe recipe) async {
    final existingIndex = _recipes.indexWhere((r) => r.id == recipe.id);

    if (existingIndex != -1) {
      _recipes[existingIndex] = recipe;
    } else {
      _recipes.add(recipe);
    }

    _notifyListeners();
    debugPrint('[INFO] ADD_RECIPE - id: ${recipe.id}, title: ${recipe.title}');
    return recipe.id;
  }

  @override
  Future<void> delete(String id) async {
    _recipes.removeWhere((r) => r.id == id);
    _notifyListeners();
    debugPrint('[INFO] DELETE_RECIPE - id: $id');
  }

  List<Recipe> getAllRecipes() {
    return List.from(_recipes);
  }

  void _notifyListeners() {
    if (!_controller.isClosed) {
      _controller.add(List.from(_recipes));
    }
  }

  void dispose() {
    _controller.close();
  }
}
