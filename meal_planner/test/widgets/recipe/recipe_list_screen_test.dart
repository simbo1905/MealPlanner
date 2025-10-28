import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/models/recipe.freezed_model.dart';
import 'package:meal_planner/models/ingredient.freezed_model.dart';
import 'package:meal_planner/models/enums.dart';
import 'package:meal_planner/providers/recipe_providers.dart';
import 'package:meal_planner/screens/recipe/recipe_list_screen.dart';
import '../../repositories/fake_recipe_repository.dart';

void main() {
  late FakeRecipeRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeRecipeRepository();
  });

  tearDown(() {
    fakeRepo.clear();
  });

  group('RecipeListScreen', () {
    testWidgets('displays empty state when no recipes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipeRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: RecipeListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No recipes found'), findsOneWidget);
    });

    testWidgets('displays list of recipes when loaded', (tester) async {
      final recipe1 = Recipe(
        id: 'recipe-1',
        title: 'Pasta Carbonara',
        imageUrl: '',
        description: 'Classic Italian pasta',
        notes: '',
        preReqs: [],
        totalTime: 30.0,
        ingredients: [
          const Ingredient(
            name: 'Pasta',
            ucumUnit: UcumUnit.cupUs,
            ucumAmount: 2.0,
            metricUnit: MetricUnit.g,
            metricAmount: 200.0,
            notes: '',
          ),
        ],
        steps: ['Cook pasta'],
      );

      final recipe2 = Recipe(
        id: 'recipe-2',
        title: 'Caesar Salad',
        imageUrl: '',
        description: 'Fresh salad',
        notes: '',
        preReqs: [],
        totalTime: 15.0,
        ingredients: [
          const Ingredient(
            name: 'Lettuce',
            ucumUnit: UcumUnit.cupUs,
            ucumAmount: 2.0,
            metricUnit: MetricUnit.g,
            metricAmount: 100.0,
            notes: '',
          ),
        ],
        steps: ['Chop lettuce'],
      );

      fakeRepo.seed('recipe-1', recipe1);
      fakeRepo.seed('recipe-2', recipe2);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipeRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: RecipeListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Pasta Carbonara'), findsOneWidget);
      expect(find.text('Caesar Salad'), findsOneWidget);
    });

    testWidgets('navigates to detail screen on recipe tap', (tester) async {
      final recipe = Recipe(
        id: 'recipe-1',
        title: 'Tappable Recipe',
        imageUrl: '',
        description: 'Test',
        notes: '',
        preReqs: [],
        totalTime: 10.0,
        ingredients: [],
        steps: [],
      );

      fakeRepo.seed('recipe-1', recipe);

      String? navigatedRoute;
      Object? navigatedArgs;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipeRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            home: const RecipeListScreen(),
            onGenerateRoute: (settings) {
              navigatedRoute = settings.name;
              navigatedArgs = settings.arguments;
              return null;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Tappable Recipe'));
      await tester.pump();

      expect(navigatedRoute, '/recipe-detail');
      expect(navigatedArgs, 'recipe-1');
    });

    testWidgets('navigates to form screen on FAB tap', (tester) async {
      String? navigatedRoute;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipeRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            home: const RecipeListScreen(),
            onGenerateRoute: (settings) {
              navigatedRoute = settings.name;
              return null;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(navigatedRoute, '/recipe-form');
    });

    testWidgets('filters recipes by search query', (tester) async {
      final recipe1 = Recipe(
        id: 'recipe-1',
        title: 'Pasta Carbonara',
        imageUrl: '',
        description: 'Italian pasta',
        notes: '',
        preReqs: [],
        totalTime: 30.0,
        ingredients: [],
        steps: [],
      );

      final recipe2 = Recipe(
        id: 'recipe-2',
        title: 'Chicken Curry',
        imageUrl: '',
        description: 'Spicy curry',
        notes: '',
        preReqs: [],
        totalTime: 45.0,
        ingredients: [],
        steps: [],
      );

      fakeRepo.seed('recipe-1', recipe1);
      fakeRepo.seed('recipe-2', recipe2);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipeRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: RecipeListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Both recipes visible initially
      expect(find.text('Pasta Carbonara'), findsOneWidget);
      expect(find.text('Chicken Curry'), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField), 'pasta');
      await tester.pump();

      // Only pasta recipe should be visible
      expect(find.text('Pasta Carbonara'), findsOneWidget);
      expect(find.text('Chicken Curry'), findsNothing);
    });

    testWidgets('filters recipes by allergens', (tester) async {
      final recipe1 = Recipe(
        id: 'recipe-1',
        title: 'Peanut Butter Toast',
        imageUrl: '',
        description: 'Toast',
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
        ],
        steps: [],
      );

      final recipe2 = Recipe(
        id: 'recipe-2',
        title: 'Fruit Salad',
        imageUrl: '',
        description: 'Fresh fruit',
        notes: '',
        preReqs: [],
        totalTime: 10.0,
        ingredients: [
          const Ingredient(
            name: 'Apple',
            ucumUnit: UcumUnit.cupUs,
            ucumAmount: 1.0,
            metricUnit: MetricUnit.g,
            metricAmount: 100.0,
            notes: '',
          ),
        ],
        steps: [],
      );

      fakeRepo.seed('recipe-1', recipe1);
      fakeRepo.seed('recipe-2', recipe2);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipeRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: RecipeListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Both recipes visible initially
      expect(find.text('Peanut Butter Toast'), findsOneWidget);
      expect(find.text('Fruit Salad'), findsOneWidget);

      // Select PEANUT allergen to exclude
      await tester.tap(find.widgetWithText(FilterChip, 'PEANUT'));
      await tester.pump();

      // Only Fruit Salad should be visible
      expect(find.text('Peanut Butter Toast'), findsNothing);
      expect(find.text('Fruit Salad'), findsOneWidget);
    });

    testWidgets('filters recipes by max cook time', (tester) async {
      final recipe1 = Recipe(
        id: 'recipe-1',
        title: 'Quick Snack',
        imageUrl: '',
        description: '5 min recipe',
        notes: '',
        preReqs: [],
        totalTime: 5.0,
        ingredients: [],
        steps: [],
      );

      final recipe2 = Recipe(
        id: 'recipe-2',
        title: 'Long Dinner',
        imageUrl: '',
        description: '120 min recipe',
        notes: '',
        preReqs: [],
        totalTime: 120.0,
        ingredients: [],
        steps: [],
      );

      fakeRepo.seed('recipe-1', recipe1);
      fakeRepo.seed('recipe-2', recipe2);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipeRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: RecipeListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Both recipes visible initially
      expect(find.text('Quick Snack'), findsOneWidget);
      expect(find.text('Long Dinner'), findsOneWidget);

      // Drag slider to lower value (left)
      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(-500, 0));
      await tester.pump();

      // Only Quick Snack should be visible
      expect(find.text('Quick Snack'), findsOneWidget);
      expect(find.text('Long Dinner'), findsNothing);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipeRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: RecipeListScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
