// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'week_section.freezed_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WeekSection _$WeekSectionFromJson(Map<String, dynamic> json) {
  return _WeekSection.fromJson(json);
}

/// @nodoc
mixin _$WeekSection {
  DateTime get weekStart => throw _privateConstructorUsedError;
  DateTime get weekEnd => throw _privateConstructorUsedError;
  int get weekNumber => throw _privateConstructorUsedError;
  List<DaySection> get days => throw _privateConstructorUsedError;
  int get totalMeals => throw _privateConstructorUsedError;
  int get totalPrepTime => throw _privateConstructorUsedError;

  /// Serializes this WeekSection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeekSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeekSectionCopyWith<WeekSection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeekSectionCopyWith<$Res> {
  factory $WeekSectionCopyWith(
    WeekSection value,
    $Res Function(WeekSection) then,
  ) = _$WeekSectionCopyWithImpl<$Res, WeekSection>;
  @useResult
  $Res call({
    DateTime weekStart,
    DateTime weekEnd,
    int weekNumber,
    List<DaySection> days,
    int totalMeals,
    int totalPrepTime,
  });
}

/// @nodoc
class _$WeekSectionCopyWithImpl<$Res, $Val extends WeekSection>
    implements $WeekSectionCopyWith<$Res> {
  _$WeekSectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeekSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekStart = null,
    Object? weekEnd = null,
    Object? weekNumber = null,
    Object? days = null,
    Object? totalMeals = null,
    Object? totalPrepTime = null,
  }) {
    return _then(
      _value.copyWith(
            weekStart: null == weekStart
                ? _value.weekStart
                : weekStart // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            weekEnd: null == weekEnd
                ? _value.weekEnd
                : weekEnd // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            weekNumber: null == weekNumber
                ? _value.weekNumber
                : weekNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            days: null == days
                ? _value.days
                : days // ignore: cast_nullable_to_non_nullable
                      as List<DaySection>,
            totalMeals: null == totalMeals
                ? _value.totalMeals
                : totalMeals // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPrepTime: null == totalPrepTime
                ? _value.totalPrepTime
                : totalPrepTime // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeekSectionImplCopyWith<$Res>
    implements $WeekSectionCopyWith<$Res> {
  factory _$$WeekSectionImplCopyWith(
    _$WeekSectionImpl value,
    $Res Function(_$WeekSectionImpl) then,
  ) = __$$WeekSectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime weekStart,
    DateTime weekEnd,
    int weekNumber,
    List<DaySection> days,
    int totalMeals,
    int totalPrepTime,
  });
}

/// @nodoc
class __$$WeekSectionImplCopyWithImpl<$Res>
    extends _$WeekSectionCopyWithImpl<$Res, _$WeekSectionImpl>
    implements _$$WeekSectionImplCopyWith<$Res> {
  __$$WeekSectionImplCopyWithImpl(
    _$WeekSectionImpl _value,
    $Res Function(_$WeekSectionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeekSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekStart = null,
    Object? weekEnd = null,
    Object? weekNumber = null,
    Object? days = null,
    Object? totalMeals = null,
    Object? totalPrepTime = null,
  }) {
    return _then(
      _$WeekSectionImpl(
        weekStart: null == weekStart
            ? _value.weekStart
            : weekStart // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        weekEnd: null == weekEnd
            ? _value.weekEnd
            : weekEnd // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        weekNumber: null == weekNumber
            ? _value.weekNumber
            : weekNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        days: null == days
            ? _value._days
            : days // ignore: cast_nullable_to_non_nullable
                  as List<DaySection>,
        totalMeals: null == totalMeals
            ? _value.totalMeals
            : totalMeals // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPrepTime: null == totalPrepTime
            ? _value.totalPrepTime
            : totalPrepTime // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeekSectionImpl implements _WeekSection {
  const _$WeekSectionImpl({
    required this.weekStart,
    required this.weekEnd,
    required this.weekNumber,
    required final List<DaySection> days,
    required this.totalMeals,
    required this.totalPrepTime,
  }) : _days = days;

  factory _$WeekSectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeekSectionImplFromJson(json);

  @override
  final DateTime weekStart;
  @override
  final DateTime weekEnd;
  @override
  final int weekNumber;
  final List<DaySection> _days;
  @override
  List<DaySection> get days {
    if (_days is EqualUnmodifiableListView) return _days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_days);
  }

  @override
  final int totalMeals;
  @override
  final int totalPrepTime;

  @override
  String toString() {
    return 'WeekSection(weekStart: $weekStart, weekEnd: $weekEnd, weekNumber: $weekNumber, days: $days, totalMeals: $totalMeals, totalPrepTime: $totalPrepTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeekSectionImpl &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            (identical(other.weekEnd, weekEnd) || other.weekEnd == weekEnd) &&
            (identical(other.weekNumber, weekNumber) ||
                other.weekNumber == weekNumber) &&
            const DeepCollectionEquality().equals(other._days, _days) &&
            (identical(other.totalMeals, totalMeals) ||
                other.totalMeals == totalMeals) &&
            (identical(other.totalPrepTime, totalPrepTime) ||
                other.totalPrepTime == totalPrepTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    weekStart,
    weekEnd,
    weekNumber,
    const DeepCollectionEquality().hash(_days),
    totalMeals,
    totalPrepTime,
  );

  /// Create a copy of WeekSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeekSectionImplCopyWith<_$WeekSectionImpl> get copyWith =>
      __$$WeekSectionImplCopyWithImpl<_$WeekSectionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeekSectionImplToJson(this);
  }
}

abstract class _WeekSection implements WeekSection {
  const factory _WeekSection({
    required final DateTime weekStart,
    required final DateTime weekEnd,
    required final int weekNumber,
    required final List<DaySection> days,
    required final int totalMeals,
    required final int totalPrepTime,
  }) = _$WeekSectionImpl;

  factory _WeekSection.fromJson(Map<String, dynamic> json) =
      _$WeekSectionImpl.fromJson;

  @override
  DateTime get weekStart;
  @override
  DateTime get weekEnd;
  @override
  int get weekNumber;
  @override
  List<DaySection> get days;
  @override
  int get totalMeals;
  @override
  int get totalPrepTime;

  /// Create a copy of WeekSection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeekSectionImplCopyWith<_$WeekSectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DaySection _$DaySectionFromJson(Map<String, dynamic> json) {
  return _DaySection.fromJson(json);
}

/// @nodoc
mixin _$DaySection {
  DateTime get date => throw _privateConstructorUsedError;
  String get dayLabel => throw _privateConstructorUsedError;
  bool get isToday => throw _privateConstructorUsedError;
  bool get isSelected => throw _privateConstructorUsedError;
  List<Meal> get meals => throw _privateConstructorUsedError;

  /// Serializes this DaySection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DaySection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DaySectionCopyWith<DaySection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DaySectionCopyWith<$Res> {
  factory $DaySectionCopyWith(
    DaySection value,
    $Res Function(DaySection) then,
  ) = _$DaySectionCopyWithImpl<$Res, DaySection>;
  @useResult
  $Res call({
    DateTime date,
    String dayLabel,
    bool isToday,
    bool isSelected,
    List<Meal> meals,
  });
}

/// @nodoc
class _$DaySectionCopyWithImpl<$Res, $Val extends DaySection>
    implements $DaySectionCopyWith<$Res> {
  _$DaySectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DaySection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? dayLabel = null,
    Object? isToday = null,
    Object? isSelected = null,
    Object? meals = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            dayLabel: null == dayLabel
                ? _value.dayLabel
                : dayLabel // ignore: cast_nullable_to_non_nullable
                      as String,
            isToday: null == isToday
                ? _value.isToday
                : isToday // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSelected: null == isSelected
                ? _value.isSelected
                : isSelected // ignore: cast_nullable_to_non_nullable
                      as bool,
            meals: null == meals
                ? _value.meals
                : meals // ignore: cast_nullable_to_non_nullable
                      as List<Meal>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DaySectionImplCopyWith<$Res>
    implements $DaySectionCopyWith<$Res> {
  factory _$$DaySectionImplCopyWith(
    _$DaySectionImpl value,
    $Res Function(_$DaySectionImpl) then,
  ) = __$$DaySectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime date,
    String dayLabel,
    bool isToday,
    bool isSelected,
    List<Meal> meals,
  });
}

/// @nodoc
class __$$DaySectionImplCopyWithImpl<$Res>
    extends _$DaySectionCopyWithImpl<$Res, _$DaySectionImpl>
    implements _$$DaySectionImplCopyWith<$Res> {
  __$$DaySectionImplCopyWithImpl(
    _$DaySectionImpl _value,
    $Res Function(_$DaySectionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DaySection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? dayLabel = null,
    Object? isToday = null,
    Object? isSelected = null,
    Object? meals = null,
  }) {
    return _then(
      _$DaySectionImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        dayLabel: null == dayLabel
            ? _value.dayLabel
            : dayLabel // ignore: cast_nullable_to_non_nullable
                  as String,
        isToday: null == isToday
            ? _value.isToday
            : isToday // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSelected: null == isSelected
            ? _value.isSelected
            : isSelected // ignore: cast_nullable_to_non_nullable
                  as bool,
        meals: null == meals
            ? _value._meals
            : meals // ignore: cast_nullable_to_non_nullable
                  as List<Meal>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DaySectionImpl implements _DaySection {
  const _$DaySectionImpl({
    required this.date,
    required this.dayLabel,
    required this.isToday,
    required this.isSelected,
    required final List<Meal> meals,
  }) : _meals = meals;

  factory _$DaySectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$DaySectionImplFromJson(json);

  @override
  final DateTime date;
  @override
  final String dayLabel;
  @override
  final bool isToday;
  @override
  final bool isSelected;
  final List<Meal> _meals;
  @override
  List<Meal> get meals {
    if (_meals is EqualUnmodifiableListView) return _meals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_meals);
  }

  @override
  String toString() {
    return 'DaySection(date: $date, dayLabel: $dayLabel, isToday: $isToday, isSelected: $isSelected, meals: $meals)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DaySectionImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.dayLabel, dayLabel) ||
                other.dayLabel == dayLabel) &&
            (identical(other.isToday, isToday) || other.isToday == isToday) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected) &&
            const DeepCollectionEquality().equals(other._meals, _meals));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    dayLabel,
    isToday,
    isSelected,
    const DeepCollectionEquality().hash(_meals),
  );

  /// Create a copy of DaySection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DaySectionImplCopyWith<_$DaySectionImpl> get copyWith =>
      __$$DaySectionImplCopyWithImpl<_$DaySectionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DaySectionImplToJson(this);
  }
}

abstract class _DaySection implements DaySection {
  const factory _DaySection({
    required final DateTime date,
    required final String dayLabel,
    required final bool isToday,
    required final bool isSelected,
    required final List<Meal> meals,
  }) = _$DaySectionImpl;

  factory _DaySection.fromJson(Map<String, dynamic> json) =
      _$DaySectionImpl.fromJson;

  @override
  DateTime get date;
  @override
  String get dayLabel;
  @override
  bool get isToday;
  @override
  bool get isSelected;
  @override
  List<Meal> get meals;

  /// Create a copy of DaySection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DaySectionImplCopyWith<_$DaySectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
