import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/widgets/preferences/preferred_supermarkets_selector.dart';

void main() {
  group('PreferredSupermarketsSelector', () {
    testWidgets('displays all available supermarkets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PreferredSupermarketsSelector(
                selectedSupermarkets: const [],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Preferred Supermarkets'), findsOneWidget);
      expect(find.text('Whole Foods'), findsOneWidget);
      expect(find.text('Trader Joe\'s'), findsOneWidget);
      expect(find.text('Safeway'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNWidgets(8));
    });

    testWidgets('toggle supermarket selection', (tester) async {
      List<String> selected = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return PreferredSupermarketsSelector(
                    selectedSupermarkets: selected,
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
        ),
      );

      // Tap Whole Foods checkbox
      await tester.tap(find.text('Whole Foods'));
      await tester.pumpAndSettle();

      expect(selected, ['Whole Foods']);

      // Tap Trader Joe's
      await tester.tap(find.text('Trader Joe\'s'));
      await tester.pumpAndSettle();

      expect(selected, ['Whole Foods', 'Trader Joe\'s']);

      // Tap Whole Foods again to deselect
      await tester.tap(find.text('Whole Foods'));
      await tester.pumpAndSettle();

      expect(selected, ['Trader Joe\'s']);
    });

    testWidgets('show selected supermarkets highlighted', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PreferredSupermarketsSelector(
                selectedSupermarkets: const ['Whole Foods', 'Costco'],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      final wholeFoodsTile = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, 'Whole Foods'),
      );
      final safewayTile = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, 'Safeway'),
      );
      final costcoTile = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, 'Costco'),
      );

      expect(wholeFoodsTile.value, isTrue);
      expect(costcoTile.value, isTrue);
      expect(safewayTile.value, isFalse);
    });

    testWidgets('call onChanged with updated list', (tester) async {
      List<String>? receivedList;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PreferredSupermarketsSelector(
                selectedSupermarkets: const [],
                onChanged: (updated) {
                  receivedList = updated;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Target'));
      await tester.pumpAndSettle();

      expect(receivedList, ['Target']);
    });

    testWidgets('search field filters supermarket list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PreferredSupermarketsSelector(
                selectedSupermarkets: const [],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Before search - all supermarkets visible
      expect(find.byType(CheckboxListTile), findsNWidgets(8));

      // Enter search query
      await tester.enterText(find.byType(TextField), 'whole');
      await tester.pumpAndSettle();

      // Should only show Whole Foods
      expect(find.text('Whole Foods'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsOneWidget);
    });

    testWidgets('case-insensitive search', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PreferredSupermarketsSelector(
                selectedSupermarkets: const [],
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Search with different cases
      await tester.enterText(find.byType(TextField), 'COSTCO');
      await tester.pumpAndSettle();

      expect(find.text('Costco'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsOneWidget);

      // Clear and search lowercase
      await tester.enterText(find.byType(TextField), 'target');
      await tester.pumpAndSettle();

      expect(find.text('Target'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsOneWidget);
    });
  });
}
