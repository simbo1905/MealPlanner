import 'package:flutter_test/flutter_test.dart';
import '../repositories/fake_user_favourites_v1_repository.dart';

void main() {
  group('FakeUserFavouritesV1Repository', () {
    late FakeUserFavouritesV1Repository repository;
    const userId = 'test_user_123';

    setUp(() {
      repository = FakeUserFavouritesV1Repository();
    });

    tearDown(() {
      repository.clear();
    });

    test('watchFavouriteIds returns empty list for new user', () async {
      final favouriteIds = await repository.watchFavouriteIds(userId).first;
      
      expect(favouriteIds, isEmpty);
    });

    test('addFavourite adds recipe ID to user favourites', () async {
      await repository.addFavourite(userId, 'recipe_1', 'Test Recipe');
      final favouriteIds = await repository.watchFavouriteIds(userId).first;
      
      expect(favouriteIds.length, equals(1));
      expect(favouriteIds.first, equals('recipe_1'));
    });

    test('addFavourite adds multiple recipe IDs', () async {
      await repository.addFavourite(userId, 'recipe_1', 'Recipe 1');
      await repository.addFavourite(userId, 'recipe_2', 'Recipe 2');
      final favouriteIds = await repository.watchFavouriteIds(userId).first;
      
      expect(favouriteIds.length, equals(2));
      expect(favouriteIds, containsAll(['recipe_1', 'recipe_2']));
    });

    test('removeFavourite removes recipe ID from favourites', () async {
      await repository.addFavourite(userId, 'recipe_1', 'Test Recipe');
      await repository.removeFavourite(userId, 'recipe_1');
      final favouriteIds = await repository.watchFavouriteIds(userId).first;
      
      expect(favouriteIds, isEmpty);
    });

    test('removeFavourite from non-existent user does nothing', () async {
      await repository.removeFavourite('non_existent_user', 'recipe_1');
    });

    test('isFavourite returns true for added recipe', () async {
      await repository.addFavourite(userId, 'recipe_1', 'Test Recipe');
      final isFav = await repository.isFavourite(userId, 'recipe_1');
      
      expect(isFav, isTrue);
    });

    test('isFavourite returns false for non-added recipe', () async {
      final isFav = await repository.isFavourite(userId, 'recipe_1');
      
      expect(isFav, isFalse);
    });

    test('isFavourite returns false after removal', () async {
      await repository.addFavourite(userId, 'recipe_1', 'Test Recipe');
      await repository.removeFavourite(userId, 'recipe_1');
      final isFav = await repository.isFavourite(userId, 'recipe_1');
      
      expect(isFav, isFalse);
    });

    test('different users have separate favourites', () async {
      const user1 = 'user_1';
      const user2 = 'user_2';
      
      await repository.addFavourite(user1, 'recipe_1', 'Recipe 1');
      await repository.addFavourite(user2, 'recipe_2', 'Recipe 2');
      
      final user1Ids = await repository.watchFavouriteIds(user1).first;
      final user2Ids = await repository.watchFavouriteIds(user2).first;
      
      expect(user1Ids.length, equals(1));
      expect(user1Ids.first, equals('recipe_1'));
      expect(user2Ids.length, equals(1));
      expect(user2Ids.first, equals('recipe_2'));
    });
  });
}
