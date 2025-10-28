import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/widgets/preferences/portions_selector.dart';

void main() {
  group('PortionsSelector', () {
    testWidgets('displays current portion value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortionsSelector(
              currentPortions: 4,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Portions'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(
        find.text('Ingredient quantities will scale accordingly'),
        findsOneWidget,
      );
    });

    testWidgets('adjust portions with slider', (tester) async {
      int selectedPortions = 4;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortionsSelector(
              currentPortions: selectedPortions,
              onChanged: (newValue) {
                selectedPortions = newValue;
              },
            ),
          ),
        ),
      );

      // Find and interact with slider
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Simulate slider change to 6
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();

      expect(selectedPortions > 4, isTrue);
    });

    testWidgets('enforce min boundary with minus button', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortionsSelector(
              currentPortions: 1,
              minPortions: 1,
              onChanged: (_) {
                callCount++;
              },
            ),
          ),
        ),
      );

      // Find all IconButtons and verify first one (minus) is disabled
      final buttons = find.byType(IconButton);
      expect(buttons, findsNWidgets(2));

      final minusButton = tester.widget<IconButton>(buttons.first);
      expect(minusButton.onPressed, isNull);
    });

    testWidgets('enforce max boundary with plus button', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortionsSelector(
              currentPortions: 12,
              maxPortions: 12,
              onChanged: (_) {
                callCount++;
              },
            ),
          ),
        ),
      );

      // Find all IconButtons and verify second one (plus) is disabled
      final buttons = find.byType(IconButton);
      expect(buttons, findsNWidgets(2));

      final plusButton = tester.widget<IconButton>(buttons.last);
      expect(plusButton.onPressed, isNull);
    });

    testWidgets('call onChanged when plus button pressed', (tester) async {
      int selectedPortions = 4;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return PortionsSelector(
                  currentPortions: selectedPortions,
                  onChanged: (newValue) {
                    setState(() {
                      selectedPortions = newValue;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Tap plus button (second IconButton)
      final buttons = find.byType(IconButton);
      await tester.tap(buttons.last);
      await tester.pumpAndSettle();

      expect(selectedPortions, 5);
      expect(find.text('5'), findsOneWidget);
    });
  });
}
