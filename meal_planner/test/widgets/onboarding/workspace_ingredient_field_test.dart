import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/ingredient.freezed_model.dart';
import 'package:meal_planner/models/enums.dart';
import 'package:meal_planner/widgets/onboarding/workspace_ingredient_field.dart';

void main() {
  group('WorkspaceIngredientField', () {
    late Ingredient testIngredient;

    setUp(() {
      testIngredient = const Ingredient(
        name: 'Pasta',
        ucumAmount: 2.0,
        ucumUnit: UcumUnit.cup_us,
        metricAmount: 500.0,
        metricUnit: MetricUnit.g,
        notes: 'Dry pasta',
      );
    });

    testWidgets('displays ingredient name, amounts, units, and notes',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkspaceIngredientField(
              ingredient: testIngredient,
              onChanged: (_) {},
              onRemove: () {},
            ),
          ),
        ),
      );

      expect(find.text('Pasta'), findsOneWidget);
      expect(find.text('2.0'), findsOneWidget);
      expect(find.text('500.0'), findsOneWidget);
      expect(find.text('Dry pasta'), findsOneWidget);
    });

    testWidgets('edit ingredient name and call onChanged', (tester) async {
      Ingredient? changedIngredient;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkspaceIngredientField(
              ingredient: testIngredient,
              onChanged: (ing) {
                changedIngredient = ing;
              },
              onRemove: () {},
            ),
          ),
        ),
      );

      // Find name text field and enter new text
      final nameField = find.widgetWithText(TextField, 'Pasta');
      await tester.enterText(nameField, 'Spaghetti');
      await tester.pump();

      expect(changedIngredient, isNotNull);
      expect(changedIngredient!.name, 'Spaghetti');
    });

    testWidgets('change UCUM unit dropdown', (tester) async {
      Ingredient? changedIngredient;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkspaceIngredientField(
              ingredient: testIngredient,
              onChanged: (ing) {
                changedIngredient = ing;
              },
              onRemove: () {},
            ),
          ),
        ),
      );

      // Find UCUM unit dropdown
      final dropdown = find.byType(DropdownButtonFormField<UcumUnit>);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Select a different unit
      await tester.tap(find.text('cup_m').last);
      await tester.pumpAndSettle();

      expect(changedIngredient, isNotNull);
      expect(changedIngredient!.ucumUnit, UcumUnit.cup_m);
    });

    testWidgets('change metric unit dropdown', (tester) async {
      Ingredient? changedIngredient;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkspaceIngredientField(
              ingredient: testIngredient,
              onChanged: (ing) {
                changedIngredient = ing;
              },
              onRemove: () {},
            ),
          ),
        ),
      );

      // Find metric unit dropdown
      final dropdown = find.byType(DropdownButtonFormField<MetricUnit>);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Select a different unit
      await tester.tap(find.text('ml').last);
      await tester.pumpAndSettle();

      expect(changedIngredient, isNotNull);
      expect(changedIngredient!.metricUnit, MetricUnit.ml);
    });

    testWidgets('edit notes field', (tester) async {
      Ingredient? changedIngredient;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkspaceIngredientField(
              ingredient: testIngredient,
              onChanged: (ing) {
                changedIngredient = ing;
              },
              onRemove: () {},
            ),
          ),
        ),
      );

      // Find notes field and enter new text
      final notesField = find.widgetWithText(TextField, 'Dry pasta');
      await tester.enterText(notesField, 'Fresh pasta');
      await tester.pump();

      expect(changedIngredient, isNotNull);
      expect(changedIngredient!.notes, 'Fresh pasta');
    });

    testWidgets('remove ingredient button calls onRemove', (tester) async {
      var removeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkspaceIngredientField(
              ingredient: testIngredient,
              onChanged: (_) {},
              onRemove: () {
                removeCalled = true;
              },
            ),
          ),
        ),
      );

      // Find and tap remove button
      final removeButton = find.byIcon(Icons.close);
      expect(removeButton, findsOneWidget);

      await tester.tap(removeButton);
      await tester.pump();

      expect(removeCalled, true);
    });

    testWidgets('read-only mode disables edits and hides remove button',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkspaceIngredientField(
              ingredient: testIngredient,
              onChanged: (_) {},
              onRemove: () {},
              readOnly: true,
            ),
          ),
        ),
      );

      // Remove button should not be visible
      expect(find.byIcon(Icons.close), findsNothing);

      // Text fields should be read-only
      final nameField =
          tester.widget<TextField>(find.widgetWithText(TextField, 'Pasta'));
      expect(nameField.readOnly, true);

      // Dropdowns should be disabled (onChanged is null)
      final ucumDropdown =
          tester.widget<DropdownButtonFormField<UcumUnit>>(
              find.byType(DropdownButtonFormField<UcumUnit>));
      expect(ucumDropdown.onChanged, isNull);

      final metricDropdown =
          tester.widget<DropdownButtonFormField<MetricUnit>>(
              find.byType(DropdownButtonFormField<MetricUnit>));
      expect(metricDropdown.onChanged, isNull);
    });
  });
}
