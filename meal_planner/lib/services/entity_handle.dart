import '../models/store_event.dart';
import '../models/event_type.dart';
import 'local_buffer.dart';
import 'uuid_generator.dart';
import 'sync_isolate.dart';

/// Generic active-record cursor for event-sourced entities.
/// 
/// Only one writable handle per entity should be alive at a time.
/// Supports undo/redo for the last 10 operations.
class EntityHandle<T> {
  final String entityId;
  final LocalBuffer _buffer;
  final SyncIsolate? _syncIsolate;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  int _currentVersion = 0;
  int _initialVersion = 0;
  final List<StoreEvent> _undoStack = [];
  final List<StoreEvent> _redoStack = [];
  late T _currentState;
  late T _initialState;

  EntityHandle({
    required this.entityId,
    required this.fromJson,
    required this.toJson,
    LocalBuffer? buffer,
    SyncIsolate? syncIsolate,
  }) : _buffer = buffer ?? LocalBuffer(),
       _syncIsolate = syncIsolate;

  /// Initialize the handle with an existing entity state and version.
  void initialize(T initialState, int version) {
    _currentState = initialState;
    _initialState = initialState;
    _currentVersion = version;
    _initialVersion = version;
    _undoStack.clear();
    _redoStack.clear();
  }

  /// Update the entity with new state.
  /// Stages an event but does NOT persist yet – call save() for that.
  Future<void> update(T newState) async {
    final uuid = await UuidGenerator.next();
    final stateJson = toJson(newState);

    final event = StoreEvent(
      id: uuid,
      entityId: entityId,
      priorVersion: _currentVersion,
      nextVersion: _currentVersion + 1,
      eventType: EventType.update,
      newStateJson: stateJson,
    );

    _undoStack.add(event);
    if (_undoStack.length > 10) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();

    _currentState = newState;
    _currentVersion++;
  }

  /// Persist all staged events to the local buffer.
  /// Typically called after update(). Triggers SyncIsolate on success.
  Future<void> save() async {
    for (final event in _undoStack) {
      await _buffer.append(event);
    }
    _undoStack.clear();
    
    // Trigger background flush if sync isolate is available
    _syncIsolate?.triggerFlush();
  }

  /// Stage a DELETE event for this entity.
  Future<void> delete() async {
    final uuid = await UuidGenerator.next();

    final event = StoreEvent(
      id: uuid,
      entityId: entityId,
      priorVersion: _currentVersion,
      nextVersion: _currentVersion + 1,
      eventType: EventType.delete,
      newStateJson: {},
    );

    await _buffer.append(event);
    _currentVersion++;
  }

  /// Undo the last operation by rolling back to the previous state.
  void undo() {
    if (_undoStack.isEmpty) return;

    final lastEvent = _undoStack.removeLast();
    _redoStack.add(lastEvent);

    if (_undoStack.isNotEmpty) {
      final previousEvent = _undoStack.last;
      _currentState = fromJson(previousEvent.newStateJson);
      _currentVersion = previousEvent.nextVersion;
    } else {
      // Revert to initial state when undo stack is empty
      _currentState = _initialState;
      _currentVersion = _initialVersion;
    }
  }

  /// Redo the last undone operation.
  void redo() {
    if (_redoStack.isEmpty) return;

    final nextEvent = _redoStack.removeLast();
    _undoStack.add(nextEvent);

    _currentState = fromJson(nextEvent.newStateJson);
    _currentVersion = nextEvent.nextVersion;
  }

  T get state => _currentState;

  int get version => _currentVersion;

  bool get canUndo => _undoStack.isNotEmpty;

  bool get canRedo => _redoStack.isNotEmpty;

  @override
  String toString() =>
      'EntityHandle(entityId=$entityId, version=$_currentVersion, undoDepth=${_undoStack.length})';
}
