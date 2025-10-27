import 'package:freezed_annotation/freezed_annotation.dart';

part 'shopping_list.freezed_model.freezed.dart';
part 'shopping_list.freezed_model.g.dart';

@freezed
class ShoppingItem with _$ShoppingItem {
  const factory ShoppingItem({
    required String name,
    required double quantity,
    required String unit,
    required String section,
    @Default([]) List<String> alternatives,
  }) = _ShoppingItem;

  factory ShoppingItem.fromJson(Map<String, dynamic> json) =>
      _$ShoppingItemFromJson(json);
}

@freezed
class ShoppingList with _$ShoppingList {
  const factory ShoppingList({
    required String id,
    required List<ShoppingItem> items,
    required double totalEstimatedCost,
    required DateTime createdAt,
  }) = _ShoppingList;

  factory ShoppingList.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListFromJson(json);
}
