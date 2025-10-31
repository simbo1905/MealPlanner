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
    // New optional fields for v1 recipe search
    String? titleLower,
    List<String>? titleTokens,
    List<String>? ingredientNamesNormalized,
    String? version,
    // ignore: invalid_annotation_target
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime? createdAt,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) =>
      _$RecipeFromJson(json);
}

DateTime? _timestampFromJson(dynamic value) {
  if (value == null) return null;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.parse(value);
  return null;
}

dynamic _timestampToJson(DateTime? dateTime) {
  return dateTime?.toIso8601String();
}
