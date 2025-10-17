import 'dart:math';
import 'dart:typed_data';

class UUIDGenerator {
  static int _sequence = 0;
  static int _lastEpochMs = 0;
  static final Random _random = Random.secure();

  /// Generates a time-based UUID with sub-millisecond ordering
  /// 
  /// Web-safe implementation using BigInt for proper 64-bit operations.
  /// 
  /// Format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx (32 hex chars + 4 hyphens)
  /// MSB (first 16 hex chars): (epoch_ms << 20) | (counter & 0xFFFFF)
  /// LSB (last 16 hex chars): random 64 bits for global uniqueness
  static String generateUUID() {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Sub-millisecond ordering via 20-bit counter
    if (now == _lastEpochMs) {
      _sequence = (_sequence + 1) & 0xFFFFF; // 20-bit mask
    } else {
      _sequence = 0;
      _lastEpochMs = now;
    }

    // Use BigInt for web-safe 64-bit operations
    // MSB: time (44 bits) + counter (20 bits) = 64 bits
    final msb = (BigInt.from(now) << 20) | BigInt.from(_sequence);

    // LSB: random 64 bits for uniqueness
    final lsb = _randomBigInt();

    return _formatUUID(msb, lsb);
  }

  /// Extracts the timestamp (epoch milliseconds) from a UUID
  static int dissect(String uuid) {
    final hex = uuid.replaceAll('-', '');
    final msbHex = hex.substring(0, 16);
    final msb = BigInt.parse(msbHex, radix: 16);
    final epochMs = msb >> 20; // Extract timestamp from upper bits
    return epochMs.toInt();
  }

  /// Extracts both timestamp and sequence counter from a UUID
  static ({int timestampMs, int sequence}) dissectFull(String uuid) {
    final hex = uuid.replaceAll('-', '');
    final msbHex = hex.substring(0, 16);
    final msb = BigInt.parse(msbHex, radix: 16);
    final timestampMs = (msb >> 20).toInt();
    final sequence = (msb & BigInt.from(0xFFFFF)).toInt();
    return (timestampMs: timestampMs, sequence: sequence);
  }

  /// Generates a random 64-bit BigInt using secure random bytes
  static BigInt _randomBigInt() {
    // Generate 8 random bytes (64 bits)
    final bytes = Uint8List(8);
    for (int i = 0; i < 8; i++) {
      bytes[i] = _random.nextInt(256);
    }

    // Convert bytes to BigInt
    BigInt result = BigInt.zero;
    for (int i = 0; i < 8; i++) {
      result = (result << 8) | BigInt.from(bytes[i]);
    }
    return result;
  }

  /// Formats two 64-bit BigInts as UUID string
  static String _formatUUID(BigInt msb, BigInt lsb) {
    final msbHex = msb.toRadixString(16).padLeft(16, '0');
    final lsbHex = lsb.toRadixString(16).padLeft(16, '0');

    return '${msbHex.substring(0, 8)}-'
        '${msbHex.substring(8, 12)}-'
        '${msbHex.substring(12, 16)}-'
        '${lsbHex.substring(0, 4)}-'
        '${lsbHex.substring(4, 16)}';
  }
}
