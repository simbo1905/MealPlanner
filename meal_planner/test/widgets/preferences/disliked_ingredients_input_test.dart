import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/widgets/preferences/disliked_ingredients_input.dart';

void main() {
  group('DislikedIngredientsInput', () {
    testWidgets('display existing disliked ingredients as chips',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DislikedIngredientsInput(
              dislikedIngredients: const ['onions', 'cilantro', 'mushrooms'],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Disliked Ingredients'), findsOneWidget);
      expect(find.text('onions'), findsOneWidget);
      expect(find.text('cilantro'), findsOneWidget);
      expect(find.text('mushrooms'), findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(3));
    });

    testWidgets('add ingredient by typing and pressing Enter', (tester) async {
      List<String> ingredients = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DislikedIngredientsInput(
                  dislikedIngredients: ingredients,
                  onChanged: (updated) {
                    setState(() {
                      ingredients = updated;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'garlic');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(ingredients, ['garlic']);
      expect(find.text('garlic'), findsOneWidget);
    });

    testWidgets('show autocomplete suggestions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DislikedIngredientsInput(
              dislikedIngredients: const [],
              onChanged: (_) {},
              existingIngredients: const [
                'onions',
                'garlic',
                'ginger',
                'cilantro',
              ],
            ),
          ),
        ),
      );

      // Type 'g' to trigger autocomplete
      await tester.enterText(find.byType(TextField), 'g');
      await tester.pumpAndSettle();

      // Should show suggestions containing 'g'
      expect(find.text('garlic'), findsOneWidget);
      expect(find.text('ginger'), findsOneWidget);
    });

    testWidgets('remove ingredient by tapping X', (tester) async {
      List<String> ingredients = ['onions', 'cilantro'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DislikedIngredientsInput(
                  dislikedIngredients: ingredients,
                  onChanged: (updated) {
                    setState(() {
                      ingredients = updated;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Find the first chip's delete button
      final deleteIcon = find.byIcon(Icons.close).first;
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      expect(ingredients.length, 1);
      expect(ingredients.contains('onions'), isFalse);
    });

    testWidgets('call onChanged on add/remove', (tester) async {
      List<String>? receivedList;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DislikedIngredientsInput(
              dislikedIngredients: const [],
              onChanged: (updated) {
                receivedList = updated;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'pepper');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(receivedList, ['pepper']);
    });

    testWidgets('prevent duplicate ingredients', (tester) async {
      List<String> ingredients = ['onions'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DislikedIngredientsInput(
                  dislikedIngredients: ingredients,
                  onChanged: (updated) {
                    setState(() {
                      ingredients = updated;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Try to add 'onions' again
      await tester.enterText(find.byType(TextField), 'onions');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Should still only have one
      expect(ingredients, ['onions']);
      expect(find.byType(Chip), findsOneWidget);
    });
  });
}
