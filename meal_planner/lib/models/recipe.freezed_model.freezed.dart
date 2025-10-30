// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe.freezed_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Recipe _$RecipeFromJson(Map<String, dynamic> json) {
  return _Recipe.fromJson(json);
}

/// @nodoc
mixin _$Recipe {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  List<String> get preReqs => throw _privateConstructorUsedError;
  double get totalTime => throw _privateConstructorUsedError;
  List<Ingredient> get ingredients => throw _privateConstructorUsedError;
  List<String> get steps =>
      throw _privateConstructorUsedError; // New optional fields for v1 recipe search
  String? get titleLower => throw _privateConstructorUsedError;
  List<String>? get titleTokens => throw _privateConstructorUsedError;
  List<String>? get ingredientNamesNormalized =>
      throw _privateConstructorUsedError;
  String? get version => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Recipe to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeCopyWith<Recipe> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeCopyWith<$Res> {
  factory $RecipeCopyWith(Recipe value, $Res Function(Recipe) then) =
      _$RecipeCopyWithImpl<$Res, Recipe>;
  @useResult
  $Res call({
    String id,
    String title,
    String imageUrl,
    String description,
    String notes,
    List<String> preReqs,
    double totalTime,
    List<Ingredient> ingredients,
    List<String> steps,
    String? titleLower,
    List<String>? titleTokens,
    List<String>? ingredientNamesNormalized,
    String? version,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime? createdAt,
  });
}

/// @nodoc
class _$RecipeCopyWithImpl<$Res, $Val extends Recipe>
    implements $RecipeCopyWith<$Res> {
  _$RecipeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? description = null,
    Object? notes = null,
    Object? preReqs = null,
    Object? totalTime = null,
    Object? ingredients = null,
    Object? steps = null,
    Object? titleLower = freezed,
    Object? titleTokens = freezed,
    Object? ingredientNamesNormalized = freezed,
    Object? version = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
            preReqs: null == preReqs
                ? _value.preReqs
                : preReqs // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            totalTime: null == totalTime
                ? _value.totalTime
                : totalTime // ignore: cast_nullable_to_non_nullable
                      as double,
            ingredients: null == ingredients
                ? _value.ingredients
                : ingredients // ignore: cast_nullable_to_non_nullable
                      as List<Ingredient>,
            steps: null == steps
                ? _value.steps
                : steps // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            titleLower: freezed == titleLower
                ? _value.titleLower
                : titleLower // ignore: cast_nullable_to_non_nullable
                      as String?,
            titleTokens: freezed == titleTokens
                ? _value.titleTokens
                : titleTokens // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            ingredientNamesNormalized: freezed == ingredientNamesNormalized
                ? _value.ingredientNamesNormalized
                : ingredientNamesNormalized // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            version: freezed == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecipeImplCopyWith<$Res> implements $RecipeCopyWith<$Res> {
  factory _$$RecipeImplCopyWith(
    _$RecipeImpl value,
    $Res Function(_$RecipeImpl) then,
  ) = __$$RecipeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String imageUrl,
    String description,
    String notes,
    List<String> preReqs,
    double totalTime,
    List<Ingredient> ingredients,
    List<String> steps,
    String? titleLower,
    List<String>? titleTokens,
    List<String>? ingredientNamesNormalized,
    String? version,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$RecipeImplCopyWithImpl<$Res>
    extends _$RecipeCopyWithImpl<$Res, _$RecipeImpl>
    implements _$$RecipeImplCopyWith<$Res> {
  __$$RecipeImplCopyWithImpl(
    _$RecipeImpl _value,
    $Res Function(_$RecipeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? description = null,
    Object? notes = null,
    Object? preReqs = null,
    Object? totalTime = null,
    Object? ingredients = null,
    Object? steps = null,
    Object? titleLower = freezed,
    Object? titleTokens = freezed,
    Object? ingredientNamesNormalized = freezed,
    Object? version = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$RecipeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
        preReqs: null == preReqs
            ? _value._preReqs
            : preReqs // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        totalTime: null == totalTime
            ? _value.totalTime
            : totalTime // ignore: cast_nullable_to_non_nullable
                  as double,
        ingredients: null == ingredients
            ? _value._ingredients
            : ingredients // ignore: cast_nullable_to_non_nullable
                  as List<Ingredient>,
        steps: null == steps
            ? _value._steps
            : steps // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        titleLower: freezed == titleLower
            ? _value.titleLower
            : titleLower // ignore: cast_nullable_to_non_nullable
                  as String?,
        titleTokens: freezed == titleTokens
            ? _value._titleTokens
            : titleTokens // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        ingredientNamesNormalized: freezed == ingredientNamesNormalized
            ? _value._ingredientNamesNormalized
            : ingredientNamesNormalized // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        version: freezed == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeImpl implements _Recipe {
  const _$RecipeImpl({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.notes,
    required final List<String> preReqs,
    required this.totalTime,
    required final List<Ingredient> ingredients,
    required final List<String> steps,
    this.titleLower,
    final List<String>? titleTokens,
    final List<String>? ingredientNamesNormalized,
    this.version,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    this.createdAt,
  }) : _preReqs = preReqs,
       _ingredients = ingredients,
       _steps = steps,
       _titleTokens = titleTokens,
       _ingredientNamesNormalized = ingredientNamesNormalized;

  factory _$RecipeImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String imageUrl;
  @override
  final String description;
  @override
  final String notes;
  final List<String> _preReqs;
  @override
  List<String> get preReqs {
    if (_preReqs is EqualUnmodifiableListView) return _preReqs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preReqs);
  }

  @override
  final double totalTime;
  final List<Ingredient> _ingredients;
  @override
  List<Ingredient> get ingredients {
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredients);
  }

  final List<String> _steps;
  @override
  List<String> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  // New optional fields for v1 recipe search
  @override
  final String? titleLower;
  final List<String>? _titleTokens;
  @override
  List<String>? get titleTokens {
    final value = _titleTokens;
    if (value == null) return null;
    if (_titleTokens is EqualUnmodifiableListView) return _titleTokens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _ingredientNamesNormalized;
  @override
  List<String>? get ingredientNamesNormalized {
    final value = _ingredientNamesNormalized;
    if (value == null) return null;
    if (_ingredientNamesNormalized is EqualUnmodifiableListView)
      return _ingredientNamesNormalized;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? version;
  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Recipe(id: $id, title: $title, imageUrl: $imageUrl, description: $description, notes: $notes, preReqs: $preReqs, totalTime: $totalTime, ingredients: $ingredients, steps: $steps, titleLower: $titleLower, titleTokens: $titleTokens, ingredientNamesNormalized: $ingredientNamesNormalized, version: $version, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._preReqs, _preReqs) &&
            (identical(other.totalTime, totalTime) ||
                other.totalTime == totalTime) &&
            const DeepCollectionEquality().equals(
              other._ingredients,
              _ingredients,
            ) &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            (identical(other.titleLower, titleLower) ||
                other.titleLower == titleLower) &&
            const DeepCollectionEquality().equals(
              other._titleTokens,
              _titleTokens,
            ) &&
            const DeepCollectionEquality().equals(
              other._ingredientNamesNormalized,
              _ingredientNamesNormalized,
            ) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    imageUrl,
    description,
    notes,
    const DeepCollectionEquality().hash(_preReqs),
    totalTime,
    const DeepCollectionEquality().hash(_ingredients),
    const DeepCollectionEquality().hash(_steps),
    titleLower,
    const DeepCollectionEquality().hash(_titleTokens),
    const DeepCollectionEquality().hash(_ingredientNamesNormalized),
    version,
    createdAt,
  );

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      __$$RecipeImplCopyWithImpl<_$RecipeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecipeImplToJson(this);
  }
}

abstract class _Recipe implements Recipe {
  const factory _Recipe({
    required final String id,
    required final String title,
    required final String imageUrl,
    required final String description,
    required final String notes,
    required final List<String> preReqs,
    required final double totalTime,
    required final List<Ingredient> ingredients,
    required final List<String> steps,
    final String? titleLower,
    final List<String>? titleTokens,
    final List<String>? ingredientNamesNormalized,
    final String? version,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    final DateTime? createdAt,
  }) = _$RecipeImpl;

  factory _Recipe.fromJson(Map<String, dynamic> json) = _$RecipeImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get imageUrl;
  @override
  String get description;
  @override
  String get notes;
  @override
  List<String> get preReqs;
  @override
  double get totalTime;
  @override
  List<Ingredient> get ingredients;
  @override
  List<String> get steps; // New optional fields for v1 recipe search
  @override
  String? get titleLower;
  @override
  List<String>? get titleTokens;
  @override
  List<String>? get ingredientNamesNormalized;
  @override
  String? get version;
  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime? get createdAt;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
