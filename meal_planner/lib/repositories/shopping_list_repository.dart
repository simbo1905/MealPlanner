import 'package:meal_planner/models/shopping_list.freezed_model.dart';

abstract class ShoppingListRepository {
  Future<String> save(ShoppingList list);
}
