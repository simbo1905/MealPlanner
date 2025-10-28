// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_template.freezed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealTemplateImpl _$$MealTemplateImplFromJson(Map<String, dynamic> json) =>
    _$MealTemplateImpl(
      templateId: json['templateId'] as String,
      title: json['title'] as String,
      type: $enumDecode(_$MealTypeEnumMap, json['type']),
      prepTimeMinutes: (json['prepTimeMinutes'] as num).toInt(),
      iconName: json['iconName'] as String,
      colorHex: json['colorHex'] as String,
    );

Map<String, dynamic> _$$MealTemplateImplToJson(_$MealTemplateImpl instance) =>
    <String, dynamic>{
      'templateId': instance.templateId,
      'title': instance.title,
      'type': _$MealTypeEnumMap[instance.type]!,
      'prepTimeMinutes': instance.prepTimeMinutes,
      'iconName': instance.iconName,
      'colorHex': instance.colorHex,
    };

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
  MealType.snack: 'snack',
  MealType.supper: 'supper',
};
