// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_recipe.freezed_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WorkspaceRecipe _$WorkspaceRecipeFromJson(Map<String, dynamic> json) {
  return _WorkspaceRecipe.fromJson(json);
}

/// @nodoc
mixin _$WorkspaceRecipe {
  String get id => throw _privateConstructorUsedError;
  Recipe get recipe => throw _privateConstructorUsedError;
  WorkspaceRecipeStatus get status => throw _privateConstructorUsedError;
  List<String> get missingFields => throw _privateConstructorUsedError;
  List<String> get photoIds => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this WorkspaceRecipe to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkspaceRecipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkspaceRecipeCopyWith<WorkspaceRecipe> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkspaceRecipeCopyWith<$Res> {
  factory $WorkspaceRecipeCopyWith(
    WorkspaceRecipe value,
    $Res Function(WorkspaceRecipe) then,
  ) = _$WorkspaceRecipeCopyWithImpl<$Res, WorkspaceRecipe>;
  @useResult
  $Res call({
    String id,
    Recipe recipe,
    WorkspaceRecipeStatus status,
    List<String> missingFields,
    List<String> photoIds,
    DateTime createdAt,
    DateTime updatedAt,
  });

  $RecipeCopyWith<$Res> get recipe;
}

/// @nodoc
class _$WorkspaceRecipeCopyWithImpl<$Res, $Val extends WorkspaceRecipe>
    implements $WorkspaceRecipeCopyWith<$Res> {
  _$WorkspaceRecipeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkspaceRecipe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? recipe = null,
    Object? status = null,
    Object? missingFields = null,
    Object? photoIds = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            recipe: null == recipe
                ? _value.recipe
                : recipe // ignore: cast_nullable_to_non_nullable
                      as Recipe,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as WorkspaceRecipeStatus,
            missingFields: null == missingFields
                ? _value.missingFields
                : missingFields // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            photoIds: null == photoIds
                ? _value.photoIds
                : photoIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of WorkspaceRecipe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecipeCopyWith<$Res> get recipe {
    return $RecipeCopyWith<$Res>(_value.recipe, (value) {
      return _then(_value.copyWith(recipe: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WorkspaceRecipeImplCopyWith<$Res>
    implements $WorkspaceRecipeCopyWith<$Res> {
  factory _$$WorkspaceRecipeImplCopyWith(
    _$WorkspaceRecipeImpl value,
    $Res Function(_$WorkspaceRecipeImpl) then,
  ) = __$$WorkspaceRecipeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    Recipe recipe,
    WorkspaceRecipeStatus status,
    List<String> missingFields,
    List<String> photoIds,
    DateTime createdAt,
    DateTime updatedAt,
  });

  @override
  $RecipeCopyWith<$Res> get recipe;
}

/// @nodoc
class __$$WorkspaceRecipeImplCopyWithImpl<$Res>
    extends _$WorkspaceRecipeCopyWithImpl<$Res, _$WorkspaceRecipeImpl>
    implements _$$WorkspaceRecipeImplCopyWith<$Res> {
  __$$WorkspaceRecipeImplCopyWithImpl(
    _$WorkspaceRecipeImpl _value,
    $Res Function(_$WorkspaceRecipeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkspaceRecipe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? recipe = null,
    Object? status = null,
    Object? missingFields = null,
    Object? photoIds = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$WorkspaceRecipeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        recipe: null == recipe
            ? _value.recipe
            : recipe // ignore: cast_nullable_to_non_nullable
                  as Recipe,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as WorkspaceRecipeStatus,
        missingFields: null == missingFields
            ? _value._missingFields
            : missingFields // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        photoIds: null == photoIds
            ? _value._photoIds
            : photoIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkspaceRecipeImpl implements _WorkspaceRecipe {
  const _$WorkspaceRecipeImpl({
    required this.id,
    required this.recipe,
    required this.status,
    final List<String> missingFields = const [],
    final List<String> photoIds = const [],
    required this.createdAt,
    required this.updatedAt,
  }) : _missingFields = missingFields,
       _photoIds = photoIds;

  factory _$WorkspaceRecipeImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkspaceRecipeImplFromJson(json);

  @override
  final String id;
  @override
  final Recipe recipe;
  @override
  final WorkspaceRecipeStatus status;
  final List<String> _missingFields;
  @override
  @JsonKey()
  List<String> get missingFields {
    if (_missingFields is EqualUnmodifiableListView) return _missingFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_missingFields);
  }

  final List<String> _photoIds;
  @override
  @JsonKey()
  List<String> get photoIds {
    if (_photoIds is EqualUnmodifiableListView) return _photoIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoIds);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'WorkspaceRecipe(id: $id, recipe: $recipe, status: $status, missingFields: $missingFields, photoIds: $photoIds, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkspaceRecipeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.recipe, recipe) || other.recipe == recipe) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._missingFields,
              _missingFields,
            ) &&
            const DeepCollectionEquality().equals(other._photoIds, _photoIds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    recipe,
    status,
    const DeepCollectionEquality().hash(_missingFields),
    const DeepCollectionEquality().hash(_photoIds),
    createdAt,
    updatedAt,
  );

  /// Create a copy of WorkspaceRecipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkspaceRecipeImplCopyWith<_$WorkspaceRecipeImpl> get copyWith =>
      __$$WorkspaceRecipeImplCopyWithImpl<_$WorkspaceRecipeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkspaceRecipeImplToJson(this);
  }
}

abstract class _WorkspaceRecipe implements WorkspaceRecipe {
  const factory _WorkspaceRecipe({
    required final String id,
    required final Recipe recipe,
    required final WorkspaceRecipeStatus status,
    final List<String> missingFields,
    final List<String> photoIds,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$WorkspaceRecipeImpl;

  factory _WorkspaceRecipe.fromJson(Map<String, dynamic> json) =
      _$WorkspaceRecipeImpl.fromJson;

  @override
  String get id;
  @override
  Recipe get recipe;
  @override
  WorkspaceRecipeStatus get status;
  @override
  List<String> get missingFields;
  @override
  List<String> get photoIds;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of WorkspaceRecipe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkspaceRecipeImplCopyWith<_$WorkspaceRecipeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
