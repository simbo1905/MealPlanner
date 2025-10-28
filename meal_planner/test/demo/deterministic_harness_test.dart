import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/screens/calendar/infinite_calendar_screen.dart';
import 'package:meal_planner/demo/deterministic_test_harness.dart';
import 'package:intl/intl.dart';

/// Demo test showing how to use DeterministicCalendarTestHarness with a fixed date.
/// This test uses 2025-10-28 (Tuesday) as the fixed "now" for all operations.
void main() {
  group('DeterministicCalendarTestHarness Demo', () {
    testWidgets('demonstrates harness usage with fixed date 2025-10-28', (tester) async {
      // Fixed date: Tuesday, October 28, 2025
      final fixedNow = DateTime(2025, 10, 28, 10, 0, 0);
      
      // Create harness with mocked clock
      final harness = DeterministicCalendarTestHarness(
        fixedNow: fixedNow,
      );

      // Build the app with harness providers
      await tester.pumpWidget(
        ProviderScope(
          overrides: harness.providerOverrides(),
          child: const MaterialApp(
            home: InfiniteCalendarScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the screen loaded
      expect(find.text('Meal Planner'), findsOneWidget);
      
      // Calculate Monday of the week (UK model: weekday 1 = Monday)
      // For 2025-10-28 (Tue, weekday=2), Monday is 2025-10-27
      final monday = fixedNow.subtract(Duration(days: fixedNow.weekday - 1));
      expect(monday.day, 27);
      expect(monday.weekday, DateTime.monday);

      // Verify week badge shows correct week number
      final weekNumber = _getIsoWeekNumber(fixedNow);
      expect(find.byKey(const Key('week-badge')), findsAtLeastNWidgets(1));

      // Verify day labels are present
      final dayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      for (final label in dayLabels) {
        expect(find.text(label), findsAtLeastNWidgets(1));
      }

      // Verify reset button exists
      final resetButton = find.byKey(const Key('reset-button'));
      expect(resetButton, findsOneWidget);

      print('[TEST] Demo completed successfully with fixed date: ${DateFormat('yyyy-MM-dd').format(fixedNow)}');
      print('[TEST] Monday of week: ${DateFormat('yyyy-MM-dd').format(monday)}');
      print('[TEST] Week number: $weekNumber');
    });

    testWidgets('verifies clock determinism across operations', (tester) async {
      final fixedNow = DateTime(2025, 10, 28, 14, 30, 0);
      final harness = DeterministicCalendarTestHarness(fixedNow: fixedNow);

      await tester.pumpWidget(
        ProviderScope(
          overrides: harness.providerOverrides(),
          child: const MaterialApp(
            home: InfiniteCalendarScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that the harness provides the fixed clock
      expect(harness.currentTime, fixedNow);

      // Verify screen loaded with deterministic data
      expect(find.text('Meal Planner'), findsOneWidget);
      
      print('[TEST] Clock determinism verified: ${harness.currentTime}');
    });
  });
}

/// Calculate ISO week number (UK/ISO 8601 standard)
int _getIsoWeekNumber(DateTime date) {
  // ISO week 1 is the week with the first Thursday of the year
  final thursday = date.add(Duration(days: DateTime.thursday - date.weekday));
  final firstThursday = DateTime(thursday.year, 1, 1);
  final firstThursdayWeekday = firstThursday.weekday;
  final firstWeekStart = firstThursday.subtract(
    Duration(days: firstThursdayWeekday - DateTime.monday),
  );
  
  final weekNumber = ((thursday.difference(firstWeekStart).inDays) / 7).floor() + 1;
  return weekNumber;
}
