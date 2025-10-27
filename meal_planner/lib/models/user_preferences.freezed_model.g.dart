// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.freezed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserPreferencesImpl _$$UserPreferencesImplFromJson(
  Map<String, dynamic> json,
) => _$UserPreferencesImpl(
  userId: json['userId'] as String,
  portions: (json['portions'] as num?)?.toInt() ?? 4,
  maxCookTime: (json['maxCookTime'] as num?)?.toInt(),
  dietaryRestrictions:
      (json['dietaryRestrictions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  dislikedIngredients:
      (json['dislikedIngredients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  preferredSupermarkets:
      (json['preferredSupermarkets'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$UserPreferencesImplToJson(
  _$UserPreferencesImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'portions': instance.portions,
  'maxCookTime': instance.maxCookTime,
  'dietaryRestrictions': instance.dietaryRestrictions,
  'dislikedIngredients': instance.dislikedIngredients,
  'preferredSupermarkets': instance.preferredSupermarkets,
};
