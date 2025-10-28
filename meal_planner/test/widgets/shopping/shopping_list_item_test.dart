import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/shopping_list.freezed_model.dart';
import 'package:meal_planner/widgets/shopping/shopping_list_item.dart';

void main() {
  group('ShoppingListItem Widget Tests', () {
    testWidgets('displays item name, quantity, and unit', (tester) async {
      // Arrange
      final item = ShoppingItem(
        name: 'Pasta',
        quantity: 500,
        unit: 'g',
        section: 'Pantry',
        alternatives: [],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingListItem(
              item: item,
              isChecked: false,
              onCheckChanged: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Pasta'), findsOneWidget);
      expect(find.text('500.0 g'), findsOneWidget);
    });

    testWidgets('shows section badge', (tester) async {
      // Arrange
      final item = ShoppingItem(
        name: 'Milk',
        quantity: 1,
        unit: 'L',
        section: 'Dairy',
        alternatives: [],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingListItem(
              item: item,
              isChecked: false,
              onCheckChanged: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Dairy'), findsOneWidget);
    });

    testWidgets('toggles checkbox and calls callback', (tester) async {
      // Arrange
      final item = ShoppingItem(
        name: 'Eggs',
        quantity: 12,
        unit: 'count',
        section: 'Dairy',
        alternatives: [],
      );
      bool? capturedValue;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingListItem(
              item: item,
              isChecked: false,
              onCheckChanged: (value) {
                capturedValue = value;
              },
            ),
          ),
        ),
      );

      // Tap the checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Assert
      expect(capturedValue, isTrue);
    });

    testWidgets('shows strikethrough text when checked', (tester) async {
      // Arrange
      final item = ShoppingItem(
        name: 'Bread',
        quantity: 1,
        unit: 'loaf',
        section: 'Bakery',
        alternatives: [],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingListItem(
              item: item,
              isChecked: true,
              onCheckChanged: (_) {},
            ),
          ),
        ),
      );

      // Assert - find the Text widget and check its style
      final textWidget = tester.widget<Text>(
        find.descendant(
          of: find.byType(ShoppingListItem),
          matching: find.text('Bread'),
        ),
      );
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('calls onDelete when delete button tapped', (tester) async {
      // Arrange
      final item = ShoppingItem(
        name: 'Cheese',
        quantity: 200,
        unit: 'g',
        section: 'Dairy',
        alternatives: [],
      );
      bool deleteCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingListItem(
              item: item,
              isChecked: false,
              onCheckChanged: (_) {},
              onDelete: () {
                deleteCalled = true;
              },
            ),
          ),
        ),
      );

      // Tap the delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      // Assert
      expect(deleteCalled, isTrue);
    });
  });
}
