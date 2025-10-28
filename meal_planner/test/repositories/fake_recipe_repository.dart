import 'dart:async';
import 'package:meal_planner/models/recipe.freezed_model.dart';
import 'package:meal_planner/providers/recipe_providers.dart';

/// In-memory fake repository for recipes used in widget tests.
class FakeRecipeRepository implements RecipeRepository {
  final Map<String, Recipe> _recipes = {};
  final Map<String, StreamController<List<Recipe>>> _controllers = {};

  /// Pre-seed a recipe for testing
  void seed(String recipeId, Recipe recipe) {
    _recipes[recipeId] = recipe;
    _notifyListeners();
  }

  /// Clear all recipes
  void clear() {
    _recipes.clear();
    for (var controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }

  /// Watch all recipes (returns a stream)
  @override
  Stream<List<Recipe>> watchAllRecipes() async* {
    // Emit current recipes immediately
    yield _recipes.values.toList();
    
    // Then listen to future updates via controller
    if (!_controllers.containsKey('all')) {
      _controllers['all'] = StreamController<List<Recipe>>.broadcast();
    }
    
    await for (final recipes in _controllers['all']!.stream) {
      yield recipes;
    }
  }

  /// Get a single recipe by ID
  @override
  Future<Recipe?> getRecipe(String recipeId) async {
    return _recipes[recipeId];
  }

  /// Save a recipe
  @override
  Future<String> save(Recipe recipe) async {
    _recipes[recipe.id] = recipe;
    _notifyListeners();
    return recipe.id;
  }

  /// Delete a recipe
  @override
  Future<void> delete(String recipeId) async {
    _recipes.remove(recipeId);
    _notifyListeners();
  }

  void _notifyListeners() {
    if (_controllers.containsKey('all') && !_controllers['all']!.isClosed) {
      _controllers['all']!.add(_recipes.values.toList());
    }
  }
}
