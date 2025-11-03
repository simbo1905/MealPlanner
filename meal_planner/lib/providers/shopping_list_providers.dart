import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/shopping_list.freezed_model.dart';
import 'recipe_providers.dart';

part 'shopping_list_providers.g.dart';

// Generate shopping list from meal assignments
@riverpod
Future<ShoppingList> generateShoppingList(
  Ref ref,
  List<String> assignmentIds,
) async {
  final allRecipes = ref.watch(recipesProvider);

  return allRecipes.when(
    data: (recipes) {
      // Aggregate all ingredients from selected recipes
      final ingredientMap = <String, ShoppingItem>{};

      // This is simplified - in production, you'd fetch the specific assignments
      // For now, just group ingredients by name and section
      for (var recipe in recipes) {
        for (var ingredient in recipe.ingredients) {
          final key = ingredient.name.toLowerCase();
          if (ingredientMap.containsKey(key)) {
            final existing = ingredientMap[key]!;
            ingredientMap[key] = existing.copyWith(
              quantity: existing.quantity + ingredient.metricAmount,
            );
          } else {
            ingredientMap[key] = ShoppingItem(
              name: ingredient.name,
              quantity: ingredient.metricAmount,
              unit: ingredient.metricUnit.name,
              section: 'General', // Default section
              alternatives: [],
            );
          }
        }
      }

      // Calculate total cost (mock: $2 per item average)
      final totalCost = ingredientMap.length * 2.0;

      return ShoppingList(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        items: ingredientMap.values.toList(),
        totalEstimatedCost: totalCost,
        createdAt: DateTime.now(),
      );
    },
    loading: () => ShoppingList(
      id: '',
      items: [],
      totalEstimatedCost: 0,
      createdAt: DateTime.now(),
    ),
    error: (_, _) => ShoppingList(
      id: '',
      items: [],
      totalEstimatedCost: 0,
      createdAt: DateTime.now(),
    ),
  );
}

// Notifier for shopping list operations
@riverpod
class ShoppingListNotifier extends _$ShoppingListNotifier {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<String> save(ShoppingList shoppingList) async {
    String savedId = '';
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await FirebaseFirestore.instance
          .collection('shopping_lists')
          .doc(shoppingList.id)
          .set(shoppingList.toJson());
      savedId = shoppingList.id;
    });
    return savedId;
  }

  Future<void> updateItemQuantity(String itemName, double quantity) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Implementation would fetch and update specific item
    });
  }
}
