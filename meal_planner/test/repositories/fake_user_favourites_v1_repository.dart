import 'package:meal_planner/repositories/user_favourites_v1_repository.dart';

/// Fake implementation of UserFavouritesV1Repository for testing
class FakeUserFavouritesV1Repository implements UserFavouritesV1Repository {
  final Map<String, Set<String>> _userFavouriteIds = {};

  @override
  Stream<List<String>> watchFavouriteIds(String userId) {
    if (!_userFavouriteIds.containsKey(userId)) {
      _userFavouriteIds[userId] = {};
    }

    return Stream.value(_userFavouriteIds[userId]!.toList());
  }

  @override
  Future<void> addFavourite(String userId, String recipeId, String title) async {
    if (!_userFavouriteIds.containsKey(userId)) {
      _userFavouriteIds[userId] = {};
    }

    _userFavouriteIds[userId]!.add(recipeId);
  }

  @override
  Future<void> removeFavourite(String userId, String recipeId) async {
    if (_userFavouriteIds.containsKey(userId)) {
      _userFavouriteIds[userId]!.remove(recipeId);
    }
  }

  @override
  Future<bool> isFavourite(String userId, String recipeId) async {
    if (!_userFavouriteIds.containsKey(userId)) {
      return false;
    }

    return _userFavouriteIds[userId]!.contains(recipeId);
  }

  /// Clear all data (useful for testing)
  void clear() {
    _userFavouriteIds.clear();
  }
}
