import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/widgets/calendar/calendar_day_cell.dart';

void main() {
  group('CalendarDayCell Widget Tests', () {
    testWidgets('displays day of month', (tester) async {
      final date = DateTime(2025, 10, 27);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDayCell(
              date: date,
              mealCount: 0,
              isToday: false,
            ),
          ),
        ),
      );

      expect(find.text('27'), findsOneWidget);
    });

    testWidgets('displays day of week abbreviation', (tester) async {
      final date = DateTime(2025, 10, 27); // Monday

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDayCell(
              date: date,
              mealCount: 0,
              isToday: false,
            ),
          ),
        ),
      );

      expect(find.text('Mon'), findsOneWidget);
    });

    testWidgets('shows meal count badge when meals assigned', (tester) async {
      final date = DateTime(2025, 10, 27);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDayCell(
              date: date,
              mealCount: 3,
              isToday: false,
            ),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows total cook time formatted when provided',
        (tester) async {
      final date = DateTime(2025, 10, 27);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDayCell(
              date: date,
              mealCount: 2,
              totalTime: 125.0, // 2h 5m
              isToday: false,
            ),
          ),
        ),
      );

      expect(find.text('2h5m'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('highlights cell when isToday is true', (tester) async {
      final date = DateTime(2025, 10, 27);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDayCell(
              date: date,
              mealCount: 0,
              isToday: true,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CalendarDayCell),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isA<Border>());
      final border = decoration.border as Border;
      expect(border.top.width, 2);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      final date = DateTime(2025, 10, 27);
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDayCell(
              date: date,
              mealCount: 0,
              isToday: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CalendarDayCell));
      await tester.pump();

      expect(tapped, true);
    });
  });
}
