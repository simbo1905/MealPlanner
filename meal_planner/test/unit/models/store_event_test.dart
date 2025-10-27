import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/store_event.dart';
import 'package:meal_planner/models/event_type.dart';

void main() {
  group('StoreEvent', () {
    test('toJson and fromJson round-trip', () {
      final event = StoreEvent(
        id: '1716283456789:1:12345',
        entityId: '1716283456789',
        priorVersion: 0,
        nextVersion: 1,
        eventType: EventType.create,
        newStateJson: {
          'title': 'Test Recipe',
          'description': 'A test recipe',
        },
      );

      final json = event.toJson();
      final restored = StoreEvent.fromJson(event.id, json);

      expect(restored.id, event.id);
      expect(restored.entityId, event.entityId);
      expect(restored.priorVersion, event.priorVersion);
      expect(restored.nextVersion, event.nextVersion);
      expect(restored.eventType, event.eventType);
      expect(restored.newStateJson, event.newStateJson);
    });

    test('UPDATE event type serializes correctly', () {
      final event = StoreEvent(
        id: '1716283456789:2:12345',
        entityId: '1716283456789',
        priorVersion: 1,
        nextVersion: 2,
        eventType: EventType.update,
        newStateJson: {'title': 'Updated'},
      );

      final json = event.toJson();
      expect(json['event_type'], 'UPDATE');

      final restored = StoreEvent.fromJson(event.id, json);
      expect(restored.eventType, EventType.update);
    });

    test('DELETE event type serializes correctly', () {
      final event = StoreEvent(
        id: '1716283456789:3:12345',
        entityId: '1716283456789',
        priorVersion: 2,
        nextVersion: 3,
        eventType: EventType.delete,
        newStateJson: {},
      );

      final json = event.toJson();
      expect(json['event_type'], 'DELETE');

      final restored = StoreEvent.fromJson(event.id, json);
      expect(restored.eventType, EventType.delete);
    });

    test('toString provides useful debug info', () {
      final event = StoreEvent(
        id: '1716283456789:1:12345',
        entityId: '1716283456789',
        priorVersion: 0,
        nextVersion: 1,
        eventType: EventType.create,
        newStateJson: {},
      );

      expect(event.toString(), contains('1716283456789'));
      expect(event.toString(), contains('nextVersion=1'));
    });
  });
}
