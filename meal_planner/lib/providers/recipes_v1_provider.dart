import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.freezed_model.dart';
import '../repositories/recipes_v1_repository.dart';
import '../repositories/fakes/fake_recipes_v1_repository.dart';

part 'recipes_v1_provider.g.dart';

@riverpod
RecipesV1Repository recipesV1Repository(Ref ref) {
  // Default to fake repository for deterministic tests and local runs.
  // Opt-in to Firebase by compiling with: --dart-define=USE_FIREBASE=true
  const useFirebase = bool.fromEnvironment('USE_FIREBASE');
  if (useFirebase) {
    return FirebaseRecipesV1Repository(FirebaseFirestore.instance);
  }
  return FakeRecipesV1Repository();
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
Future<int> recipesV1Count(Ref ref) async {
  final repo = ref.watch(recipesV1RepositoryProvider);
  return repo.getTotalCount();
}
