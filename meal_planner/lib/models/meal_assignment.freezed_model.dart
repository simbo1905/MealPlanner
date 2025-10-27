import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_assignment.freezed_model.freezed.dart';
part 'meal_assignment.freezed_model.g.dart';

@freezed
class MealAssignment with _$MealAssignment {
  const factory MealAssignment({
    required String id,
    required String recipeId,
    required String dayIsoDate,
    required DateTime assignedAt,
  }) = _MealAssignment;

  factory MealAssignment.fromJson(Map<String, dynamic> json) =>
      _$MealAssignmentFromJson(json);
}
