import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import '../models/meal.freezed_model.dart';
import '../models/week_section.freezed_model.dart';
import '../repositories/meal_repository.dart';
import 'auth_providers.dart';
import 'favorites_providers.dart';

part 'meal_providers.g.dart';

/// Repository providers (overridable in tests)
@riverpod
MealRepository mealRepository(Ref ref) {
  throw UnimplementedError('MealRepository must be overridden');
}

/// Selected date state
@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void select(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }
}

/// Stream of meals for the signed-in user
/// Stream of meals for current user
@riverpod
Stream<List<Meal>> userMeals(UserMealsRef ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return const Stream<List<Meal>>.empty();
  }
  final repository = ref.watch(mealRepositoryProvider);
  return repository.watchMeals(userId);
}

/// Meals for a specific date
@riverpod
AsyncValue<List<Meal>> mealsForDate(MealsForDateRef ref, DateTime date) {
  final meals = ref.watch(userMealsProvider);
  return meals.whenData(
    (list) => list
        .where((meal) => _isSameDay(meal.date, date))
        .toList()
      ..sort((a, b) => a.slot.index.compareTo(b.slot.index)),
  );
}

/// Meals for a date range (inclusive)
@riverpod
AsyncValue<List<Meal>> mealsForDateRange(
  MealsForDateRangeRef ref,
  DateTime start,
  DateTime end,
) {
  final meals = ref.watch(userMealsProvider);
  return meals.whenData((list) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return list.where((meal) {
      final mealDate = DateTime(meal.date.year, meal.date.month, meal.date.day);
      return !mealDate.isBefore(startDate) && !mealDate.isAfter(endDate);
    }).toList();
  });
}

/// Planned meals count for next 30 days
@riverpod
AsyncValue<int> plannedMealCount(PlannedMealCountRef ref) {
  final meals = ref.watch(userMealsProvider);
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  final endDate = tomorrow.add(const Duration(days: 30));
  return meals.whenData((list) {
    return list.where((meal) {
      final mealDate = DateTime(meal.date.year, meal.date.month, meal.date.day);
      return !mealDate.isBefore(tomorrow) && !mealDate.isAfter(endDate);
    }).length;
  });
}

/// Week sections for infinite scroll
@riverpod
AsyncValue<List<WeekSection>> weekSections(
  WeekSectionsRef ref, {
  required int weeksAround,
}) {
  final meals = ref.watch(userMealsProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final selectedWeekStart = _getWeekStart(selectedDate);

  return meals.whenData((list) {
    final sections = <WeekSection>[];

    for (int i = -weeksAround; i <= weeksAround; i++) {
      final weekStart = selectedWeekStart.add(Duration(days: i * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final weekNumber = _getWeekNumber(weekStart);

      final days = <DaySection>[];
      int totalMeals = 0;

      for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
        final date = weekStart.add(Duration(days: dayOffset));
        final dayMeals = list
            .where((meal) => _isSameDay(meal.date, date))
            .toList()
          ..sort((a, b) => a.slot.index.compareTo(b.slot.index));

        totalMeals += dayMeals.length;

        days.add(
          DaySection(
            date: date,
            dayLabel: _getDayLabel(date),
            isToday: _isSameDay(date, today),
            isSelected: _isSameDay(date, selectedDate),
            meals: dayMeals,
          ),
        );
      }

      sections.add(
        WeekSection(
          weekStart: weekStart,
          weekEnd: weekEnd,
          weekNumber: weekNumber,
          days: days,
          totalMeals: totalMeals,
          totalPrepTime: 0,
        ),
      );
    }

    return sections;
  });
}

/// Helper: Get Monday of the week containing the date
DateTime _getWeekStart(DateTime date) {
  return date.subtract(Duration(days: date.weekday - 1));
}

/// Helper: Get week number of year
int _getWeekNumber(DateTime date) {
  final firstDayOfYear = DateTime(date.year, 1, 1);
  final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
  return ((daysSinceFirstDay + firstDayOfYear.weekday) / 7).ceil();
}

/// Helper: Get day label (MON, TUE, etc.)
String _getDayLabel(DateTime date) {
  return DateFormat('EEE').format(date).toUpperCase();
}

/// Helper: Check if two dates are the same day
bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
