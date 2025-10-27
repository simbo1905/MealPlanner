// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_preferences.freezed_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) {
  return _UserPreferences.fromJson(json);
}

/// @nodoc
mixin _$UserPreferences {
  String get userId => throw _privateConstructorUsedError;
  int get portions => throw _privateConstructorUsedError;
  int? get maxCookTime => throw _privateConstructorUsedError;
  List<String> get dietaryRestrictions => throw _privateConstructorUsedError;
  List<String> get dislikedIngredients => throw _privateConstructorUsedError;
  List<String> get preferredSupermarkets => throw _privateConstructorUsedError;

  /// Serializes this UserPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPreferencesCopyWith<UserPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesCopyWith<$Res> {
  factory $UserPreferencesCopyWith(
    UserPreferences value,
    $Res Function(UserPreferences) then,
  ) = _$UserPreferencesCopyWithImpl<$Res, UserPreferences>;
  @useResult
  $Res call({
    String userId,
    int portions,
    int? maxCookTime,
    List<String> dietaryRestrictions,
    List<String> dislikedIngredients,
    List<String> preferredSupermarkets,
  });
}

/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res, $Val extends UserPreferences>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? portions = null,
    Object? maxCookTime = freezed,
    Object? dietaryRestrictions = null,
    Object? dislikedIngredients = null,
    Object? preferredSupermarkets = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            portions: null == portions
                ? _value.portions
                : portions // ignore: cast_nullable_to_non_nullable
                      as int,
            maxCookTime: freezed == maxCookTime
                ? _value.maxCookTime
                : maxCookTime // ignore: cast_nullable_to_non_nullable
                      as int?,
            dietaryRestrictions: null == dietaryRestrictions
                ? _value.dietaryRestrictions
                : dietaryRestrictions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            dislikedIngredients: null == dislikedIngredients
                ? _value.dislikedIngredients
                : dislikedIngredients // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            preferredSupermarkets: null == preferredSupermarkets
                ? _value.preferredSupermarkets
                : preferredSupermarkets // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserPreferencesImplCopyWith<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  factory _$$UserPreferencesImplCopyWith(
    _$UserPreferencesImpl value,
    $Res Function(_$UserPreferencesImpl) then,
  ) = __$$UserPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    int portions,
    int? maxCookTime,
    List<String> dietaryRestrictions,
    List<String> dislikedIngredients,
    List<String> preferredSupermarkets,
  });
}

/// @nodoc
class __$$UserPreferencesImplCopyWithImpl<$Res>
    extends _$UserPreferencesCopyWithImpl<$Res, _$UserPreferencesImpl>
    implements _$$UserPreferencesImplCopyWith<$Res> {
  __$$UserPreferencesImplCopyWithImpl(
    _$UserPreferencesImpl _value,
    $Res Function(_$UserPreferencesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? portions = null,
    Object? maxCookTime = freezed,
    Object? dietaryRestrictions = null,
    Object? dislikedIngredients = null,
    Object? preferredSupermarkets = null,
  }) {
    return _then(
      _$UserPreferencesImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        portions: null == portions
            ? _value.portions
            : portions // ignore: cast_nullable_to_non_nullable
                  as int,
        maxCookTime: freezed == maxCookTime
            ? _value.maxCookTime
            : maxCookTime // ignore: cast_nullable_to_non_nullable
                  as int?,
        dietaryRestrictions: null == dietaryRestrictions
            ? _value._dietaryRestrictions
            : dietaryRestrictions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        dislikedIngredients: null == dislikedIngredients
            ? _value._dislikedIngredients
            : dislikedIngredients // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        preferredSupermarkets: null == preferredSupermarkets
            ? _value._preferredSupermarkets
            : preferredSupermarkets // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferencesImpl implements _UserPreferences {
  const _$UserPreferencesImpl({
    required this.userId,
    this.portions = 4,
    this.maxCookTime,
    final List<String> dietaryRestrictions = const [],
    final List<String> dislikedIngredients = const [],
    final List<String> preferredSupermarkets = const [],
  }) : _dietaryRestrictions = dietaryRestrictions,
       _dislikedIngredients = dislikedIngredients,
       _preferredSupermarkets = preferredSupermarkets;

  factory _$UserPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesImplFromJson(json);

  @override
  final String userId;
  @override
  @JsonKey()
  final int portions;
  @override
  final int? maxCookTime;
  final List<String> _dietaryRestrictions;
  @override
  @JsonKey()
  List<String> get dietaryRestrictions {
    if (_dietaryRestrictions is EqualUnmodifiableListView)
      return _dietaryRestrictions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dietaryRestrictions);
  }

  final List<String> _dislikedIngredients;
  @override
  @JsonKey()
  List<String> get dislikedIngredients {
    if (_dislikedIngredients is EqualUnmodifiableListView)
      return _dislikedIngredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dislikedIngredients);
  }

  final List<String> _preferredSupermarkets;
  @override
  @JsonKey()
  List<String> get preferredSupermarkets {
    if (_preferredSupermarkets is EqualUnmodifiableListView)
      return _preferredSupermarkets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredSupermarkets);
  }

  @override
  String toString() {
    return 'UserPreferences(userId: $userId, portions: $portions, maxCookTime: $maxCookTime, dietaryRestrictions: $dietaryRestrictions, dislikedIngredients: $dislikedIngredients, preferredSupermarkets: $preferredSupermarkets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.portions, portions) ||
                other.portions == portions) &&
            (identical(other.maxCookTime, maxCookTime) ||
                other.maxCookTime == maxCookTime) &&
            const DeepCollectionEquality().equals(
              other._dietaryRestrictions,
              _dietaryRestrictions,
            ) &&
            const DeepCollectionEquality().equals(
              other._dislikedIngredients,
              _dislikedIngredients,
            ) &&
            const DeepCollectionEquality().equals(
              other._preferredSupermarkets,
              _preferredSupermarkets,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    portions,
    maxCookTime,
    const DeepCollectionEquality().hash(_dietaryRestrictions),
    const DeepCollectionEquality().hash(_dislikedIngredients),
    const DeepCollectionEquality().hash(_preferredSupermarkets),
  );

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      __$$UserPreferencesImplCopyWithImpl<_$UserPreferencesImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesImplToJson(this);
  }
}

abstract class _UserPreferences implements UserPreferences {
  const factory _UserPreferences({
    required final String userId,
    final int portions,
    final int? maxCookTime,
    final List<String> dietaryRestrictions,
    final List<String> dislikedIngredients,
    final List<String> preferredSupermarkets,
  }) = _$UserPreferencesImpl;

  factory _UserPreferences.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesImpl.fromJson;

  @override
  String get userId;
  @override
  int get portions;
  @override
  int? get maxCookTime;
  @override
  List<String> get dietaryRestrictions;
  @override
  List<String> get dislikedIngredients;
  @override
  List<String> get preferredSupermarkets;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
