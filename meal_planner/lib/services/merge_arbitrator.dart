import '../models/store_event.dart';
import 'pocketbase_service.dart';
import 'uuid_generator.dart';

/// Conflict resolution for divergent event histories.
/// 
/// When two devices edit the same entity offline and both reconnect,
/// their event chains diverge. This arbitrator finds the common ancestor
/// and determines the winner based on longest chain + timestamp.
class MergeArbitrator {
  final PocketBaseService pb;

  MergeArbitrator({PocketBaseService? pocketbase})
      : pb = pocketbase ?? PocketBaseService();

  /// Resolve a conflict for the given entity.
  /// 
  /// Returns the winning branch. If local loses, recommends app restart.
  Future<ConflictResolution> resolveConflict(
    String entityId,
    List<StoreEvent> localEvents,
  ) async {
    try {
      // Fetch remote events
      final remoteEvents = await pb.getEvents(entityId);

      // Find common ancestor
      final commonAncestor =
          _findCommonAncestor(localEvents, remoteEvents);

      if (commonAncestor == null) {
        // No common ancestor – completely divergent
        return ConflictResolution.panic(
          'No common ancestor found. Local state discarded.',
        );
      }

      // Count events from ancestor in each branch
      final localCount = _countEventsAfter(localEvents, commonAncestor.nextVersion);
      final remoteCount =
          _countEventsAfter(remoteEvents, commonAncestor.nextVersion);

      // Determine winner
      int winner;
      if (localCount > remoteCount) {
        winner = 1; // Local wins
      } else if (remoteCount > localCount) {
        winner = -1; // Remote wins
      } else {
        // Same count – tie-break by timestamp (first UUID component)
        final localNewest = _newestEvent(localEvents, commonAncestor.nextVersion);
        final remoteNewest =
            _newestEvent(remoteEvents, commonAncestor.nextVersion);

        if (localNewest == null || remoteNewest == null) {
          return ConflictResolution.panic('Cannot determine newest event');
        }

        final localTime = UuidGenerator.parse(localNewest.id).$1;
        final remoteTime = UuidGenerator.parse(remoteNewest.id).$1;

        winner = remoteTime.compareTo(localTime); // Newer timestamp wins
      }

      if (winner == 1) {
        return ConflictResolution.localWins(localEvents);
      } else {
        return ConflictResolution.remoteWins(
          'Remote branch has more edits. Recommend app restart.',
        );
      }
    } catch (e) {
      return ConflictResolution.panic('Arbitration failed: $e');
    }
  }

  StoreEvent? _findCommonAncestor(
    List<StoreEvent> local,
    List<StoreEvent> remote,
  ) {
    // Walk back through local events until we find one that exists in remote
    // Match by version number rather than JSON equality
    for (final le in local.reversed) {
      for (final re in remote) {
        if (le.entityId == re.entityId && 
            le.nextVersion == re.nextVersion &&
            le.priorVersion == re.priorVersion) {
          return le;
        }
      }
    }
    return null;
  }

  int _countEventsAfter(List<StoreEvent> events, int sinceVersion) {
    return events.where((e) => e.nextVersion > sinceVersion).length;
  }

  StoreEvent? _newestEvent(List<StoreEvent> events, int sinceVersion) {
    final candidates = events.where((e) => e.nextVersion > sinceVersion);
    if (candidates.isEmpty) return null;
    
    // Sort by created timestamp (if available) or event_id as fallback
    return candidates.reduce((a, b) {
      if (a.created != null && b.created != null) {
        return a.created!.isAfter(b.created!) ? a : b;
      }
      // Fallback to event_id lexicographic comparison (time-ordered UUIDs)
      return a.id.compareTo(b.id) > 0 ? a : b;
    });
  }
}

/// Result of conflict arbitration.
class ConflictResolution {
  final String status; // 'local_wins', 'remote_wins', 'panic'
  final List<StoreEvent>? winningEvents;
  final String message;

  ConflictResolution({
    required this.status,
    this.winningEvents,
    required this.message,
  });

  factory ConflictResolution.localWins(List<StoreEvent> events) =>
      ConflictResolution(
        status: 'local_wins',
        winningEvents: events,
        message: 'Local branch wins (longer chain or newer timestamp)',
      );

  factory ConflictResolution.remoteWins(String message) => ConflictResolution(
        status: 'remote_wins',
        message: message,
      );

  factory ConflictResolution.panic(String message) => ConflictResolution(
        status: 'panic',
        message: message,
      );

  @override
  String toString() => 'ConflictResolution($status: $message)';
}
