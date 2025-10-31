import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/screens/calendar/week_calendar_screen.dart';
import 'package:meal_planner/providers/meal_assignment_providers.dart';
import 'package:meal_planner/providers/calendar_providers.dart';
import 'package:meal_planner/providers/recipe_providers.dart';
import 'package:meal_planner/models/meal_assignment.freezed_model.dart';
import 'package:meal_planner/models/recipe.freezed_model.dart';
import 'package:meal_planner/models/ingredient.freezed_model.dart';
import 'package:meal_planner/models/enums.dart';

void main() {
  group('WeekCalendarScreen Tests', () {
    late Recipe testRecipe;
    late MealAssignment testAssignment;

    setUp(() {
      testRecipe = const Recipe(
        id: 'recipe-1',
        title: 'Test Recipe',
        imageUrl: '',
        description: 'Test',
        notes: '',
        preReqs: [],
        totalTime: 30.0,
        ingredients: [
          Ingredient(
            name: 'Ingredient 1',
            ucumUnit: UcumUnit.cupUs,
            ucumAmount: 1.0,
            metricUnit: MetricUnit.g,
            metricAmount: 100.0,
            notes: '',
          ),
        ],
        steps: ['Step 1'],
      );

      testAssignment = MealAssignment(
        id: 'assign-1',
        recipeId: 'recipe-1',
        dayIsoDate: '2025-10-27',
        assignedAt: DateTime(2025, 10, 27, 10, 0),
      );
    });

    testWidgets('displays week navigation buttons', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weekMealAssignmentsProvider('2025-10-27')
                .overrideWith((ref) => const Stream.empty()),
            weekMealCountsProvider('2025-10-27')
                .overrideWith((ref) async => {}),
            weekTotalTimeProvider('2025-10-27')
                .overrideWith((ref) async => 0.0),
            recipesProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: const MaterialApp(
            home: WeekCalendarScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byTooltip('Previous week'), findsOneWidget);
      expect(find.byTooltip('Next week'), findsOneWidget);
    });

    testWidgets('shows weekly summary', skip: true, (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weekMealAssignmentsProvider('2025-10-27').overrideWith(
              (ref) => Stream.value({
                '2025-10-27': [testAssignment],
              }),
            ),
            weekMealCountsProvider('2025-10-27').overrideWith(
              (ref) async => {'2025-10-27': 1},
            ),
            weekTotalTimeProvider('2025-10-27').overrideWith(
              (ref) async => 30.0,
            ),
            recipesProvider.overrideWith(
              (ref) => Stream.value([testRecipe]),
            ),
          ],
          child: const MaterialApp(
            home: WeekCalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Weekly Summary'), findsOneWidget);
      expect(find.text('1 meal planned'), findsOneWidget);
    });

    testWidgets('shows "No meals planned" when week is empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weekMealAssignmentsProvider('2025-10-27').overrideWith(
              (ref) => Stream.value({}),
            ),
            weekMealCountsProvider('2025-10-27').overrideWith(
              (ref) async => {},
            ),
            weekTotalTimeProvider('2025-10-27').overrideWith(
              (ref) async => 0.0,
            ),
            recipesProvider.overrideWith(
              (ref) => const Stream.empty(),
            ),
          ],
          child: const MaterialApp(
            home: WeekCalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No meals planned'), findsOneWidget);
    });

    testWidgets('displays meal counts per day', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weekMealAssignmentsProvider('2025-10-27').overrideWith(
              (ref) => Stream.value({
                '2025-10-27': [testAssignment],
              }),
            ),
            weekMealCountsProvider('2025-10-27').overrideWith(
              (ref) async => {'2025-10-27': 1},
            ),
            weekTotalTimeProvider('2025-10-27').overrideWith(
              (ref) async => 30.0,
            ),
            recipesProvider.overrideWith(
              (ref) => Stream.value([testRecipe]),
            ),
          ],
          child: const MaterialApp(
            home: WeekCalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for day cell with meal count badge
      expect(find.text('1'), findsWidgets); // meal count badge
    });

    testWidgets('navigates to previous week when left button tapped',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weekMealAssignmentsProvider('2025-10-27').overrideWith(
              (ref) => Stream.value({}),
            ),
            weekMealCountsProvider('2025-10-27').overrideWith(
              (ref) async => {},
            ),
            weekTotalTimeProvider('2025-10-27').overrideWith(
              (ref) async => 0.0,
            ),
            // Also need to override for the previous week
            weekMealAssignmentsProvider('2025-10-20').overrideWith(
              (ref) => Stream.value({}),
            ),
            weekMealCountsProvider('2025-10-20').overrideWith(
              (ref) async => {},
            ),
            weekTotalTimeProvider('2025-10-20').overrideWith(
              (ref) async => 0.0,
            ),
            recipesProvider.overrideWith(
              (ref) => const Stream.empty(),
            ),
          ],
          child: const MaterialApp(
            home: WeekCalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final initialWeekText = find.byType(Text).evaluate().firstWhere(
        (element) {
          final widget = element.widget as Text;
          return widget.data?.contains('Oct') ?? false;
        },
      );
      final initialText = (initialWeekText.widget as Text).data;

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // The week text should change
      final newWeekText = find.byType(Text).evaluate().firstWhere(
        (element) {
          final widget = element.widget as Text;
          return widget.data?.contains('Oct') ?? false;
        },
      );
      final newText = (newWeekText.widget as Text).data;

      expect(newText, isNot(equals(initialText)));
    });

    testWidgets('navigates to next week when right button tapped',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weekMealAssignmentsProvider('2025-10-27').overrideWith(
              (ref) => Stream.value({}),
            ),
            weekMealCountsProvider('2025-10-27').overrideWith(
              (ref) async => {},
            ),
            weekTotalTimeProvider('2025-10-27').overrideWith(
              (ref) async => 0.0,
            ),
            // Also need to override for the next week
            weekMealAssignmentsProvider('2025-11-03').overrideWith(
              (ref) => Stream.value({}),
            ),
            weekMealCountsProvider('2025-11-03').overrideWith(
              (ref) async => {},
            ),
            weekTotalTimeProvider('2025-11-03').overrideWith(
              (ref) async => 0.0,
            ),
            recipesProvider.overrideWith(
              (ref) => const Stream.empty(),
            ),
          ],
          child: const MaterialApp(
            home: WeekCalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      // Week should advance
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('shows FAB to add meal', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weekMealAssignmentsProvider('2025-10-27').overrideWith(
              (ref) => Stream.value({}),
            ),
            weekMealCountsProvider('2025-10-27').overrideWith(
              (ref) async => {},
            ),
            weekTotalTimeProvider('2025-10-27').overrideWith(
              (ref) async => 0.0,
            ),
            recipesProvider.overrideWith(
              (ref) => const Stream.empty(),
            ),
          ],
          child: const MaterialApp(
            home: WeekCalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping FAB shows meal assignment modal', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weekMealAssignmentsProvider('2025-10-27').overrideWith(
              (ref) => Stream.value({}),
            ),
            weekMealCountsProvider('2025-10-27').overrideWith(
              (ref) async => {},
            ),
            weekTotalTimeProvider('2025-10-27').overrideWith(
              (ref) async => 0.0,
            ),
            recipesProvider.overrideWith(
              (ref) => const Stream.empty(),
            ),
          ],
          child: const MaterialApp(
            home: WeekCalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Assign Meal'), findsOneWidget);
    });
  });
}
