import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/widgets/preferences/dietary_restrictions_selector.dart';

void main() {
  group('DietaryRestrictionsSelector', () {
    testWidgets('displays all available restrictions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DietaryRestrictionsSelector(
              selectedRestrictions: const [],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Dietary Restrictions'), findsOneWidget);
      expect(find.text('vegetarian'), findsOneWidget);
      expect(find.text('vegan'), findsOneWidget);
      expect(find.text('gluten-free'), findsOneWidget);
      expect(find.byType(FilterChip), findsNWidgets(8));
    });

    testWidgets('toggle restriction selection', (tester) async {
      List<String> selected = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DietaryRestrictionsSelector(
                  selectedRestrictions: selected,
                  onChanged: (updated) {
                    setState(() {
                      selected = updated;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Tap vegetarian chip
      await tester.tap(find.text('vegetarian'));
      await tester.pumpAndSettle();

      expect(selected, ['vegetarian']);

      // Tap vegan chip
      await tester.tap(find.text('vegan'));
      await tester.pumpAndSettle();

      expect(selected, ['vegetarian', 'vegan']);

      // Tap vegetarian again to deselect
      await tester.tap(find.text('vegetarian'));
      await tester.pumpAndSettle();

      expect(selected, ['vegan']);
    });

    testWidgets('show selected restrictions highlighted', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DietaryRestrictionsSelector(
              selectedRestrictions: const ['vegetarian', 'gluten-free'],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Find the FilterChips for selected items
      final chips = find.byType(FilterChip);
      final vegetarianChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'vegetarian'),
      );
      final veganChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'vegan'),
      );
      final glutenFreeChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'gluten-free'),
      );

      expect(vegetarianChip.selected, isTrue);
      expect(glutenFreeChip.selected, isTrue);
      expect(veganChip.selected, isFalse);
    });

    testWidgets('call onChanged with updated list', (tester) async {
      List<String>? receivedList;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DietaryRestrictionsSelector(
              selectedRestrictions: const [],
              onChanged: (updated) {
                receivedList = updated;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('dairy-free'));
      await tester.pumpAndSettle();

      expect(receivedList, ['dairy-free']);
    });

    testWidgets('Select All button selects all restrictions', (tester) async {
      List<String> selected = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DietaryRestrictionsSelector(
                  selectedRestrictions: selected,
                  onChanged: (updated) {
                    setState(() {
                      selected = updated;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Select All'));
      await tester.pumpAndSettle();

      expect(selected.length, 8);
      expect(selected.contains('vegetarian'), isTrue);
      expect(selected.contains('vegan'), isTrue);
      expect(selected.contains('gluten-free'), isTrue);
    });

    testWidgets('Clear All button deselects all restrictions', (tester) async {
      List<String> selected = ['vegetarian', 'vegan', 'gluten-free'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DietaryRestrictionsSelector(
                  selectedRestrictions: selected,
                  onChanged: (updated) {
                    setState(() {
                      selected = updated;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      expect(selected, isEmpty);
    });
  });
}
