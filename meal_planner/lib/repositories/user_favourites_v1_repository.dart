import 'package:cloud_firestore/cloud_firestore.dart';

/// Interface for accessing user's favorite recipes
abstract class UserFavouritesV1Repository {
  /// Watch user's favorite recipe IDs (real-time updates)
  /// Returns only recipe IDs; the UI layer should fetch full Recipe objects
  Stream<List<String>> watchFavouriteIds(String userId);

  /// Add recipe to user's favorites
  /// [title] is denormalized from recipes_v1 for display purposes only
  Future<void> addFavourite(String userId, String recipeId, String title);

  /// Remove recipe from user's favorites
  Future<void> removeFavourite(String userId, String recipeId);

  /// Check if recipe is in user's favorites
  Future<bool> isFavourite(String userId, String recipeId);
}

/// Firebase implementation of UserFavouritesV1Repository
class FirebaseUserFavouritesV1Repository implements UserFavouritesV1Repository {
  final FirebaseFirestore _firestore;

  FirebaseUserFavouritesV1Repository(this._firestore);

  @override
  Stream<List<String>> watchFavouriteIds(String userId) {
    return _firestore
        .collection('user_favourites_v1/$userId/recipes')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  return doc['recipeId'] as String;
                } catch (e) {
                  print('Error extracting recipeId: $e');
                  return null;
                }
              })
              .whereType<String>()
              .toList();
        })
        .handleError((e) {
          print('Error watching favorite IDs: $e');
          return <String>[];
        });
  }

  @override
  Future<void> addFavourite(String userId, String recipeId, String title) async {
    try {
      await _firestore
          .collection('user_favourites_v1/$userId/recipes')
          .doc(recipeId)
          .set({
            'recipeId': recipeId,
            'title': title,
            'addedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error adding favorite: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeFavourite(String userId, String recipeId) async {
    try {
      await _firestore
          .collection('user_favourites_v1/$userId/recipes')
          .doc(recipeId)
          .delete();
    } catch (e) {
      print('Error removing favorite: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isFavourite(String userId, String recipeId) async {
    try {
      final doc = await _firestore
          .collection('user_favourites_v1/$userId/recipes')
          .doc(recipeId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }
}
