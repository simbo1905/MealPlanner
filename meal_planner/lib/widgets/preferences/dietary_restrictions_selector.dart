import 'package:flutter/material.dart';

/// Widget for selecting dietary restrictions using filter chips
class DietaryRestrictionsSelector extends StatelessWidget {
  final List<String> selectedRestrictions;
  final ValueChanged<List<String>> onChanged;
  final List<String> availableRestrictions;

  const DietaryRestrictionsSelector({
    required this.selectedRestrictions,
    required this.onChanged,
    this.availableRestrictions = const [
      'vegetarian',
      'vegan',
      'gluten-free',
      'dairy-free',
      'nut-free',
      'shellfish-free',
      'soy-free',
      'egg-free',
    ],
    super.key,
  });

  void _toggleRestriction(String restriction) {
    final updated = List<String>.from(selectedRestrictions);
    if (updated.contains(restriction)) {
      updated.remove(restriction);
    } else {
      updated.add(restriction);
    }
    onChanged(updated);
  }

  void _selectAll() {
    onChanged(List<String>.from(availableRestrictions));
  }

  void _clearAll() {
    onChanged([]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dietary Restrictions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              children: [
                TextButton(
                  onPressed: _selectAll,
                  child: const Text('Select All'),
                ),
                TextButton(
                  onPressed: _clearAll,
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: availableRestrictions.map((restriction) {
            final isSelected = selectedRestrictions.contains(restriction);
            return FilterChip(
              label: Text(restriction),
              selected: isSelected,
              onSelected: (_) => _toggleRestriction(restriction),
            );
          }).toList(),
        ),
      ],
    );
  }
}
