import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import '../models/meal.freezed_model.dart';
import '../models/meal_template.freezed_model.dart';
import '../models/week_section.freezed_model.dart';
import '../repositories/meal_repository.dart';
import '../repositories/meal_template_repository.dart';

part 'meal_providers.g.dart';

/// Repository providers (overridable in tests)
@riverpod
MealRepository mealRepository(Ref ref) {
  throw UnimplementedError('MealRepository must be overridden');
}

@riverpod
MealTemplateRepository mealTemplateRepository(Ref ref) {
  throw UnimplementedError('MealTemplateRepository must be overridden');
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

/// Get meals for a specific date
@riverpod
List<Meal> mealsForDate(Ref ref, DateTime date) {
  final repository = ref.watch(mealRepositoryProvider);
  return repository.getMealsForDate(date);
}

/// Get meals for a date range
@riverpod
List<Meal> mealsForDateRange(Ref ref, DateTime start, DateTime end) {
  final repository = ref.watch(mealRepositoryProvider);
  return repository.getMealsForDateRange(start, end);
}

/// Get all meal templates
@riverpod
List<MealTemplate> mealTemplates(Ref ref) {
  final repository = ref.watch(mealTemplateRepositoryProvider);
  return repository.getAllTemplates();
}

/// Get template by ID
@riverpod
MealTemplate? mealTemplateById(Ref ref, String templateId) {
  final repository = ref.watch(mealTemplateRepositoryProvider);
  return repository.getTemplateById(templateId);
}

/// Calculate planned meals count (meals from tomorrow onwards)
@riverpod
int plannedMealCount(Ref ref) {
  final repository = ref.watch(mealRepositoryProvider);
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  
  // Count meals for next 30 days
  final endDate = tomorrow.add(const Duration(days: 30));
  final meals = repository.getMealsForDateRange(tomorrow, endDate);
  
  return meals.length;
}



/// Generate week sections for infinite scroll
@riverpod
List<WeekSection> weekSections(Ref ref, {required int weeksAround}) {
  final repository = ref.watch(mealRepositoryProvider);
  final templateRepository = ref.watch(mealTemplateRepositoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  // Find the start of the week containing selected date (Monday)
  final selectedWeekStart = _getWeekStart(selectedDate);
  
  final sections = <WeekSection>[];
  
  // Generate weeks from (weeksAround) weeks before to (weeksAround) weeks after
  for (int i = -weeksAround; i <= weeksAround; i++) {
    final weekStart = selectedWeekStart.add(Duration(days: i * 7));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    // Get week number
    final weekNumber = _getWeekNumber(weekStart);
    
    // Build day sections
    final days = <DaySection>[];
    int totalMeals = 0;
    int totalPrepTime = 0;
    
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final date = weekStart.add(Duration(days: dayOffset));
      final meals = repository.getMealsForDate(date);
      
      // Calculate prep time for this day
      int dayPrepTime = 0;
      for (final meal in meals) {
        final template = templateRepository.getTemplateById(meal.templateId);
        if (template != null) {
          dayPrepTime += template.prepTimeMinutes;
        }
      }
      
      totalMeals += meals.length;
      totalPrepTime += dayPrepTime;
      
      days.add(DaySection(
        date: date,
        dayLabel: _getDayLabel(date),
        isToday: _isSameDay(date, today),
        isSelected: _isSameDay(date, selectedDate),
        meals: meals,
      ));
    }
    
    sections.add(WeekSection(
      weekStart: weekStart,
      weekEnd: weekEnd,
      weekNumber: weekNumber,
      days: days,
      totalMeals: totalMeals,
      totalPrepTime: totalPrepTime,
    ));
  }
  
  return sections;
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
