import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/meal.freezed_model.dart';
import '../../providers/meal_providers.dart';
import 'meal_card.dart';
import 'add_meal_card.dart';
import '../../utils/card_dimensions.dart';

/// Data transferred during drag-and-drop operations
class MealDragData {
  final Meal meal;
  final DateTime sourceDate;
  final int index;

  MealDragData({
    required this.meal,
    required this.sourceDate,
    required this.index,
  });
}

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
    final dateKey = _dateToKey(date);
    
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
            // Left rail with day label and date
            SizedBox(
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
            ),
            
            // Meal cards carousel with drag target
            Expanded(
              child: DragTarget<MealDragData>(
                key: Key('drag-target-$dateKey'),
                onWillAcceptWithDetails: (_) => true,
                onAcceptWithDetails: (details) => _onDropMeal(ref, details.data, date),
                builder: (context, candidateData, rejectedData) {
                  final rowHeight = CardDimensions.rowHeightFor(context);
                  final listPadding = CardDimensions.carouselPadding(context);
                  final interCardGap = CardDimensions.interCardGap(context);

                  return Container(
                    decoration: candidateData.isNotEmpty
                        ? BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: SizedBox(
                      height: rowHeight,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: listPadding,
                        itemExtent: null,
                        children: [
                          // Existing meal cards
                          ...meals.asMap().entries.map((entry) {
                            final index = entry.key;
                            final meal = entry.value;
                            final template = ref.watch(mealTemplateByIdProvider(meal.templateId));
                            if (template == null) return const SizedBox.shrink();
                            
                            final dragWidth = CardDimensions.dragFeedbackWidth(
                              context: context,
                              rowHeight: rowHeight,
                            );

                            return Container(
                              margin: EdgeInsets.only(right: interCardGap),
                              child: LongPressDraggable<MealDragData>(
                              key: Key('meal-${template.title}-$dateKey'),
                              data: MealDragData(
                                meal: meal,
                                sourceDate: date,
                                index: index,
                              ),
                              feedback: Material(
                                elevation: 6,
                                borderRadius: BorderRadius.circular(12),
                                child: Opacity(
                                  opacity: 0.8,
                                  child: SizedBox(
                                    width: dragWidth,
                                    child: MealCard(
                                      meal: meal,
                                      template: template,
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: MealCard(
                                  meal: meal,
                                  template: template,
                                ),
                              ),
                              child: MealCard(
                                meal: meal,
                                template: template,
                                deleteKey: Key('delete-meal-$dateKey-$index'),
                                onDelete: () => _onDeleteMeal(ref, meal.id),
                                onLongPress: () => _onLongPressMeal(context, meal),
                              ),
                              ),
                            );
                          }),
                          
                          // Add meal card
                          Container(
                            key: Key('add-meal-$dateKey'),
                            margin: EdgeInsets.only(right: interCardGap),
                            child: AddMealCard(
                              onTap: onAddMeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dateToKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void _onDeleteMeal(WidgetRef ref, String mealId) {
    final repository = ref.read(mealRepositoryProvider);
    repository.removeMeal(mealId);
  }

  void _onDropMeal(WidgetRef ref, MealDragData data, DateTime targetDate) {
    if (_isSameDay(data.sourceDate, targetDate)) return;
    
    final repository = ref.read(mealRepositoryProvider);
    repository.moveMeal(data.meal.id, data.sourceDate, targetDate);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _onLongPressMeal(BuildContext context, Meal meal) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _MealActionsSheet(meal: meal),
    );
  }
}

class _MealActionsSheet extends ConsumerWidget {
  final Meal meal;

  const _MealActionsSheet({required this.meal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete Meal'),
            onTap: () {
              final repository = ref.read(mealRepositoryProvider);
              repository.removeMeal(meal.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
