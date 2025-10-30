import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/week_section.freezed_model.dart';
import '../../providers/auth_providers.dart';
import '../../providers/meal_providers.dart';
import '../../models/meal.freezed_model.dart';

class LandscapeWeekGrid extends ConsumerWidget {
  final WeekSection weekSection;
  final void Function(DateTime date) onSelectDay;
  final void Function(DateTime date) onAddMeal;
  final Future<void> Function(String firstMealId, String secondMealId) onSwapMeals;

  const LandscapeWeekGrid({
    super.key,
    required this.weekSection,
    required this.onSelectDay,
    required this.onAddMeal,
    required this.onSwapMeals,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = weekSection.days;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final day in columns)
            Expanded(
              child: _DayColumn(
                day: day,
                onSelectDay: onSelectDay,
                onAddMeal: onAddMeal,
                onSwapMeals: onSwapMeals,
              ),
            ),
        ],
      ),
    );
  }
}

class _DayColumn extends ConsumerWidget {
  final DaySection day;
  final void Function(DateTime date) onSelectDay;
  final void Function(DateTime date) onAddMeal;
  final Future<void> Function(String firstMealId, String secondMealId) onSwapMeals;

  const _DayColumn({
    required this.day,
    required this.onSelectDay,
    required this.onAddMeal,
    required this.onSwapMeals,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<Meal>(
      onWillAccept: (incoming) => incoming != null,
      onAccept: (incoming) async {
        if (incoming == null) return;
        if (day.meals.isEmpty) {
          await _moveMeal(ref, incoming, day.date);
        } else {
          final targetMeal = day.meals.first;
          await onSwapMeals(incoming.id, targetMeal.id);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: day.isSelected ? Colors.blue : Colors.transparent,
              width: day.isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DayHeader(
                day: day,
                onTap: () => onSelectDay(day.date),
              ),
              const SizedBox(height: 12),
              for (final meal in day.meals)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _DraggableMealCard(
                    meal: meal,
                    onSwap: (otherId) => onSwapMeals(meal.id, otherId),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () => onAddMeal(day.date),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _moveMeal(WidgetRef ref, Meal meal, DateTime newDate) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    await ref.read(mealRepositoryProvider).updateMeal(
          userId: userId,
          mealId: meal.id,
          newDate: newDate,
        );
  }
}

class _DayHeader extends StatelessWidget {
  final DaySection day;
  final VoidCallback onTap;

  const _DayHeader({required this.day, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day.dayLabel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Text(
            '${day.date.month}/${day.date.day}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DraggableMealCard extends ConsumerWidget {
  final Meal meal;
  final Future<void> Function(String otherMealId) onSwap;

  const _DraggableMealCard({required this.meal, required this.onSwap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LongPressDraggable<Meal>(
      data: meal,
      feedback: _MealChip(meal: meal),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _MealChip(meal: meal),
      ),
      child: DragTarget<Meal>(
        onWillAccept: (incoming) => incoming != null && incoming.id != meal.id,
        onAccept: (incoming) async {
          if (incoming == null) return;
          await onSwap(incoming.id);
        },
        builder: (context, candidateData, rejectedData) {
          final isActive = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              border: Border.all(
                color: isActive ? Colors.blue : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _MealChip(meal: meal),
          );
        },
      ),
    );
  }
}

class _MealChip extends StatelessWidget {
  final Meal meal;

  const _MealChip({required this.meal});

  @override
  Widget build(BuildContext context) {
    final slotLabel = meal.slot.name[0].toUpperCase() + meal.slot.name.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            slotLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            meal.recipeTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}