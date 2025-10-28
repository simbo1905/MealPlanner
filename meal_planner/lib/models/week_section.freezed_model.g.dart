// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week_section.freezed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeekSectionImpl _$$WeekSectionImplFromJson(Map<String, dynamic> json) =>
    _$WeekSectionImpl(
      weekStart: DateTime.parse(json['weekStart'] as String),
      weekEnd: DateTime.parse(json['weekEnd'] as String),
      weekNumber: (json['weekNumber'] as num).toInt(),
      days: (json['days'] as List<dynamic>)
          .map((e) => DaySection.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalMeals: (json['totalMeals'] as num).toInt(),
      totalPrepTime: (json['totalPrepTime'] as num).toInt(),
    );

Map<String, dynamic> _$$WeekSectionImplToJson(_$WeekSectionImpl instance) =>
    <String, dynamic>{
      'weekStart': instance.weekStart.toIso8601String(),
      'weekEnd': instance.weekEnd.toIso8601String(),
      'weekNumber': instance.weekNumber,
      'days': instance.days,
      'totalMeals': instance.totalMeals,
      'totalPrepTime': instance.totalPrepTime,
    };

_$DaySectionImpl _$$DaySectionImplFromJson(Map<String, dynamic> json) =>
    _$DaySectionImpl(
      date: DateTime.parse(json['date'] as String),
      dayLabel: json['dayLabel'] as String,
      isToday: json['isToday'] as bool,
      isSelected: json['isSelected'] as bool,
      meals: (json['meals'] as List<dynamic>)
          .map((e) => Meal.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$DaySectionImplToJson(_$DaySectionImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'dayLabel': instance.dayLabel,
      'isToday': instance.isToday,
      'isSelected': instance.isSelected,
      'meals': instance.meals,
    };
