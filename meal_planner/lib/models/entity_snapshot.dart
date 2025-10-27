class EntitySnapshot {
  final String id;
  final int version;
  final String typeVersion;
  final Map<String, dynamic> stateJson;
  final bool deleted;
  final int latestHandleVersion;
  final DateTime? created;
  final DateTime? updated;

  EntitySnapshot({
    required this.id,
    required this.version,
    required this.typeVersion,
    required this.stateJson,
    required this.deleted,
    required this.latestHandleVersion,
    this.created,
    this.updated,
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'type_version': typeVersion,
        'state_json': stateJson,
        'deleted': deleted,
        'latest_handle_version': latestHandleVersion,
      };

  factory EntitySnapshot.fromJson(String id, Map<String, dynamic> json) => EntitySnapshot(
        id: id,
        version: json['version'] as int,
        typeVersion: json['type_version'] as String,
        stateJson: json['state_json'] as Map<String, dynamic>,
        deleted: json['deleted'] as bool? ?? false,
        latestHandleVersion: json['latest_handle_version'] as int? ?? 0,
        created: json['created'] != null
            ? DateTime.parse(json['created'] as String)
            : null,
        updated: json['updated'] != null
            ? DateTime.parse(json['updated'] as String)
            : null,
      );

  @override
  String toString() =>
      'EntitySnapshot(id=$id, version=$version, deleted=$deleted, latestHandleVersion=$latestHandleVersion)';
}
