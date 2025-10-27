// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan.freezed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealPlanImpl _$$MealPlanImplFromJson(Map<String, dynamic> json) =>
    _$MealPlanImpl(
      id: json['id'] as String,
      mealAssignmentIds: (json['mealAssignmentIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      shoppingListId: json['shoppingListId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$MealPlanImplToJson(_$MealPlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mealAssignmentIds': instance.mealAssignmentIds,
      'shoppingListId': instance.shoppingListId,
      'createdAt': instance.createdAt.toIso8601String(),
    };
