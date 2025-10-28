
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meal_planner/models/meal.freezed_model.dart';

part 'week_section.freezed_model.freezed.dart';
part 'week_section.freezed_model.g.dart';

@freezed
class WeekSection with _$WeekSection {
  const factory WeekSection({
    required DateTime weekStart,
    required DateTime weekEnd,
    required int weekNumber,
    required List<DaySection> days,
    required int totalMeals,
    required int totalPrepTime,
  }) = _WeekSection;

  factory WeekSection.fromJson(Map<String, dynamic> json) =>
      _$WeekSectionFromJson(json);
}

@freezed
class DaySection with _$DaySection {
  const factory DaySection({
    required DateTime date,
    required String dayLabel,
    required bool isToday,
    required bool isSelected,
    required List<Meal> meals,
  }) = _DaySection;

  factory DaySection.fromJson(Map<String, dynamic> json) =>
      _$DaySectionFromJson(json);
}
