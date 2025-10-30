import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/meal.freezed_model.dart';
import '../../providers/meal_providers.dart';
import '../../providers/auth_providers.dart';
import 'meal_card.dart';
import 'add_meal_card.dart';
import '../../utils/card_dimensions.dart';

class DayRow extends ConsumerWidget {
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final List<Meal> meals;
  final VoidCallback onTap;
  final VoidCallback onAddMeal;

  const DayRow({
    super.key,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.meals,
    required this.onTap,
    required this.onAddMeal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundColor = isSelected ? Colors.blue[50] : Colors.white;
    final borderColor = isSelected ? Colors.blue[400] : Colors.transparent;
    final dateKey = DateFormat('yyyy-MM-dd').format(date);

    final rowHeight = CardDimensions.rowHeightFor(context);
    final listPadding = CardDimensions.carouselPadding(context);
    final interCardGap = CardDimensions.interCardGap(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: Key('day-row-$dateKey'),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            left: BorderSide(
              color: borderColor!,
              width: 4,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateRail(date: date, isToday: isToday),
            Expanded(
              child: SizedBox(
                height: rowHeight,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: listPadding,
                  children: [
                    ...meals.asMap().entries.map((entry) {
                      final index = entry.key;
                      final meal = entry.value;
                      return Container(
                        margin: EdgeInsets.only(right: interCardGap),
                        child: MealCard(
                          key: Key('meal-${meal.id}-$dateKey'),
                          meal: meal,
                          deleteKey: Key('delete-meal-$dateKey-$index'),
                          onDelete: () => _onDeleteMeal(ref, meal.id),
                          onLongPress: () => _onShowActionsSheet(context, ref, meal),
                        ),
                      );
                    }),
                    Container(
                      key: Key('add-meal-$dateKey'),
                      margin: EdgeInsets.only(right: interCardGap),
                      child: AddMealCard(onTap: onAddMeal),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDeleteMeal(WidgetRef ref, String mealId) {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final repository = ref.read(mealRepositoryProvider);
    repository.deleteMeal(userId: userId, mealId: mealId);
  }

  void _onShowActionsSheet(BuildContext context, WidgetRef ref, Meal meal) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _MealActionsSheet(meal: meal),
    );
  }
}

class _DateRail extends StatelessWidget {
  final DateTime date;
  final bool isToday;

  const _DateRail({required this.date, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: Column(
        children: [
          Text(
            DateFormat('EEE').format(date).toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isToday ? Colors.blue : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isToday ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealActionsSheet extends ConsumerWidget {
  final Meal meal;

  const _MealActionsSheet({required this.meal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Meal'),
              onTap: () {
                final userId = ref.read(currentUserIdProvider);
                if (userId != null) {
                  ref.read(mealRepositoryProvider).deleteMeal(
                        userId: userId,
                        mealId: meal.id,
                      );
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}