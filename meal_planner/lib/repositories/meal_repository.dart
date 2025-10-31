import 'package:meal_planner/models/meal.freezed_model.dart';

/// Strategy for handling conflicts when adding a meal to an occupied slot
enum MealConflictStrategy { keepBoth, replace }

abstract class MealRepository {
  // New Firestore-backed API
  Stream<List<Meal>> watchMeals(String userId);
  Future<Meal> addMeal({
    required String userId,
    required DateTime date,
    required MealSlot slot,
    required String recipeTitle,
    MealConflictStrategy conflictStrategy,
  });
  Future<void> deleteMeal({required String userId, required String mealId});
  Future<void> updateMeal({
    required String userId,
    required String mealId,
    DateTime? newDate,
    MealSlot? newSlot,
    String? newRecipeTitle,
  });
  Future<void> swapMeals({
    required String userId,
    required String firstMealId,
    required String secondMealId,
  });
  Future<Meal?> findMealByDateSlot({
    required String userId,
    required DateTime date,
    required MealSlot slot,
  });

  // Legacy in-memory API used by existing UI code
  List<Meal> getMealsForDate(DateTime date) => const [];
  List<Meal> getMealsForDateRange(DateTime start, DateTime end) => const [];
  Future<void> saveState(Map<String, List<Meal>> state) async {}
  void resetToPersistedState() {}
}
