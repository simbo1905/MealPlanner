import 'event_type.dart';

class StoreEvent {
  final String id;
  final String entityId;
  final int priorVersion;
  final int nextVersion;
  final EventType eventType;
  final Map<String, dynamic> newStateJson;
  final DateTime? created;

  StoreEvent({
    required this.id,
    required this.entityId,
    required this.priorVersion,
    required this.nextVersion,
    required this.eventType,
    required this.newStateJson,
    this.created,
  });

  Map<String, dynamic> toJson() => {
        'event_id': id,  // Store app UUID as event_id field
        'entity_id': entityId,
        'prior_version': priorVersion,
        'next_version': nextVersion,
        'event_type': eventType.toJson(),
        'new_state_json': newStateJson,
      };

  factory StoreEvent.fromJson(String id, Map<String, dynamic> json) => StoreEvent(
        id: json['event_id'] as String? ?? id,  // Prefer event_id, fallback to record.id
        entityId: json['entity_id'] as String,
        priorVersion: json['prior_version'] as int,
        nextVersion: json['next_version'] as int,
        eventType: EventType.fromJson(json['event_type'] as String),
        newStateJson: json['new_state_json'] as Map<String, dynamic>,
        created: json['created'] != null
            ? DateTime.parse(json['created'] as String)
            : null,
      );

  @override
  String toString() =>
      'StoreEvent(id=$id, entityId=$entityId, nextVersion=$nextVersion, eventType=${eventType.toJson()})';
}
