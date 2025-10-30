import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/favorites_repository.dart';
import 'auth_providers.dart';
import 'recipe_providers.dart';

part 'favorites_providers.g.dart';

@riverpod
FavoritesRepository favoritesRepository(FavoritesRepositoryRef ref) {
  return FavoritesRepository();
}

@riverpod
Stream<List<String>> favoriteRecipes(FavoriteRecipesRef ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return const Stream.empty();
  }
  return ref.watch(favoritesRepositoryProvider).watchFavorites(userId);
}

@riverpod
class FavoriteSuggestions extends _$FavoriteSuggestions {
  Timer? _debounce;

  @override
  FutureOr<List<String>> build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });
    return [];
  }

  Future<void> search(String query) async {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      state = const AsyncValue.data([]);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final favorites = await ref.read(favoriteRecipesProvider.future);
        final recipes = await ref.read(recipesProvider.future);
        final lower = query.trim().toLowerCase();

        final favoriteMatches = favorites
            .where((title) => title.toLowerCase().contains(lower))
            .toList();

        final recipeMatches = recipes
            .map((r) => r.title)
            .where((title) => title.toLowerCase().contains(lower))
            .toList();

        final combined = <String>{};
        final results = <String>[];

        for (final title in favoriteMatches) {
          if (combined.add(title)) {
            results.add(title);
          }
        }
        for (final title in recipeMatches) {
          if (combined.add(title)) {
            results.add(title);
          }
        }

        state = AsyncValue.data(results.take(10).toList());
      } catch (e, stack) {
        state = AsyncValue.error(e, stack);
      }
    });
  }

  void clear() {
    _debounce?.cancel();
    state = const AsyncValue.data([]);
  }
}