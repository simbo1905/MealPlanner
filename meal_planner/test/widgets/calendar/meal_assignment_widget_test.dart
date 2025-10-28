import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/meal_assignment.freezed_model.dart';
import 'package:meal_planner/models/recipe.freezed_model.dart';
import 'package:meal_planner/models/ingredient.freezed_model.dart';
import 'package:meal_planner/models/enums.dart';
import 'package:meal_planner/widgets/calendar/meal_assignment_widget.dart';

void main() {
  group('MealAssignmentWidget Tests', () {
    late MealAssignment testAssignment;
    late Recipe testRecipe;

    setUp(() {
      testAssignment = MealAssignment(
        id: 'assign-1',
        recipeId: 'recipe-1',
        dayIsoDate: '2025-10-27',
        assignedAt: DateTime(2025, 10, 27, 10, 0),
      );

      testRecipe = const Recipe(
        id: 'recipe-1',
        title: 'Spaghetti Carbonara',
        imageUrl: 'https://example.com/image.jpg',
        description: 'Classic Italian pasta',
        notes: 'Test notes',
        preReqs: [],
        totalTime: 30.0,
        ingredients: [
          Ingredient(
            name: 'Pasta',
            ucumUnit: UcumUnit.cup_us,
            ucumAmount: 2.0,
            metricUnit: MetricUnit.g,
            metricAmount: 200.0,
            notes: '',
          ),
          Ingredient(
            name: 'Eggs',
            ucumUnit: UcumUnit.cup_us,
            ucumAmount: 0.5,
            metricUnit: MetricUnit.g,
            metricAmount: 100.0,
            notes: '',
          ),
        ],
        steps: ['Boil pasta', 'Mix eggs'],
      );
    });

    testWidgets('displays recipe title and cook time', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealAssignmentWidget(
              assignment: testAssignment,
              recipe: testRecipe,
            ),
          ),
        ),
      );

      expect(find.text('Spaghetti Carbonara'), findsOneWidget);
      expect(find.text('30 min'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('shows ingredient count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealAssignmentWidget(
              assignment: testAssignment,
              recipe: testRecipe,
            ),
          ),
        ),
      );

      expect(find.text('2 ingredients'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_basket_outlined), findsOneWidget);
    });

    testWidgets('calls onUnassign when unassign button tapped',
        (tester) async {
      var unassignCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealAssignmentWidget(
              assignment: testAssignment,
              recipe: testRecipe,
              onUnassign: () => unassignCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(unassignCalled, true);
    });

    testWidgets('calls onTap when card tapped', (tester) async {
      var tapCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealAssignmentWidget(
              assignment: testAssignment,
              recipe: testRecipe,
              onTap: () => tapCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(tapCalled, true);
    });
  });
}
