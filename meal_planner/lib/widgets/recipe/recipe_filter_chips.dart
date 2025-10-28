import 'package:flutter/material.dart';

/// RecipeFilterChips provides filter controls for allergens, max cook time, and ingredients.
class RecipeFilterChips extends StatelessWidget {
  final Function(List<String> allergens) onAllergenChanged;
  final Function(int? maxMinutes) onMaxTimeChanged;
  final Function(List<String> ingredients) onIngredientsChanged;
  final List<String> selectedAllergens;
  final int? selectedMaxTime;
  final List<String> selectedIngredients;

  const RecipeFilterChips({
    super.key,
    required this.onAllergenChanged,
    required this.onMaxTimeChanged,
    required this.onIngredientsChanged,
    required this.selectedAllergens,
    this.selectedMaxTime,
    required this.selectedIngredients,
  });

  static const List<String> commonAllergens = [
    'GLUTEN',
    'PEANUT',
    'MILK',
    'EGG',
    'FISH',
    'SHELLFISH',
    'SOY',
    'NUT',
  ];

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = selectedAllergens.isNotEmpty ||
        selectedMaxTime != null ||
        selectedIngredients.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with reset button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (hasActiveFilters)
              TextButton.icon(
                onPressed: () {
                  onAllergenChanged([]);
                  onMaxTimeChanged(null);
                  onIngredientsChanged([]);
                },
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Reset'),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Allergen exclusion chips
        Text(
          'Exclude Allergens',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: commonAllergens
                .map((allergen) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(allergen),
                        selected: selectedAllergens.contains(allergen),
                        onSelected: (selected) {
                          final updated = List<String>.from(selectedAllergens);
                          if (selected) {
                            updated.add(allergen);
                          } else {
                            updated.remove(allergen);
                          }
                          onAllergenChanged(updated);
                        },
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Max cook time slider
        Text(
          'Max Cook Time: ${selectedMaxTime != null ? "${selectedMaxTime} min" : "Any"}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Slider(
          value: (selectedMaxTime ?? 120).toDouble(),
          min: 0,
          max: 120,
          divisions: 12,
          label: selectedMaxTime != null ? '${selectedMaxTime} min' : 'Any',
          onChanged: (value) {
            final intValue = value.toInt();
            onMaxTimeChanged(intValue == 0 ? null : intValue);
          },
        ),
      ],
    );
  }
}
