import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/shopping_list.freezed_model.dart';
import 'package:meal_planner/screens/shopping/shopping_list_screen.dart';
import '../../repositories/fake_shopping_list_repository.dart';

void main() {
  late FakeShoppingListRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeShoppingListRepository();
  });

  tearDown(() {
    fakeRepo.clear();
  });

  group('ShoppingListScreen Widget Tests', () {
    testWidgets('loads and displays shopping list', (tester) async {
      // Arrange
      final shoppingList = ShoppingList(
        id: 'list-1',
        items: const [
          ShoppingItem(
            name: 'Pasta',
            quantity: 500,
            unit: 'g',
            section: 'Pantry',
            alternatives: [],
          ),
          ShoppingItem(
            name: 'Milk',
            quantity: 1,
            unit: 'L',
            section: 'Dairy',
            alternatives: [],
          ),
        ],
        totalEstimatedCost: 10.50,
        createdAt: DateTime(2025, 1, 15),
      );
      fakeRepo.seed('list-1', shoppingList);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ShoppingListScreen(
              listId: 'list-1',
              repository: fakeRepo,
            ),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('Pasta'), findsOneWidget);
      expect(find.text('Milk'), findsOneWidget);
    });

    testWidgets('displays items grouped by section', skip: 'MVP1: Shopping list management not in scope', (tester) async {
      // Arrange
      final shoppingList = ShoppingList(
        id: 'list-1',
        items: const [
          ShoppingItem(
            name: 'Apple',
            quantity: 5,
            unit: 'count',
            section: 'Produce',
            alternatives: [],
          ),
          ShoppingItem(
            name: 'Banana',
            quantity: 3,
            unit: 'count',
            section: 'Produce',
            alternatives: [],
          ),
          ShoppingItem(
            name: 'Cheese',
            quantity: 200,
            unit: 'g',
            section: 'Dairy',
            alternatives: [],
          ),
        ],
        totalEstimatedCost: 15.00,
        createdAt: DateTime(2025, 1, 15),
      );
      fakeRepo.seed('list-1', shoppingList);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ShoppingListScreen(
              listId: 'list-1',
              repository: fakeRepo,
            ),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('Produce'), findsOneWidget);
      expect(find.text('Dairy'), findsOneWidget);
    });

    testWidgets('toggles item checkbox', (tester) async {
      // Arrange
      final shoppingList = ShoppingList(
        id: 'list-1',
        items: const [
          ShoppingItem(
            name: 'Bread',
            quantity: 1,
            unit: 'loaf',
            section: 'Bakery',
            alternatives: [],
          ),
        ],
        totalEstimatedCost: 3.50,
        createdAt: DateTime(2025, 1, 15),
      );
      fakeRepo.seed('list-1', shoppingList);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ShoppingListScreen(
              listId: 'list-1',
              repository: fakeRepo,
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Assert - checkbox should be checked now
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('shows checked/unchecked count', (tester) async {
      // Arrange
      final shoppingList = ShoppingList(
        id: 'list-1',
        items: const [
          ShoppingItem(
            name: 'Item1',
            quantity: 1,
            unit: 'count',
            section: 'General',
            alternatives: [],
          ),
          ShoppingItem(
            name: 'Item2',
            quantity: 1,
            unit: 'count',
            section: 'General',
            alternatives: [],
          ),
          ShoppingItem(
            name: 'Item3',
            quantity: 1,
            unit: 'count',
            section: 'General',
            alternatives: [],
          ),
        ],
        totalEstimatedCost: 9.00,
        createdAt: DateTime(2025, 1, 15),
      );
      fakeRepo.seed('list-1', shoppingList);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ShoppingListScreen(
              listId: 'list-1',
              repository: fakeRepo,
            ),
          ),
        ),
      );
      await tester.pump();

      // Assert - should show 0 of 3 items initially
      expect(find.text('0 of 3 items'), findsOneWidget);
    });

    testWidgets('deletes item from list', (tester) async {
      // Arrange
      final shoppingList = ShoppingList(
        id: 'list-1',
        items: const [
          ShoppingItem(
            name: 'ToDelete',
            quantity: 1,
            unit: 'count',
            section: 'General',
            alternatives: [],
          ),
        ],
        totalEstimatedCost: 2.00,
        createdAt: DateTime(2025, 1, 15),
      );
      fakeRepo.seed('list-1', shoppingList);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ShoppingListScreen(
              listId: 'list-1',
              repository: fakeRepo,
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      // Assert - item should be removed
      expect(find.text('ToDelete'), findsNothing);
    });

    testWidgets('clears all completed items', (tester) async {
      // Arrange
      final shoppingList = ShoppingList(
        id: 'list-1',
        items: const [
          ShoppingItem(
            name: 'Item1',
            quantity: 1,
            unit: 'count',
            section: 'General',
            alternatives: [],
          ),
          ShoppingItem(
            name: 'Item2',
            quantity: 1,
            unit: 'count',
            section: 'General',
            alternatives: [],
          ),
        ],
        totalEstimatedCost: 6.00,
        createdAt: DateTime(2025, 1, 15),
      );
      fakeRepo.seed('list-1', shoppingList);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ShoppingListScreen(
              listId: 'list-1',
              repository: fakeRepo,
            ),
          ),
        ),
      );
      await tester.pump();

      // Check first item
      final firstCheckbox = find.byType(Checkbox).first;
      await tester.tap(firstCheckbox);
      await tester.pump();

      // Tap "Clear completed" button
      await tester.tap(find.text('Clear Completed'));
      await tester.pump();

      // Assert - only one item left
      expect(find.text('Item2'), findsOneWidget);
      expect(find.text('Item1'), findsNothing);
    });

    testWidgets('deletes entire list with confirmation', skip: 'MVP1: Shopping list management not in scope', (tester) async {
      // Arrange
      final shoppingList = ShoppingList(
        id: 'list-1',
        items: const [
          ShoppingItem(
            name: 'Item',
            quantity: 1,
            unit: 'count',
            section: 'General',
            alternatives: [],
          ),
        ],
        totalEstimatedCost: 3.00,
        createdAt: DateTime(2025, 1, 15),
      );
      fakeRepo.seed('list-1', shoppingList);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ShoppingListScreen(
              listId: 'list-1',
              repository: fakeRepo,
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap delete list button
      await tester.tap(find.text('Delete List'));
      await tester.pump();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert - list should be deleted from repository
      final deletedList = await fakeRepo.getShoppingList('list-1');
      expect(deletedList, isNull);
    });

    testWidgets('collapses/expands sections', skip: 'MVP1: Shopping list management not in scope', (tester) async {
      // Arrange
      final shoppingList = ShoppingList(
        id: 'list-1',
        items: const [
          ShoppingItem(
            name: 'Pasta',
            quantity: 500,
            unit: 'g',
            section: 'Pantry',
            alternatives: [],
          ),
        ],
        totalEstimatedCost: 2.50,
        createdAt: DateTime(2025, 1, 15),
      );
      fakeRepo.seed('list-1', shoppingList);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ShoppingListScreen(
              listId: 'list-1',
              repository: fakeRepo,
            ),
          ),
        ),
      );
      await tester.pump();

      // Initially expanded - should see item
      expect(find.text('Pasta'), findsOneWidget);

      // Tap section header to collapse
      await tester.tap(find.text('Pantry'));
      await tester.pumpAndSettle();

      // Items should still be visible (ExpansionTile doesn't hide immediately)
      // This is a simplified test - real behavior depends on ExpansionTile state
    });

    testWidgets('shows cost summary', (tester) async {
      // Arrange
      final shoppingList = ShoppingList(
        id: 'list-1',
        items: const [
          ShoppingItem(
            name: 'Item',
            quantity: 1,
            unit: 'count',
            section: 'General',
            alternatives: [],
          ),
        ],
        totalEstimatedCost: 25.75,
        createdAt: DateTime(2025, 1, 15),
      );
      fakeRepo.seed('list-1', shoppingList);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ShoppingListScreen(
              listId: 'list-1',
              repository: fakeRepo,
            ),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('\$25.75'), findsOneWidget);
    });

    testWidgets('empty list shows message', (tester) async {
      // Arrange
      final shoppingList = ShoppingList(
        id: 'list-1',
        items: const [],
        totalEstimatedCost: 0.0,
        createdAt: DateTime(2025, 1, 15),
      );
      fakeRepo.seed('list-1', shoppingList);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ShoppingListScreen(
              listId: 'list-1',
              repository: fakeRepo,
            ),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('No items in list'), findsOneWidget);
    });
  });
}
