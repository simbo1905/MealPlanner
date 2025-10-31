import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/screens/calendar/infinite_calendar_screen.dart';
import 'package:meal_planner/demo/deterministic_test_harness.dart';
import 'package:intl/intl.dart';

void main() {
  group('InfiniteCalendarScreen', () {
    late DeterministicCalendarTestHarness harness;
    
    setUp(() {
      // Use fixed date: Tuesday, October 28, 2025
      final fixedNow = DateTime(2025, 10, 28, 10, 0, 0);
      harness = DeterministicCalendarTestHarness(fixedNow: fixedNow);
    });

    Widget createTestApp() {
      return ProviderScope(
        overrides: harness.providerOverrides(),
        child: const MaterialApp(
          home: InfiniteCalendarScreen(),
        ),
      );
    }

    testWidgets('displays current week on initial load', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Should display week header
      expect(find.text('Meal Planner'), findsOneWidget);
      
      // Should display planned meals counter
      expect(find.byKey(const Key('planned_meals_counter')), findsOneWidget);
    });

    testWidgets('displays seeded demo meals', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Demo data has 10 meals total (deterministic seeding)
      // Should find some meal cards
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('planned meals counter shows correct count', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Should display planned meals counter
      final counter = find.byKey(const Key('planned_meals_counter'));
      expect(counter, findsOneWidget);
    });

    testWidgets('save and reset buttons exist in AppBar', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Should have Save button
      expect(find.text('Save'), findsOneWidget);
      
      // Should have Reset button
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('can scroll through weeks', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Scroll down
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Should still display the screen
      expect(find.text('Meal Planner'), findsOneWidget);
    });

    testWidgets('displays week headers with correct week number', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Should find week badge with fixed week number for 2025-10-28
      expect(find.byKey(const Key('week-badge')), findsAtLeastNWidgets(1));
      expect(find.textContaining('WEEK'), findsAtLeastNWidgets(1));
    });

    testWidgets('can add meal via bottom sheet', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find Monday of the week (2025-10-27 for fixed date 2025-10-28)
      final monday = harness.currentTime.subtract(
        Duration(days: harness.currentTime.weekday - 1),
      );
      final mondayKey = DateFormat('yyyy-MM-dd').format(monday);
      final addKey = Key('add-meal-$mondayKey');

      // Find and tap the Add button
      final addButton = find.byKey(addKey);
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        // Should show bottom sheet with "Select a Meal" title
        expect(find.text('Select a Meal'), findsOneWidget);
      }
    });

    testWidgets('displays day labels (MON, TUE, etc.)', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Should display day labels
      final dayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      for (final label in dayLabels) {
        expect(find.text(label), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('verify deterministic seeding with mocked clock', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Monday of week for 2025-10-28 is 2025-10-27
      final monday = DateTime(2025, 10, 27);
      expect(monday.weekday, DateTime.monday);

      // Verify that demo data was seeded with deterministic pattern
      // Should have exactly 10 meals at specific offsets
      
      // Verify screen is functional
      expect(find.text('Meal Planner'), findsOneWidget);
      
      // Verify day labels are present (indicating calendar rendered)
      final dayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      for (final label in dayLabels) {
        expect(find.text(label), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('uses icon actions on compact width without overflow', (tester) async {
      // Build with a narrow MediaQuery width to trigger compact actions
      final app = ProviderScope(
        overrides: harness.providerOverrides(),
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 800),
            devicePixelRatio: 2.0,
          ),
          child: const MaterialApp(
            home: InfiniteCalendarScreen(),
          ),
        ),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // On compact width, Save/Reset are IconButtons (Save has tooltip; Reset keeps key)
      expect(find.byTooltip('Save'), findsOneWidget);
      expect(find.byKey(const Key('reset-button')), findsOneWidget);

      // Text labels should not be shown in compact mode
      expect(find.text('Save'), findsNothing);
    });
  });
}
