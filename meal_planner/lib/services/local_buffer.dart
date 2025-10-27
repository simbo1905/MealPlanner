import 'dart:collection';
import 'dart:convert';
import '../models/store_event.dart';

class LocalBuffer {
  final LinkedHashMap<String, String> _buffer = LinkedHashMap();

  LocalBuffer._();

  static final LocalBuffer _instance = LocalBuffer._();

  factory LocalBuffer() => _instance;

  /// Append an event to the local buffer.
  /// Returns immediately; no I/O blocking.
  Future<void> append(StoreEvent event) async {
    _buffer[event.id] = jsonEncode(event.toJson());
  }

  /// Read all buffered events in insertion order.
  Future<List<StoreEvent>> readAll() async {
    return _buffer.entries.map((entry) {
      final json = jsonDecode(entry.value) as Map<String, dynamic>;
      return StoreEvent.fromJson(entry.key, json);
    }).toList();
  }

  /// Delete a batch of events by ID.
  Future<void> deleteBatch(List<String> eventIds) async {
    for (final id in eventIds) {
      _buffer.remove(id);
    }
  }

  /// Get the size of the buffer (number of events).
  int get size => _buffer.length;

  /// Clear all buffered events.
  Future<void> clear() async {
    _buffer.clear();
  }

  /// Close the buffer (no-op for in-memory mock).
  Future<void> close() async {}
}
