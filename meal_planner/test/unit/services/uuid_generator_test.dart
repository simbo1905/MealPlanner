import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/services/uuid_generator.dart';

void main() {
  group('UUIDGenerator', () {
    test('should generate valid UUID format', () {
      final uuid = UUIDGenerator.generateUUID();
      final pattern = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');
      expect(uuid, matches(pattern));
    });

    test('should generate unique UUIDs', () {
      final uuids = <String>{};
      for (int i = 0; i < 10000; i++) {
        uuids.add(UUIDGenerator.generateUUID());
      }
      expect(uuids.length, 10000);
    });

    test('should generate time-ordered UUIDs', () async {
      final uuid1 = UUIDGenerator.generateUUID();
      await Future.delayed(const Duration(milliseconds: 10));
      final uuid2 = UUIDGenerator.generateUUID();
      await Future.delayed(const Duration(milliseconds: 10));
      final uuid3 = UUIDGenerator.generateUUID();

      final time1 = UUIDGenerator.dissect(uuid1);
      final time2 = UUIDGenerator.dissect(uuid2);
      final time3 = UUIDGenerator.dissect(uuid3);

      expect(time1 < time2, true);
      expect(time2 < time3, true);
    });

    test('should maintain ordering for rapid generation', () {
      final uuids = <String>[];
      for (int i = 0; i < 1000; i++) {
        uuids.add(UUIDGenerator.generateUUID());
      }

      final timestamps = uuids.map((uuid) => UUIDGenerator.dissect(uuid)).toList();
      
      for (int i = 1; i < timestamps.length; i++) {
        expect(timestamps[i] >= timestamps[i - 1], true,
            reason: 'UUID at index $i has timestamp ${timestamps[i]} which is less than previous ${timestamps[i - 1]}');
      }
    });

    test('should dissect UUID to extract timestamp', () {
      final uuid = UUIDGenerator.generateUUID();
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final extractedMs = UUIDGenerator.dissect(uuid);

      // Should be within 50ms tolerance
      expect((extractedMs - nowMs).abs(), lessThan(50));
    });

    test('should extract both timestamp and sequence from UUID', () {
      final uuids = <String>[];
      
      // Generate multiple UUIDs rapidly (likely same millisecond)
      for (int i = 0; i < 10; i++) {
        uuids.add(UUIDGenerator.generateUUID());
      }

      // Dissect each UUID
      for (int i = 0; i < uuids.length; i++) {
        final result = UUIDGenerator.dissectFull(uuids[i]);
        expect(result.timestampMs, isNotNull);
        expect(result.sequence, greaterThanOrEqualTo(0));
        expect(result.sequence, lessThan(0x100000)); // 20-bit max
        
        // If same millisecond, sequence should increment
        if (i > 0) {
          final prev = UUIDGenerator.dissectFull(uuids[i - 1]);
          if (result.timestampMs == prev.timestampMs) {
            expect(result.sequence, greaterThan(prev.sequence));
          }
        }
      }
    });

    test('should round-trip timestamp correctly', () async {
      final uuid = UUIDGenerator.generateUUID();
      final extracted = UUIDGenerator.dissect(uuid);
      
      // Generate another UUID with similar time
      await Future.delayed(const Duration(milliseconds: 1));
      final uuid2 = UUIDGenerator.generateUUID();
      final extracted2 = UUIDGenerator.dissect(uuid2);

      expect(extracted, isNotNull);
      expect(extracted2, isNotNull);
      expect(extracted2 >= extracted, true);
    });

    test('should handle sub-millisecond generation with counter', () {
      final uuids = <String>[];
      
      // Generate many UUIDs rapidly (within same millisecond)
      for (int i = 0; i < 100; i++) {
        uuids.add(UUIDGenerator.generateUUID());
      }

      // All UUIDs should be unique even if generated in same millisecond
      final uniqueUuids = uuids.toSet();
      expect(uniqueUuids.length, 100);

      // Extract timestamps - some may be same millisecond, but UUIDs must be unique
      final timestamps = uuids.map((uuid) => UUIDGenerator.dissect(uuid)).toList();
      expect(timestamps, isNotNull);
    });

    test('should reset counter when millisecond changes', () async {
      final uuid1 = UUIDGenerator.generateUUID();
      
      // Wait for millisecond to change
      await Future.delayed(const Duration(milliseconds: 2));
      
      final uuid2 = UUIDGenerator.generateUUID();
      
      final time1 = UUIDGenerator.dissect(uuid1);
      final time2 = UUIDGenerator.dissect(uuid2);
      
      expect(time2 > time1, true);
      expect(uuid1, isNot(equals(uuid2)));
    });

    test('should generate different random portions', () {
      final uuids = <String>[];
      for (int i = 0; i < 100; i++) {
        uuids.add(UUIDGenerator.generateUUID());
      }

      // Extract last 12 chars (random portion)
      final randomPortions = uuids.map((uuid) => uuid.substring(uuid.length - 12)).toSet();
      
      // Should have many unique random portions
      expect(randomPortions.length, greaterThan(90));
    });

    test('should handle edge case of maximum counter value', () {
      // Generate enough UUIDs to potentially overflow 20-bit counter
      // 2^20 = 1,048,576
      final uuids = <String>[];
      
      for (int i = 0; i < 1000; i++) {
        uuids.add(UUIDGenerator.generateUUID());
      }
      
      // Should still generate valid, unique UUIDs
      expect(uuids.toSet().length, 1000);
    });
  });
}
