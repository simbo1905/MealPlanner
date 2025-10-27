// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_models.freezed_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SearchOptions _$SearchOptionsFromJson(Map<String, dynamic> json) {
  return _SearchOptions.fromJson(json);
}

/// @nodoc
mixin _$SearchOptions {
  String? get query => throw _privateConstructorUsedError;
  int? get maxTime => throw _privateConstructorUsedError;
  List<String>? get ingredients => throw _privateConstructorUsedError;
  List<String>? get excludeAllergens => throw _privateConstructorUsedError;
  int? get limit => throw _privateConstructorUsedError;
  SearchSortBy? get sortBy => throw _privateConstructorUsedError;

  /// Serializes this SearchOptions to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchOptionsCopyWith<SearchOptions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchOptionsCopyWith<$Res> {
  factory $SearchOptionsCopyWith(
    SearchOptions value,
    $Res Function(SearchOptions) then,
  ) = _$SearchOptionsCopyWithImpl<$Res, SearchOptions>;
  @useResult
  $Res call({
    String? query,
    int? maxTime,
    List<String>? ingredients,
    List<String>? excludeAllergens,
    int? limit,
    SearchSortBy? sortBy,
  });
}

/// @nodoc
class _$SearchOptionsCopyWithImpl<$Res, $Val extends SearchOptions>
    implements $SearchOptionsCopyWith<$Res> {
  _$SearchOptionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = freezed,
    Object? maxTime = freezed,
    Object? ingredients = freezed,
    Object? excludeAllergens = freezed,
    Object? limit = freezed,
    Object? sortBy = freezed,
  }) {
    return _then(
      _value.copyWith(
            query: freezed == query
                ? _value.query
                : query // ignore: cast_nullable_to_non_nullable
                      as String?,
            maxTime: freezed == maxTime
                ? _value.maxTime
                : maxTime // ignore: cast_nullable_to_non_nullable
                      as int?,
            ingredients: freezed == ingredients
                ? _value.ingredients
                : ingredients // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            excludeAllergens: freezed == excludeAllergens
                ? _value.excludeAllergens
                : excludeAllergens // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            limit: freezed == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int?,
            sortBy: freezed == sortBy
                ? _value.sortBy
                : sortBy // ignore: cast_nullable_to_non_nullable
                      as SearchSortBy?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchOptionsImplCopyWith<$Res>
    implements $SearchOptionsCopyWith<$Res> {
  factory _$$SearchOptionsImplCopyWith(
    _$SearchOptionsImpl value,
    $Res Function(_$SearchOptionsImpl) then,
  ) = __$$SearchOptionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? query,
    int? maxTime,
    List<String>? ingredients,
    List<String>? excludeAllergens,
    int? limit,
    SearchSortBy? sortBy,
  });
}

/// @nodoc
class __$$SearchOptionsImplCopyWithImpl<$Res>
    extends _$SearchOptionsCopyWithImpl<$Res, _$SearchOptionsImpl>
    implements _$$SearchOptionsImplCopyWith<$Res> {
  __$$SearchOptionsImplCopyWithImpl(
    _$SearchOptionsImpl _value,
    $Res Function(_$SearchOptionsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchOptions
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = freezed,
    Object? maxTime = freezed,
    Object? ingredients = freezed,
    Object? excludeAllergens = freezed,
    Object? limit = freezed,
    Object? sortBy = freezed,
  }) {
    return _then(
      _$SearchOptionsImpl(
        query: freezed == query
            ? _value.query
            : query // ignore: cast_nullable_to_non_nullable
                  as String?,
        maxTime: freezed == maxTime
            ? _value.maxTime
            : maxTime // ignore: cast_nullable_to_non_nullable
                  as int?,
        ingredients: freezed == ingredients
            ? _value._ingredients
            : ingredients // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        excludeAllergens: freezed == excludeAllergens
            ? _value._excludeAllergens
            : excludeAllergens // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        limit: freezed == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int?,
        sortBy: freezed == sortBy
            ? _value.sortBy
            : sortBy // ignore: cast_nullable_to_non_nullable
                  as SearchSortBy?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchOptionsImpl implements _SearchOptions {
  const _$SearchOptionsImpl({
    this.query,
    this.maxTime,
    final List<String>? ingredients,
    final List<String>? excludeAllergens,
    this.limit,
    this.sortBy,
  }) : _ingredients = ingredients,
       _excludeAllergens = excludeAllergens;

  factory _$SearchOptionsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchOptionsImplFromJson(json);

  @override
  final String? query;
  @override
  final int? maxTime;
  final List<String>? _ingredients;
  @override
  List<String>? get ingredients {
    final value = _ingredients;
    if (value == null) return null;
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _excludeAllergens;
  @override
  List<String>? get excludeAllergens {
    final value = _excludeAllergens;
    if (value == null) return null;
    if (_excludeAllergens is EqualUnmodifiableListView)
      return _excludeAllergens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? limit;
  @override
  final SearchSortBy? sortBy;

  @override
  String toString() {
    return 'SearchOptions(query: $query, maxTime: $maxTime, ingredients: $ingredients, excludeAllergens: $excludeAllergens, limit: $limit, sortBy: $sortBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchOptionsImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.maxTime, maxTime) || other.maxTime == maxTime) &&
            const DeepCollectionEquality().equals(
              other._ingredients,
              _ingredients,
            ) &&
            const DeepCollectionEquality().equals(
              other._excludeAllergens,
              _excludeAllergens,
            ) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    query,
    maxTime,
    const DeepCollectionEquality().hash(_ingredients),
    const DeepCollectionEquality().hash(_excludeAllergens),
    limit,
    sortBy,
  );

  /// Create a copy of SearchOptions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchOptionsImplCopyWith<_$SearchOptionsImpl> get copyWith =>
      __$$SearchOptionsImplCopyWithImpl<_$SearchOptionsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchOptionsImplToJson(this);
  }
}

abstract class _SearchOptions implements SearchOptions {
  const factory _SearchOptions({
    final String? query,
    final int? maxTime,
    final List<String>? ingredients,
    final List<String>? excludeAllergens,
    final int? limit,
    final SearchSortBy? sortBy,
  }) = _$SearchOptionsImpl;

  factory _SearchOptions.fromJson(Map<String, dynamic> json) =
      _$SearchOptionsImpl.fromJson;

  @override
  String? get query;
  @override
  int? get maxTime;
  @override
  List<String>? get ingredients;
  @override
  List<String>? get excludeAllergens;
  @override
  int? get limit;
  @override
  SearchSortBy? get sortBy;

  /// Create a copy of SearchOptions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchOptionsImplCopyWith<_$SearchOptionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SearchResult _$SearchResultFromJson(Map<String, dynamic> json) {
  return _SearchResult.fromJson(json);
}

/// @nodoc
mixin _$SearchResult {
  Recipe get recipe => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  List<String> get matchedFields => throw _privateConstructorUsedError;

  /// Serializes this SearchResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchResultCopyWith<SearchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchResultCopyWith<$Res> {
  factory $SearchResultCopyWith(
    SearchResult value,
    $Res Function(SearchResult) then,
  ) = _$SearchResultCopyWithImpl<$Res, SearchResult>;
  @useResult
  $Res call({Recipe recipe, double score, List<String> matchedFields});

  $RecipeCopyWith<$Res> get recipe;
}

/// @nodoc
class _$SearchResultCopyWithImpl<$Res, $Val extends SearchResult>
    implements $SearchResultCopyWith<$Res> {
  _$SearchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipe = null,
    Object? score = null,
    Object? matchedFields = null,
  }) {
    return _then(
      _value.copyWith(
            recipe: null == recipe
                ? _value.recipe
                : recipe // ignore: cast_nullable_to_non_nullable
                      as Recipe,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double,
            matchedFields: null == matchedFields
                ? _value.matchedFields
                : matchedFields // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of SearchResult
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
abstract class _$$SearchResultImplCopyWith<$Res>
    implements $SearchResultCopyWith<$Res> {
  factory _$$SearchResultImplCopyWith(
    _$SearchResultImpl value,
    $Res Function(_$SearchResultImpl) then,
  ) = __$$SearchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Recipe recipe, double score, List<String> matchedFields});

  @override
  $RecipeCopyWith<$Res> get recipe;
}

/// @nodoc
class __$$SearchResultImplCopyWithImpl<$Res>
    extends _$SearchResultCopyWithImpl<$Res, _$SearchResultImpl>
    implements _$$SearchResultImplCopyWith<$Res> {
  __$$SearchResultImplCopyWithImpl(
    _$SearchResultImpl _value,
    $Res Function(_$SearchResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipe = null,
    Object? score = null,
    Object? matchedFields = null,
  }) {
    return _then(
      _$SearchResultImpl(
        recipe: null == recipe
            ? _value.recipe
            : recipe // ignore: cast_nullable_to_non_nullable
                  as Recipe,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double,
        matchedFields: null == matchedFields
            ? _value._matchedFields
            : matchedFields // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchResultImpl implements _SearchResult {
  const _$SearchResultImpl({
    required this.recipe,
    required this.score,
    required final List<String> matchedFields,
  }) : _matchedFields = matchedFields;

  factory _$SearchResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchResultImplFromJson(json);

  @override
  final Recipe recipe;
  @override
  final double score;
  final List<String> _matchedFields;
  @override
  List<String> get matchedFields {
    if (_matchedFields is EqualUnmodifiableListView) return _matchedFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_matchedFields);
  }

  @override
  String toString() {
    return 'SearchResult(recipe: $recipe, score: $score, matchedFields: $matchedFields)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchResultImpl &&
            (identical(other.recipe, recipe) || other.recipe == recipe) &&
            (identical(other.score, score) || other.score == score) &&
            const DeepCollectionEquality().equals(
              other._matchedFields,
              _matchedFields,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    recipe,
    score,
    const DeepCollectionEquality().hash(_matchedFields),
  );

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchResultImplCopyWith<_$SearchResultImpl> get copyWith =>
      __$$SearchResultImplCopyWithImpl<_$SearchResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchResultImplToJson(this);
  }
}

abstract class _SearchResult implements SearchResult {
  const factory _SearchResult({
    required final Recipe recipe,
    required final double score,
    required final List<String> matchedFields,
  }) = _$SearchResultImpl;

  factory _SearchResult.fromJson(Map<String, dynamic> json) =
      _$SearchResultImpl.fromJson;

  @override
  Recipe get recipe;
  @override
  double get score;
  @override
  List<String> get matchedFields;

  /// Create a copy of SearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchResultImplCopyWith<_$SearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
