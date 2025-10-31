import 'dart:async';

import '../../models/recipe.freezed_model.dart';
import '../../providers/recipe_providers.dart';

class FakeRecipeRepository implements RecipeRepository {
  FakeRecipeRepository({List<Recipe>? seed}) : _recipes = seed ?? _default;

  final List<Recipe> _recipes;

  static List<Recipe> get _default => [
        Recipe(
          id: 'r_beef_tacos',
          title: 'Beef Tacos',
          imageUrl: '',
          description: 'Quick beef tacos',
          notes: '',
          preReqs: const [],
          totalTime: 20,
          ingredients: const [],
          steps: const [],
        ),
        Recipe(
          id: 'r_veggie_stir_fry',
          title: 'Vegetable Stir Fry',
          imageUrl: '',
          description: 'Fast veggie stir fry',
          notes: '',
          preReqs: const [],
          totalTime: 15,
          ingredients: const [],
          steps: const [],
        ),
      ];

  final _ctrl = StreamController<List<Recipe>>.broadcast();
  bool _seeded = false;

  void _ensureSeed() {
    if (_seeded) return;
    _seeded = true;
    _ctrl.add(List.unmodifiable(_recipes));
  }

  @override
  Stream<List<Recipe>> watchAllRecipes() {
    _ensureSeed();
    return _ctrl.stream;
  }

  @override
  Future<Recipe?> getRecipe(String id) async {
    try {
      return _recipes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> save(Recipe recipe) async {
    final idx = _recipes.indexWhere((r) => r.id == recipe.id);
    if (idx == -1) {
      _recipes.add(recipe);
    } else {
      _recipes[idx] = recipe;
    }
    _ctrl.add(List.unmodifiable(_recipes));
    return recipe.id;
  }

  @override
  Future<void> delete(String id) async {
    _recipes.removeWhere((r) => r.id == id);
    _ctrl.add(List.unmodifiable(_recipes));
  }
}
