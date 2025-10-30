import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.freezed_model.dart';
import '../repositories/recipes_v1_repository.dart';

part 'recipes_v1_provider.g.dart';

@riverpod
RecipesV1Repository recipesV1Repository(RecipesV1RepositoryRef ref) {
  final firestore = FirebaseFirestore.instance;
  return FirebaseRecipesV1Repository(firestore);
}

@riverpod
class RecipeSearchV1Notifier extends _$RecipeSearchV1Notifier {
  @override
  Stream<List<Recipe>> build(String query) async* {
    if (query.isEmpty) {
      yield [];
      return;
    }

    final repo = ref.watch(recipesV1RepositoryProvider);
    yield* repo.searchByTitlePrefix(query, limit: 10);
  }
}

@riverpod
Future<int> recipesV1Count(RecipesV1CountRef ref) async {
  final repo = ref.watch(recipesV1RepositoryProvider);
  return repo.getTotalCount();
}
