import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/widgets/calendar/weekly_summary.dart';

void main() {
  group('WeeklySummary Tests', () {
    testWidgets('displays total meals', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeeklySummary(
              totalMeals: 7,
              totalCookTime: 0,
              mealsPerDay: {},
            ),
          ),
        ),
      );

      expect(find.text('7 meals planned'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });

    testWidgets('displays total cook time formatted (HH:MM)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeeklySummary(
              totalMeals: 5,
              totalCookTime: 185.0, // 3 hours 5 minutes
              mealsPerDay: {},
            ),
          ),
        ),
      );

      expect(find.text('3 hours 5 minutes total'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('displays meals per day breakdown', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WeeklySummary(
              totalMeals: 5,
              totalCookTime: 100.0,
              mealsPerDay: const {
                '2025-10-27': 2, // Monday
                '2025-10-28': 1, // Tuesday
                '2025-10-29': 3, // Wednesday - changed to 3 to avoid duplication
              },
            ),
          ),
        ),
      );

      expect(find.text('Breakdown'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('2 meals'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('1 meal'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('3 meals'), findsOneWidget);
    });

    testWidgets('shows 0 meals when empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeeklySummary(
              totalMeals: 0,
              totalCookTime: 0,
              mealsPerDay: {},
            ),
          ),
        ),
      );

      expect(find.text('0 meals planned'), findsOneWidget);
      expect(find.text('0 minutes total'), findsOneWidget);
    });
  });
}
