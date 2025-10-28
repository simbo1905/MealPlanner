import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/models/workspace_recipe.freezed_model.dart';
import 'package:meal_planner/models/recipe.freezed_model.dart';
import 'package:meal_planner/models/ingredient.freezed_model.dart';
import 'package:meal_planner/models/enums.dart';
import 'package:meal_planner/screens/onboarding/recipe_review_screen.dart';

void main() {
  group('RecipeReviewScreen', () {
    late WorkspaceRecipe testWorkspace;

    setUp(() {
      final testRecipe = const Recipe(
        id: 'recipe-1',
        title: 'Test Recipe',
        imageUrl: 'test://image.jpg',
        description: 'Test description',
        notes: 'Test notes',
        preReqs: [],
        totalTime: 30.0,
        ingredients: [
          Ingredient(
            name: 'Test Ingredient',
            ucumAmount: 1.0,
            ucumUnit: UcumUnit.cupUs,
            metricAmount: 100.0,
            metricUnit: MetricUnit.g,
            notes: '',
          ),
        ],
        steps: ['Step 1'],
      );

      testWorkspace = WorkspaceRecipe(
        id: 'workspace-1',
        recipe: testRecipe,
        status: WorkspaceRecipeStatus.draft,
        missingFields: [],
        photoIds: [],
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
    });

    testWidgets('displays workspace recipe', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RecipeReviewScreen(workspace: testWorkspace),
          ),
        ),
      );

      expect(find.text('Test Recipe'), findsOneWidget);
      expect(find.text('Accept & Save'), findsOneWidget);
    });

    testWidgets('shows discard button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RecipeReviewScreen(workspace: testWorkspace),
          ),
        ),
      );

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('edit recipe title updates workspace', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RecipeReviewScreen(workspace: testWorkspace),
          ),
        ),
      );

      final titleField = find.widgetWithText(TextField, 'Test Recipe');
      await tester.enterText(titleField, 'Updated Recipe');
      await tester.pump();

      // Widget should update
      expect(find.text('Updated Recipe'), findsOneWidget);
    });

    testWidgets('tap discard shows confirmation dialog', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RecipeReviewScreen(workspace: testWorkspace),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Discard Recipe?'), findsOneWidget);
      expect(find.text('Are you sure you want to discard this recipe?'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
    });

    testWidgets('cancel in discard dialog keeps recipe', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RecipeReviewScreen(workspace: testWorkspace),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Tap Cancel in dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Should still be on review screen
      expect(find.text('Review Recipe'), findsOneWidget);
    });

    testWidgets('confirm discard pops screen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeReviewScreen(workspace: testWorkspace),
                        ),
                      );
                    },
                    child: const Text('Open Review'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Open review screen
      await tester.tap(find.text('Open Review'));
      await tester.pumpAndSettle();

      // Tap discard
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Confirm discard
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      // Should be back to main screen
      expect(find.text('Open Review'), findsOneWidget);
    });

    testWidgets('displays recipe workspace widget', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RecipeReviewScreen(workspace: testWorkspace),
          ),
        ),
      );

      // Should show ingredients section
      expect(find.text('Ingredients'), findsOneWidget);
      expect(find.text('Test Ingredient'), findsOneWidget);
    });

    testWidgets('bottom button bar is visible', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RecipeReviewScreen(workspace: testWorkspace),
          ),
        ),
      );

      expect(find.text('Accept & Save'), findsOneWidget);
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Accept & Save'),
      );
      expect(button.onPressed, isNotNull); // Button should be enabled
    });

    testWidgets('shows Accept & Save button at bottom', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RecipeReviewScreen(workspace: testWorkspace),
          ),
        ),
      );

      expect(find.text('Accept & Save'), findsOneWidget);
    });
  });
}
