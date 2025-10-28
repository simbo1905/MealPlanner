import 'package:flutter/material.dart';
import 'package:meal_planner/models/shopping_list.freezed_model.dart';
import 'package:meal_planner/widgets/shopping/cost_summary.dart';
import 'package:meal_planner/widgets/shopping/shopping_list_section.dart';

/// Screen that displays a shopping list with items grouped by section.
/// Allows checking off items, deleting items, and managing the list.
class ShoppingListScreen extends StatefulWidget {
  final String listId;
  final dynamic repository; // FakeShoppingListRepository in tests

  const ShoppingListScreen({
    super.key,
    required this.listId,
    required this.repository,
  });

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  ShoppingList? _shoppingList;
  final Set<String> _checkedItems = {};
  final Map<String, bool> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    _loadShoppingList();
  }

  Future<void> _loadShoppingList() async {
    final list = await widget.repository.getShoppingList(widget.listId);
    if (mounted) {
      setState(() {
        _shoppingList = list;
        // Initialize all sections as expanded
        if (list != null) {
          for (var item in list.items) {
            _expandedSections[item.section] = true;
          }
        }
      });
    }
  }

  Map<String, List<ShoppingItem>> _groupItemsBySection() {
    if (_shoppingList == null) return {};
    
    final Map<String, List<ShoppingItem>> grouped = {};
    for (var item in _shoppingList!.items) {
      grouped.putIfAbsent(item.section, () => []);
      grouped[item.section]!.add(item);
    }
    return grouped;
  }

  void _toggleItemCheck(String itemName, bool isChecked) {
    setState(() {
      if (isChecked) {
        _checkedItems.add(itemName);
      } else {
        _checkedItems.remove(itemName);
      }
    });
  }

  void _deleteItem(String itemName) {
    if (_shoppingList == null) return;
    
    setState(() {
      final updatedItems = _shoppingList!.items
          .where((item) => item.name != itemName)
          .toList();
      _shoppingList = _shoppingList!.copyWith(items: updatedItems);
      _checkedItems.remove(itemName);
    });
    
    // Save to repository
    widget.repository.save(_shoppingList!);
  }

  void _clearCompleted() {
    if (_shoppingList == null) return;
    
    setState(() {
      final updatedItems = _shoppingList!.items
          .where((item) => !_checkedItems.contains(item.name))
          .toList();
      _shoppingList = _shoppingList!.copyWith(items: updatedItems);
      _checkedItems.clear();
    });
    
    // Save to repository
    widget.repository.save(_shoppingList!);
  }

  Future<void> _deleteList() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List'),
        content: const Text('Are you sure you want to delete this shopping list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await widget.repository.delete(widget.listId);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_shoppingList == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_shoppingList!.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Shopping List'),
        ),
        body: const Center(
          child: Text('No items in list'),
        ),
      );
    }

    final groupedItems = _groupItemsBySection();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _deleteList,
            tooltip: 'Delete List',
          ),
        ],
      ),
      body: Column(
        children: [
          CostSummary(
            totalEstimatedCost: _shoppingList!.totalEstimatedCost,
            itemCount: _shoppingList!.items.length,
            checkedCount: _checkedItems.length,
          ),
          Expanded(
            child: ListView(
              children: groupedItems.entries.map((entry) {
                final section = entry.key;
                final items = entry.value;
                final isExpanded = _expandedSections[section] ?? true;
                
                return ShoppingListSection(
                  section: section,
                  items: items,
                  isExpanded: isExpanded,
                  onExpandChanged: (value) {
                    setState(() {
                      _expandedSections[section] = value;
                    });
                  },
                  onItemCheckChanged: _toggleItemCheck,
                  onItemDelete: _deleteItem,
                  checkedItems: _checkedItems,
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _checkedItems.isEmpty ? null : _clearCompleted,
              child: const Text('Clear Completed'),
            ),
          ),
        ],
      ),
    );
  }
}
