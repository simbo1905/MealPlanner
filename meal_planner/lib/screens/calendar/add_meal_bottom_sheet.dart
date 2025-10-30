import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/meal.freezed_model.dart';
import '../../providers/auth_providers.dart';
import '../../providers/meal_providers.dart';
import '../../repositories/meal_repository.dart';
// Removed unused import of recipe_providers.dart
import '../../providers/favorites_providers.dart';

class AddMealBottomSheet extends ConsumerStatefulWidget {
  final DateTime date;

  const AddMealBottomSheet({
    super.key,
    required this.date,
  });

  @override
  ConsumerState<AddMealBottomSheet> createState() => _AddMealBottomSheetState();
}

class _AddMealBottomSheetState extends ConsumerState<AddMealBottomSheet> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    ref.read(favoriteSuggestionsProvider.notifier).clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suggestionsAsync = ref.watch(favoriteSuggestionsProvider);
    final userId = ref.watch(currentUserIdProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Text(
              'Add a Meal',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Type to search for recipes... (enter to add custom)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                ref.read(favoriteSuggestionsProvider.notifier).search(value);
              },
              onSubmitted: (value) {
                if (value.trim().isEmpty) return;
                _onConfirmMeal(value.trim(), userId);
              },
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Suggestions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Flexible(
            child: suggestionsAsync.when(
              data: (suggestions) {
                if (suggestions.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Start typing above to add a custom recipe.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: suggestions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    return _RecipeItem(
                      title: suggestion,
                      onAddToCalendar: () => _onConfirmMeal(suggestion, userId),
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error: $error'),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _onConfirmMeal(String recipeTitle, String? userId) async {
    final trimmed = recipeTitle.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a recipe title'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be signed in to add meals'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final slot = await _selectSlot();
    if (slot == null) return;

    final conflictStrategy = await _resolveConflict(userId, slot);
    if (conflictStrategy == null) return;

    try {
      final mealRepository = ref.read(mealRepositoryProvider);
      await ref.read(favoritesRepositoryProvider).addFavorite(
            userId: userId,
            recipeTitle: trimmed,
          );
      await mealRepository.addMeal(
        userId: userId,
        date: widget.date,
        slot: slot,
        recipeTitle: trimmed,
        conflictStrategy: conflictStrategy,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$trimmed added to calendar'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add meal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<MealSlot?> _selectSlot() async {
    return showModalBottomSheet<MealSlot>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                'Select meal slot',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ...MealSlot.values.map((slot) {
                return ListTile(
                  title: Text(slot.name[0].toUpperCase() + slot.name.substring(1)),
                  onTap: () => Navigator.pop(context, slot),
                );
              }),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<MealConflictStrategy?> _resolveConflict(String userId, MealSlot slot) async {
    final existing = await ref.read(mealRepositoryProvider).findMealByDateSlot(
          userId: userId,
          date: widget.date,
          slot: slot,
        );

    if (existing == null) {
      return MealConflictStrategy.keepBoth;
    }

    if (!mounted) return null;
    return showDialog<MealConflictStrategy>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Conflicting meal'),
          content: Text(
            'There is already a meal planned for this slot: "${existing.recipeTitle}". What would you like to do?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, MealConflictStrategy.keepBoth),
              child: const Text('Keep both'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, MealConflictStrategy.replace),
              child: const Text('Replace'),
            ),
          ],
        );
      },
    );
  }
}

class _RecipeItem extends StatelessWidget {
  final String title;
  final VoidCallback onAddToCalendar;

  const _RecipeItem({
    required this.title,
    required this.onAddToCalendar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: onAddToCalendar,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
