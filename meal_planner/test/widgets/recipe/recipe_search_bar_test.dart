import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/widgets/recipe/recipe_search_bar.dart';

void main() {
  group('RecipeSearchBar', () {
    testWidgets('calls onChanged on text input', (tester) async {
      String? lastQuery;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeSearchBar(
              onChanged: (query) {
                lastQuery = query;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'pasta');
      await tester.pump();

      expect(lastQuery, 'pasta');
    });

    testWidgets('shows clear button when text entered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeSearchBar(
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // No clear button initially
      expect(find.byIcon(Icons.clear), findsNothing);

      // Enter text
      await tester.enterText(find.byType(TextField), 'chicken');
      await tester.pump();

      // Clear button appears
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clears text on clear button tap', (tester) async {
      String? lastQuery;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeSearchBar(
              onChanged: (query) {
                lastQuery = query;
              },
            ),
          ),
        ),
      );

      // Enter text
      await tester.enterText(find.byType(TextField), 'salad');
      await tester.pump();

      expect(lastQuery, 'salad');

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(lastQuery, '');
      expect(find.text('salad'), findsNothing);
    });
  });
}
