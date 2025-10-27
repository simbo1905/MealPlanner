import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_preferences.freezed_model.freezed.dart';
part 'user_preferences.freezed_model.g.dart';

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    required String userId,
    @Default(4) int portions,
    int? maxCookTime,
    @Default([]) List<String> dietaryRestrictions,
    @Default([]) List<String> dislikedIngredients,
    @Default([]) List<String> preferredSupermarkets,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}
