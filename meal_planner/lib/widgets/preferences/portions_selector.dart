import 'package:flutter/material.dart';

/// Widget for selecting number of portions (servings)
/// Uses a slider with plus/minus buttons for fine control
class PortionsSelector extends StatelessWidget {
  final int currentPortions;
  final ValueChanged<int> onChanged;
  final int minPortions;
  final int maxPortions;

  const PortionsSelector({
    required this.currentPortions,
    required this.onChanged,
    this.minPortions = 1,
    this.maxPortions = 12,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: currentPortions > minPortions
                  ? () => onChanged(currentPortions - 1)
                  : null,
            ),
            Expanded(
              child: Slider(
                value: currentPortions.toDouble(),
                min: minPortions.toDouble(),
                max: maxPortions.toDouble(),
                divisions: maxPortions - minPortions,
                label: currentPortions.toString(),
                onChanged: (value) => onChanged(value.toInt()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: currentPortions < maxPortions
                  ? () => onChanged(currentPortions + 1)
                  : null,
            ),
            SizedBox(
              width: 40,
              child: Text(
                currentPortions.toString(),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        Text(
          'Ingredient quantities will scale accordingly',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
