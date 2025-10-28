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
  UcumUnit.cupUs: 'cupUs',
  UcumUnit.cupM: 'cupM',
  UcumUnit.cupImp: 'cupImp',
  UcumUnit.tbspUs: 'tbspUs',
  UcumUnit.tbspM: 'tbspM',
  UcumUnit.tbspImp: 'tbspImp',
  UcumUnit.tspUs: 'tspUs',
  UcumUnit.tspM: 'tspM',
  UcumUnit.tspImp: 'tspImp',
};

const _$MetricUnitEnumMap = {MetricUnit.ml: 'ml', MetricUnit.g: 'g'};

const _$AllergenCodeEnumMap = {
  AllergenCode.gluten: 'gluten',
  AllergenCode.crustacean: 'crustacean',
  AllergenCode.egg: 'egg',
  AllergenCode.fish: 'fish',
  AllergenCode.peanut: 'peanut',
  AllergenCode.soy: 'soy',
  AllergenCode.milk: 'milk',
  AllergenCode.nut: 'nut',
  AllergenCode.celery: 'celery',
  AllergenCode.mustard: 'mustard',
  AllergenCode.sesame: 'sesame',
  AllergenCode.sulphite: 'sulphite',
  AllergenCode.lupin: 'lupin',
  AllergenCode.mollusc: 'mollusc',
  AllergenCode.shellfish: 'shellfish',
  AllergenCode.treenut: 'treenut',
  AllergenCode.wheat: 'wheat',
};
