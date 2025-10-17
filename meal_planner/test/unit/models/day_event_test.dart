import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/day_event.dart';

void main() {
  group('DayEventOperation enum', () {
    test('should have add and del operations', () {
      expect(DayEventOperation.values.length, 2);
      expect(DayEventOperation.values.contains(DayEventOperation.add), true);
      expect(DayEventOperation.values.contains(DayEventOperation.del), true);
    });

    test('should convert to/from string', () {
      expect(dayEventOperationToString(DayEventOperation.add), 'add');
      expect(dayEventOperationToString(DayEventOperation.del), 'del');
      expect(dayEventOperationFromString('add'), DayEventOperation.add);
      expect(dayEventOperationFromString('del'), DayEventOperation.del);
    });
  });

  group('RecipeSnapshot', () {
    test('should create valid snapshot', () {
      final snapshot = RecipeSnapshot(
        title: 'Pancakes',
        imageUrl: 'https://example.com/pancakes.jpg',
        totalTime: 30.0,
      );

      expect(snapshot.title, 'Pancakes');
      expect(snapshot.imageUrl, 'https://example.com/pancakes.jpg');
      expect(snapshot.totalTime, 30.0);
    });

    test('should serialize to/from JSON', () {
      final snapshot = RecipeSnapshot(
        title: 'Toast',
        imageUrl: 'https://example.com/toast.jpg',
        totalTime: 5.0,
      );

      final json = snapshot.toJson();
      expect(json['title'], 'Toast');
      expect(json['image_url'], 'https://example.com/toast.jpg');
      expect(json['total_time'], 5.0);

      final deserialized = RecipeSnapshot.fromJson(json);
      expect(deserialized, equals(snapshot));
    });
  });

  group('DayEvent model', () {
    test('should create valid add event with snapshot', () {
      final snapshot = RecipeSnapshot(
        title: 'Breakfast',
        imageUrl: 'https://example.com/breakfast.jpg',
        totalTime: 15.0,
      );

      final event = DayEvent(
        id: '1730150405123-add-0afc123',
        isoDate: '2025-10-16',
        op: DayEventOperation.add,
        recipeUuid: '0afc123',
        occurredAtEpochMs: 1730150405123,
        snapshot: snapshot,
      );

      expect(event.id, '1730150405123-add-0afc123');
      expect(event.isoDate, '2025-10-16');
      expect(event.op, DayEventOperation.add);
      expect(event.recipeUuid, '0afc123');
      expect(event.occurredAtEpochMs, 1730150405123);
      expect(event.snapshot, isNotNull);
      expect(event.snapshot!.title, 'Breakfast');
    });

    test('should create valid del event without snapshot', () {
      final event = DayEvent(
        id: '1730150405456-del-0afc123',
        isoDate: '2025-10-16',
        op: DayEventOperation.del,
        recipeUuid: '0afc123',
        occurredAtEpochMs: 1730150405456,
      );

      expect(event.op, DayEventOperation.del);
      expect(event.snapshot, null);
    });

    test('should parse timestamp from event ID', () {
      final event = DayEvent(
        id: '1730150405789-add-xyz789',
        isoDate: '2025-10-16',
        op: DayEventOperation.add,
        recipeUuid: 'xyz789',
        occurredAtEpochMs: 1730150405789,
        snapshot: RecipeSnapshot(
          title: 'Parse Test',
          imageUrl: 'https://example.com/parse.jpg',
          totalTime: 15.0,
        ),
      );

      expect(event.occurredAtEpochMs, 1730150405789);
    });

    test('should serialize to JSON with snapshot', () {
      final snapshot = RecipeSnapshot(
        title: 'Lunch',
        imageUrl: 'https://example.com/lunch.jpg',
        totalTime: 45.0,
      );

      final event = DayEvent(
        id: '1730150405000-add-abc123',
        isoDate: '2025-10-16',
        op: DayEventOperation.add,
        recipeUuid: 'abc123',
        occurredAtEpochMs: 1730150405000,
        snapshot: snapshot,
      );

      final json = event.toJson();
      expect(json['id'], '1730150405000-add-abc123');
      expect(json['iso_date'], '2025-10-16');
      expect(json['op'], 'add');
      expect(json['recipe_uuid'], 'abc123');
      expect(json['occurred_at_epoch_ms'], 1730150405000);
      expect(json['snapshot'], isNotNull);
    });

    test('should serialize to JSON without snapshot', () {
      final event = DayEvent(
        id: '1730150405000-del-abc123',
        isoDate: '2025-10-16',
        op: DayEventOperation.del,
        recipeUuid: 'abc123',
        occurredAtEpochMs: 1730150405000,
      );

      final json = event.toJson();
      expect(json.containsKey('snapshot'), false);
    });

    test('should deserialize from JSON with snapshot', () {
      final json = {
        'id': '1730150405111-add-def456',
        'iso_date': '2025-10-16',
        'op': 'add',
        'recipe_uuid': 'def456',
        'occurred_at_epoch_ms': 1730150405111,
        'snapshot': {
          'title': 'Dinner',
          'image_url': 'https://example.com/dinner.jpg',
          'total_time': 60.0,
        },
      };

      final event = DayEvent.fromJson(json);
      expect(event.id, '1730150405111-add-def456');
      expect(event.isoDate, '2025-10-16');
      expect(event.op, DayEventOperation.add);
      expect(event.recipeUuid, 'def456');
      expect(event.occurredAtEpochMs, 1730150405111);
      expect(event.snapshot, isNotNull);
      expect(event.snapshot!.title, 'Dinner');
    });

    test('should deserialize from JSON without snapshot', () {
      final json = {
        'id': '1730150405222-del-def456',
        'iso_date': '2025-10-16',
        'op': 'del',
        'recipe_uuid': 'def456',
        'occurred_at_epoch_ms': 1730150405222,
      };

      final event = DayEvent.fromJson(json);
      expect(event.op, DayEventOperation.del);
      expect(event.snapshot, null);
    });

    test('should support equality', () {
      final snapshot = RecipeSnapshot(
        title: 'Test',
        imageUrl: 'https://example.com/test.jpg',
        totalTime: 20.0,
      );

      final event1 = DayEvent(
        id: '1730150405333-add-xyz',
        isoDate: '2025-10-16',
        op: DayEventOperation.add,
        recipeUuid: 'xyz',
        occurredAtEpochMs: 1730150405333,
        snapshot: snapshot,
      );

      final event2 = DayEvent(
        id: '1730150405333-add-xyz',
        isoDate: '2025-10-16',
        op: DayEventOperation.add,
        recipeUuid: 'xyz',
        occurredAtEpochMs: 1730150405333,
        snapshot: snapshot,
      );

      final event3 = DayEvent(
        id: '1730150405444-del-xyz',
        isoDate: '2025-10-16',
        op: DayEventOperation.del,
        recipeUuid: 'xyz',
        occurredAtEpochMs: 1730150405444,
      );

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
      expect(event1.hashCode, equals(event2.hashCode));
    });
  });
}
