import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/recipe.freezed_model.dart';
import '../../providers/meal_providers.dart';
import '../../providers/recipe_providers.dart';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesProvider);

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
              'Add a Recipe',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter recipe title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _onAddRecipe(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Your Recipes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Flexible(
            child: recipesAsync.when(
              data: (recipes) {
                if (recipes.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No recipes yet. Add one above!',
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
                  itemCount: recipes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return _RecipeItem(
                      title: recipe.title,
                      onAddToCalendar: () => _onAddToCalendar(recipe.title),
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

  Future<void> _onAddRecipe() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a recipe title'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final recipeRepository = ref.read(recipeRepositoryProvider);
    final templateRepository = ref.read(mealTemplateRepositoryProvider);

    try {
      final recipeId = 'recipe_${DateTime.now().millisecondsSinceEpoch}';
      await recipeRepository.save(
        _createRecipe(recipeId, title),
      );

      templateRepository.addDynamicTemplate(title);

      _titleController.clear();

      if (mounted) {
        ref.invalidate(recipesProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recipe "$title" added'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add recipe: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _onAddToCalendar(String recipeTitle) async {
    final templateRepository = ref.read(mealTemplateRepositoryProvider);
    final mealRepository = ref.read(mealRepositoryProvider);

    try {
      final template = templateRepository
          .getAllTemplates()
          .firstWhere((t) => t.title == recipeTitle);

      await mealRepository.addMeal(widget.date, template.templateId);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$recipeTitle added to calendar'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to calendar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Recipe _createRecipe(String id, String title) {
    return Recipe(
      id: id,
      title: title,
      imageUrl: '',
      description: '',
      notes: '',
      preReqs: [],
      totalTime: 30,
      ingredients: [],
      steps: [],
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
