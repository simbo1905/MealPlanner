import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Use widget-test binding for headless runs when web devices are unavailable.
// Keeping this under integration_test/ so it can be promoted to device runs later.
import 'package:meal_planner/widgets/recipe/recipe_search_autocomplete.dart';

void main() {
  // Fallback to default binding to avoid device requirement in headless runs.
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('recipe search shows beef results (fake data)', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: RecipeSearchAutocomplete(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final searchField = find.byKey(const Key('recipe-search-field'));
    expect(searchField, findsOneWidget);

    await tester.tap(searchField);
    await tester.enterText(searchField, 'Beef');
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Expect a known fake recipe from FakeRecipesV1Repository
    expect(find.textContaining('Beef'), findsWidgets);
    expect(find.text('Beef Tacos'), findsOneWidget);
  });
}
