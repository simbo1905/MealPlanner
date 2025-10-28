import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/shopping_list.freezed_model.dart';
import 'package:meal_planner/widgets/shopping/shopping_list_section.dart';

void main() {
  group('ShoppingListSection Widget Tests', () {
    testWidgets('displays section header with item count', (tester) async {
      // Arrange
      final items = [
        const ShoppingItem(
          name: 'Milk',
          quantity: 1,
          unit: 'L',
          section: 'Dairy',
          alternatives: [],
        ),
        const ShoppingItem(
          name: 'Cheese',
          quantity: 200,
          unit: 'g',
          section: 'Dairy',
          alternatives: [],
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingListSection(
              section: 'Dairy',
              items: items,
              isExpanded: true,
              onExpandChanged: (_) {},
              onItemCheckChanged: (_, __) {},
              onItemDelete: (_) {},
              checkedItems: const {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Dairy'), findsOneWidget);
      expect(find.text('(2)'), findsOneWidget);
    });

    testWidgets('collapses/expands section on header tap', (tester) async {
      // Arrange
      final items = [
        const ShoppingItem(
          name: 'Pasta',
          quantity: 500,
          unit: 'g',
          section: 'Pantry',
          alternatives: [],
        ),
      ];
      bool? capturedExpandState;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingListSection(
              section: 'Pantry',
              items: items,
              isExpanded: false,
              onExpandChanged: (value) {
                capturedExpandState = value;
              },
              onItemCheckChanged: (_, __) {},
              onItemDelete: (_) {},
              checkedItems: const {},
            ),
          ),
        ),
      );

      // Tap the expansion tile
      await tester.tap(find.text('Pantry'));
      await tester.pump();

      // Assert
      expect(capturedExpandState, isTrue);
    });

    testWidgets('displays all items in section when expanded', (tester) async {
      // Arrange
      final items = [
        const ShoppingItem(
          name: 'Apple',
          quantity: 5,
          unit: 'count',
          section: 'Produce',
          alternatives: [],
        ),
        const ShoppingItem(
          name: 'Banana',
          quantity: 3,
          unit: 'count',
          section: 'Produce',
          alternatives: [],
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingListSection(
              section: 'Produce',
              items: items,
              isExpanded: true,
              onExpandChanged: (_) {},
              onItemCheckChanged: (_, __) {},
              onItemDelete: (_) {},
              checkedItems: const {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('calls onItemCheckChanged when item checkbox tapped',
        (tester) async {
      // Arrange
      final items = [
        const ShoppingItem(
          name: 'Bread',
          quantity: 1,
          unit: 'loaf',
          section: 'Bakery',
          alternatives: [],
        ),
      ];
      String? capturedItemName;
      bool? capturedCheckState;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingListSection(
              section: 'Bakery',
              items: items,
              isExpanded: true,
              onExpandChanged: (_) {},
              onItemCheckChanged: (itemName, isChecked) {
                capturedItemName = itemName;
                capturedCheckState = isChecked;
              },
              onItemDelete: (_) {},
              checkedItems: const {},
            ),
          ),
        ),
      );

      // Tap the checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Assert
      expect(capturedItemName, 'Bread');
      expect(capturedCheckState, isTrue);
    });

    testWidgets('calls onItemDelete when delete button tapped',
        (tester) async {
      // Arrange
      final items = [
        const ShoppingItem(
          name: 'Eggs',
          quantity: 12,
          unit: 'count',
          section: 'Dairy',
          alternatives: [],
        ),
      ];
      String? capturedItemName;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingListSection(
              section: 'Dairy',
              items: items,
              isExpanded: true,
              onExpandChanged: (_) {},
              onItemCheckChanged: (_, __) {},
              onItemDelete: (itemName) {
                capturedItemName = itemName;
              },
              checkedItems: const {},
            ),
          ),
        ),
      );

      // Tap the delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      // Assert
      expect(capturedItemName, 'Eggs');
    });
  });
}
