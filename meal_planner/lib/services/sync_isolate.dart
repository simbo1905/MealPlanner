import 'dart:async';
import 'dart:isolate';
import '../models/store_event.dart';
import 'local_buffer.dart';
import 'pocketbase_service.dart';

/// Background isolate for batched event flush to PocketBase.
/// 
/// Runs independently from the main UI thread and communicates via
/// ReceivePort/SendPort message passing.
class SyncIsolate {
  static SyncIsolate? _instance;
  late Isolate _isolate;
  late SendPort _sendPort;
  final ReceivePort _receivePort = ReceivePort();
  final StreamController<SyncMessage> _messageStream =
      StreamController<SyncMessage>.broadcast();

  int _retryCount = 0;
  Timer? _retryTimer;

  SyncIsolate._();

  /// Spawn a new background sync isolate.
  static Future<SyncIsolate> spawn() async {
    if (_instance != null) {
      return _instance!;
    }

    final sync = SyncIsolate._();
    await sync._initialize();
    _instance = sync;
    return sync;
  }

  Future<void> _initialize() async {
    _isolate = await Isolate.spawn(
      _isolateEntryPoint,
      _receivePort.sendPort,
      debugName: 'SyncIsolate',
    );

    // Wait for isolate to send back its SendPort
    _sendPort = await _receivePort.first as SendPort;

    // Listen for messages from the isolate
    _receivePort.listen((message) {
      if (message is Map) {
        final status = message['status'] as String?;
        final entityId = message['entityId'] as String?;
        final error = message['error'] as String?;

        if (status == 'conflict' && entityId != null) {
          _messageStream
              .add(SyncMessage.conflict(entityId, error ?? 'Conflict detected'));
        } else if (status == 'error') {
          _messageStream.add(SyncMessage.error(error ?? 'Unknown error'));
        } else if (status == 'flushed') {
          _retryCount = 0;
        }
      }
    });
  }

  /// Trigger a flush of buffered events to PocketBase.
  void triggerFlush() {
    _sendPort.send({'action': 'flush'});
  }

  /// Listen for sync messages (conflicts, errors).
  Stream<SyncMessage> get messages => _messageStream.stream;

  /// Gracefully shutdown the isolate.
  Future<void> shutdown() async {
    _retryTimer?.cancel();
    _sendPort.send({'action': 'shutdown'});
    _messageStream.close();
    _receivePort.close();
    _isolate.kill(priority: Isolate.immediate);
  }

  static Future<void> _isolateEntryPoint(SendPort mainPort) async {
    final receivePort = ReceivePort();
    mainPort.send(receivePort.sendPort);

    final buffer = LocalBuffer();
    final pb = PocketBaseService();

    try {
      await pb.initialize();
    } catch (e) {
      mainPort.send({'status': 'error', 'error': 'PocketBase init failed: $e'});
    }

    // Listen for messages from main isolate
    await for (final message in receivePort) {
      if (message is Map) {
        final action = message['action'] as String?;

        if (action == 'flush') {
          await _performFlush(buffer, pb, mainPort);
        } else if (action == 'shutdown') {
          receivePort.close();
          break;
        }
      }
    }
  }

  static Future<void> _performFlush(
    LocalBuffer buffer,
    PocketBaseService pb,
    SendPort mainPort,
  ) async {
    try {
      final events = await buffer.readAll();

      if (events.isEmpty) {
        return;
      }

      // Batch in groups of 100
      for (int i = 0; i < events.length; i += 100) {
        final batch = events.sublist(
          i,
          (i + 100 < events.length) ? i + 100 : events.length,
        );

        try {
          await pb.batchCreateEvents(batch);
          final eventIds = batch.map((e) => e.id).toList();
          await buffer.deleteBatch(eventIds);
          mainPort.send({'status': 'flushed', 'count': batch.length});
        } catch (e) {
          if (e.toString().contains('409')) {
            // Conflict: divergent histories
            if (batch.isNotEmpty) {
              mainPort.send({
                'status': 'conflict',
                'entityId': batch.first.entityId,
                'error': e.toString(),
              });
            }
          } else {
            rethrow;
          }
        }
      }
    } catch (e) {
      mainPort.send({'status': 'error', 'error': 'Flush failed: $e'});
    }
  }
}

/// Message sent from isolate to main thread.
class SyncMessage {
  final String type; // 'conflict', 'error'
  final String? entityId;
  final String message;

  SyncMessage({
    required this.type,
    this.entityId,
    required this.message,
  });

  factory SyncMessage.conflict(String entityId, String message) =>
      SyncMessage(type: 'conflict', entityId: entityId, message: message);

  factory SyncMessage.error(String message) =>
      SyncMessage(type: 'error', message: message);

  @override
  String toString() => 'SyncMessage($type${entityId != null ? ', $entityId' : ''})';
}
