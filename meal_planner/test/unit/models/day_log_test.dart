import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/day_log.dart';
import 'package:meal_planner/models/day_event.dart';

void main() {
  group('DayLog model', () {
    test('should create valid day log', () {
      final event1 = DayEvent(
        id: '1730150405000-add-abc',
        isoDate: '2025-10-16',
        op: DayEventOperation.add,
        recipeUuid: 'abc',
        occurredAtEpochMs: 1730150405000,
        snapshot: RecipeSnapshot(
          title: 'Breakfast',
          imageUrl: 'https://example.com/breakfast.jpg',
          totalTime: 15.0,
        ),
      );

      final dayLog = DayLog(
        isoDate: '2025-10-16',
        events: [event1],
      );

      expect(dayLog.isoDate, '2025-10-16');
      expect(dayLog.events.length, 1);
      expect(dayLog.lastChangeToken, null);
    });

    test('should create day log with change token', () {
      final dayLog = DayLog(
        isoDate: '2025-10-16',
        events: [],
        lastChangeToken: 'token123',
      );

      expect(dayLog.lastChangeToken, 'token123');
    });

    test('should add event to day log', () {
      final dayLog = DayLog(
        isoDate: '2025-10-16',
        events: [],
      );

      final event = DayEvent(
        id: '1730150405000-add-xyz',
        isoDate: '2025-10-16',
        op: DayEventOperation.add,
        recipeUuid: 'xyz',
        occurredAtEpochMs: 1730150405000,
        snapshot: RecipeSnapshot(
          title: 'Test Meal',
          imageUrl: 'https://example.com/meal.jpg',
          totalTime: 20.0,
        ),
      );

      final updated = dayLog.addEvent(event);
      expect(updated.events.length, 1);
      expect(updated.events[0], equals(event));
      expect(dayLog.events.length, 0); // Original unchanged
    });

    test('should add multiple events preserving order', () {
      final event1 = DayEvent(
        id: '1730150405000-add-abc',
        isoDate: '2025-10-16',
        op: DayEventOperation.add,
        recipeUuid: 'abc',
        occurredAtEpochMs: 1730150405000,
        snapshot: RecipeSnapshot(title: 'Meal 1', imageUrl: 'https://example.com/1.jpg', totalTime: 30.0),
      );

      final event2 = DayEvent(
        id: '1730150405111-add-def',
        isoDate: '2025-10-16',
        op: DayEventOperation.add,
        recipeUuid: 'def',
        occurredAtEpochMs: 1730150405111,
        snapshot: RecipeSnapshot(title: 'Meal 2', imageUrl: 'https://example.com/2.jpg', totalTime: 45.0),
      );

      final event3 = DayEvent(
        id: '1730150405222-del-abc',
        isoDate: '2025-10-16',
        op: DayEventOperation.del,
        recipeUuid: 'abc',
        occurredAtEpochMs: 1730150405222,
      );

      final dayLog = DayLog(isoDate: '2025-10-16', events: []);
      final updated = dayLog.addEvent(event1).addEvent(event2).addEvent(event3);

      expect(updated.events.length, 3);
      expect(updated.events[0], equals(event1));
      expect(updated.events[1], equals(event2));
      expect(updated.events[2], equals(event3));
    });

    test('should compact day log removing obsolete events', () {
      final event1 = DayEvent(
        id: '1730150405000-add-abc',
        isoDate: '2025-10-16',
        op: DayEventOperation.add,
        recipeUuid: 'abc',
        occurredAtEpochMs: 1730150405000,
        snapshot: RecipeSnapshot(
          title: 'Meal 1',
          imageUrl: 'https://example.com/1.jpg',
          totalTime: 30.0,
        ),
      );

      final event2 = DayEvent(
        id: '1730150405111-del-abc',
        isoDate: '2025-10-16',
        op: DayEventOperation.del,
        recipeUuid: 'abc',
        occurredAtEpochMs: 1730150405111,
      );

      final event3 = DayEvent(
        id: '1730150405222-add-def',
        isoDate: '2025-10-16',
        op: DayEventOperation.add,
        recipeUuid: 'def',
        occurredAtEpochMs: 1730150405222,
        snapshot: RecipeSnapshot(
          title: 'Meal 2',
          imageUrl: 'https://example.com/2.jpg',
          totalTime: 45.0,
        ),
      );

      final dayLog = DayLog(
        isoDate: '2025-10-16',
        events: [event1, event2, event3],
      );

      final compacted = dayLog.compact();

      // Should remove add-del pair for 'abc', keep only 'def' add
      expect(compacted.events.length, 1);
      expect(compacted.events[0].recipeUuid, 'def');
      expect(compacted.events[0].op, DayEventOperation.add);
    });

    test('should handle compaction with multiple surviving events', () {
      final event1 = DayEvent(
        id: '1730150405000-add-abc',
        isoDate: '2025-10-16',
        op: DayEventOperation.add,
        recipeUuid: 'abc',
        occurredAtEpochMs: 1730150405000,
        snapshot: RecipeSnapshot(title: 'Meal A', imageUrl: 'https://example.com/a.jpg', totalTime: 30.0),
      );

      final event2 = DayEvent(
        id: '1730150405111-add-def',
        isoDate: '2025-10-16',
        op: DayEventOperation.add,
        recipeUuid: 'def',
        occurredAtEpochMs: 1730150405111,
        snapshot: RecipeSnapshot(title: 'Meal D', imageUrl: 'https://example.com/d.jpg', totalTime: 40.0),
      );

      final event3 = DayEvent(
        id: '1730150405222-del-abc',
        isoDate: '2025-10-16',
        op: DayEventOperation.del,
        recipeUuid: 'abc',
        occurredAtEpochMs: 1730150405222,
      );

      final dayLog = DayLog(
        isoDate: '2025-10-16',
        events: [event1, event2, event3],
      );

      final compacted = dayLog.compact();

      // Should keep only 'def' (abc was deleted)
      expect(compacted.events.length, 1);
      expect(compacted.events[0].recipeUuid, 'def');
    });

    test('should serialize to JSON', () {
      final event = DayEvent(
        id: '1730150405000-add-abc',
        isoDate: '2025-10-16',
        op: DayEventOperation.add,
        recipeUuid: 'abc',
        occurredAtEpochMs: 1730150405000,
        snapshot: RecipeSnapshot(
          title: 'Test',
          imageUrl: 'https://example.com/test.jpg',
          totalTime: 20.0,
        ),
      );

      final dayLog = DayLog(
        isoDate: '2025-10-16',
        events: [event],
        lastChangeToken: 'token456',
      );

      final json = dayLog.toJson();
      expect(json['iso_date'], '2025-10-16');
      expect(json['events'], isA<List>());
      expect(json['events'].length, 1);
      expect(json['last_change_token'], 'token456');
    });

    test('should deserialize from JSON', () {
      final json = {
        'iso_date': '2025-10-16',
        'events': [
          {
            'id': '1730150405000-add-xyz',
            'iso_date': '2025-10-16',
            'op': 'add',
            'recipe_uuid': 'xyz',
            'occurred_at_epoch_ms': 1730150405000,
            'snapshot': {
              'title': 'Deserialized',
              'image_url': 'https://example.com/des.jpg',
              'total_time': 35.0,
            },
          },
        ],
        'last_change_token': 'token789',
      };

      final dayLog = DayLog.fromJson(json);
      expect(dayLog.isoDate, '2025-10-16');
      expect(dayLog.events.length, 1);
      expect(dayLog.events[0].recipeUuid, 'xyz');
      expect(dayLog.lastChangeToken, 'token789');
    });

    test('should support equality', () {
      final event = DayEvent(
        id: '1730150405000-add-abc',
        isoDate: '2025-10-16',
        op: DayEventOperation.add,
        recipeUuid: 'abc',
        occurredAtEpochMs: 1730150405000,
        snapshot: RecipeSnapshot(title: 'Test', imageUrl: 'https://example.com/test.jpg', totalTime: 20.0),
      );

      final dayLog1 = DayLog(
        isoDate: '2025-10-16',
        events: [event],
      );

      final dayLog2 = DayLog(
        isoDate: '2025-10-16',
        events: [event],
      );

      final dayLog3 = DayLog(
        isoDate: '2025-10-17',
        events: [event],
      );

      expect(dayLog1, equals(dayLog2));
      expect(dayLog1, isNot(equals(dayLog3)));
      expect(dayLog1.hashCode, equals(dayLog2.hashCode));
    });

    test('should support copyWith', () {
      final event = DayEvent(
        id: '1730150405000-add-abc',
        isoDate: '2025-10-16',
        op: DayEventOperation.add,
        recipeUuid: 'abc',
        occurredAtEpochMs: 1730150405000,
        snapshot: RecipeSnapshot(title: 'Test', imageUrl: 'https://example.com/test.jpg', totalTime: 20.0),
      );

      final original = DayLog(
        isoDate: '2025-10-16',
        events: [event],
        lastChangeToken: 'old-token',
      );

      final modified = original.copyWith(lastChangeToken: 'new-token');

      expect(modified.isoDate, '2025-10-16');
      expect(modified.events, equals(original.events));
      expect(modified.lastChangeToken, 'new-token');
      expect(original.lastChangeToken, 'old-token');
    });
  });
}
