import 'package:flutter_test/flutter_test.dart';
import 'fake_recipes_v1_repository.dart';
import 'fake_user_favourites_v1_repository.dart';

void main() {
  group('Recipe Search Integration Tests', () {
    late FakeRecipesV1Repository recipesRepo;
    late FakeUserFavouritesV1Repository favoritesRepo;

    setUp(() {
      recipesRepo = FakeRecipesV1Repository();
      favoritesRepo = FakeUserFavouritesV1Repository();
    });

    test('Autocomplete search returns results quickly', () async {
      final startTime = DateTime.now();
      final results = await recipesRepo.searchByTitlePrefix('chick').first;
      final duration = DateTime.now().difference(startTime);

      expect(results, isNotEmpty);
      expect(duration.inMilliseconds, lessThan(500));
    });

    test('Title prefix search works with various inputs', () async {
      final tests = [
        ('chicken', ['Chicken Salad with Tomato', 'Chicken Parmesan']),
        ('tomato', ['Tomato Basil Soup']),
        ('grilled', ['Grilled Cheese Sandwich']),
        ('italian', ['Italian Sausage and Bread Stuffing']),
      ];

      for (var (query, expectedTitles) in tests) {
        final results = await recipesRepo.searchByTitlePrefix(query).first;
        final resultTitles = results.map((r) => r.title).toList();
        
        for (var expected in expectedTitles) {
          expect(
            resultTitles.any((title) => title.contains(expected)),
            isTrue,
            reason: 'Expected to find "$expected" in results for query "$query"',
          );
        }
      }
    });

    test('Ingredient search returns correct recipes', () async {
      final results = await recipesRepo.searchByIngredient('tomato').first;
      
      expect(results.isNotEmpty, isTrue);
      expect(
        results.every((r) => r.ingredientNamesNormalized?.contains('tomato') ?? false),
        isTrue,
      );
    });

    test('User favorites are isolated by userId', () async {
      const user1 = 'user_1';
      const user2 = 'user_2';

      await favoritesRepo.addFavourite(user1, 'recipe_1', 'Recipe 1');
      await favoritesRepo.addFavourite(user1, 'recipe_2', 'Recipe 2');
      await favoritesRepo.addFavourite(user2, 'recipe_3', 'Recipe 3');

      final user1Ids = await favoritesRepo.watchFavouriteIds(user1).first;
      final user2Ids = await favoritesRepo.watchFavouriteIds(user2).first;

      expect(user1Ids.length, equals(2));
      expect(user2Ids.length, equals(1));
      expect(user1Ids.every((id) => id == 'recipe_1' || id == 'recipe_2'), isTrue);
      expect(user2Ids.first, equals('recipe_3'));
    });

    test('Adding recipe to favorites updates real-time stream', () async {
      const userId = 'test_user';

      var ids = await favoritesRepo.watchFavouriteIds(userId).first;
      expect(ids, isEmpty);

      await favoritesRepo.addFavourite(userId, 'recipe_1', 'Test Recipe');

      var ids2 = await favoritesRepo.watchFavouriteIds(userId).first;
      expect(ids2.length, equals(1));
      expect(ids2.first, equals('recipe_1'));
    });

    test('Recipe count matches expected total', () async {
      final count = await recipesRepo.getTotalCount();
      
      expect(count, greaterThan(0));
    });

    test('Searching with limit parameter respects limit', () async {
      final resultsWithLimit = await recipesRepo.searchByTitlePrefix('recipe', limit: 3).first;
      
      expect(resultsWithLimit.length, lessThanOrEqualTo(3));
    });

    test('Case-insensitive search works correctly', () async {
      final resultsLower = await recipesRepo.searchByTitlePrefix('chicken').first;
      final resultsUpper = await recipesRepo.searchByTitlePrefix('CHICKEN').first;
      final resultsMixed = await recipesRepo.searchByTitlePrefix('ChIcKeN').first;

      expect(resultsLower.length, equals(resultsUpper.length));
      expect(resultsLower.length, equals(resultsMixed.length));
    });
  });
}
