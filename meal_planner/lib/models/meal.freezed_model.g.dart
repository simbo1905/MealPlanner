// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.freezed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealImpl _$$MealImplFromJson(Map<String, dynamic> json) => _$MealImpl(
  id: json['id'] as String,
  recipeTitle: json['recipeTitle'] as String,
  date: DateTime.parse(json['date'] as String),
  slot: $enumDecode(_$MealSlotEnumMap, json['slot']),
  userId: json['userId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$MealImplToJson(_$MealImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipeTitle': instance.recipeTitle,
      'date': instance.date.toIso8601String(),
      'slot': _$MealSlotEnumMap[instance.slot]!,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$MealSlotEnumMap = {
  MealSlot.breakfast: 'breakfast',
  MealSlot.lunch: 'lunch',
  MealSlot.dinner: 'dinner',
  MealSlot.other: 'other',
};
