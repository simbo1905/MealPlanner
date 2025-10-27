// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_assignment.freezed_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MealAssignment _$MealAssignmentFromJson(Map<String, dynamic> json) {
  return _MealAssignment.fromJson(json);
}

/// @nodoc
mixin _$MealAssignment {
  String get id => throw _privateConstructorUsedError;
  String get recipeId => throw _privateConstructorUsedError;
  String get dayIsoDate => throw _privateConstructorUsedError;
  DateTime get assignedAt => throw _privateConstructorUsedError;

  /// Serializes this MealAssignment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealAssignment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealAssignmentCopyWith<MealAssignment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealAssignmentCopyWith<$Res> {
  factory $MealAssignmentCopyWith(
    MealAssignment value,
    $Res Function(MealAssignment) then,
  ) = _$MealAssignmentCopyWithImpl<$Res, MealAssignment>;
  @useResult
  $Res call({
    String id,
    String recipeId,
    String dayIsoDate,
    DateTime assignedAt,
  });
}

/// @nodoc
class _$MealAssignmentCopyWithImpl<$Res, $Val extends MealAssignment>
    implements $MealAssignmentCopyWith<$Res> {
  _$MealAssignmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealAssignment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? recipeId = null,
    Object? dayIsoDate = null,
    Object? assignedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            recipeId: null == recipeId
                ? _value.recipeId
                : recipeId // ignore: cast_nullable_to_non_nullable
                      as String,
            dayIsoDate: null == dayIsoDate
                ? _value.dayIsoDate
                : dayIsoDate // ignore: cast_nullable_to_non_nullable
                      as String,
            assignedAt: null == assignedAt
                ? _value.assignedAt
                : assignedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealAssignmentImplCopyWith<$Res>
    implements $MealAssignmentCopyWith<$Res> {
  factory _$$MealAssignmentImplCopyWith(
    _$MealAssignmentImpl value,
    $Res Function(_$MealAssignmentImpl) then,
  ) = __$$MealAssignmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String recipeId,
    String dayIsoDate,
    DateTime assignedAt,
  });
}

/// @nodoc
class __$$MealAssignmentImplCopyWithImpl<$Res>
    extends _$MealAssignmentCopyWithImpl<$Res, _$MealAssignmentImpl>
    implements _$$MealAssignmentImplCopyWith<$Res> {
  __$$MealAssignmentImplCopyWithImpl(
    _$MealAssignmentImpl _value,
    $Res Function(_$MealAssignmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealAssignment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? recipeId = null,
    Object? dayIsoDate = null,
    Object? assignedAt = null,
  }) {
    return _then(
      _$MealAssignmentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        recipeId: null == recipeId
            ? _value.recipeId
            : recipeId // ignore: cast_nullable_to_non_nullable
                  as String,
        dayIsoDate: null == dayIsoDate
            ? _value.dayIsoDate
            : dayIsoDate // ignore: cast_nullable_to_non_nullable
                  as String,
        assignedAt: null == assignedAt
            ? _value.assignedAt
            : assignedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MealAssignmentImpl implements _MealAssignment {
  const _$MealAssignmentImpl({
    required this.id,
    required this.recipeId,
    required this.dayIsoDate,
    required this.assignedAt,
  });

  factory _$MealAssignmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealAssignmentImplFromJson(json);

  @override
  final String id;
  @override
  final String recipeId;
  @override
  final String dayIsoDate;
  @override
  final DateTime assignedAt;

  @override
  String toString() {
    return 'MealAssignment(id: $id, recipeId: $recipeId, dayIsoDate: $dayIsoDate, assignedAt: $assignedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealAssignmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.recipeId, recipeId) ||
                other.recipeId == recipeId) &&
            (identical(other.dayIsoDate, dayIsoDate) ||
                other.dayIsoDate == dayIsoDate) &&
            (identical(other.assignedAt, assignedAt) ||
                other.assignedAt == assignedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, recipeId, dayIsoDate, assignedAt);

  /// Create a copy of MealAssignment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealAssignmentImplCopyWith<_$MealAssignmentImpl> get copyWith =>
      __$$MealAssignmentImplCopyWithImpl<_$MealAssignmentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MealAssignmentImplToJson(this);
  }
}

abstract class _MealAssignment implements MealAssignment {
  const factory _MealAssignment({
    required final String id,
    required final String recipeId,
    required final String dayIsoDate,
    required final DateTime assignedAt,
  }) = _$MealAssignmentImpl;

  factory _MealAssignment.fromJson(Map<String, dynamic> json) =
      _$MealAssignmentImpl.fromJson;

  @override
  String get id;
  @override
  String get recipeId;
  @override
  String get dayIsoDate;
  @override
  DateTime get assignedAt;

  /// Create a copy of MealAssignment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealAssignmentImplCopyWith<_$MealAssignmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
