
import 'package:flutter/foundation.dart';
import 'day_log.dart';
import 'enums.dart';

@immutable
class MealEntry {
  final String recipeUuid;
  final String title;
  final String imageUrl;
  final double totalTime;

  const MealEntry({
    required this.recipeUuid,
    required this.title,
    required this.imageUrl,
    required this.totalTime,
  });

  factory MealEntry.fromEvent(DayEvent event) {
    if (event.op != DayEventOperation.add || event.snapshot == null) {
      throw ArgumentError('Cannot create MealEntry from a non-add event or event with no snapshot.');
    }
    return MealEntry(
      recipeUuid: event.recipeUuid,
      title: event.snapshot!.title,
      imageUrl: event.snapshot!.imageUrl,
      totalTime: event.snapshot!.totalTime,
    );
  }
}
