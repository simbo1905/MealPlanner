import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/recipe.freezed_model.dart';
import 'recipe_providers.dart';
import 'meal_assignment_providers.dart';

part 'calendar_providers.g.dart';

// Get recipes for a specific day (computed from meal_assignments + recipes)
@riverpod
Future<List<Recipe>> recipesForDay(
  Ref ref,
  String isoDate,
) async {
  final assignments = ref.watch(mealAssignmentsForDayProvider(isoDate));
  final allRecipes = ref.watch(recipesProvider);

  return assignments.when(
    data: (assignmentList) {
      return allRecipes.when(
        data: (recipeList) {
          // Build recipe lookup map for O(1) access
          final recipeById = {for (var r in recipeList) r.id: r};
          
          final result = <Recipe>[];
          for (var assignment in assignmentList) {
            final recipe = recipeById[assignment.recipeId];
            if (recipe != null) {
              result.add(recipe);
            }
          }
          return result;
        },
        loading: () => [],
        error: (_, __) => [],
      );
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

// Count meals per day for a week
@riverpod
Future<Map<String, int>> weekMealCounts(
  Ref ref,
  String startIsoDate,
) async {
  final weekAssignments = ref.watch(weekMealAssignmentsProvider(startIsoDate));

  return weekAssignments.when(
    data: (assignmentMap) {
      final result = <String, int>{};
      assignmentMap.forEach((day, assignments) {
        result[day] = assignments.length;
      });
      return result;
    },
    loading: () => {},
    error: (_, __) => {},
  );
}

// Sum total cooking time for week
@riverpod
Future<double> weekTotalTime(
  Ref ref,
  String startIsoDate,
) async {
  final weekAssignments = ref.watch(weekMealAssignmentsProvider(startIsoDate));
  final allRecipes = ref.watch(recipesProvider);

  return weekAssignments.when(
    data: (assignmentMap) {
      return allRecipes.when(
        data: (recipeList) {
          // Build recipe lookup map for O(1) access
          final recipeById = {for (var r in recipeList) r.id: r};
          
          double total = 0.0;
          assignmentMap.forEach((_, assignments) {
            for (var assignment in assignments) {
              final recipe = recipeById[assignment.recipeId];
              if (recipe != null) {
                total += recipe.totalTime;
              }
            }
          });
          return total;
        },
        loading: () => 0.0,
        error: (_, __) => 0.0,
      );
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
}
