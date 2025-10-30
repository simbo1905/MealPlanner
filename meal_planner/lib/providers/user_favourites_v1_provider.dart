import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/user_favourites_v1_repository.dart';

part 'user_favourites_v1_provider.g.dart';

@riverpod
UserFavouritesV1Repository userFavouritesV1Repository(UserFavouritesV1RepositoryRef ref) {
  final firestore = FirebaseFirestore.instance;
  return FirebaseUserFavouritesV1Repository(firestore);
}

@riverpod
Stream<List<String>> userFavouriteIds(UserFavouriteIdsRef ref, String userId) {
  final repo = ref.watch(userFavouritesV1RepositoryProvider);
  return repo.watchFavouriteIds(userId);
}

@riverpod
class AddUserFavouriteV1Notifier extends _$AddUserFavouriteV1Notifier {
  @override
  FutureOr<void> build() {}

  Future<void> addFavourite(String userId, String recipeId, String title) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(userFavouritesV1RepositoryProvider);
      await repo.addFavourite(userId, recipeId, title);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeFavourite(String userId, String recipeId) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(userFavouritesV1RepositoryProvider);
      await repo.removeFavourite(userId, recipeId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
