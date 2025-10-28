import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/workspace_recipe.freezed_model.dart';
import 'package:meal_planner/models/recipe.freezed_model.dart';
import 'package:meal_planner/models/ingredient.freezed_model.dart';
import 'package:meal_planner/models/enums.dart';
import 'package:meal_planner/widgets/onboarding/recipe_workspace_widget.dart';

void main() {
  group('RecipeWorkspaceWidget', () {
    late WorkspaceRecipe testWorkspace;

    setUp(() {
      final testRecipe = const Recipe(
        id: 'recipe-1',
        title: 'Pasta Carbonara',
        imageUrl: 'https://example.com/image.jpg',
        description: 'Classic Italian pasta',
        notes: 'Use fresh eggs',
        preReqs: [],
        totalTime: 30.0,
        ingredients: [
          Ingredient(
            name: 'Pasta',
            ucumAmount: 2.0,
            ucumUnit: UcumUnit.cup_us,
            metricAmount: 500.0,
            metricUnit: MetricUnit.g,
            notes: '',
          ),
        ],
        steps: ['Boil water', 'Cook pasta', 'Mix ingredients'],
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

    testWidgets('displays all recipe fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeWorkspaceWidget(
              workspace: testWorkspace,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Pasta Carbonara'), findsOneWidget);
      expect(find.text('https://example.com/image.jpg'), findsOneWidget);
      expect(find.text('Classic Italian pasta'), findsOneWidget);
      expect(find.text('Use fresh eggs'), findsOneWidget);
      expect(find.text('30.0'), findsOneWidget);
    });

    testWidgets('edit title field and call onChanged', (tester) async {
      WorkspaceRecipe? changedWorkspace;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeWorkspaceWidget(
              workspace: testWorkspace,
              onChanged: (workspace) {
                changedWorkspace = workspace;
              },
            ),
          ),
        ),
      );

      final titleField = find.widgetWithText(TextField, 'Pasta Carbonara');
      await tester.enterText(titleField, 'Spaghetti Carbonara');
      await tester.pump();

      expect(changedWorkspace, isNotNull);
      expect(changedWorkspace!.recipe.title, 'Spaghetti Carbonara');
    });

    testWidgets('edit description field', (tester) async {
      WorkspaceRecipe? changedWorkspace;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeWorkspaceWidget(
              workspace: testWorkspace,
              onChanged: (workspace) {
                changedWorkspace = workspace;
              },
            ),
          ),
        ),
      );

      final descField =
          find.widgetWithText(TextField, 'Classic Italian pasta');
      await tester.enterText(descField, 'Updated description');
      await tester.pump();

      expect(changedWorkspace, isNotNull);
      expect(changedWorkspace!.recipe.description, 'Updated description');
    });

    testWidgets('displays ingredients list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeWorkspaceWidget(
              workspace: testWorkspace,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Ingredients'), findsOneWidget);
      expect(find.text('Pasta'), findsOneWidget);
    });

    testWidgets('add ingredient to list', (tester) async {
      WorkspaceRecipe? changedWorkspace;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeWorkspaceWidget(
              workspace: testWorkspace,
              onChanged: (workspace) {
                changedWorkspace = workspace;
              },
            ),
          ),
        ),
      );

      // Find and tap add ingredient button
      final addButton = find.ancestor(
        of: find.byIcon(Icons.add),
        matching: find.byType(IconButton),
      ).first;
      await tester.tap(addButton);
      await tester.pump();

      expect(changedWorkspace, isNotNull);
      expect(changedWorkspace!.recipe.ingredients.length, 2);
      expect(changedWorkspace!.recipe.ingredients.last.name, '');
    });

    testWidgets('remove ingredient from list', (tester) async {
      WorkspaceRecipe? changedWorkspace;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeWorkspaceWidget(
              workspace: testWorkspace,
              onChanged: (workspace) {
                changedWorkspace = workspace;
              },
            ),
          ),
        ),
      );

      // Find and tap remove button (X icon in WorkspaceIngredientField)
      final removeButton = find.byIcon(Icons.close).first;
      await tester.tap(removeButton);
      await tester.pump();

      expect(changedWorkspace, isNotNull);
      expect(changedWorkspace!.recipe.ingredients.length, 0);
    });

    testWidgets('edit ingredient details', (tester) async {
      WorkspaceRecipe? changedWorkspace;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeWorkspaceWidget(
              workspace: testWorkspace,
              onChanged: (workspace) {
                changedWorkspace = workspace;
              },
            ),
          ),
        ),
      );

      // Find the ingredient name field and change it
      final ingredientNameField = find.widgetWithText(TextField, 'Pasta');
      await tester.enterText(ingredientNameField, 'Spaghetti');
      await tester.pump();

      expect(changedWorkspace, isNotNull);
      expect(changedWorkspace!.recipe.ingredients.first.name, 'Spaghetti');
    });

    testWidgets('add step to list', (tester) async {
      WorkspaceRecipe? changedWorkspace;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeWorkspaceWidget(
              workspace: testWorkspace,
              onChanged: (workspace) {
                changedWorkspace = workspace;
              },
            ),
          ),
        ),
      );

      // Scroll to the Steps section
      await tester.dragUntilVisible(
        find.text('Steps'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      // Find and tap add step button (second add button)
      final addButtons = find.byIcon(Icons.add);
      await tester.tap(addButtons.last);
      await tester.pump();

      expect(changedWorkspace, isNotNull);
      expect(changedWorkspace!.recipe.steps.length, 4);
      expect(changedWorkspace!.recipe.steps.last, '');
    });

    testWidgets('remove step from list', (tester) async {
      WorkspaceRecipe? changedWorkspace;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeWorkspaceWidget(
              workspace: testWorkspace,
              onChanged: (workspace) {
                changedWorkspace = workspace;
              },
            ),
          ),
        ),
      );

      // Scroll to the Steps section
      await tester.dragUntilVisible(
        find.text('Steps'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      // Find and tap remove button for first step
      // Skip the ingredient's close button (first one)
      final closeButtons = find.byIcon(Icons.close);
      await tester.tap(closeButtons.at(1)); // Second close button is first step
      await tester.pump();

      expect(changedWorkspace, isNotNull);
      expect(changedWorkspace!.recipe.steps.length, 2);
      expect(changedWorkspace!.recipe.steps.first, 'Cook pasta');
    });

    testWidgets('read-only mode disables all edits', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeWorkspaceWidget(
              workspace: testWorkspace,
              onChanged: (_) {},
              readOnly: true,
            ),
          ),
        ),
      );

      // Check that add buttons are not present
      expect(find.byIcon(Icons.add), findsNothing);

      // Check that title field is read-only
      final titleField =
          tester.widget<TextField>(find.widgetWithText(TextField, 'Pasta Carbonara'));
      expect(titleField.readOnly, true);
    });
  });
}
