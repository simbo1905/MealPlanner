import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meal_planner/calendar_controller.dart';

import 'training_calendar_test.mocks.dart';

@GenerateMocks([CalendarController])
void main() {
  late MockCalendarController mockController;

  setUp(() {
    mockController = MockCalendarController();
  });

  group('Calendar logic tests (Mockito)', () {
    test('Adding event updates controller list', () async {
      final event = Event(title: 'Spaghetti Bolognese', distance: 0);
      when(mockController.addEvent(any)).thenAnswer((_) async => true);

      final result = await mockController.addEvent(event);

      verify(mockController.addEvent(event)).called(1);
      expect(result, isTrue);
    });

    test('Deleting event removes it from controller list', () async {
      when(mockController.deleteEvent(any)).thenAnswer((_) async => true);
      final result = await mockController.deleteEvent('Spaghetti Bolognese');

      verify(mockController.deleteEvent('Spaghetti Bolognese')).called(1);
      expect(result, isTrue);
    });

    test('Drag-and-drop reorder fires correct method', () async {
      when(mockController.reorderEvent(any, any))
          .thenAnswer((_) async => true);

      final result = await mockController.reorderEvent(1, 0);

      verify(mockController.reorderEvent(1, 0)).called(1);
      expect(result, isTrue);
    });
  });
}