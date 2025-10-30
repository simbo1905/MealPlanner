import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/recipe.freezed_model.dart';
import 'package:meal_planner/models/ingredient.freezed_model.dart';
import 'package:meal_planner/models/enums.dart';
import 'package:meal_planner/widgets/recipe/recipe_card.dart';

void main() {
  group('RecipeCard', () {
    testWidgets('displays recipe title and time', (tester) async {
      final recipe = Recipe(
        id: 'recipe-1',
        title: 'Test Recipe',
        imageUrl: '',
        description: 'A test recipe',
        notes: '',
        preReqs: [],
        totalTime: 30.0,
        ingredients: [
          const Ingredient(
            name: 'Salt',
            ucumUnit: UcumUnit.tspUs,
            ucumAmount: 1.0,
            metricUnit: MetricUnit.g,
            metricAmount: 5.0,
            notes: '',
          ),
        ],
        steps: ['Step 1'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Recipe'), findsOneWidget);
      expect(find.text('30 min'), findsOneWidget);
      expect(find.text('1 ingredients'), findsOneWidget);
    });

    testWidgets('shows allergen badges when present', skip: 'MVP1: Allergen display not implemented', (tester) async {
      final recipe = Recipe(
        id: 'recipe-2',
        title: 'Peanut Butter Toast',
        imageUrl: '',
        description: 'Toast with peanut butter',
        notes: '',
        preReqs: [],
        totalTime: 5.0,
        ingredients: [
          const Ingredient(
            name: 'Peanut Butter',
            ucumUnit: UcumUnit.tbspUs,
            ucumAmount: 2.0,
            metricUnit: MetricUnit.g,
            metricAmount: 30.0,
            notes: '',
            allergenCode: AllergenCode.peanut,
          ),
          const Ingredient(
            name: 'Bread',
            ucumUnit: UcumUnit.cupUs,
            ucumAmount: 1.0,
            metricUnit: MetricUnit.g,
            metricAmount: 50.0,
            notes: '',
            allergenCode: AllergenCode.gluten,
          ),
        ],
        steps: ['Toast bread', 'Spread peanut butter'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('PEANUT'), findsOneWidget);
      expect(find.text('GLUTEN'), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      var tapped = false;
      final recipe = Recipe(
        id: 'recipe-3',
        title: 'Tappable Recipe',
        imageUrl: '',
        description: 'Test tap',
        notes: '',
        preReqs: [],
        totalTime: 15.0,
        ingredients: [],
        steps: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipe,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(RecipeCard));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('shows placeholder image when imageUrl is empty', (tester) async {
      final recipe = Recipe(
        id: 'recipe-4',
        title: 'No Image Recipe',
        imageUrl: '',
        description: 'Recipe without image',
        notes: '',
        preReqs: [],
        totalTime: 20.0,
        ingredients: [],
        steps: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: recipe,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });
  });
}
