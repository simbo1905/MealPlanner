import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/services/uuid_generator.dart';

void main() {
  group('UuidGenerator (3×64-bit)', () {
    test('generates valid 3-part format', () async {
      final uuid = await UuidGenerator.next();
      final parts = uuid.split(':');

      expect(parts, hasLength(3));
      expect(int.tryParse(parts[0]), isNotNull); // msb1 (time)
      expect(int.tryParse(parts[1]), isNotNull); // msb2 (counter)
      expect(int.tryParse(parts[2]), isNotNull); // lsb (device hash)
    });

    test('generates time-ordered UUIDs', () async {
      final uuid1 = await UuidGenerator.next();
      await Future.delayed(const Duration(milliseconds: 5));
      final uuid2 = await UuidGenerator.next();

      expect(uuid2.compareTo(uuid1), greaterThan(0));
    });

    test('increments counter for rapid generation', () async {
      final uuid1 = await UuidGenerator.next();
      final uuid2 = await UuidGenerator.next();

      final (time1, counter1, device1) = UuidGenerator.parse(uuid1);
      final (time2, counter2, device2) = UuidGenerator.parse(uuid2);

      // If same millisecond, counter increments
      if (time1 == time2) {
        expect(counter2, greaterThan(counter1));
      }

      // Device should be same
      expect(device1, equals(device2));
    });

    test('parse extracts all three components', () async {
      final uuid = await UuidGenerator.next();
      final (msb1, msb2, lsb) = UuidGenerator.parse(uuid);

      expect(msb1, greaterThan(0)); // timestamp > 0
      expect(msb2, greaterThan(0)); // counter > 0
      expect(lsb, isNotNull);
    });

    test('getTimeMs extracts timestamp', () async {
      final uuid = await UuidGenerator.next();
      final timeMs = UuidGenerator.getTimeMs(uuid);

      final nowMs = DateTime.now().millisecondsSinceEpoch;

      // Should be within 50ms
      expect((timeMs - nowMs).abs(), lessThan(50));
    });

    test('getEntityId extracts first part', () async {
      final uuid = await UuidGenerator.next();
      final entityId = UuidGenerator.getEntityId(uuid);

      final parts = uuid.split(':');
      expect(entityId, equals(parts[0]));
    });

    test('generates unique UUIDs across calls', () async {
      final uuids = <String>{};
      for (int i = 0; i < 100; i++) {
        uuids.add(await UuidGenerator.next());
      }

      expect(uuids, hasLength(100));
    });

    test('device hash is consistent', () async {
      final uuid1 = await UuidGenerator.next();
      final uuid2 = await UuidGenerator.next();

      final (_, _, device1) = UuidGenerator.parse(uuid1);
      final (_, _, device2) = UuidGenerator.parse(uuid2);

      expect(device1, equals(device2));
    });

    test('counter resets after millisecond changes', () async {
      final uuid1 = await UuidGenerator.next();
      await Future.delayed(const Duration(milliseconds: 5));
      final uuid2 = await UuidGenerator.next();

      final (time1, counter1, _) = UuidGenerator.parse(uuid1);
      final (time2, counter2, _) = UuidGenerator.parse(uuid2);

      if (time1 != time2) {
        // New millisecond, counter should reset to 1
        expect(counter2, equals(1));
      }
    });

    test('parse throws on invalid format', () {
      expect(
        () => UuidGenerator.parse('invalid'),
        throwsFormatException,
      );

      expect(
        () => UuidGenerator.parse('1:2'), // only 2 parts
        throwsFormatException,
      );
    });

    test('handles mock device generation', () async {
      final uuid = await UuidGenerator.next();
      expect(uuid, isNotEmpty);
      expect(uuid.contains(':'), isTrue);
    });
  });
}
