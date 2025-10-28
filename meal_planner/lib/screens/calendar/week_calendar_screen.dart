import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meal_planner/widgets/calendar/calendar_day_cell.dart';
import 'package:meal_planner/widgets/calendar/weekly_summary.dart';
import 'package:meal_planner/providers/meal_assignment_providers.dart';
import 'package:meal_planner/providers/calendar_providers.dart';
import 'package:meal_planner/providers/recipe_providers.dart';

/// Main calendar screen displaying a week of meal assignments
class WeekCalendarScreen extends ConsumerStatefulWidget {
  const WeekCalendarScreen({super.key});

  @override
  ConsumerState<WeekCalendarScreen> createState() =>
      _WeekCalendarScreenState();
}

class _WeekCalendarScreenState extends ConsumerState<WeekCalendarScreen> {
  DateTime _selectedWeekStart = _getMonday(DateTime.now());

  static DateTime _getMonday(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  String _getIsoDate(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  void _navigateToPreviousWeek() {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _navigateToNextWeek() {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startIsoDate = _getIsoDate(_selectedWeekStart);

    final weekAssignmentsAsync =
        ref.watch(weekMealAssignmentsProvider(startIsoDate));
    final weekMealCountsAsync =
        ref.watch(weekMealCountsProvider(startIsoDate));
    final weekTotalTimeAsync =
        ref.watch(weekTotalTimeProvider(startIsoDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Calendar'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          // Week navigation
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _navigateToPreviousWeek,
                  tooltip: 'Previous week',
                ),
                Text(
                  '${DateFormat.MMMd().format(_selectedWeekStart)} - ${DateFormat.MMMd().format(_selectedWeekStart.add(const Duration(days: 6)))}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _navigateToNextWeek,
                  tooltip: 'Next week',
                ),
              ],
            ),
          ),

          // Calendar grid
          Expanded(
            child: weekMealCountsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
              data: (mealCounts) {
                final hasAnyMeals = mealCounts.values.any((count) => count > 0);

                if (!hasAnyMeals) {
                  return const Center(
                    child: Text('No meals planned'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final day = _selectedWeekStart.add(Duration(days: index));
                    final dayIsoDate = _getIsoDate(day);
                    final mealCount = mealCounts[dayIsoDate] ?? 0;
                    final isToday = _getIsoDate(DateTime.now()) == dayIsoDate;

                    // Get total time for this day
                    double? dayTotalTime;
                    weekAssignmentsAsync.whenData((assignments) {
                      final dayAssignments = assignments[dayIsoDate] ?? [];
                      if (dayAssignments.isNotEmpty) {
                        ref.watch(recipesProvider).whenData((recipes) {
                          double total = 0.0;
                          for (var assignment in dayAssignments) {
                            final recipe = recipes.firstWhere(
                              (r) => r.id == assignment.recipeId,
                              orElse: () => recipes.first,
                            );
                            total += recipe.totalTime;
                          }
                          dayTotalTime = total;
                        });
                      }
                    });

                    return CalendarDayCell(
                      date: day,
                      mealCount: mealCount,
                      totalTime: dayTotalTime,
                      isToday: isToday,
                      onTap: () {
                        // Navigate to DayDetailScreen
                        Navigator.pushNamed(
                          context,
                          '/day-detail',
                          arguments: dayIsoDate,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Weekly summary
          weekTotalTimeAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (totalTime) {
              return weekMealCountsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (mealCounts) {
                  final totalMeals =
                      mealCounts.values.fold<int>(0, (sum, count) => sum + count);
                  return WeeklySummary(
                    totalMeals: totalMeals,
                    totalCookTime: totalTime,
                    mealsPerDay: mealCounts,
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show meal assignment modal
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Assign Meal'),
              content: const Text('Meal assignment modal placeholder'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
