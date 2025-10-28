import 'package:flutter/material.dart';
import 'package:meal_planner/models/shopping_list.freezed_model.dart';
import 'package:meal_planner/widgets/shopping/shopping_list_item.dart';

/// Widget that displays a collapsible section of shopping list items.
/// Groups items by section (e.g., Produce, Dairy, Meat).
class ShoppingListSection extends StatelessWidget {
  final String section;
  final List<ShoppingItem> items;
  final bool isExpanded;
  final ValueChanged<bool> onExpandChanged;
  final void Function(String itemName, bool isChecked) onItemCheckChanged;
  final void Function(String itemName) onItemDelete;
  final Set<String> checkedItems;

  const ShoppingListSection({
    super.key,
    required this.section,
    required this.items,
    required this.isExpanded,
    required this.onExpandChanged,
    required this.onItemCheckChanged,
    required this.onItemDelete,
    required this.checkedItems,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        section,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Text(
        '(${items.length})',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      initiallyExpanded: isExpanded,
      onExpansionChanged: onExpandChanged,
      children: items.map((item) {
        final isChecked = checkedItems.contains(item.name);
        return ShoppingListItem(
          item: item,
          isChecked: isChecked,
          onCheckChanged: (value) {
            onItemCheckChanged(item.name, value);
          },
          onDelete: () {
            onItemDelete(item.name);
          },
        );
      }).toList(),
    );
  }
}
