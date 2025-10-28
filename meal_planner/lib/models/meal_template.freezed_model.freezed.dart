// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_template.freezed_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MealTemplate _$MealTemplateFromJson(Map<String, dynamic> json) {
  return _MealTemplate.fromJson(json);
}

/// @nodoc
mixin _$MealTemplate {
  String get templateId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  MealType get type => throw _privateConstructorUsedError;
  int get prepTimeMinutes => throw _privateConstructorUsedError;
  String get iconName => throw _privateConstructorUsedError;
  String get colorHex => throw _privateConstructorUsedError;

  /// Serializes this MealTemplate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealTemplateCopyWith<MealTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealTemplateCopyWith<$Res> {
  factory $MealTemplateCopyWith(
    MealTemplate value,
    $Res Function(MealTemplate) then,
  ) = _$MealTemplateCopyWithImpl<$Res, MealTemplate>;
  @useResult
  $Res call({
    String templateId,
    String title,
    MealType type,
    int prepTimeMinutes,
    String iconName,
    String colorHex,
  });
}

/// @nodoc
class _$MealTemplateCopyWithImpl<$Res, $Val extends MealTemplate>
    implements $MealTemplateCopyWith<$Res> {
  _$MealTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? templateId = null,
    Object? title = null,
    Object? type = null,
    Object? prepTimeMinutes = null,
    Object? iconName = null,
    Object? colorHex = null,
  }) {
    return _then(
      _value.copyWith(
            templateId: null == templateId
                ? _value.templateId
                : templateId // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MealType,
            prepTimeMinutes: null == prepTimeMinutes
                ? _value.prepTimeMinutes
                : prepTimeMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            iconName: null == iconName
                ? _value.iconName
                : iconName // ignore: cast_nullable_to_non_nullable
                      as String,
            colorHex: null == colorHex
                ? _value.colorHex
                : colorHex // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealTemplateImplCopyWith<$Res>
    implements $MealTemplateCopyWith<$Res> {
  factory _$$MealTemplateImplCopyWith(
    _$MealTemplateImpl value,
    $Res Function(_$MealTemplateImpl) then,
  ) = __$$MealTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String templateId,
    String title,
    MealType type,
    int prepTimeMinutes,
    String iconName,
    String colorHex,
  });
}

/// @nodoc
class __$$MealTemplateImplCopyWithImpl<$Res>
    extends _$MealTemplateCopyWithImpl<$Res, _$MealTemplateImpl>
    implements _$$MealTemplateImplCopyWith<$Res> {
  __$$MealTemplateImplCopyWithImpl(
    _$MealTemplateImpl _value,
    $Res Function(_$MealTemplateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? templateId = null,
    Object? title = null,
    Object? type = null,
    Object? prepTimeMinutes = null,
    Object? iconName = null,
    Object? colorHex = null,
  }) {
    return _then(
      _$MealTemplateImpl(
        templateId: null == templateId
            ? _value.templateId
            : templateId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MealType,
        prepTimeMinutes: null == prepTimeMinutes
            ? _value.prepTimeMinutes
            : prepTimeMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        iconName: null == iconName
            ? _value.iconName
            : iconName // ignore: cast_nullable_to_non_nullable
                  as String,
        colorHex: null == colorHex
            ? _value.colorHex
            : colorHex // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MealTemplateImpl implements _MealTemplate {
  const _$MealTemplateImpl({
    required this.templateId,
    required this.title,
    required this.type,
    required this.prepTimeMinutes,
    required this.iconName,
    required this.colorHex,
  });

  factory _$MealTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealTemplateImplFromJson(json);

  @override
  final String templateId;
  @override
  final String title;
  @override
  final MealType type;
  @override
  final int prepTimeMinutes;
  @override
  final String iconName;
  @override
  final String colorHex;

  @override
  String toString() {
    return 'MealTemplate(templateId: $templateId, title: $title, type: $type, prepTimeMinutes: $prepTimeMinutes, iconName: $iconName, colorHex: $colorHex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealTemplateImpl &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.prepTimeMinutes, prepTimeMinutes) ||
                other.prepTimeMinutes == prepTimeMinutes) &&
            (identical(other.iconName, iconName) ||
                other.iconName == iconName) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    templateId,
    title,
    type,
    prepTimeMinutes,
    iconName,
    colorHex,
  );

  /// Create a copy of MealTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealTemplateImplCopyWith<_$MealTemplateImpl> get copyWith =>
      __$$MealTemplateImplCopyWithImpl<_$MealTemplateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MealTemplateImplToJson(this);
  }
}

abstract class _MealTemplate implements MealTemplate {
  const factory _MealTemplate({
    required final String templateId,
    required final String title,
    required final MealType type,
    required final int prepTimeMinutes,
    required final String iconName,
    required final String colorHex,
  }) = _$MealTemplateImpl;

  factory _MealTemplate.fromJson(Map<String, dynamic> json) =
      _$MealTemplateImpl.fromJson;

  @override
  String get templateId;
  @override
  String get title;
  @override
  MealType get type;
  @override
  int get prepTimeMinutes;
  @override
  String get iconName;
  @override
  String get colorHex;

  /// Create a copy of MealTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealTemplateImplCopyWith<_$MealTemplateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
