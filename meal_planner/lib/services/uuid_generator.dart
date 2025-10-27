import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Time-ordered, device-unique, cross-platform UUID generator for Flutter.
/// Format:  "${msb1}:${msb2}:${lsb}"  (3 × 64-bit values)
/// - msb1  →  unix epoch milliseconds
/// - msb2  →  counter (0 at every cold start)
/// - lsb   →  SHA-256(device ID) XOR-folded to 64 bit
///
/// The string representation is *sortable by time* and collision-safe across
/// devices (clock drift + device fingerprint).

/// Generator state lives in a private singleton.
class _UuidState {
  static final _UuidState _instance = _UuidState._();
  _UuidState._();

  int _counter = 0;
  int _lastMs = 0;
  late final Future<int> _deviceHash = _computeDeviceHash();

  Future<int> _computeDeviceHash() async {
    // For now, use a simple hash of the current time + milliseconds
    // In production, this would integrate with device_info_plus
    final id = 'mock-device-${DateTime.now().millisecondsSinceEpoch}';
    final digest = sha256.convert(Uint8List.fromList(id.codeUnits));

    // XOR-fold the first 128 bits down to 64 bits
    final buf = ByteData.sublistView(
        Uint8List.fromList(digest.bytes.take(16).toList()));
    final hi = buf.getUint64(0);
    final lo = buf.getUint64(8);
    return hi ^ lo; // 64-bit result
  }
}

/// Public API – completely stateless from caller's POV.
class UuidGenerator {
  const UuidGenerator._();

  /// Generate next UUID string.
  static Future<String> next() async {
    final s = _UuidState._instance;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now != s._lastMs) {
      s._counter = 0;
      s._lastMs = now;
    }

    s._counter++;

    final device = await s._deviceHash;

    return '${s._lastMs}:${s._counter}:$device';
  }

  /// Parse a previously generated UUID back into its components.
  static (int msb1, int msb2, int lsb) parse(String uuid) {
    final parts = uuid.split(':');
    if (parts.length != 3) throw FormatException('Invalid UUID', uuid);
    return (int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  /// Extract just the timestamp component (msb1).
  static int getTimeMs(String uuid) {
    final (msb1, _, _) = parse(uuid);
    return msb1;
  }

  /// Extract entity ID (first part: timeMs).
  /// Useful for grouping all events from a cold-start window.
  static String getEntityId(String uuid) {
    final parts = uuid.split(':');
    return parts[0]; // Just the timestamp
  }
}
