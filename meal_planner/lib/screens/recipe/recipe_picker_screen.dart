import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/recipe.freezed_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_favourites_v1_provider.dart';
import '../../widgets/recipe/recipe_search_autocomplete.dart';

class RecipePickerScreen extends ConsumerWidget {
  final void Function(Recipe)? onRecipeSelected;

  const RecipePickerScreen({
    super.key,
    this.onRecipeSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);

    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final favoriteIdsAsync = ref.watch(userFavouriteIdsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Recipe'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: RecipeSearchAutocomplete(
              onRecipeSelected: (recipe) => _handleSelection(
                context,
                ref,
                userId,
                recipe,
                favoriteIdsAsync,
              ),
            ),
          ),
          Expanded(
            child: favoriteIdsAsync.when(
              data: (favoriteIds) {
                if (favoriteIds.isEmpty) {
                  return const Center(
                    child: Text('Search above to find recipes'),
                  );
                }
                return ListView.builder(
                  itemCount: favoriteIds.length,
                  itemBuilder: (context, index) {
                    final recipeId = favoriteIds[index];
                    return ListTile(
                      title: Text(recipeId),
                      onTap: () {
                        final recipe = Recipe(
                          id: recipeId,
                          title: recipeId,
                          imageUrl: '',
                          description: '',
                          notes: '',
                          preReqs: [],
                          totalTime: 0.0,
                          ingredients: [],
                          steps: [],
                        );
                        _handleSelection(
                          context,
                          ref,
                          userId,
                          recipe,
                          favoriteIdsAsync,
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSelection(
    BuildContext context,
    WidgetRef ref,
    String userId,
    Recipe recipe,
    AsyncValue<List<String>> favoriteIdsAsync,
  ) {
    final currentFavoriteIds = favoriteIdsAsync.maybeWhen(
      data: (ids) => ids,
      orElse: () => <String>[],
    );

    if (!currentFavoriteIds.contains(recipe.id)) {
      ref.read(addUserFavouriteV1NotifierProvider.notifier).addFavourite(
            userId,
            recipe.id,
            recipe.title,
          );
    }

    onRecipeSelected?.call(recipe);
  }
}
