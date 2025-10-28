import 'package:flutter/material.dart';
import '../../models/workspace_recipe.freezed_model.dart';
import '../../models/ingredient.freezed_model.dart';
import '../../models/enums.dart';
import 'workspace_ingredient_field.dart';

class RecipeWorkspaceWidget extends StatelessWidget {
  final WorkspaceRecipe workspace;
  final ValueChanged<WorkspaceRecipe> onChanged;
  final bool readOnly;

  const RecipeWorkspaceWidget({
    super.key,
    required this.workspace,
    required this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = workspace.recipe;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          TextField(
            controller: TextEditingController(text: recipe.title),
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            readOnly: readOnly,
            onChanged: (value) {
              onChanged(workspace.copyWith(
                recipe: recipe.copyWith(title: value),
              ));
            },
          ),
          const SizedBox(height: 16),

          // Image URL
          TextField(
            controller: TextEditingController(text: recipe.imageUrl),
            decoration: const InputDecoration(
              labelText: 'Image URL',
              border: OutlineInputBorder(),
            ),
            readOnly: readOnly,
            onChanged: (value) {
              onChanged(workspace.copyWith(
                recipe: recipe.copyWith(imageUrl: value),
              ));
            },
          ),
          const SizedBox(height: 16),

          // Description
          TextField(
            controller: TextEditingController(text: recipe.description),
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            readOnly: readOnly,
            onChanged: (value) {
              onChanged(workspace.copyWith(
                recipe: recipe.copyWith(description: value),
              ));
            },
          ),
          const SizedBox(height: 16),

          // Notes
          TextField(
            controller: TextEditingController(text: recipe.notes),
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            readOnly: readOnly,
            onChanged: (value) {
              onChanged(workspace.copyWith(
                recipe: recipe.copyWith(notes: value),
              ));
            },
          ),
          const SizedBox(height: 16),

          // Total Time
          TextField(
            controller: TextEditingController(text: recipe.totalTime.toString()),
            decoration: const InputDecoration(
              labelText: 'Total Time (minutes)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            readOnly: readOnly,
            onChanged: (value) {
              final time = double.tryParse(value) ?? 0.0;
              onChanged(workspace.copyWith(
                recipe: recipe.copyWith(totalTime: time),
              ));
            },
          ),
          const SizedBox(height: 24),

          // Ingredients Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ingredients',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (!readOnly)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final newIngredient = const Ingredient(
                      name: '',
                      ucumAmount: 0.0,
                      ucumUnit: UcumUnit.cupUs,
                      metricAmount: 0.0,
                      metricUnit: MetricUnit.g,
                      notes: '',
                    );
                    final updatedIngredients = [
                      ...recipe.ingredients,
                      newIngredient,
                    ];
                    onChanged(workspace.copyWith(
                      recipe: recipe.copyWith(ingredients: updatedIngredients),
                    ));
                  },
                  tooltip: 'Add ingredient',
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...recipe.ingredients.asMap().entries.map((entry) {
            final index = entry.key;
            final ingredient = entry.value;
            return WorkspaceIngredientField(
              key: ValueKey('ingredient-$index'),
              ingredient: ingredient,
              readOnly: readOnly,
              onChanged: (updated) {
                final updatedIngredients = [...recipe.ingredients];
                updatedIngredients[index] = updated;
                onChanged(workspace.copyWith(
                  recipe: recipe.copyWith(ingredients: updatedIngredients),
                ));
              },
              onRemove: () {
                final updatedIngredients = [...recipe.ingredients];
                updatedIngredients.removeAt(index);
                onChanged(workspace.copyWith(
                  recipe: recipe.copyWith(ingredients: updatedIngredients),
                ));
              },
            );
          }),
          const SizedBox(height: 24),

          // Steps Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Steps',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (!readOnly)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final updatedSteps = [...recipe.steps, ''];
                    onChanged(workspace.copyWith(
                      recipe: recipe.copyWith(steps: updatedSteps),
                    ));
                  },
                  tooltip: 'Add step',
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...recipe.steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('${index + 1}.'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: step),
                        decoration: const InputDecoration(
                          hintText: 'Step description',
                          border: InputBorder.none,
                        ),
                        readOnly: readOnly,
                        maxLines: null,
                        onChanged: (value) {
                          final updatedSteps = [...recipe.steps];
                          updatedSteps[index] = value;
                          onChanged(workspace.copyWith(
                            recipe: recipe.copyWith(steps: updatedSteps),
                          ));
                        },
                      ),
                    ),
                    if (!readOnly)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          final updatedSteps = [...recipe.steps];
                          updatedSteps.removeAt(index);
                          onChanged(workspace.copyWith(
                            recipe: recipe.copyWith(steps: updatedSteps),
                          ));
                        },
                        tooltip: 'Remove step',
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
