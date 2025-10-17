import 'package:flutter/foundation.dart';
import 'enums.dart';

@immutable
class RecipeSnapshot {
  final String title;
  final String imageUrl;
  final double totalTime;

  const RecipeSnapshot({
    required this.title,
    required this.imageUrl,
    required this.totalTime,
  });
}

@immutable
class DayEvent {
  final String id; // Format: "$timestamp-$verb-$uuid"
  final String isoDate;
  final DayEventOperation op;
  final String recipeUuid;
  final int occurredAtEpochMs;
  final RecipeSnapshot? snapshot; // Only for 'add' events

  const DayEvent({
    required this.id,
    required this.isoDate,
    required this.op,
    required this.recipeUuid,
    required this.occurredAtEpochMs,
    this.snapshot,
  });
}

@immutable
class DayLog {
  final String isoDate;
  final List<DayEvent> events;
  final String? lastChangeToken; // For sync bookkeeping

  const DayLog({
    required this.isoDate,
    required this.events,
    this.lastChangeToken,
  });
}