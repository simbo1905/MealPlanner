// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingredient.freezed_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Ingredient _$IngredientFromJson(Map<String, dynamic> json) {
  return _Ingredient.fromJson(json);
}

/// @nodoc
mixin _$Ingredient {
  String get name => throw _privateConstructorUsedError;
  UcumUnit get ucumUnit => throw _privateConstructorUsedError;
  double get ucumAmount => throw _privateConstructorUsedError;
  MetricUnit get metricUnit => throw _privateConstructorUsedError;
  double get metricAmount => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  AllergenCode? get allergenCode => throw _privateConstructorUsedError;

  /// Serializes this Ingredient to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Ingredient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IngredientCopyWith<Ingredient> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IngredientCopyWith<$Res> {
  factory $IngredientCopyWith(
    Ingredient value,
    $Res Function(Ingredient) then,
  ) = _$IngredientCopyWithImpl<$Res, Ingredient>;
  @useResult
  $Res call({
    String name,
    UcumUnit ucumUnit,
    double ucumAmount,
    MetricUnit metricUnit,
    double metricAmount,
    String notes,
    AllergenCode? allergenCode,
  });
}

/// @nodoc
class _$IngredientCopyWithImpl<$Res, $Val extends Ingredient>
    implements $IngredientCopyWith<$Res> {
  _$IngredientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Ingredient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? ucumUnit = null,
    Object? ucumAmount = null,
    Object? metricUnit = null,
    Object? metricAmount = null,
    Object? notes = null,
    Object? allergenCode = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            ucumUnit: null == ucumUnit
                ? _value.ucumUnit
                : ucumUnit // ignore: cast_nullable_to_non_nullable
                      as UcumUnit,
            ucumAmount: null == ucumAmount
                ? _value.ucumAmount
                : ucumAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            metricUnit: null == metricUnit
                ? _value.metricUnit
                : metricUnit // ignore: cast_nullable_to_non_nullable
                      as MetricUnit,
            metricAmount: null == metricAmount
                ? _value.metricAmount
                : metricAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
            allergenCode: freezed == allergenCode
                ? _value.allergenCode
                : allergenCode // ignore: cast_nullable_to_non_nullable
                      as AllergenCode?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IngredientImplCopyWith<$Res>
    implements $IngredientCopyWith<$Res> {
  factory _$$IngredientImplCopyWith(
    _$IngredientImpl value,
    $Res Function(_$IngredientImpl) then,
  ) = __$$IngredientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    UcumUnit ucumUnit,
    double ucumAmount,
    MetricUnit metricUnit,
    double metricAmount,
    String notes,
    AllergenCode? allergenCode,
  });
}

/// @nodoc
class __$$IngredientImplCopyWithImpl<$Res>
    extends _$IngredientCopyWithImpl<$Res, _$IngredientImpl>
    implements _$$IngredientImplCopyWith<$Res> {
  __$$IngredientImplCopyWithImpl(
    _$IngredientImpl _value,
    $Res Function(_$IngredientImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Ingredient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? ucumUnit = null,
    Object? ucumAmount = null,
    Object? metricUnit = null,
    Object? metricAmount = null,
    Object? notes = null,
    Object? allergenCode = freezed,
  }) {
    return _then(
      _$IngredientImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        ucumUnit: null == ucumUnit
            ? _value.ucumUnit
            : ucumUnit // ignore: cast_nullable_to_non_nullable
                  as UcumUnit,
        ucumAmount: null == ucumAmount
            ? _value.ucumAmount
            : ucumAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        metricUnit: null == metricUnit
            ? _value.metricUnit
            : metricUnit // ignore: cast_nullable_to_non_nullable
                  as MetricUnit,
        metricAmount: null == metricAmount
            ? _value.metricAmount
            : metricAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
        allergenCode: freezed == allergenCode
            ? _value.allergenCode
            : allergenCode // ignore: cast_nullable_to_non_nullable
                  as AllergenCode?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IngredientImpl implements _Ingredient {
  const _$IngredientImpl({
    required this.name,
    required this.ucumUnit,
    required this.ucumAmount,
    required this.metricUnit,
    required this.metricAmount,
    required this.notes,
    this.allergenCode,
  });

  factory _$IngredientImpl.fromJson(Map<String, dynamic> json) =>
      _$$IngredientImplFromJson(json);

  @override
  final String name;
  @override
  final UcumUnit ucumUnit;
  @override
  final double ucumAmount;
  @override
  final MetricUnit metricUnit;
  @override
  final double metricAmount;
  @override
  final String notes;
  @override
  final AllergenCode? allergenCode;

  @override
  String toString() {
    return 'Ingredient(name: $name, ucumUnit: $ucumUnit, ucumAmount: $ucumAmount, metricUnit: $metricUnit, metricAmount: $metricAmount, notes: $notes, allergenCode: $allergenCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IngredientImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.ucumUnit, ucumUnit) ||
                other.ucumUnit == ucumUnit) &&
            (identical(other.ucumAmount, ucumAmount) ||
                other.ucumAmount == ucumAmount) &&
            (identical(other.metricUnit, metricUnit) ||
                other.metricUnit == metricUnit) &&
            (identical(other.metricAmount, metricAmount) ||
                other.metricAmount == metricAmount) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.allergenCode, allergenCode) ||
                other.allergenCode == allergenCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    ucumUnit,
    ucumAmount,
    metricUnit,
    metricAmount,
    notes,
    allergenCode,
  );

  /// Create a copy of Ingredient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IngredientImplCopyWith<_$IngredientImpl> get copyWith =>
      __$$IngredientImplCopyWithImpl<_$IngredientImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IngredientImplToJson(this);
  }
}

abstract class _Ingredient implements Ingredient {
  const factory _Ingredient({
    required final String name,
    required final UcumUnit ucumUnit,
    required final double ucumAmount,
    required final MetricUnit metricUnit,
    required final double metricAmount,
    required final String notes,
    final AllergenCode? allergenCode,
  }) = _$IngredientImpl;

  factory _Ingredient.fromJson(Map<String, dynamic> json) =
      _$IngredientImpl.fromJson;

  @override
  String get name;
  @override
  UcumUnit get ucumUnit;
  @override
  double get ucumAmount;
  @override
  MetricUnit get metricUnit;
  @override
  double get metricAmount;
  @override
  String get notes;
  @override
  AllergenCode? get allergenCode;

  /// Create a copy of Ingredient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IngredientImplCopyWith<_$IngredientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
