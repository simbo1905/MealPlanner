import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'providers.dart';
import '../repositories/in_memory_meal_repository.dart';
import '../repositories/in_memory_meal_template_repository.dart';
import '../providers/meal_providers.dart';

/// Deterministic test harness for the infinite calendar.
///
/// - Provides deterministic time via provider overrides
/// - Computes UK-week Monday for a given fixed date
/// - Generates 10 stable meal placement dates over 14 days
/// - Supplies provider overrides for tests to use directly
///
/// Example (in your test):
///
///   final harness = DeterministicCalendarTestHarness(
///     fixedNow: DateTime(2025, 10, 28), // Tue 28 Oct 2025
///   );
///
///   await tester.pumpWidget(
///     ProviderScope(
///       overrides: harness.providerOverrides(),
///       child: const MyApp(),
///     ),
///   );
///
///   // Use harness.dateKeys for deterministic keys like 'yyyy-MM-dd'
class DeterministicCalendarTestHarness {
  DeterministicCalendarTestHarness({required this.fixedNow});

  /// The fixed current time to use in tests.
  final DateTime fixedNow;

  /// Deterministic offsets (10 meals across the first 14 days starting Monday).
  /// Mon..Sun, next Mon..Sun (14 days total). These indices place meals
  /// consistently while leaving empty days for DnD tests.
  static const List<int> mealOffsets = [0, 1, 2, 3, 5, 6, 8, 10, 12, 13];

  /// Returns the Monday of the UK week for [date].
  DateTime mondayOfWeek(DateTime date) {
    // In Dart, Monday = 1. Subtract weekday - 1 to get Monday.
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }

  /// The Monday for [fixedNow].
  DateTime get monday => mondayOfWeek(fixedNow);

  /// Alias for fixedNow for convenience in tests
  DateTime get currentTime => fixedNow;

  /// The list of DateTimes (10 total) for meal seeding over the next 14 days
  /// starting from [monday].
  List<DateTime> get seededDates {
    return mealOffsets.map((d) => monday.add(Duration(days: d))).toList();
  }

  /// The same seeded dates, formatted as yyyy-MM-dd (used in keys).
  List<String> get dateKeys {
    final fmt = DateFormat('yyyy-MM-dd');
    return seededDates.map((d) => fmt.format(d)).toList();
  }

  /// Provider overrides for a ProviderScope in tests.
  /// - Overrides nowProvider to a fixed date
  /// - Ensures demo seeding is enabled
  /// - Provides meal repository with mocked clock
  List<Override> providerOverrides({bool enableDemoSeeding = true}) {
    // Create repositories with the mocked clock
    final mealRepo = InMemoryMealRepository(clock: () => fixedNow);
    if (enableDemoSeeding) {
      mealRepo.seedDemoMeals();
    }
    final templateRepo = InMemoryMealTemplateRepository();
    
    return [
      nowProvider.overrideWithValue(() => fixedNow),
      demoSeedingEnabledProvider.overrideWithValue(enableDemoSeeding),
      mealRepositoryProvider.overrideWithValue(mealRepo),
      mealTemplateRepositoryProvider.overrideWithValue(templateRepo),
    ];
  }
}

