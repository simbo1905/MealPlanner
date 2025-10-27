// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_recipe.freezed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkspaceRecipeImpl _$$WorkspaceRecipeImplFromJson(
  Map<String, dynamic> json,
) => _$WorkspaceRecipeImpl(
  id: json['id'] as String,
  recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
  status: $enumDecode(_$WorkspaceRecipeStatusEnumMap, json['status']),
  missingFields:
      (json['missingFields'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  photoIds:
      (json['photoIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$WorkspaceRecipeImplToJson(
  _$WorkspaceRecipeImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'recipe': instance.recipe,
  'status': _$WorkspaceRecipeStatusEnumMap[instance.status]!,
  'missingFields': instance.missingFields,
  'photoIds': instance.photoIds,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$WorkspaceRecipeStatusEnumMap = {
  WorkspaceRecipeStatus.draft: 'draft',
  WorkspaceRecipeStatus.incomplete: 'incomplete',
  WorkspaceRecipeStatus.ready: 'ready',
};
