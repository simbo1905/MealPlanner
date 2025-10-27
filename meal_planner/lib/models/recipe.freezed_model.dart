import 'package:freezed_annotation/freezed_annotation.dart';
import 'ingredient.freezed_model.dart';

part 'recipe.freezed_model.freezed.dart';
part 'recipe.freezed_model.g.dart';

@freezed
class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required String title,
    required String imageUrl,
    required String description,
    required String notes,
    required List<String> preReqs,
    required double totalTime,
    required List<Ingredient> ingredients,
    required List<String> steps,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) =>
      _$RecipeFromJson(json);
}
