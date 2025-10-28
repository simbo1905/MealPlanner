import 'package:meal_planner/models/meal_assignment.freezed_model.dart';

abstract class MealAssignmentRepository {
  List<MealAssignment> getAllAssignments();
  
  Future<List<MealAssignment>> getMealAssignments(
    DateTime startDate,
    DateTime endDate,
  );
}
