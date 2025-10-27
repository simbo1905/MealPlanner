// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient.freezed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IngredientImpl _$$IngredientImplFromJson(Map<String, dynamic> json) =>
    _$IngredientImpl(
      name: json['name'] as String,
      ucumUnit: $enumDecode(_$UcumUnitEnumMap, json['ucumUnit']),
      ucumAmount: (json['ucumAmount'] as num).toDouble(),
      metricUnit: $enumDecode(_$MetricUnitEnumMap, json['metricUnit']),
      metricAmount: (json['metricAmount'] as num).toDouble(),
      notes: json['notes'] as String,
      allergenCode: $enumDecodeNullable(
        _$AllergenCodeEnumMap,
        json['allergenCode'],
      ),
    );

Map<String, dynamic> _$$IngredientImplToJson(_$IngredientImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'ucumUnit': _$UcumUnitEnumMap[instance.ucumUnit]!,
      'ucumAmount': instance.ucumAmount,
      'metricUnit': _$MetricUnitEnumMap[instance.metricUnit]!,
      'metricAmount': instance.metricAmount,
      'notes': instance.notes,
      'allergenCode': _$AllergenCodeEnumMap[instance.allergenCode],
    };

const _$UcumUnitEnumMap = {
  UcumUnit.cup_us: 'cup_us',
  UcumUnit.cup_m: 'cup_m',
  UcumUnit.cup_imp: 'cup_imp',
  UcumUnit.tbsp_us: 'tbsp_us',
  UcumUnit.tbsp_m: 'tbsp_m',
  UcumUnit.tbsp_imp: 'tbsp_imp',
  UcumUnit.tsp_us: 'tsp_us',
  UcumUnit.tsp_m: 'tsp_m',
  UcumUnit.tsp_imp: 'tsp_imp',
};

const _$MetricUnitEnumMap = {MetricUnit.ml: 'ml', MetricUnit.g: 'g'};

const _$AllergenCodeEnumMap = {
  AllergenCode.GLUTEN: 'GLUTEN',
  AllergenCode.CRUSTACEAN: 'CRUSTACEAN',
  AllergenCode.EGG: 'EGG',
  AllergenCode.FISH: 'FISH',
  AllergenCode.PEANUT: 'PEANUT',
  AllergenCode.SOY: 'SOY',
  AllergenCode.MILK: 'MILK',
  AllergenCode.NUT: 'NUT',
  AllergenCode.CELERY: 'CELERY',
  AllergenCode.MUSTARD: 'MUSTARD',
  AllergenCode.SESAME: 'SESAME',
  AllergenCode.SULPHITE: 'SULPHITE',
  AllergenCode.LUPIN: 'LUPIN',
  AllergenCode.MOLLUSC: 'MOLLUSC',
  AllergenCode.SHELLFISH: 'SHELLFISH',
  AllergenCode.TREENUT: 'TREENUT',
  AllergenCode.WHEAT: 'WHEAT',
};
