import 'package:meal_planner/models/meal_template.freezed_model.dart';

abstract class MealTemplateRepository {
  List<MealTemplate> getAllTemplates();
  MealTemplate? getTemplateById(String templateId);
  MealTemplate addDynamicTemplate(String title);
}
