import 'package:meal_planner/models/recipe.freezed_model.dart';

abstract class MealTemplateRepository {
  Stream<List<Recipe>> watchRecipes();
  Future<List<String>> searchTitles(String query);
  Future<void> saveFavorite(String userId, String recipeTitle);
  Stream<List<String>> watchFavorites(String userId);
}
