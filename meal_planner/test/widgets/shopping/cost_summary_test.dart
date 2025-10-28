import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/widgets/shopping/cost_summary.dart';

void main() {
  group('CostSummary Widget Tests', () {
    testWidgets('displays total estimated cost', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostSummary(
              totalEstimatedCost: 45.50,
              itemCount: 10,
              checkedCount: 3,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('\$45.50'), findsOneWidget);
    });

    testWidgets('shows item count (X of Y)', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostSummary(
              totalEstimatedCost: 30.00,
              itemCount: 15,
              checkedCount: 5,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('5 of 15 items'), findsOneWidget);
    });

    testWidgets('displays progress bar with checked/total', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostSummary(
              totalEstimatedCost: 20.00,
              itemCount: 10,
              checkedCount: 4,
            ),
          ),
        ),
      );

      // Assert
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, 0.4); // 4/10 = 0.4
    });

    testWidgets('formats currency symbol correctly', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostSummary(
              totalEstimatedCost: 100.00,
              itemCount: 5,
              checkedCount: 2,
              currencySymbol: '€',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('€100.00'), findsOneWidget);
    });

    testWidgets('shows \$0.00 if cost is null', (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CostSummary(
              totalEstimatedCost: null,
              itemCount: 8,
              checkedCount: 0,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('\$0.00'), findsOneWidget);
    });
  });
}
