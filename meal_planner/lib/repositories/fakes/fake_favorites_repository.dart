import 'dart:async';

import '../favorites_repository.dart';

class FakeFavoritesRepository implements IFavoritesRepository {
  final Map<String, List<String>> _byUser = {};
  final Map<String, StreamController<List<String>>> _controllers = {};

  List<String> _listFor(String userId) => _byUser.putIfAbsent(userId, () => <String>[]);
  StreamController<List<String>> _controllerFor(String userId) =>
      _controllers.putIfAbsent(userId, () => StreamController<List<String>>.broadcast());

  @override
  Stream<List<String>> watchFavorites(String userId) {
    final ctrl = _controllerFor(userId);
    // Emit initial value
    Future.microtask(() => ctrl.add(List.unmodifiable(_listFor(userId))));
    return ctrl.stream;
  }

  @override
  Future<void> addFavorite({required String userId, required String recipeTitle}) async {
    final trimmed = recipeTitle.trim();
    if (trimmed.isEmpty) return;
    final list = _listFor(userId);
    // Move to top if already exists, else insert at start
    list.removeWhere((e) => e.toLowerCase() == trimmed.toLowerCase());
    list.insert(0, trimmed);
    _controllerFor(userId).add(List.unmodifiable(list));
  }
}
