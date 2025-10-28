import 'package:meal_planner/models/meal_template.freezed_model.dart';
import 'package:meal_planner/repositories/meal_template_repository.dart';

/// In-memory fake repository for meal templates used in widget tests.
/// Uses hardcoded demo templates from SPEC.md
class FakeMealTemplateRepository implements MealTemplateRepository {
  final List<MealTemplate> _templates = DemoMealTemplates.templates;

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
}
