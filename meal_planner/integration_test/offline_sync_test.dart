import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/main.dart';
import 'package:meal_planner/services/local_buffer.dart';
import 'package:meal_planner/services/sync_isolate.dart';
import 'package:meal_planner/services/entity_handle.dart';
import 'package:meal_planner/models/recipe.dart';
import 'package:meal_planner/models/ingredient.dart';
import 'package:meal_planner/models/enums.dart';

void main() {
  group('Offline Sync Integration Tests', () {
    late LocalBuffer buffer;
    late SyncIsolate syncIsolate;

    setUpAll(() async {
      buffer = LocalBuffer();
      syncIsolate = await SyncIsolate.spawn();
    });

    tearDownAll(() async {
      await buffer.close();
      await syncIsolate.shutdown();
    });

    test('create recipe offline and stage to buffer', () async {
      final recipe = Recipe(
        uuid: 'test-uuid-1',
        title: 'Offline Recipe',
        description: 'Created while offline',
        imageUrl: '',
        notes: 'Test notes',
        preReqs: [],
        totalTime: 30,
        ingredients: [
          const Ingredient(
            name: 'Test Ingredient',
            ucumUnit: UcumUnit.cup_us,
            ucumAmount: 1.0,
            metricUnit: MetricUnit.g,
            metricAmount: 100,
            notes: '',
          ),
        ],
        steps: ['Step 1', 'Step 2'],
      );

      final handle = EntityHandle<Recipe>(
        entityId: 'test-entity-1',
        fromJson: (json) => Recipe(
          uuid: json['uuid'] as String?,
          title: json['title'] as String? ?? '',
          description: json['description'] as String? ?? '',
          imageUrl: json['imageUrl'] as String? ?? '',
          notes: json['notes'] as String? ?? '',
          preReqs: (json['preReqs'] as List?)?.cast<String>() ?? [],
          totalTime: (json['totalTime'] as num?)?.toDouble() ?? 0,
          ingredients: [],
          steps: (json['steps'] as List?)?.cast<String>() ?? [],
        ),
        toJson: (recipe) => {
          'uuid': recipe.uuid,
          'title': recipe.title,
          'description': recipe.description,
          'imageUrl': recipe.imageUrl,
          'notes': recipe.notes,
          'preReqs': recipe.preReqs,
          'totalTime': recipe.totalTime,
          'steps': recipe.steps,
        },
        buffer: buffer,
      );

      handle.initialize(recipe, 0);
      await handle.update(recipe);
      await handle.save();

      final bufferedEvents = await buffer.readAll();
      expect(bufferedEvents, isNotEmpty);
      expect(bufferedEvents[0].entityId, 'test-entity-1');
    });

    test('buffer persists events in order', () async {
      final handle = EntityHandle<Recipe>(
        entityId: 'test-entity-2',
        fromJson: (_) => Recipe(
          title: 'Test',
          description: '',
          imageUrl: '',
          notes: '',
          preReqs: [],
          totalTime: 0,
          ingredients: [],
          steps: [],
        ),
        toJson: (_) => {},
        buffer: buffer,
      );

      final recipe = Recipe(
        title: 'Test Recipe',
        description: '',
        imageUrl: '',
        notes: '',
        preReqs: [],
        totalTime: 30,
        ingredients: [],
        steps: [],
      );

      handle.initialize(recipe, 0);

      final updated1 = Recipe(
        title: 'Updated 1',
        description: '',
        imageUrl: '',
        notes: '',
        preReqs: [],
        totalTime: 30,
        ingredients: [],
        steps: [],
      );
      await handle.update(updated1);

      final updated2 = Recipe(
        title: 'Updated 2',
        description: '',
        imageUrl: '',
        notes: '',
        preReqs: [],
        totalTime: 30,
        ingredients: [],
        steps: [],
      );
      await handle.update(updated2);

      await handle.save();

      final allEvents = await buffer.readAll();
      final entityEvents = allEvents
          .where((e) => e.entityId == 'test-entity-2')
          .toList();

      expect(entityEvents, hasLength(greaterThanOrEqualTo(2)));
      expect(entityEvents[0].nextVersion, 1);
      if (entityEvents.length > 1) {
        expect(entityEvents[1].nextVersion, 2);
      }
    });

    test('undo/redo before save does not persist', () async {
      final handle = EntityHandle<Recipe>(
        entityId: 'test-entity-3',
        fromJson: (_) => Recipe(
          title: 'Test',
          description: '',
          imageUrl: '',
          notes: '',
          preReqs: [],
          totalTime: 0,
          ingredients: [],
          steps: [],
        ),
        toJson: (_) => {},
        buffer: buffer,
      );

      final recipe = Recipe(
        title: 'V1',
        description: '',
        imageUrl: '',
        notes: '',
        preReqs: [],
        totalTime: 30,
        ingredients: [],
        steps: [],
      );

      handle.initialize(recipe, 0);

      final updated = Recipe(
        title: 'V2',
        description: '',
        imageUrl: '',
        notes: '',
        preReqs: [],
        totalTime: 30,
        ingredients: [],
        steps: [],
      );
      await handle.update(updated);

      handle.undo();

      // Don't save – undone changes should not be in buffer
      final allEvents = await buffer.readAll();
      final entity3Events =
          allEvents.where((e) => e.entityId == 'test-entity-3').toList();

      expect(entity3Events, isEmpty);
    });

    test('sync isolate receives flush message', () async {
      // Trigger a flush
      syncIsolate.triggerFlush();

      // Give isolate time to process
      await Future.delayed(const Duration(milliseconds: 100));

      // No errors should have occurred
      // (This is a basic smoke test; full integration test would mock PocketBase)
    });
  });
}
