import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesRepository {
  FavoritesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('favorites');
  }

  Stream<List<String>> watchFavorites(String userId) {
    return _collection(userId)
        .orderBy('addedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => (doc.data()['recipeTitle'] as String).trim())
            .where((title) => title.isNotEmpty)
            .toList());
  }

  Future<void> addFavorite({required String userId, required String recipeTitle}) async {
    final trimmed = recipeTitle.trim();
    if (trimmed.isEmpty) return;

    final collection = _collection(userId);
    final existing = await collection
        .where('recipeTitle', isEqualTo: trimmed)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update({'addedAt': DateTime.now()});
      return;
    }

    await collection.add({
      'recipeTitle': trimmed,
      'addedAt': DateTime.now(),
    });
  }
}