import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/meal_providers.dart';

class PlannedMealsCounter extends ConsumerWidget {
  const PlannedMealsCounter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(plannedMealCountProvider);
    final theme = Theme.of(context);

    return countAsync.when(
      data: (count) {
        final textColor = count > 0 ? theme.colorScheme.primary : Colors.grey;
        return Container(
          key: const Key('planned_meals_counter'),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            count > 0 ? 'Planned Meals: $count' : 'No Planned Meals',
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: count > 0 ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, _) => Container(
        key: const Key('planned_meals_counter'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          'Planned Meals: --',
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
