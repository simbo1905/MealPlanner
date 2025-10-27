// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_assignment.freezed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealAssignmentImpl _$$MealAssignmentImplFromJson(Map<String, dynamic> json) =>
    _$MealAssignmentImpl(
      id: json['id'] as String,
      recipeId: json['recipeId'] as String,
      dayIsoDate: json['dayIsoDate'] as String,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
    );

Map<String, dynamic> _$$MealAssignmentImplToJson(
  _$MealAssignmentImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'recipeId': instance.recipeId,
  'dayIsoDate': instance.dayIsoDate,
  'assignedAt': instance.assignedAt.toIso8601String(),
};
