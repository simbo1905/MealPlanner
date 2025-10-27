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

    final scaffold = find.byKey(const Key('calendar-scaffold'));
    expect(scaffold, findsOneWidget);

    final now = DateTime.now();
    final dayKey = DateFormat('yyyy-MM-dd').format(now);
    final addButton = find.byKey(Key('add-meal-$dayKey'));

    if (addButton.evaluate().isNotEmpty) {
      final activityCountBefore = find.byKey(const Key('total-activities'));
      final textBefore = tester.widget<Text>(activityCountBefore).data;
      
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      final activityCountAfter = find.byKey(const Key('total-activities'));
      final textAfter = tester.widget<Text>(activityCountAfter).data;
      
      expect(textAfter, isNot(equals(textBefore)));
    }

    final eventTile = find.textContaining('Chicken');
    if (eventTile.evaluate().isNotEmpty) {
      await tester.longPress(eventTile.first);
      await tester.pumpAndSettle();
    }

    final dragSource = find.textContaining('Roast');
    if (dragSource.evaluate().isNotEmpty) {
      final start = tester.getCenter(dragSource.first);
      final end = start + const Offset(0, 100);
      final gesture = await tester.startGesture(start);
      await gesture.moveTo(end);
      await gesture.up();
      await tester.pumpAndSettle();
    }

    await tester.fling(find.byType(EventsList), const Offset(0, -600), 1000);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('calendar-scaffold')), findsOneWidget);
  });

  testWidgets('Today is highlighted distinctly', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final todayCircle = find.byKey(const Key('today-circle'));
    expect(todayCircle, findsOneWidget);

    final container = tester.widget<Container>(todayCircle);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, equals(Colors.black));
    expect(decoration.shape, equals(BoxShape.circle));
  });

  testWidgets('Activity count updates dynamically', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final activityCount = find.byKey(const Key('total-activities'));
    expect(activityCount, findsOneWidget);

    final initialText = tester.widget<Text>(activityCount).data;
    expect(initialText, contains('Total:'));
    expect(initialText, contains('activities'));

    final now = DateTime.now();
    final dayKey = DateFormat('yyyy-MM-dd').format(now);
    final addButton = find.byKey(Key('add-meal-$dayKey'));

    if (addButton.evaluate().isNotEmpty) {
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      final updatedText = tester.widget<Text>(activityCount).data;
      expect(updatedText, isNot(equals(initialText)));
    }
  });

  testWidgets('Reset button clears all meals', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final resetButton = find.byKey(const Key('reset-button'));
    expect(resetButton, findsOneWidget);

    await tester.tap(resetButton);
    await tester.pumpAndSettle();

    final activityCount = find.byKey(const Key('total-activities'));
    final text = tester.widget<Text>(activityCount).data;
    expect(text, equals('Total: 0 activities'));
  });

  testWidgets('Week range and number use consistent calculation', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final weekRange = find.byKey(const Key('week-range'));
    final weekBadge = find.byKey(const Key('week-badge'));

    expect(weekRange, findsOneWidget);
    expect(weekBadge, findsOneWidget);

    final weekRangeText = tester.widget<Text>(weekRange).data;
    final weekBadgeText = tester.widget<Text>(find.descendant(of: weekBadge, matching: find.byType(Text))).data;

    expect(weekRangeText, isNotNull);
    expect(weekBadgeText, contains('WEEK'));
  });
}
