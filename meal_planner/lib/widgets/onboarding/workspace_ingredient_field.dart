import 'package:flutter/material.dart';
import '../../models/ingredient.freezed_model.dart';
import '../../models/enums.dart';

class WorkspaceIngredientField extends StatelessWidget {
  final Ingredient ingredient;
  final ValueChanged<Ingredient> onChanged;
  final VoidCallback onRemove;
  final bool readOnly;

  const WorkspaceIngredientField({
    super.key,
    required this.ingredient,
    required this.onChanged,
    required this.onRemove,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: ingredient.name),
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      isDense: true,
                    ),
                    readOnly: readOnly,
                    onChanged: (value) {
                      onChanged(ingredient.copyWith(name: value));
                    },
                  ),
                ),
                if (!readOnly)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onRemove,
                    tooltip: 'Remove ingredient',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                        text: ingredient.ucumAmount.toString()),
                    decoration: const InputDecoration(
                      labelText: 'UCUM Amount',
                      isDense: true,
                    ),
                    readOnly: readOnly,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final amount = double.tryParse(value) ?? 0.0;
                      onChanged(ingredient.copyWith(ucumAmount: amount));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<UcumUnit>(
                    initialValue: ingredient.ucumUnit,
                    decoration: const InputDecoration(
                      labelText: 'UCUM Unit',
                      isDense: true,
                    ),
                    isExpanded: true,
                    items: UcumUnit.values
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(_ucumLabel(unit)),
                            ))
                        .toList(),
                    onChanged: readOnly
                        ? null
                        : (value) {
                            if (value != null) {
                              onChanged(ingredient.copyWith(ucumUnit: value));
                            }
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                        text: ingredient.metricAmount.toString()),
                    decoration: const InputDecoration(
                      labelText: 'Metric Amount',
                      isDense: true,
                    ),
                    readOnly: readOnly,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final amount = double.tryParse(value) ?? 0.0;
                      onChanged(ingredient.copyWith(metricAmount: amount));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<MetricUnit>(
                    initialValue: ingredient.metricUnit,
                    decoration: const InputDecoration(
                      labelText: 'Metric Unit',
                      isDense: true,
                    ),
                    isExpanded: true,
                    items: MetricUnit.values
                        .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit.name),
                            ))
                        .toList(),
                    onChanged: readOnly
                        ? null
                        : (value) {
                            if (value != null) {
                              onChanged(ingredient.copyWith(metricUnit: value));
                            }
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: ingredient.notes),
              decoration: const InputDecoration(
                labelText: 'Notes',
                isDense: true,
              ),
              readOnly: readOnly,
              onChanged: (value) {
                onChanged(ingredient.copyWith(notes: value));
              },
            ),
          ],
        ),
      ),
    );
  }
}

String _ucumLabel(UcumUnit unit) {
  switch (unit) {
    case UcumUnit.cupUs:
      return 'cup_us';
    case UcumUnit.cupM:
      return 'cup_m';
    case UcumUnit.cupImp:
      return 'cup_imp';
    case UcumUnit.tbspUs:
      return 'tbsp_us';
    case UcumUnit.tbspM:
      return 'tbsp_m';
    case UcumUnit.tbspImp:
      return 'tbsp_imp';
    case UcumUnit.tspUs:
      return 'tsp_us';
    case UcumUnit.tspM:
      return 'tsp_m';
    case UcumUnit.tspImp:
      return 'tsp_imp';
  }
}
