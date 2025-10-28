import 'dart:async';
import 'package:meal_planner/models/shopping_list.freezed_model.dart';
import 'package:meal_planner/repositories/shopping_list_repository.dart';

/// In-memory fake repository for shopping lists used in widget tests.
/// Implements the same interface as the production Firestore repository.
class FakeShoppingListRepository implements ShoppingListRepository {
  final Map<String, ShoppingList> _lists = {};

  /// Pre-seed a shopping list for testing
  void seed(String listId, ShoppingList list) {
    _lists[listId] = list;
  }

  /// Clear all shopping lists
  void clear() {
    _lists.clear();
  }

  /// Get a shopping list by ID
  Future<ShoppingList?> getShoppingList(String listId) async {
    return _lists[listId];
  }

  /// Save or update a shopping list
  @override
  Future<String> save(ShoppingList list) async {
    _lists[list.id] = list;
    return list.id;
  }

  /// Delete a shopping list
  Future<void> delete(String listId) async {
    _lists.remove(listId);
  }

  /// Get all shopping lists (for testing purposes)
  Future<List<ShoppingList>> getAllLists() async {
    return _lists.values.toList();
  }
}
