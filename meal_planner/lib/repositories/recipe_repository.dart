import 'package:meal_planner/models/recipe.freezed_model.dart';

abstract class RecipeRepository {
  Future<Recipe?> getRecipe(String id);
}
