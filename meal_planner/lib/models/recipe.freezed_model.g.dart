// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.freezed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecipeImpl _$$RecipeImplFromJson(Map<String, dynamic> json) => _$RecipeImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  imageUrl: json['imageUrl'] as String,
  description: json['description'] as String,
  notes: json['notes'] as String,
  preReqs: (json['preReqs'] as List<dynamic>).map((e) => e as String).toList(),
  totalTime: (json['totalTime'] as num).toDouble(),
  ingredients: (json['ingredients'] as List<dynamic>)
      .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
      .toList(),
  steps: (json['steps'] as List<dynamic>).map((e) => e as String).toList(),
  titleLower: json['titleLower'] as String?,
  titleTokens: (json['titleTokens'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  ingredientNamesNormalized:
      (json['ingredientNamesNormalized'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  version: json['version'] as String?,
  createdAt: _timestampFromJson(json['createdAt']),
);

Map<String, dynamic> _$$RecipeImplToJson(_$RecipeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'notes': instance.notes,
      'preReqs': instance.preReqs,
      'totalTime': instance.totalTime,
      'ingredients': instance.ingredients,
      'steps': instance.steps,
      'titleLower': instance.titleLower,
      'titleTokens': instance.titleTokens,
      'ingredientNamesNormalized': instance.ingredientNamesNormalized,
      'version': instance.version,
      'createdAt': _timestampToJson(instance.createdAt),
    };
