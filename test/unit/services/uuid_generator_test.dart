import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/services/uuid_generator.dart';

void main() {
  group('UuidGenerator', () {
    test('generates valid UUID string with colon delimiters', () async {
      final uuid = await UuidGenerator.next();
      expect(uuid, matches(r'^\d+:\d+:(-?\d+)$'));
      final parts = uuid.split(':');
      expect(parts.length, 3);
    });

    test('generates time-ordered UUIDs', () async {
      final uuid1 = await UuidGenerator.next();
      await Future.delayed(const Duration(milliseconds: 10));
      final uuid2 = await UuidGenerator.next();

      final (msb1_1, _, _) = UuidGenerator.parse(uuid1);
      final (msb1_2, _, _) = UuidGenerator.parse(uuid2);

      expect(msb1_2, greaterThanOrEqualTo(msb1_1));
    });

    test('increments counter within same millisecond', () async {
      final uuid1 = await UuidGenerator.next();
      final uuid2 = await UuidGenerator.next();

      final (_, msb2_1, _) = UuidGenerator.parse(uuid1);
      final (_, msb2_2, _) = UuidGenerator.parse(uuid2);

      expect(msb2_2, greaterThan(msb2_1));
    });

    test('parses UUID back into components', () async {
      final uuid = await UuidGenerator.next();
      final (msb1, msb2, lsb) = UuidGenerator.parse(uuid);

      expect(msb1, greaterThan(0));
      expect(msb2, greaterThan(0));
      expect(lsb, isNotNull);
    });

    test('getTimeMs extracts timestamp correctly', () async {
      final uuid = await UuidGenerator.next();
      final timeMs = UuidGenerator.getTimeMs(uuid);
      final (msb1, _, _) = UuidGenerator.parse(uuid);

      expect(timeMs, equals(msb1));
    });

    test('getEntityId returns timestamp string', () async {
      final uuid = await UuidGenerator.next();
      final entityId = UuidGenerator.getEntityId(uuid);
      final (msb1, _, _) = UuidGenerator.parse(uuid);

      expect(entityId, equals(msb1.toString()));
    });

    test('parse throws on invalid UUID format', () {
      expect(
        () => UuidGenerator.parse('invalid'),
        throwsA(isA<FormatException>()),
      );
    });

    test('parse throws on wrong number of parts', () {
      expect(
        () => UuidGenerator.parse('1:2'),
        throwsA(isA<FormatException>()),
      );
    });

    test('device hash is consistent across calls', () async {
      final uuid1 = await UuidGenerator.next();
      final uuid2 = await UuidGenerator.next();

      final (_, _, lsb1) = UuidGenerator.parse(uuid1);
      final (_, _, lsb2) = UuidGenerator.parse(uuid2);

      expect(lsb1, equals(lsb2));
    });

    test('counter resets after timestamp changes', () async {
      final uuid1 = await UuidGenerator.next();
      final (_, msb2_1, _) = UuidGenerator.parse(uuid1);

      await Future.delayed(const Duration(milliseconds: 50));
      final uuid2 = await UuidGenerator.next();
      final (msb1_2, msb2_2, _) = UuidGenerator.parse(uuid2);

      final (msb1_1, _, _) = UuidGenerator.parse(uuid1);

      if (msb1_2 > msb1_1) {
        expect(msb2_2, equals(1));
      }
    });

    test('generated UUIDs are sortable by time', () async {
      final uuids = <String>[];
      for (int i = 0; i < 5; i++) {
        uuids.add(await UuidGenerator.next());
        await Future.delayed(const Duration(milliseconds: 10));
      }

      final sorted = List<String>.from(uuids)
        ..sort((a, b) {
          final timeA = UuidGenerator.getTimeMs(a);
          final timeB = UuidGenerator.getTimeMs(b);
          return timeA.compareTo(timeB);
        });

      expect(sorted, equals(uuids));
    });
  });
}
