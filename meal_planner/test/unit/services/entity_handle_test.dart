import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/services/entity_handle.dart';
import 'package:meal_planner/models/store_event.dart';
import 'package:meal_planner/models/event_type.dart';

class TestEntity {
  final String name;
  final int value;

  TestEntity({required this.name, required this.value});

  Map<String, dynamic> toJson() => {'name': name, 'value': value};

  factory TestEntity.fromJson(Map<String, dynamic> json) => TestEntity(
        name: json['name'] as String? ?? '',
        value: json['value'] as int? ?? 0,
      );
}

void main() {
  group('EntityHandle', () {
    test('update and undo', () async {
      final handle = EntityHandle<TestEntity>(
        entityId: '1716283456789',
        fromJson: TestEntity.fromJson,
        toJson: (e) => e.toJson(),
      );

      final initial = TestEntity(name: 'initial', value: 1);
      handle.initialize(initial, 0);

      expect(handle.state.name, 'initial');
      expect(handle.version, 0);
      expect(handle.canUndo, false);

      final updated = TestEntity(name: 'updated', value: 2);
      await handle.update(updated);

      expect(handle.state.name, 'updated');
      expect(handle.version, 1);
      expect(handle.canUndo, true);

      handle.undo();

      expect(handle.state.name, 'initial');
      expect(handle.version, 0);
      expect(handle.canRedo, true);
    });

    test('redo after undo', () async {
      final handle = EntityHandle<TestEntity>(
        entityId: '1716283456789',
        fromJson: TestEntity.fromJson,
        toJson: (e) => e.toJson(),
      );

      final initial = TestEntity(name: 'initial', value: 1);
      handle.initialize(initial, 0);

      final updated = TestEntity(name: 'updated', value: 2);
      await handle.update(updated);

      handle.undo();
      expect(handle.state.name, 'initial');

      handle.redo();
      expect(handle.state.name, 'updated');
      expect(handle.version, 1);
    });

    test('undo stack max size is 10', () async {
      final handle = EntityHandle<TestEntity>(
        entityId: '1716283456789',
        fromJson: TestEntity.fromJson,
        toJson: (e) => e.toJson(),
      );

      handle.initialize(TestEntity(name: 'initial', value: 0), 0);

      for (int i = 0; i < 15; i++) {
        await handle.update(TestEntity(name: 'test', value: i + 1));
      }

      // Max 10 undo operations
      for (int i = 0; i < 10; i++) {
        handle.undo();
      }

      // One more undo should do nothing
      handle.undo();

      // We should be at version 5 (15 - 10)
      expect(handle.version, 5);
    });

    test('update clears redo stack', () async {
      final handle = EntityHandle<TestEntity>(
        entityId: '1716283456789',
        fromJson: TestEntity.fromJson,
        toJson: (e) => e.toJson(),
      );

      handle.initialize(TestEntity(name: 'v1', value: 1), 0);

      await handle.update(TestEntity(name: 'v2', value: 2));
      await handle.update(TestEntity(name: 'v3', value: 3));

      handle.undo();
      handle.undo();

      expect(handle.canRedo, true);

      await handle.update(TestEntity(name: 'v2alt', value: 20));

      expect(handle.canRedo, false);
    });

    test('delete stages DELETE event', () async {
      final handle = EntityHandle<TestEntity>(
        entityId: '1716283456789',
        fromJson: TestEntity.fromJson,
        toJson: (e) => e.toJson(),
      );

      handle.initialize(TestEntity(name: 'test', value: 1), 0);

      await handle.delete();

      expect(handle.version, 1);
    });

    test('canUndo and canRedo properties', () async {
      final handle = EntityHandle<TestEntity>(
        entityId: '1716283456789',
        fromJson: TestEntity.fromJson,
        toJson: (e) => e.toJson(),
      );

      handle.initialize(TestEntity(name: 'initial', value: 1), 0);

      expect(handle.canUndo, false);
      expect(handle.canRedo, false);

      await handle.update(TestEntity(name: 'updated', value: 2));

      expect(handle.canUndo, true);
      expect(handle.canRedo, false);

      handle.undo();

      expect(handle.canUndo, false);
      expect(handle.canRedo, true);
    });
  });
}
