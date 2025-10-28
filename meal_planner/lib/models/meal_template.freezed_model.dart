import 'package:freezed_annotation/freezed_annotation.dart';

part 'meal_template.freezed_model.freezed.dart';
part 'meal_template.freezed_model.g.dart';

enum MealType { breakfast, lunch, dinner, snack, supper }

@freezed
class MealTemplate with _$MealTemplate {
  const factory MealTemplate({
    required String templateId,
    required String title,
    required MealType type,
    required int prepTimeMinutes,
    required String iconName,
    required String colorHex,
  }) = _MealTemplate;

  factory MealTemplate.fromJson(Map<String, dynamic> json) =>
      _$MealTemplateFromJson(json);
}

/// Hardcoded demo templates from SPEC.md
class DemoMealTemplates {
  static final List<MealTemplate> templates = [
    const MealTemplate(
      templateId: 'breakfast_1',
      title: 'Oatmeal',
      type: MealType.breakfast,
      prepTimeMinutes: 10,
      iconName: 'bowl',
      colorHex: '#4285F4',
    ),
    const MealTemplate(
      templateId: 'breakfast_2',
      title: 'Scrambled Eggs',
      type: MealType.breakfast,
      prepTimeMinutes: 15,
      iconName: 'egg',
      colorHex: '#4285F4',
    ),
    const MealTemplate(
      templateId: 'lunch_1',
      title: 'Chicken Salad',
      type: MealType.lunch,
      prepTimeMinutes: 20,
      iconName: 'restaurant',
      colorHex: '#DB4437',
    ),
    const MealTemplate(
      templateId: 'lunch_2',
      title: 'Tuna Sandwich',
      type: MealType.lunch,
      prepTimeMinutes: 10,
      iconName: 'fish',
      colorHex: '#DB4437',
    ),
    const MealTemplate(
      templateId: 'dinner_1',
      title: 'Fish and Chips',
      type: MealType.dinner,
      prepTimeMinutes: 30,
      iconName: 'fast-food',
      colorHex: '#F4B400',
    ),
    const MealTemplate(
      templateId: 'dinner_2',
      title: 'Steak and Veg',
      type: MealType.dinner,
      prepTimeMinutes: 45,
      iconName: 'local-bar',
      colorHex: '#F4B400',
    ),
    const MealTemplate(
      templateId: 'snack_1',
      title: 'Apple Slices',
      type: MealType.snack,
      prepTimeMinutes: 5,
      iconName: 'nutrition',
      colorHex: '#0F9D58',
    ),
    const MealTemplate(
      templateId: 'snack_2',
      title: 'Yogurt',
      type: MealType.snack,
      prepTimeMinutes: 2,
      iconName: 'ice-cream',
      colorHex: '#0F9D58',
    ),
    const MealTemplate(
      templateId: 'supper_1',
      title: 'Glass of Milk',
      type: MealType.supper,
      prepTimeMinutes: 1,
      iconName: 'local-cafe',
      colorHex: '#AB47BC',
    ),
    const MealTemplate(
      templateId: 'supper_2',
      title: 'Herbal Tea',
      type: MealType.supper,
      prepTimeMinutes: 5,
      iconName: 'free-breakfast',
      colorHex: '#AB47BC',
    ),
  ];
}
