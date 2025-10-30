import 'package:flutter/material.dart';
import 'package:meal_planner/models/shopping_list.freezed_model.dart';

/// Widget that displays a single shopping list item with a checkbox,
/// item details, and optional delete button.
class ShoppingListItem extends StatelessWidget {
  final ShoppingItem item;
  final bool isChecked;
  final ValueChanged<bool> onCheckChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onShowAlternatives;

  const ShoppingListItem({
    super.key,
    required this.item,
    required this.isChecked,
    required this.onCheckChanged,
    this.onDelete,
    this.onShowAlternatives,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: isChecked,
        onChanged: (value) {
          if (value != null) {
            onCheckChanged(value);
          }
        },
      ),
      title: Text(
        item.name,
        style: TextStyle(
          decoration: isChecked ? TextDecoration.lineThrough : null,
          color: isChecked ? Colors.grey : null,
        ),
      ),
      subtitle: Row(
        children: [
          Text('${item.quantity} ${item.unit}'),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Section: ${item.section}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
      trailing: onDelete != null
          ? IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            )
          : null,
    );
  }
}
