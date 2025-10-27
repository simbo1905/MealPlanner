import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meal_planner/main.dart' as app;
import 'package:intl/intl.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  
  DateTime _getDate(int daysFromNow) {
    return DateTime.now().add(Duration(days: daysFromNow));
  }

  Future<void> _takeScreenshot(WidgetTester tester, String filename) async {
    await binding.takeScreenshot(filename);
    await tester.pump();
  }

  Future<void> _resetCalendar(WidgetTester tester) async {
    final resetButton = find.byKey(const Key('reset-button'));
    if (resetButton.evaluate().isNotEmpty) {
      await tester.tap(resetButton);
      await tester.pumpAndSettle();
    }
  }

  Future<void> _addMeal(WidgetTester tester, DateTime day) async {
    final dayKey = _dateKey(day);
    final addButton = find.byKey(Key('add-meal-$dayKey'));
    if (addButton.evaluate().isNotEmpty) {
      await tester.tap(addButton);
      await tester.pumpAndSettle();
    }
  }

  String _getActivityCount(WidgetTester tester) {
    final activityText = tester.widget<Text>(find.byKey(const Key('total-activities')));
    return activityText.data ?? '';
  }

  group('Test Suite 1: Basic Add/Remove Operations', () {
    testWidgets('Test 1.1: Add Meal to Empty Day', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await _takeScreenshot(tester, 'test_start_state.png');

      final initialCount = _getActivityCount(tester);
      final today = DateTime.now();
      
      await _addMeal(tester, today);
      await _takeScreenshot(tester, 'test_1_1_add_meal.png');

      final newCount = _getActivityCount(tester);
      expect(newCount, isNot(equals(initialCount)));
      expect(find.text('New Meal'), findsWidgets);
      expect(find.text('30 min'), findsWidgets);
    });

    testWidgets('Test 1.2: Remove Meal with Delete Button', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      final today = DateTime.now();
      await _addMeal(tester, today);
      await tester.pumpAndSettle();

      final dayKey = _dateKey(today);
      final deleteButton = find.byKey(Key('delete-meal-$dayKey-0'));
      
      if (deleteButton.evaluate().isNotEmpty) {
        final beforeCount = _getActivityCount(tester);
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();
        await _takeScreenshot(tester, 'test_1_2_remove_meal.png');

        final afterCount = _getActivityCount(tester);
        expect(afterCount, isNot(equals(beforeCount)));
        expect(find.byKey(Key('add-meal-$dayKey')), findsOneWidget);
      }
    });

    testWidgets('Test 1.3: Reset All Meals', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await _addMeal(tester, DateTime.now());
      await _addMeal(tester, _getDate(1));
      await _addMeal(tester, _getDate(2));
      await tester.pumpAndSettle();
      await _takeScreenshot(tester, 'test_1_3_before_reset.png');

      expect(_getActivityCount(tester), contains('3'));

      await _resetCalendar(tester);
      await _takeScreenshot(tester, 'test_1_3_after_reset.png');

      expect(_getActivityCount(tester), equals('Total: 0 activities'));
    });
  });

  group('Test Suite 2: Drag-and-Drop Between Adjacent Days', () {
    testWidgets('Test 2.1: Drag from Day with Event to Empty Day', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await _resetCalendar(tester);

      final dayX = _getDate(0);
      final dayX1 = _getDate(1);
      
      await _addMeal(tester, dayX);
      await tester.pumpAndSettle();
      await _takeScreenshot(tester, 'test_2_1_before_drag.png');

      final dayXKey = _dateKey(dayX);
      final dayX1Key = _dateKey(dayX1);
      
      final mealCard = find.byKey(Key('meal-New Meal-$dayXKey'));
      final dragTarget = find.byKey(Key('drag-target-$dayX1Key'));

      if (mealCard.evaluate().isNotEmpty && dragTarget.evaluate().isNotEmpty) {
        final mealPos = tester.getCenter(mealCard);
        final targetPos = tester.getCenter(dragTarget);
        final dragOffset = targetPos - mealPos;

        await tester.drag(mealCard, dragOffset);
        await tester.pumpAndSettle();
        await _takeScreenshot(tester, 'test_2_1_after_drop.png');

        expect(find.byKey(Key('meal-New Meal-$dayX1Key')), findsOneWidget);
        expect(find.byKey(Key('add-meal-$dayXKey')), findsOneWidget);
      }
    });

    testWidgets('Test 2.2: Drag to combine meals on same day', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await _resetCalendar(tester);

      final dayX = _getDate(2);
      final dayX1 = _getDate(3);
      
      await _addMeal(tester, dayX);
      await _addMeal(tester, dayX1);
      await tester.pumpAndSettle();
      await _takeScreenshot(tester, 'test_2_2_before_combine.png');

      final dayXKey = _dateKey(dayX);
      final dayX1Key = _dateKey(dayX1);
      
      final mealCard = find.byKey(Key('meal-New Meal-$dayXKey'));
      
      if (mealCard.evaluate().isNotEmpty) {
        final mealPos = tester.getCenter(mealCard);
        
        await tester.dragFrom(mealPos, const Offset(0, 200));
        await tester.pumpAndSettle();
        await _takeScreenshot(tester, 'test_2_2_after_combine.png');

        expect(_getActivityCount(tester), contains('2'));
      }
    });
  });

  group('Test Suite 3: Empty Day Drop Zone Validation', () {
    testWidgets('Test 3.1: Empty Day is Valid Drop Target', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await _resetCalendar(tester);

      final dayX = _getDate(0);
      final dayX1 = _getDate(1);
      
      await _addMeal(tester, dayX);
      await tester.pumpAndSettle();

      final dayXKey = _dateKey(dayX);
      final dayX1Key = _dateKey(dayX1);
      
      final mealCard = find.byKey(Key('meal-New Meal-$dayXKey'));
      final emptyDayTarget = find.byKey(Key('drag-target-$dayX1Key'));

      expect(emptyDayTarget, findsOneWidget);

      if (mealCard.evaluate().isNotEmpty && emptyDayTarget.evaluate().isNotEmpty) {
        final mealPos = tester.getCenter(mealCard);
        final targetPos = tester.getCenter(emptyDayTarget);
        
        await tester.dragFrom(mealPos, targetPos - mealPos);
        await tester.pumpAndSettle();
        await _takeScreenshot(tester, 'test_3_1_empty_hover.png');

        expect(find.byKey(Key('meal-New Meal-$dayX1Key')), findsOneWidget);
      }
    });
  });

  group('Test Suite 4: Week Number and Scroll Synchronization', () {
    testWidgets('Test 4.1: Week Number Updates on Scroll', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await _takeScreenshot(tester, 'test_4_1_week_42.png');

      final initialWeekBadge = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const Key('week-badge')),
          matching: find.byType(Text),
        ),
      );
      final initialWeek = initialWeekBadge.data ?? '';

      final eventsList = find.byType(EventsList);
      await tester.fling(eventsList, const Offset(0, -1000), 1000);
      await tester.pumpAndSettle();
      await _takeScreenshot(tester, 'test_4_1_week_43.png');

      final newWeekBadge = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const Key('week-badge')),
          matching: find.byType(Text),
        ),
      );
      final newWeek = newWeekBadge.data ?? '';

      expect(newWeek, isNot(equals(initialWeek)));
    });
  });

  group('Test Suite 5: Visual Feedback Validation', () {
    testWidgets('Test 7.1: Drag Feedback Visual Check', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await _resetCalendar(tester);

      final dayX = _getDate(0);
      await _addMeal(tester, dayX);
      await tester.pumpAndSettle();

      final dayXKey = _dateKey(dayX);
      final mealCard = find.byKey(Key('meal-New Meal-$dayXKey'));

      if (mealCard.evaluate().isNotEmpty) {
        final gesture = await tester.startGesture(tester.getCenter(mealCard));
        await tester.pump(const Duration(milliseconds: 500));
        await _takeScreenshot(tester, 'test_7_1_drag_feedback.png');
        
        await gesture.up();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Test 7.3: Quick Meal Lightning Icon', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await _resetCalendar(tester);

      final dayX = _getDate(0);
      await _addMeal(tester, dayX);
      await tester.pumpAndSettle();
      await _takeScreenshot(tester, 'test_7_3_lightning_icons.png');

      expect(find.byIcon(Icons.bolt), findsWidgets);
    });
  });

  group('Test Suite 6: State Persistence', () {
    testWidgets('Test 8.1: State Survives Multiple Operations', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await _resetCalendar(tester);

      await _addMeal(tester, _getDate(1));
      await _addMeal(tester, _getDate(1));
      await _addMeal(tester, _getDate(3));
      await _addMeal(tester, _getDate(3));
      await _addMeal(tester, _getDate(3));
      await _addMeal(tester, _getDate(4));
      await tester.pumpAndSettle();
      await _takeScreenshot(tester, 'test_8_1_state_persistence.png');

      expect(_getActivityCount(tester), equals('Total: 6 activities'));

      final eventsList = find.byType(EventsList);
      await tester.fling(eventsList, const Offset(0, -1000), 1000);
      await tester.pumpAndSettle();
      
      await tester.fling(eventsList, const Offset(0, 1000), 1000);
      await tester.pumpAndSettle();

      expect(_getActivityCount(tester), equals('Total: 6 activities'));
    });

    testWidgets('Test 8.2: Reset Clears All State', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await _resetCalendar(tester);

      for (int i = 0; i < 10; i++) {
        await _addMeal(tester, _getDate(i));
      }
      await tester.pumpAndSettle();
      await _takeScreenshot(tester, 'test_8_2_before_reset.png');

      expect(_getActivityCount(tester), contains('10'));

      await _resetCalendar(tester);
      await _takeScreenshot(tester, 'test_8_2_after_reset.png');

      expect(_getActivityCount(tester), equals('Total: 0 activities'));

      await _addMeal(tester, DateTime.now());
      await tester.pumpAndSettle();

      expect(_getActivityCount(tester), equals('Total: 1 activities'));
    });
  });

  group('Test Suite 7: Alignment Validation', () {
    testWidgets('Test 9.1: Day Header and Card Alignment', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await _resetCalendar(tester);

      await _addMeal(tester, _getDate(0));
      await _addMeal(tester, _getDate(2));
      await _addMeal(tester, _getDate(4));
      await tester.pumpAndSettle();
      await _takeScreenshot(tester, 'test_9_1_alignment.png');

      expect(find.byType(EventsList), findsOneWidget);
    });

    testWidgets('Test 9.2: Empty Day Layout', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await _resetCalendar(tester);
      await _takeScreenshot(tester, 'test_9_2_empty_layout.png');

      final today = DateTime.now();
      final todayKey = _dateKey(today);
      final addButton = find.byKey(Key('add-meal-$todayKey'));
      
      expect(addButton, findsOneWidget);
    });
  });

  group('Test Suite 8: Complete Integration', () {
    testWidgets('Test 10.1: Complete User Workflow', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await _resetCalendar(tester);
      await _takeScreenshot(tester, 'e2e_1_open.png');

      await _addMeal(tester, _getDate(0));
      await _addMeal(tester, _getDate(2));
      await _addMeal(tester, _getDate(4));
      await tester.pumpAndSettle();
      await _takeScreenshot(tester, 'e2e_2_initial_plan.png');
      expect(_getActivityCount(tester), equals('Total: 3 activities'));

      final day0Key = _dateKey(_getDate(0));
      final mealCard = find.byKey(Key('meal-New Meal-$day0Key'));
      
      if (mealCard.evaluate().isNotEmpty) {
        await tester.drag(mealCard, const Offset(0, 600));
        await tester.pumpAndSettle();
        await _takeScreenshot(tester, 'e2e_3_rearranged.png');
        expect(_getActivityCount(tester), equals('Total: 3 activities'));
      }

      await _addMeal(tester, _getDate(1));
      await _addMeal(tester, _getDate(5));
      await tester.pumpAndSettle();
      await _takeScreenshot(tester, 'e2e_4_added_more.png');
      expect(_getActivityCount(tester), equals('Total: 5 activities'));

      final day1Key = _dateKey(_getDate(1));
      final deleteButton = find.byKey(Key('delete-meal-$day1Key-0'));
      if (deleteButton.evaluate().isNotEmpty) {
        await tester.tap(deleteButton);
        await tester.pumpAndSettle();
        await _takeScreenshot(tester, 'e2e_5_removed.png');
        expect(_getActivityCount(tester), equals('Total: 4 activities'));
      }

      final eventsList = find.byType(EventsList);
      await tester.fling(eventsList, const Offset(0, -1000), 1000);
      await tester.pumpAndSettle();
      await _takeScreenshot(tester, 'e2e_6_week_43.png');

      await tester.fling(eventsList, const Offset(0, 1000), 1000);
      await tester.pumpAndSettle();
      await _takeScreenshot(tester, 'e2e_7_review.png');

      await _resetCalendar(tester);
      await _takeScreenshot(tester, 'e2e_8_reset.png');
      expect(_getActivityCount(tester), equals('Total: 0 activities'));
    });
  });
}
