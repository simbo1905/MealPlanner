import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.freezed_model.dart';

/// Interface for accessing recipes from recipes_v1 collection
abstract class RecipesV1Repository {
  /// Search recipes by title prefix (for autocomplete)
  /// Returns up to [limit] recipes ordered by title
  Stream<List<Recipe>> searchByTitlePrefix(String prefix, {int limit = 10});

  /// Search recipes by ingredient name
  /// Returns recipes containing [ingredient] in ingredientNamesNormalized
  Stream<List<Recipe>> searchByIngredient(String ingredient, {int limit = 10});

  /// Get single recipe by ID
  Future<Recipe?> getById(String recipeId);

  /// Get total count of recipes in collection
  Future<int> getTotalCount();
}

/// Firebase implementation of RecipesV1Repository
class FirebaseRecipesV1Repository implements RecipesV1Repository {
  final FirebaseFirestore _firestore;

  FirebaseRecipesV1Repository(this._firestore);

  @override
  Stream<List<Recipe>> searchByTitlePrefix(String prefix, {int limit = 10}) {
    if (prefix.isEmpty) return Stream.value([]);

    final lower = prefix.toLowerCase();
    return _firestore
        .collection('recipes_v1')
        .where('titleLower', isGreaterThanOrEqualTo: lower)
        .where('titleLower', isLessThan: lower + '~')
        .orderBy('titleLower')
        .limit(limit)
        .snapshots()
        .map(_docsToRecipes)
        .handleError((e) {
          print('Error searching recipes by title prefix: $e');
          return <Recipe>[];
        });
  }

  @override
  Stream<List<Recipe>> searchByIngredient(String ingredient,
      {int limit = 10}) {
    if (ingredient.isEmpty) return Stream.value([]);

    return _firestore
        .collection('recipes_v1')
        .where('ingredientNamesNormalized', arrayContains: ingredient.toLowerCase())
        .limit(limit)
        .snapshots()
        .map(_docsToRecipes)
        .handleError((e) {
          print('Error searching recipes by ingredient: $e');
          return <Recipe>[];
        });
  }

  @override
  Future<Recipe?> getById(String recipeId) async {
    try {
      final doc = await _firestore.collection('recipes_v1').doc(recipeId).get();
      return doc.exists ? Recipe.fromJson(doc.data()!) : null;
    } catch (e) {
      print('Error fetching recipe: $e');
      return null;
    }
  }

  @override
  Future<int> getTotalCount() async {
    try {
      final snapshot = await _firestore
          .collection('recipes_v1')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting recipe count: $e');
      return 0;
    }
  }

  List<Recipe> _docsToRecipes(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) {
          try {
            return Recipe.fromJson(doc.data() as Map<String, dynamic>);
          } catch (e) {
            print('Error converting document to Recipe: $e');
            return null;
          }
        })
        .whereType<Recipe>()
        .toList();
  }
}
