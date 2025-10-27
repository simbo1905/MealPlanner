import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/recipe.freezed_model.dart';
import '../models/search_models.freezed_model.dart';

part 'recipe_providers.g.dart';

// Stream of all recipes from Firestore
@riverpod
Stream<List<Recipe>> recipes(Ref ref) {
  return FirebaseFirestore.instance
      .collection('recipes')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => Recipe.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  });
}

// Get single recipe by ID
@riverpod
Future<Recipe?> recipe(Ref ref, String recipeId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('recipes')
        .doc(recipeId)
        .get();
    if (!doc.exists) return null;
    return Recipe.fromJson({...doc.data()!, 'id': doc.id});
  } catch (e) {
    return null;
  }
}

// Notifier for save/delete operations
@riverpod
class RecipeSaveNotifier extends _$RecipeSaveNotifier {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<String> save(Recipe recipe) async {
    String savedId = '';
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (recipe.id.isEmpty) {
        // Create new
        final ref = FirebaseFirestore.instance.collection('recipes').doc();
        await ref.set(recipe.copyWith(id: ref.id).toJson());
        savedId = ref.id;
      } else {
        // Update existing
        await FirebaseFirestore.instance
            .collection('recipes')
            .doc(recipe.id)
            .set(recipe.toJson());
        savedId = recipe.id;
      }
    });
    return savedId.isEmpty ? recipe.id : savedId;
  }

  Future<void> delete(String recipeId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(recipeId)
          .delete();
    });
  }
}

// Search provider
@riverpod
class RecipeSearchNotifier extends _$RecipeSearchNotifier {
  @override
  FutureOr<List<SearchResult>> build() async {
    return [];
  }

  Future<void> search(SearchOptions options) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final allRecipesAsync = ref.watch(recipesProvider);
      
      allRecipesAsync.when(
        data: (recipes) {
          var results = recipes;

          // Filter by max time
          if (options.maxTime != null) {
            results = results
                .where((r) => r.totalTime <= options.maxTime!)
                .toList();
          }

          // Filter by excluded allergens
          if (options.excludeAllergens != null &&
              options.excludeAllergens!.isNotEmpty) {
            results = results.where((recipe) {
              return !recipe.ingredients.any((ing) =>
                  ing.allergenCode != null &&
                  options.excludeAllergens!
                      .contains(ing.allergenCode!.name));
            }).toList();
          }

          // Text search
          List<SearchResult> searchResults = [];
          if (options.query != null && options.query!.isNotEmpty) {
            final queryLower = options.query!.toLowerCase();
            for (var recipe in results) {
              final matchedFields = <String>[];
              var score = 0.0;

              if (recipe.title.toLowerCase().contains(queryLower)) {
                matchedFields.add('title');
                score += 2.0;
              }
              if (recipe.description.toLowerCase().contains(queryLower)) {
                matchedFields.add('description');
                score += 1.0;
              }
              for (var ing in recipe.ingredients) {
                if (ing.name.toLowerCase().contains(queryLower)) {
                  matchedFields.add('ingredient: ${ing.name}');
                  score += 1.5;
                  break;
                }
              }

              if (matchedFields.isNotEmpty) {
                searchResults.add(SearchResult(
                  recipe: recipe,
                  score: score,
                  matchedFields: matchedFields,
                ));
              }
            }
          } else {
            // No query: return all
            for (var recipe in results) {
              searchResults.add(SearchResult(
                recipe: recipe,
                score: 0.0,
                matchedFields: [],
              ));
            }
          }

          // Filter by ingredients (tags)
          if (options.ingredients != null && options.ingredients!.isNotEmpty) {
            searchResults = searchResults.where((result) {
              return options.ingredients!.every((ingredientName) =>
                  result.recipe.ingredients
                      .any((ing) => ing.name.toLowerCase() ==
                          ingredientName.toLowerCase()));
            }).toList();
          }

          // Sort
          if (options.sortBy == SearchSortBy.title) {
            searchResults.sort((a, b) =>
                a.recipe.title.compareTo(b.recipe.title));
          } else if (options.sortBy == SearchSortBy.totalTime) {
            searchResults
                .sort((a, b) => a.recipe.totalTime.compareTo(b.recipe.totalTime));
          } else {
            // Default: relevance (descending)
            searchResults.sort((a, b) => b.score.compareTo(a.score));
          }

          // Limit
          if (options.limit != null) {
            searchResults = searchResults.take(options.limit!).toList();
          }

          state = AsyncValue.data(searchResults);
        },
        loading: () => state = const AsyncValue.data([]),
        error: (err, st) => state = const AsyncValue.data([]),
      );
    });
  }
}
