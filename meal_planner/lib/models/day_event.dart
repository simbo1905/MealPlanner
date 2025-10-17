import 'package:equatable/equatable.dart';

enum DayEventOperation {
  add,
  del,
}

String dayEventOperationToString(DayEventOperation op) {
  switch (op) {
    case DayEventOperation.add:
      return 'add';
    case DayEventOperation.del:
      return 'del';
  }
}

DayEventOperation dayEventOperationFromString(String str) {
  switch (str) {
    case 'add':
      return DayEventOperation.add;
    case 'del':
      return DayEventOperation.del;
    default:
      throw ArgumentError('Invalid day event operation: $str');
  }
}

class RecipeSnapshot extends Equatable {
  final String title;
  final String imageUrl;
  final double totalTime;

  const RecipeSnapshot({
    required this.title,
    required this.imageUrl,
    required this.totalTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'image_url': imageUrl,
      'total_time': totalTime,
    };
  }

  factory RecipeSnapshot.fromJson(Map<String, dynamic> json) {
    return RecipeSnapshot(
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
      totalTime: (json['total_time'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [title, imageUrl, totalTime];
}

class DayEvent extends Equatable {
  final String id;
  final String isoDate;
  final DayEventOperation op;
  final String recipeUuid;
  final int occurredAtEpochMs;
  final RecipeSnapshot? snapshot;

  DayEvent({
    required this.id,
    required this.isoDate,
    required this.op,
    required this.recipeUuid,
    required this.occurredAtEpochMs,
    this.snapshot,
  }) {
    if (op == DayEventOperation.add && snapshot == null) {
      throw ArgumentError('Add events must include a snapshot');
    }
  }

  /// Factory for creating add events with required snapshot
  factory DayEvent.add({
    required String id,
    required String isoDate,
    required String recipeUuid,
    required int occurredAtEpochMs,
    required RecipeSnapshot snapshot,
  }) {
    return DayEvent(
      id: id,
      isoDate: isoDate,
      op: DayEventOperation.add,
      recipeUuid: recipeUuid,
      occurredAtEpochMs: occurredAtEpochMs,
      snapshot: snapshot,
    );
  }

  /// Factory for creating delete events (no snapshot needed)
  factory DayEvent.del({
    required String id,
    required String isoDate,
    required String recipeUuid,
    required int occurredAtEpochMs,
  }) {
    return DayEvent(
      id: id,
      isoDate: isoDate,
      op: DayEventOperation.del,
      recipeUuid: recipeUuid,
      occurredAtEpochMs: occurredAtEpochMs,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'iso_date': isoDate,
      'op': dayEventOperationToString(op),
      'recipe_uuid': recipeUuid,
      'occurred_at_epoch_ms': occurredAtEpochMs,
    };

    if (snapshot != null) {
      json['snapshot'] = snapshot!.toJson();
    }

    return json;
  }

  factory DayEvent.fromJson(Map<String, dynamic> json) {
    return DayEvent(
      id: json['id'] as String,
      isoDate: json['iso_date'] as String,
      op: dayEventOperationFromString(json['op'] as String),
      recipeUuid: json['recipe_uuid'] as String,
      occurredAtEpochMs: json['occurred_at_epoch_ms'] as int,
      snapshot: json['snapshot'] != null
          ? RecipeSnapshot.fromJson(json['snapshot'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        isoDate,
        op,
        recipeUuid,
        occurredAtEpochMs,
        snapshot,
      ];
}
