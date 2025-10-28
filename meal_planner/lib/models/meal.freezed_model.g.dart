// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.freezed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealImpl _$$MealImplFromJson(Map<String, dynamic> json) => _$MealImpl(
  id: json['id'] as String,
  templateId: json['templateId'] as String,
  date: DateTime.parse(json['date'] as String),
  order: (json['order'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$MealImplToJson(_$MealImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'templateId': instance.templateId,
      'date': instance.date.toIso8601String(),
      'order': instance.order,
      'createdAt': instance.createdAt.toIso8601String(),
    };
