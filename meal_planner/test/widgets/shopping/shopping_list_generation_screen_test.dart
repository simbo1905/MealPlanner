import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/enums.dart';
import 'package:meal_planner/models/ingredient.freezed_model.dart';
import 'package:meal_planner/models/meal_assignment.freezed_model.dart';
import 'package:meal_planner/models/recipe.freezed_model.dart';
import 'package:meal_planner/providers/recipe_providers.dart';
import 'package:meal_planner/screens/shopping/shopping_list_generation_screen.dart';
import '../../repositories/fake_meal_assignment_repository.dart';
import '../../repositories/fake_recipe_repository.dart';
import '../../repositories/fake_shopping_list_repository.dart';

void main() {
  late FakeMealAssignmentRepository fakeAssignmentRepo;
  late FakeRecipeRepository fakeRecipeRepo;
  late FakeShoppingListRepository fakeListRepo;

  setUp(() {
    fakeAssignmentRepo = FakeMealAssignmentRepository();
    fakeRecipeRepo = FakeRecipeRepository();
    fakeListRepo = FakeShoppingListRepository();
  });

  tearDown(() {
    fakeAssignmentRepo.clear();
    fakeRecipeRepo.clear();
    fakeListRepo.clear();
  });

  group('ShoppingListGenerationScreen Widget Tests', () {
    testWidgets('displays date range picker', (tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipeRepositoryProvider.overrideWithValue(fakeRecipeRepo),
          ],
          child: MaterialApp(
            home: ShoppingListGenerationScreen(
              assignmentRepository: fakeAssignmentRepo,
              shoppingListRepository: fakeListRepo,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Select Date Range'), findsOneWidget);
    });

    testWidgets('displays meal assignments in selected range', (tester) async {
      // Arrange
      final recipe = Recipe(
        id: 'recipe-1',
        title: 'Pasta Bolognese',
        imageUrl: '',
        description: '',
        notes: '',
        preReqs: const [],
        totalTime: 30,
        ingredients: const [],
        steps: const [],
      );
      fakeRecipeRepo.seed('recipe-1', recipe);

      final assignment = MealAssignment(
        id: 'assign-1',
        recipeId: 'recipe-1',
        dayIsoDate: '2025-01-15',
        assignedAt: DateTime(2025, 1, 15),
      );
      fakeAssignmentRepo.seed('assign-1', assignment);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recipeRepositoryProvider.overrideWithValue(fakeRecipeRepo),
          ],
          child: MaterialApp(
            home: ShoppingListGenerationScreen(
              assignmentRepository: fakeAssignmentRepo,
              shoppingListRepository: fakeListRepo,
              initialStartDate: DateTime(2025, 1, 15),
            ),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('Pasta Bolognese'), findsOneWidget);
    });

    testWidgets('toggles assignment selection', (tester) async {
      // Arrange
      final recipe = Recipe(
        id: 'recipe-1',
        title: 'Test Recipe',
        imageUrl: '',
        description: '',
        notes: '',
        preReqs: const [],
        totalTime: 20,
        ingredients: const [],
        steps: const [],
      );
      fakeRecipeRepo.seed('recipe-1', recipe);

      final assignment = MealAssignment(
        id: 'assign-1',
        recipeId: 'recipe-1',
        dayIsoDate: '2025-01-15',
        assignedAt: DateTime(2025, 1, 15),
      );
      fakeAssignmentRepo.seed('assign-1', assignment);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ShoppingListGenerationScreen(
              assignmentRepository: fakeAssignmentRepo,
              shoppingListRepository: fakeListRepo,
              initialStartDate: DateTime(2025, 1, 15),
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Assert - checkbox should be checked
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('shows selected count', (tester) async {
      // Arrange
      final recipe = Recipe(
        id: 'recipe-1',
        title: 'Test Recipe',
        imageUrl: '',
        description: '',
        notes: '',
        preReqs: const [],
        totalTime: 20,
        ingredients: const [],
        steps: const [],
      );
      fakeRecipeRepo.seed('recipe-1', recipe);

      final assignment = MealAssignment(
        id: 'assign-1',
        recipeId: 'recipe-1',
        dayIsoDate: '2025-01-15',
        assignedAt: DateTime(2025, 1, 15),
      );
      fakeAssignmentRepo.seed('assign-1', assignment);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ShoppingListGenerationScreen(
              assignmentRepository: fakeAssignmentRepo,
              shoppingListRepository: fakeListRepo,
              initialStartDate: DateTime(2025, 1, 15),
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap checkbox to select
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Assert
      expect(find.text('1 selected'), findsOneWidget);
    });

    testWidgets('generates shopping list on button tap', skip: 'MVP1: Shopping list generation requires Firebase Firestore', (tester) async {
      // Arrange
      final recipe = Recipe(
        id: 'recipe-1',
        title: 'Pasta',
        imageUrl: '',
        description: '',
        notes: '',
        preReqs: const [],
        totalTime: 20,
        ingredients: const [
          Ingredient(
            name: 'Pasta',
            ucumUnit: UcumUnit.cupUs,
            ucumAmount: 2,
            metricUnit: MetricUnit.g,
            metricAmount: 500,
            notes: '',
          ),
        ],
        steps: const [],
      );
      fakeRecipeRepo.seed('recipe-1', recipe);

      final assignment = MealAssignment(
        id: 'assign-1',
        recipeId: 'recipe-1',
        dayIsoDate: '2025-01-15',
        assignedAt: DateTime(2025, 1, 15),
      );
      fakeAssignmentRepo.seed('assign-1', assignment);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ShoppingListGenerationScreen(
              assignmentRepository: fakeAssignmentRepo,
              shoppingListRepository: fakeListRepo,
              initialStartDate: DateTime(2025, 1, 15),
            ),
          ),
        ),
      );
      await tester.pump();

      // Select assignment
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Tap generate button
      await tester.tap(find.text('Generate List'));
      await tester.pump();

      // Assert - should show preview
      expect(find.text('Preview'), findsOneWidget);
    });

    testWidgets('aggregates items from multiple recipes', skip: 'MVP1: Shopping list generation requires Firebase Firestore', (tester) async {
      // Arrange
      final recipe1 = Recipe(
        id: 'recipe-1',
        title: 'Recipe 1',
        imageUrl: '',
        description: '',
        notes: '',
        preReqs: const [],
        totalTime: 20,
        ingredients: const [
          Ingredient(
            name: 'Pasta',
            ucumUnit: UcumUnit.cupUs,
            ucumAmount: 2,
            metricUnit: MetricUnit.g,
            metricAmount: 500,
            notes: '',
          ),
        ],
        steps: const [],
      );
      final recipe2 = Recipe(
        id: 'recipe-2',
        title: 'Recipe 2',
        imageUrl: '',
        description: '',
        notes: '',
        preReqs: const [],
        totalTime: 20,
        ingredients: const [
          Ingredient(
            name: 'Pasta',
            ucumUnit: UcumUnit.cupUs,
            ucumAmount: 1,
            metricUnit: MetricUnit.g,
            metricAmount: 250,
            notes: '',
          ),
        ],
        steps: const [],
      );
      fakeRecipeRepo.seed('recipe-1', recipe1);
      fakeRecipeRepo.seed('recipe-2', recipe2);

      fakeAssignmentRepo.seed(
        'assign-1',
        MealAssignment(
          id: 'assign-1',
          recipeId: 'recipe-1',
          dayIsoDate: '2025-01-15',
          assignedAt: DateTime(2025, 1, 15),
        ),
      );
      fakeAssignmentRepo.seed(
        'assign-2',
        MealAssignment(
          id: 'assign-2',
          recipeId: 'recipe-2',
          dayIsoDate: '2025-01-16',
          assignedAt: DateTime(2025, 1, 16),
        ),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ShoppingListGenerationScreen(
              assignmentRepository: fakeAssignmentRepo,
              shoppingListRepository: fakeListRepo,
              initialStartDate: DateTime(2025, 1, 15),
            ),
          ),
        ),
      );
      await tester.pump();

      // Select both assignments
      final checkboxes = find.byType(Checkbox);
      await tester.tap(checkboxes.first);
      await tester.pump();
      await tester.tap(checkboxes.last);
      await tester.pump();

      // Generate
      await tester.tap(find.text('Generate List'));
      await tester.pump();

      // Assert - should aggregate to 750g of Pasta
      expect(find.text('750.0 g'), findsOneWidget);
    });

    testWidgets('groups items by section in preview', skip: 'MVP1: Shopping list generation requires Firebase Firestore', (tester) async {
      // Arrange
      final recipe = Recipe(
        id: 'recipe-1',
        title: 'Recipe',
        imageUrl: '',
        description: '',
        notes: '',
        preReqs: const [],
        totalTime: 20,
        ingredients: const [
          Ingredient(
            name: 'Milk',
            ucumUnit: UcumUnit.cupUs,
            ucumAmount: 1,
            metricUnit: MetricUnit.ml,
            metricAmount: 250,
            notes: '',
          ),
        ],
        steps: const [],
      );
      fakeRecipeRepo.seed('recipe-1', recipe);

      fakeAssignmentRepo.seed(
        'assign-1',
        MealAssignment(
          id: 'assign-1',
          recipeId: 'recipe-1',
          dayIsoDate: '2025-01-15',
          assignedAt: DateTime(2025, 1, 15),
        ),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ShoppingListGenerationScreen(
              assignmentRepository: fakeAssignmentRepo,
              shoppingListRepository: fakeListRepo,
              initialStartDate: DateTime(2025, 1, 15),
            ),
          ),
        ),
      );
      await tester.pump();

      // Select and generate
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.text('Generate List'));
      await tester.pump();

      // Assert - should show section
      expect(find.text('General'), findsOneWidget);
    });

    testWidgets('shows success message after save', skip: 'MVP1: Shopping list generation requires Firebase Firestore', (tester) async {
      // Arrange
      final recipe = Recipe(
        id: 'recipe-1',
        title: 'Recipe',
        imageUrl: '',
        description: '',
        notes: '',
        preReqs: const [],
        totalTime: 20,
        ingredients: const [
          Ingredient(
            name: 'Item',
            ucumUnit: UcumUnit.cupUs,
            ucumAmount: 1,
            metricUnit: MetricUnit.g,
            metricAmount: 100,
            notes: '',
          ),
        ],
        steps: const [],
      );
      fakeRecipeRepo.seed('recipe-1', recipe);

      fakeAssignmentRepo.seed(
        'assign-1',
        MealAssignment(
          id: 'assign-1',
          recipeId: 'recipe-1',
          dayIsoDate: '2025-01-15',
          assignedAt: DateTime(2025, 1, 15),
        ),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ShoppingListGenerationScreen(
              assignmentRepository: fakeAssignmentRepo,
              shoppingListRepository: fakeListRepo,
              initialStartDate: DateTime(2025, 1, 15),
            ),
          ),
        ),
      );
      await tester.pump();

      // Select, generate, and save
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.text('Generate List'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Assert - should show snackbar
      expect(find.text('Shopping list saved'), findsOneWidget);
    });
  });
}
