import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_plan.freezed_model.freezed.dart';
part 'meal_plan.freezed_model.g.dart';

@freezed
class MealPlan with _$MealPlan {
  const factory MealPlan({
    required String id,
    required List<String> mealAssignmentIds,
    String? shoppingListId,
    required DateTime createdAt,
  }) = _MealPlan;

  factory MealPlan.fromJson(Map<String, dynamic> json) =>
      _$MealPlanFromJson(json);
}
