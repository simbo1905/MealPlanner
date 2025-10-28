import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal.freezed_model.freezed.dart';
part 'meal.freezed_model.g.dart';

@freezed
class Meal with _$Meal {
  const factory Meal({
    required String id,
    required String templateId,
    required DateTime date,
    required int order,
    required DateTime createdAt,
  }) = _Meal;

  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);
}
