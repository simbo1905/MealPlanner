import 'package:flutter/material.dart';
import 'package:meal_planner/models/meal_assignment.freezed_model.dart';
import 'package:meal_planner/models/recipe.freezed_model.dart';

/// Display a single meal assignment with recipe details
class MealAssignmentWidget extends StatelessWidget {
  final MealAssignment assignment;
  final Recipe recipe;
  final VoidCallback? onUnassign;
  final VoidCallback? onTap;

  const MealAssignmentWidget({
    super.key,
    required this.assignment,
    required this.recipe,
    this.onUnassign,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(recipe.totalTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.shopping_basket_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.ingredients.length} ingredients',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onUnassign != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onUnassign,
                  tooltip: 'Unassign meal',
                  iconSize: 20,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(double minutes) {
    final hours = minutes ~/ 60;
    final mins = (minutes % 60).toInt();
    if (hours > 0) {
      return '$hours hr $mins min';
    }
    return '$mins min';
  }
}
