import 'package:flutter/foundation.dart';
import 'package:meal_planner/models/meal_template.freezed_model.dart';
import 'package:meal_planner/repositories/meal_template_repository.dart';

/// In-memory fake repository for meal templates used in widget tests.
/// Uses hardcoded demo templates from SPEC.md plus dynamic user-created templates.
class FakeMealTemplateRepository implements MealTemplateRepository {
  final List<MealTemplate> _templates = List.from(DemoMealTemplates.templates);
  int _dynamicIdCounter = 1000;

  @override
  List<MealTemplate> getAllTemplates() {
    return List.from(_templates);
  }

  @override
  MealTemplate? getTemplateById(String templateId) {
    try {
      return _templates.firstWhere((t) => t.templateId == templateId);
    } catch (e) {
      return null;
    }
  }

  @override
  MealTemplate addDynamicTemplate(String title) {
    final templateId = 'dynamic_$_dynamicIdCounter';
    _dynamicIdCounter++;

    final template = MealTemplate(
      templateId: templateId,
      title: title,
      type: MealType.dinner,
      prepTimeMinutes: 30,
      iconName: 'restaurant',
      colorHex: '#FF9800',
    );

    _templates.add(template);
    debugPrint('[INFO] ADD_TEMPLATE - id: $templateId, title: $title');
    return template;
  }
}
