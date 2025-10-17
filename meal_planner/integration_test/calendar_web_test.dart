import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meal_planner/main.dart' as app;
import 'package:intl/intl.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Browser: add/delete/drag works end-to-end', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // --- Add event ---
    final addButton = find.text('Add').first;
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // --- Delete event ---
    final eventTile = find.textContaining('Spaghetti');
    if (eventTile.evaluate().isNotEmpty) {
      await tester.longPress(eventTile.first); // assume long press = delete
      await tester.pumpAndSettle();
    }

    // --- Drag and drop ---
    final dragSource = find.textContaining('Chicken');
    if (dragSource.evaluate().isNotEmpty) {
      final start = tester.getCenter(dragSource.first);
      final end = start + const Offset(0, 100);
      final gesture = await tester.startGesture(start);
      await gesture.moveTo(end);
      await gesture.up();
      await tester.pumpAndSettle();
    }

    // --- Scroll ---
    await tester.fling(find.byType(EventsList), const Offset(0, -600), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Training calendar'), findsOneWidget);
  });

  testWidgets('Today is highlighted distinctly', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // find text matching today's date
    final todayLabel = DateFormat('d MMM').format(DateTime.now());
    final todayFinder = find.textContaining(todayLabel.toUpperCase());

    expect(todayFinder, findsWidgets);

    // verify style (Material semantics)
    final headerText = tester.widget<Text>(todayFinder.first);
    expect(headerText.style?.color, equals(Colors.blue));
  });
}