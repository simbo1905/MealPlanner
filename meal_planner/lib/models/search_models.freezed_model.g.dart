// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_models.freezed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchOptionsImpl _$$SearchOptionsImplFromJson(Map<String, dynamic> json) =>
    _$SearchOptionsImpl(
      query: json['query'] as String?,
      maxTime: (json['maxTime'] as num?)?.toInt(),
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      excludeAllergens: (json['excludeAllergens'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      limit: (json['limit'] as num?)?.toInt(),
      sortBy: $enumDecodeNullable(_$SearchSortByEnumMap, json['sortBy']),
    );

Map<String, dynamic> _$$SearchOptionsImplToJson(_$SearchOptionsImpl instance) =>
    <String, dynamic>{
      'query': instance.query,
      'maxTime': instance.maxTime,
      'ingredients': instance.ingredients,
      'excludeAllergens': instance.excludeAllergens,
      'limit': instance.limit,
      'sortBy': _$SearchSortByEnumMap[instance.sortBy],
    };

const _$SearchSortByEnumMap = {
  SearchSortBy.title: 'title',
  SearchSortBy.totalTime: 'totalTime',
  SearchSortBy.relevance: 'relevance',
};

_$SearchResultImpl _$$SearchResultImplFromJson(Map<String, dynamic> json) =>
    _$SearchResultImpl(
      recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
      score: (json['score'] as num).toDouble(),
      matchedFields: (json['matchedFields'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$SearchResultImplToJson(_$SearchResultImpl instance) =>
    <String, dynamic>{
      'recipe': instance.recipe,
      'score': instance.score,
      'matchedFields': instance.matchedFields,
    };
