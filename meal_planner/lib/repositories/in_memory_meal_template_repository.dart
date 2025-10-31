import 'dart:async';

import 'package:meal_planner/models/ingredient.freezed_model.dart';
import 'package:meal_planner/models/recipe.freezed_model.dart';
import 'meal_template_repository.dart';

class InMemoryMealTemplateRepository implements MealTemplateRepository {
  final _recipes = <Recipe>[];
  final _favorites = <String, Set<String>>{}; // userId -> titles
  final _recipesCtrl = StreamController<List<String>>.broadcast();
  final _favCtrls = <String, StreamController<List<String>>>{};

  InMemoryMealTemplateRepository() {
    // Seed a few demo recipe titles
    final titles = [
      'Pancakes', 'Salad', 'Pasta', 'Curry', 'Soup',
      'Tacos', 'Burger', 'Stir Fry', 'Fish', 'Pizza'
    ];
    for (final t in titles) {
      _recipes.add(Recipe(
        id: t.toLowerCase(),
        title: t,
        imageUrl: '',
        description: '',
        notes: '',
        preReqs: const [],
        totalTime: 0,
        ingredients: const <Ingredient>[],
        steps: const [],
      ));
    }
    _recipesCtrl.add(List.from(_recipes));
  }

  @override
  Stream<List<String>> watchFavorites(String userId) {
    final ctrl = _favCtrls.putIfAbsent(userId, () => StreamController<List<String>>.broadcast());
    ctrl.add(List.from(_favorites[userId] ?? {}));
    return ctrl.stream;
  }

  @override
  Future<void> saveFavorite(String userId, String recipeTitle) async {
    final set = _favorites.putIfAbsent(userId, () => <String>{});
    set.add(recipeTitle);
    _favCtrls[userId]?.add(List.from(set));
  }

  @override
  Future<List<String>> searchTitles(String query) async {
    final q = query.toLowerCase();
    return _recipes
        .map((r) => r.title)
        .where((t) => t.toLowerCase().contains(q))
        .toList();
  }

  // Simplified: recipes are titles only in-memory. We expose as stream of titles.
  @override
  Stream<List<Recipe>> watchRecipes() async* {
    yield* _recipesCtrl.stream.map((e) => e.cast<Recipe>());
  }
}
