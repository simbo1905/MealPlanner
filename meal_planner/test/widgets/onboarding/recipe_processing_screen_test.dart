import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/models/workspace_recipe.freezed_model.dart';
import 'package:meal_planner/models/recipe.freezed_model.dart';
import 'package:meal_planner/models/ingredient.freezed_model.dart';
import 'package:meal_planner/models/enums.dart';
import 'package:meal_planner/providers/ocr_provider.dart';
import 'package:meal_planner/screens/onboarding/recipe_processing_screen.dart';

void main() {
  group('RecipeProcessingScreen', () {
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
            ucumUnit: UcumUnit.cup_us,
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

    testWidgets('displays loading state with progress', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            processRecipeImageProvider('test://image.jpg').overrideWith(
              (ref) => Future.delayed(
                const Duration(seconds: 1),
                () => testWorkspace,
              ),
            ),
          ],
          child: MaterialApp(
            home: RecipeProcessingScreen(imagePath: 'test://image.jpg'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Analyzing recipe...'), findsOneWidget);
      expect(find.text('OCR processing'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('shows image preview', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            processRecipeImageProvider('test://image.jpg').overrideWith(
              (ref) => Future.value(testWorkspace),
            ),
          ],
          child: MaterialApp(
            home: RecipeProcessingScreen(imagePath: 'test://image.jpg'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('navigates to review screen on success', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            processRecipeImageProvider('test://image.jpg').overrideWith(
              (ref) => Future.value(testWorkspace),
            ),
          ],
          child: MaterialApp(
            home: RecipeProcessingScreen(imagePath: 'test://image.jpg'),
          ),
        ),
      );

      // Wait for the future to complete
      await tester.pumpAndSettle();

      // Should have navigated to review screen
      expect(find.text('Review Recipe'), findsOneWidget);
    });

    testWidgets('shows error message on failure', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            processRecipeImageProvider('test://image.jpg').overrideWith(
              (ref) => Future.error('Processing failed'),
            ),
          ],
          child: MaterialApp(
            home: RecipeProcessingScreen(imagePath: 'test://image.jpg'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Error processing recipe'), findsOneWidget);
      expect(find.text('Processing failed'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows retry button on error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            processRecipeImageProvider('test://image.jpg').overrideWith(
              (ref) => Future.error('Processing failed'),
            ),
          ],
          child: MaterialApp(
            home: RecipeProcessingScreen(imagePath: 'test://image.jpg'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('shows cancel button on error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            processRecipeImageProvider('test://image.jpg').overrideWith(
              (ref) => Future.error('Processing failed'),
            ),
          ],
          child: MaterialApp(
            home: RecipeProcessingScreen(imagePath: 'test://image.jpg'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('cancel button pops screen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            processRecipeImageProvider('test://image.jpg').overrideWith(
              (ref) => Future.error('Processing failed'),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeProcessingScreen(
                            imagePath: 'test://image.jpg',
                          ),
                        ),
                      );
                    },
                    child: const Text('Open Processing'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Open processing screen
      await tester.tap(find.text('Open Processing'));
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Should be back to main screen
      expect(find.text('Open Processing'), findsOneWidget);
    });

    testWidgets('retry button refreshes processing', (tester) async {
      var callCount = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            processRecipeImageProvider('test://image.jpg').overrideWith(
              (ref) {
                callCount++;
                return Future.error('Processing failed');
              },
            ),
          ],
          child: MaterialApp(
            home: RecipeProcessingScreen(imagePath: 'test://image.jpg'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // First call
      expect(callCount, 1);

      // Tap retry
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Should have called again
      expect(callCount, 2);
    });
  });
}
