import 'package:meal_planner/models/meal.freezed_model.dart';

abstract class MealRepository {
  List<Meal> getMealsForDate(DateTime date);
  List<Meal> getMealsForDateRange(DateTime start, DateTime end);
  Future<Meal> addMeal(DateTime date, String templateId);
  Future<void> removeMeal(String mealId);
  Future<void> moveMeal(String mealId, DateTime fromDate, DateTime toDate);
  Future<void> reorderMeals(DateTime date, List<String> mealIds);
  Future<void> saveState(Map<String, List<Meal>> state);
  Map<String, List<Meal>> getPersistedState();
  void resetToPersistedState();
}
