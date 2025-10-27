import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'ingredient.freezed_model.freezed.dart';
part 'ingredient.freezed_model.g.dart';

@freezed
class Ingredient with _$Ingredient {
  const factory Ingredient({
    required String name,
    required UcumUnit ucumUnit,
    required double ucumAmount,
    required MetricUnit metricUnit,
    required double metricAmount,
    required String notes,
    AllergenCode? allergenCode,
  }) = _Ingredient;

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);
}
