import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal.freezed_model.freezed.dart';
part 'meal.freezed_model.g.dart';

enum MealSlot { breakfast, lunch, dinner, other }

@freezed
class Meal with _$Meal {
  const factory Meal({
    required String id,
    required String recipeTitle,
    required DateTime date,
    required MealSlot slot,
    required String userId,
    required DateTime createdAt,
  }) = _Meal;

  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);
}
