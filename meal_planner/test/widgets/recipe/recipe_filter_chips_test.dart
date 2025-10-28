import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/widgets/recipe/recipe_filter_chips.dart';

void main() {
  group('RecipeFilterChips', () {
    testWidgets('displays allergen chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeFilterChips(
              onAllergenChanged: (_) {},
              onMaxTimeChanged: (_) {},
              onIngredientsChanged: (_) {},
              selectedAllergens: const [],
              selectedIngredients: const [],
            ),
          ),
        ),
      );

      expect(find.text('GLUTEN'), findsOneWidget);
      expect(find.text('PEANUT'), findsOneWidget);
      expect(find.text('MILK'), findsOneWidget);
      expect(find.text('EGG'), findsOneWidget);
    });

    testWidgets('toggles allergen selection', (tester) async {
      List<String> selectedAllergens = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return RecipeFilterChips(
                  onAllergenChanged: (allergens) {
                    setState(() {
                      selectedAllergens = allergens;
                    });
                  },
                  onMaxTimeChanged: (_) {},
                  onIngredientsChanged: (_) {},
                  selectedAllergens: selectedAllergens,
                  selectedIngredients: const [],
                );
              },
            ),
          ),
        ),
      );

      // Tap PEANUT chip
      await tester.tap(find.widgetWithText(FilterChip, 'PEANUT'));
      await tester.pump();

      expect(selectedAllergens, contains('PEANUT'));

      // Tap PEANUT again to deselect
      await tester.tap(find.widgetWithText(FilterChip, 'PEANUT'));
      await tester.pump();

      expect(selectedAllergens, isNot(contains('PEANUT')));
    });

    testWidgets('updates max cook time slider', (tester) async {
      int? maxTime;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return RecipeFilterChips(
                  onAllergenChanged: (_) {},
                  onMaxTimeChanged: (minutes) {
                    setState(() {
                      maxTime = minutes;
                    });
                  },
                  onIngredientsChanged: (_) {},
                  selectedAllergens: const [],
                  selectedMaxTime: maxTime,
                  selectedIngredients: const [],
                );
              },
            ),
          ),
        ),
      );

      // Find the slider
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Drag slider to 60 (middle)
      await tester.drag(slider, const Offset(-200, 0));
      await tester.pump();

      // Should have updated maxTime
      expect(maxTime, isNotNull);
      expect(maxTime! > 0, true);
    });

    testWidgets('calls callbacks on selection changes', (tester) async {
      List<String> allergens = [];
      int? maxTime;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeFilterChips(
              onAllergenChanged: (selected) {
                allergens = selected;
              },
              onMaxTimeChanged: (minutes) {
                maxTime = minutes;
              },
              onIngredientsChanged: (_) {},
              selectedAllergens: const [],
              selectedIngredients: const [],
            ),
          ),
        ),
      );

      // Select allergen
      await tester.tap(find.widgetWithText(FilterChip, 'GLUTEN'));
      await tester.pump();

      expect(allergens, contains('GLUTEN'));
    });

    testWidgets('resets all filters', (tester) async {
      List<String> allergens = ['PEANUT', 'MILK'];
      int? maxTime = 60;
      List<String> ingredients = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return RecipeFilterChips(
                  onAllergenChanged: (selected) {
                    setState(() {
                      allergens = selected;
                    });
                  },
                  onMaxTimeChanged: (minutes) {
                    setState(() {
                      maxTime = minutes;
                    });
                  },
                  onIngredientsChanged: (items) {
                    setState(() {
                      ingredients = items;
                    });
                  },
                  selectedAllergens: allergens,
                  selectedMaxTime: maxTime,
                  selectedIngredients: ingredients,
                );
              },
            ),
          ),
        ),
      );

      // Reset button should be visible
      expect(find.text('Reset'), findsOneWidget);

      // Tap reset
      await tester.tap(find.text('Reset'));
      await tester.pump();

      expect(allergens, isEmpty);
      expect(maxTime, isNull);
      expect(ingredients, isEmpty);
    });
  });
}
