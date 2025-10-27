import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/services/local_buffer.dart';
import 'package:meal_planner/models/store_event.dart';
import 'package:meal_planner/models/event_type.dart';

void main() {
  group('LocalBuffer', () {
    late LocalBuffer buffer;

    setUp(() {
      buffer = LocalBuffer();
    });

    tearDown(() async {
      await buffer.close();
    });

    test('append and readAll', () async {
      final event1 = StoreEvent(
        id: '1716283456789:1:12345',
        entityId: '1716283456789',
        priorVersion: 0,
        nextVersion: 1,
        eventType: EventType.create,
        newStateJson: {'title': 'Test'},
      );

      final event2 = StoreEvent(
        id: '1716283456789:2:12345',
        entityId: '1716283456789',
        priorVersion: 1,
        nextVersion: 2,
        eventType: EventType.update,
        newStateJson: {'title': 'Updated'},
      );

      await buffer.append(event1);
      await buffer.append(event2);

      final events = await buffer.readAll();

      expect(events, hasLength(2));
      expect(events[0].id, event1.id);
      expect(events[1].id, event2.id);
    });

    test('deleteBatch removes events', () async {
      final event1 = StoreEvent(
        id: '1716283456789:1:12345',
        entityId: '1716283456789',
        priorVersion: 0,
        nextVersion: 1,
        eventType: EventType.create,
        newStateJson: {},
      );

      final event2 = StoreEvent(
        id: '1716283456789:2:12345',
        entityId: '1716283456789',
        priorVersion: 1,
        nextVersion: 2,
        eventType: EventType.update,
        newStateJson: {},
      );

      await buffer.append(event1);
      await buffer.append(event2);

      expect(buffer.size, 2);

      await buffer.deleteBatch([event1.id]);

      expect(buffer.size, 1);
      final remaining = await buffer.readAll();
      expect(remaining, hasLength(1));
      expect(remaining[0].id, event2.id);
    });

    test('clear empties buffer', () async {
      final event = StoreEvent(
        id: '1716283456789:1:12345',
        entityId: '1716283456789',
        priorVersion: 0,
        nextVersion: 1,
        eventType: EventType.create,
        newStateJson: {},
      );

      await buffer.append(event);
      expect(buffer.size, 1);

      await buffer.clear();
      expect(buffer.size, 0);
    });

    test('buffer maintains insertion order', () async {
      final events = <StoreEvent>[];
      for (int i = 0; i < 5; i++) {
        final event = StoreEvent(
          id: '1716283456789:${i + 1}:12345',
          entityId: '1716283456789',
          priorVersion: i,
          nextVersion: i + 1,
          eventType: EventType.update,
          newStateJson: {'index': i},
        );
        events.add(event);
        await buffer.append(event);
      }

      final readback = await buffer.readAll();

      for (int i = 0; i < 5; i++) {
        expect(readback[i].id, events[i].id);
        expect(readback[i].nextVersion, i + 1);
      }
    });
  });
}
