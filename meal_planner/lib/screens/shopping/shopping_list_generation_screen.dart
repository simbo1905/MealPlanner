import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/models/meal_assignment.freezed_model.dart';
import 'package:meal_planner/models/recipe.freezed_model.dart';
import 'package:meal_planner/models/shopping_list.freezed_model.dart';
import 'package:meal_planner/repositories/meal_assignment_repository.dart';
import 'package:meal_planner/providers/recipe_providers.dart';
import 'package:meal_planner/repositories/shopping_list_repository.dart';

/// Screen for selecting meal assignments and generating a shopping list.
/// Aggregates ingredients from selected recipes and groups by section.
class ShoppingListGenerationScreen extends ConsumerStatefulWidget {
  final MealAssignmentRepository assignmentRepository;
  final ShoppingListRepository shoppingListRepository;
  final DateTime? initialStartDate;

  const ShoppingListGenerationScreen({
    super.key,
    required this.assignmentRepository,
    required this.shoppingListRepository,
    this.initialStartDate,
  });

  @override
  ConsumerState<ShoppingListGenerationScreen> createState() =>
      _ShoppingListGenerationScreenState();
}

class _ShoppingListGenerationScreenState
    extends ConsumerState<ShoppingListGenerationScreen> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  List<MealAssignment> _assignments = [];
  final Set<String> _selectedAssignmentIds = {};
  ShoppingList? _generatedList;
  bool _isLoading = false;
  final Map<String, Recipe> _recipeCache = {};
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    if (widget.initialStartDate != null) {
      _startDate = widget.initialStartDate!;
      _endDate = _startDate.add(const Duration(days: 7));
    }
    Future.microtask(() => _loadAssignments());
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _loadAssignments() async {
    if (!_isMounted) return;
    setState(() {
      _isLoading = true;
    });

    // Load assignments for the date range
    final allAssignments = widget.assignmentRepository.getAllAssignments();
    final filteredAssignments = allAssignments.where((assignment) {
      final date = DateTime.parse(assignment.dayIsoDate);
      return date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();

    // Load recipes for these assignments
    final recipeRepository = ref.read(recipeRepositoryProvider);
    for (var assignment in filteredAssignments) {
      final recipe = await recipeRepository.getRecipe(assignment.recipeId);
      if (recipe != null) {
        _recipeCache[assignment.recipeId] = recipe;
      }
    }

    if (_isMounted) {
      setState(() {
        _assignments = filteredAssignments;
        _isLoading = false;
      });
    }
  }

  void _toggleAssignmentSelection(String assignmentId) {
    setState(() {
      if (_selectedAssignmentIds.contains(assignmentId)) {
        _selectedAssignmentIds.remove(assignmentId);
      } else {
        _selectedAssignmentIds.add(assignmentId);
      }
    });
  }

  Future<void> _generateList() async {
    if (!_isMounted) return;
    setState(() {
      _isLoading = true;
    });

    // Aggregate ingredients from selected assignments
    final Map<String, ShoppingItem> itemMap = {};

    for (var assignmentId in _selectedAssignmentIds) {
      final assignment = _assignments.firstWhere((a) => a.id == assignmentId);
      final recipe = _recipeCache[assignment.recipeId];

      if (recipe != null) {
        for (var ingredient in recipe.ingredients) {
          final key = ingredient.name.toLowerCase();
          if (itemMap.containsKey(key)) {
            final existing = itemMap[key]!;
            itemMap[key] = existing.copyWith(
              quantity: existing.quantity + ingredient.metricAmount,
            );
          } else {
            itemMap[key] = ShoppingItem(
              name: ingredient.name,
              quantity: ingredient.metricAmount,
              unit: ingredient.metricUnit.name,
              section: 'General', // Default section
              alternatives: const [],
            );
          }
        }
      }
    }

    // Calculate total cost (mock: $2 per item average)
    final totalCost = itemMap.length * 2.0;

    final listId =
        FirebaseFirestore.instance.collection('shopping_lists').doc().id;
    final shoppingList = ShoppingList(
      id: listId,
      items: itemMap.values.toList(),
      totalEstimatedCost: totalCost,
      createdAt: DateTime.now(),
    );

    if (_isMounted) {
      setState(() {
        _generatedList = shoppingList;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveList() async {
    if (_generatedList == null) return;
    if (!_isMounted) return;

    setState(() {
      _isLoading = true;
    });

    await widget.shoppingListRepository.save(_generatedList!);

    if (_isMounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shopping list saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Shopping List'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Date Range',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_startDate.toIso8601String().split('T')[0]} to ${_endDate.toIso8601String().split('T')[0]}',
                      ),
                    ],
                  ),
                ),
                if (_selectedAssignmentIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${_selectedAssignmentIds.length} selected',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                Expanded(
                  child: _generatedList == null
                      ? _buildAssignmentList()
                      : _buildPreview(),
                ),
                if (_generatedList == null && _selectedAssignmentIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: _generateList,
                      child: const Text('Generate List'),
                    ),
                  ),
                if (_generatedList != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: _saveList,
                      child: const Text('Save'),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildAssignmentList() {
    if (_assignments.isEmpty) {
      return const Center(
        child: Text('No meal assignments in selected range'),
      );
    }

    return ListView.builder(
      itemCount: _assignments.length,
      itemBuilder: (context, index) {
        final assignment = _assignments[index];
        final recipe = _recipeCache[assignment.recipeId];
        final isSelected = _selectedAssignmentIds.contains(assignment.id);

        return CheckboxListTile(
          title: Text(recipe?.title ?? 'Unknown Recipe'),
          subtitle: Text(assignment.dayIsoDate),
          value: isSelected,
          onChanged: (_) {
            _toggleAssignmentSelection(assignment.id);
          },
        );
      },
    );
  }

  Widget _buildPreview() {
    if (_generatedList == null) return const SizedBox.shrink();

    // Group items by section
    final Map<String, List<ShoppingItem>> grouped = {};
    for (var item in _generatedList!.items) {
      grouped.putIfAbsent(item.section, () => []);
      grouped[item.section]!.add(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Preview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView(
            children: grouped.entries.map((entry) {
              return ExpansionTile(
                title: Text(entry.key),
                initiallyExpanded: true,
                children: entry.value.map((item) {
                  return ListTile(
                    title: Text(item.name),
                    trailing: Text('${item.quantity} ${item.unit}'),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
