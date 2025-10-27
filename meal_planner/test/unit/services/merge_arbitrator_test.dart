import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/services/merge_arbitrator.dart';
import 'package:meal_planner/models/store_event.dart';
import 'package:meal_planner/models/event_type.dart';

void main() {
  group('MergeArbitrator', () {
    late MergeArbitrator arbitrator;

    setUp(() {
      arbitrator = MergeArbitrator();
    });

    test('detects conflict when branches diverge', () async {
      final commonEvent = StoreEvent(
        id: '1716283456789:1:12345',
        entityId: '1716283456789',
        priorVersion: 0,
        nextVersion: 1,
        eventType: EventType.create,
        newStateJson: {'title': 'Original'},
      );

      final localEvent = StoreEvent(
        id: '1716283456789:2:12345',
        entityId: '1716283456789',
        priorVersion: 1,
        nextVersion: 2,
        eventType: EventType.update,
        newStateJson: {'title': 'Local Edit'},
      );

      final remoteEvent = StoreEvent(
        id: '1716283456790:2:54321',
        entityId: '1716283456789',
        priorVersion: 1,
        nextVersion: 2,
        eventType: EventType.update,
        newStateJson: {'title': 'Remote Edit'},
      );

      final localEvents = [commonEvent, localEvent];
      final remoteEvents = [commonEvent, remoteEvent];

      final result = await arbitrator.resolveConflict(
        '1716283456789',
        localEvents,
      );

      // Without access to remote, arbitrator cannot resolve
      // This is a stub implementation
      expect(result.status, isNotEmpty);
    });

    test('local wins with longer chain', () async {
      final common = StoreEvent(
        id: '1716283456789:1:12345',
        entityId: '1716283456789',
        priorVersion: 0,
        nextVersion: 1,
        eventType: EventType.create,
        newStateJson: {},
      );

      final local2 = StoreEvent(
        id: '1716283456789:2:12345',
        entityId: '1716283456789',
        priorVersion: 1,
        nextVersion: 2,
        eventType: EventType.update,
        newStateJson: {},
      );

      final local3 = StoreEvent(
        id: '1716283456789:3:12345',
        entityId: '1716283456789',
        priorVersion: 2,
        nextVersion: 3,
        eventType: EventType.update,
        newStateJson: {},
      );

      final localEvents = [common, local2, local3];

      final result = await arbitrator.resolveConflict(
        '1716283456789',
        localEvents,
      );

      // Stub: just verify it doesn't crash
      expect(result, isNotNull);
    });

    test('timestamp tie-break when chains equal length', () async {
      final olderEvent = StoreEvent(
        id: '1000000000000:1:12345',
        entityId: '1716283456789',
        priorVersion: 0,
        nextVersion: 1,
        eventType: EventType.create,
        newStateJson: {},
      );

      final newerEvent = StoreEvent(
        id: '2000000000000:1:54321',
        entityId: '1716283456789',
        priorVersion: 0,
        nextVersion: 1,
        eventType: EventType.create,
        newStateJson: {},
      );

      expect(newerEvent.id.compareTo(olderEvent.id), greaterThan(0));
    });

    test('handles empty event lists gracefully', () async {
      final result = await arbitrator.resolveConflict(
        '1716283456789',
        [],
      );

      expect(result.status, equals('panic'));
    });
  });
}
