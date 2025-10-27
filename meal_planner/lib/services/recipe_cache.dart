import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';

class RecipeCache {
  static const String _cacheKey = 'recipes_cache_v1';

  Future<void> saveRecipes(List<Recipe> recipes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList =
          recipes.map((r) => _recipeToJson(r)).toList();
      final String jsonString = json.encode(jsonList);
      await prefs.setString(_cacheKey, jsonString);
    } catch (e) {
      // Silent fail - cache is best effort
    }
  }

  Future<List<Recipe>> loadRecipes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_cacheKey);

      if (jsonString == null) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => _jsonToRecipe(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addOrUpdateRecipe(Recipe recipe) async {
    final recipes = await loadRecipes();
    final index = recipes.indexWhere((r) => r.uuid == recipe.uuid);

    if (index != -1) {
      recipes[index] = recipe;
    } else {
      recipes.add(recipe);
    }

    await saveRecipes(recipes);
  }

  Future<void> removeRecipe(String uuid) async {
    final recipes = await loadRecipes();
    recipes.removeWhere((r) => r.uuid == uuid);
    await saveRecipes(recipes);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  Map<String, dynamic> _recipeToJson(Recipe recipe) {
    return {
      'uuid': recipe.uuid,
      'title': recipe.title,
      'image_url': recipe.imageUrl,
      'description': recipe.description,
      'notes': recipe.notes,
      'pre_reqs': recipe.preReqs,
      'total_time': recipe.totalTime,
      'ingredients': recipe.ingredients.map((i) => i.toJson()).toList(),
      'steps': recipe.steps,
    };
  }

  Recipe _jsonToRecipe(Map<String, dynamic> json) {
    return Recipe(
      uuid: json['uuid'],
      title: json['title'] ?? '',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
      notes: json['notes'] ?? '',
      preReqs: (json['pre_reqs'] as List?)?.cast<String>() ?? [],
      totalTime: (json['total_time'] ?? 0).toDouble(),
      ingredients: (json['ingredients'] as List?)
              ?.map((i) => Ingredient.fromJson(i))
              .toList() ??
          [],
      steps: (json['steps'] as List?)?.cast<String>() ?? [],
    );
  }
}
