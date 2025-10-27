// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_plan.freezed_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MealPlan _$MealPlanFromJson(Map<String, dynamic> json) {
  return _MealPlan.fromJson(json);
}

/// @nodoc
mixin _$MealPlan {
  String get id => throw _privateConstructorUsedError;
  List<String> get mealAssignmentIds => throw _privateConstructorUsedError;
  String? get shoppingListId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MealPlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealPlanCopyWith<MealPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealPlanCopyWith<$Res> {
  factory $MealPlanCopyWith(MealPlan value, $Res Function(MealPlan) then) =
      _$MealPlanCopyWithImpl<$Res, MealPlan>;
  @useResult
  $Res call({
    String id,
    List<String> mealAssignmentIds,
    String? shoppingListId,
    DateTime createdAt,
  });
}

/// @nodoc
class _$MealPlanCopyWithImpl<$Res, $Val extends MealPlan>
    implements $MealPlanCopyWith<$Res> {
  _$MealPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mealAssignmentIds = null,
    Object? shoppingListId = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            mealAssignmentIds: null == mealAssignmentIds
                ? _value.mealAssignmentIds
                : mealAssignmentIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            shoppingListId: freezed == shoppingListId
                ? _value.shoppingListId
                : shoppingListId // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealPlanImplCopyWith<$Res>
    implements $MealPlanCopyWith<$Res> {
  factory _$$MealPlanImplCopyWith(
    _$MealPlanImpl value,
    $Res Function(_$MealPlanImpl) then,
  ) = __$$MealPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    List<String> mealAssignmentIds,
    String? shoppingListId,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$MealPlanImplCopyWithImpl<$Res>
    extends _$MealPlanCopyWithImpl<$Res, _$MealPlanImpl>
    implements _$$MealPlanImplCopyWith<$Res> {
  __$$MealPlanImplCopyWithImpl(
    _$MealPlanImpl _value,
    $Res Function(_$MealPlanImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mealAssignmentIds = null,
    Object? shoppingListId = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$MealPlanImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        mealAssignmentIds: null == mealAssignmentIds
            ? _value._mealAssignmentIds
            : mealAssignmentIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        shoppingListId: freezed == shoppingListId
            ? _value.shoppingListId
            : shoppingListId // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MealPlanImpl implements _MealPlan {
  const _$MealPlanImpl({
    required this.id,
    required final List<String> mealAssignmentIds,
    this.shoppingListId,
    required this.createdAt,
  }) : _mealAssignmentIds = mealAssignmentIds;

  factory _$MealPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealPlanImplFromJson(json);

  @override
  final String id;
  final List<String> _mealAssignmentIds;
  @override
  List<String> get mealAssignmentIds {
    if (_mealAssignmentIds is EqualUnmodifiableListView)
      return _mealAssignmentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mealAssignmentIds);
  }

  @override
  final String? shoppingListId;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'MealPlan(id: $id, mealAssignmentIds: $mealAssignmentIds, shoppingListId: $shoppingListId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(
              other._mealAssignmentIds,
              _mealAssignmentIds,
            ) &&
            (identical(other.shoppingListId, shoppingListId) ||
                other.shoppingListId == shoppingListId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(_mealAssignmentIds),
    shoppingListId,
    createdAt,
  );

  /// Create a copy of MealPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealPlanImplCopyWith<_$MealPlanImpl> get copyWith =>
      __$$MealPlanImplCopyWithImpl<_$MealPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MealPlanImplToJson(this);
  }
}

abstract class _MealPlan implements MealPlan {
  const factory _MealPlan({
    required final String id,
    required final List<String> mealAssignmentIds,
    final String? shoppingListId,
    required final DateTime createdAt,
  }) = _$MealPlanImpl;

  factory _MealPlan.fromJson(Map<String, dynamic> json) =
      _$MealPlanImpl.fromJson;

  @override
  String get id;
  @override
  List<String> get mealAssignmentIds;
  @override
  String? get shoppingListId;
  @override
  DateTime get createdAt;

  /// Create a copy of MealPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealPlanImplCopyWith<_$MealPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
